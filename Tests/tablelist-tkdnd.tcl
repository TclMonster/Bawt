# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tablelist and tkdnd packages.
# Generate 2 tablelists acting as drag and drop sources.

package require Tk
package require tablelist
package require tkdnd

# Number of test rows and columns being generated.
set numRows 10
set numCols  5
set width   50

# A namespace implementing the functionality of drag-and-drop
# with tablelists.
namespace eval poDragAndDrop {
    variable ns [namespace current]

    namespace ensemble create

    namespace export UseAsDropTarget
    namespace export UseAsDragTarget

    proc OnTblDragInit { w columnStartIndex columnEndIndex } {
        variable sDND

        # puts "OnTblDragInit $columnStartIndex $columnEndIndex"
        set tbl [tablelist::getTablelistPath $w]
        set selIndList [$tbl curselection]
        set items [list]
        foreach ind $selIndList {
            set rowCont [lrange [$tbl get $ind] $columnStartIndex $columnEndIndex]
            lappend items $rowCont
        }
        set sDND(DragSource,Table) $tbl
        set sDND(DragSource,selIndList) $selIndList

        return [list { copy move } DND_Text $items]
    }

    proc OnTblDragEnd { w action } {
        variable sDND

        unset sDND
    }

    proc OnTblDropEnterOrPos { tbl rootX rootY actions buttons } {
        variable sPo
        variable sDND

        set y [expr {$rootY - [winfo rooty $tbl]}]
        foreach { sDND(place) sDND(row) } [$tbl targetmarkpos $y -horizontal] {}
        # puts "OnTblDropEnterOrPos $tbl $sDND(DragSource,Table) $sDND(place) $sDND(row)"

        if { $tbl eq $sDND(DragSource,Table) } {
            if { ! $sPo($tbl,AllowMove) } {
                $tbl hidetargetmark
                return refuse_drop
            }
            set minInd [lindex $sDND(DragSource,selIndList) 0]
            set maxInd [lindex $sDND(DragSource,selIndList) end]
            if { $sDND(row) >= $minInd && $sDND(row) <= $maxInd } {
                $tbl hidetargetmark
                return refuse_drop
            }
            $tbl showtargetmark $sDND(place) $sDND(row)
            return move
        }

        $tbl showtargetmark $sDND(place) $sDND(row)
        return copy
    }

    proc OnTblDrop { tbl action data } {
        variable ns

        ${ns}::HandleTblDrop $tbl $data
        return $action
    }

    proc _InsertDropData { tbl row data } {
        set dataIndex [expr { [llength $data] -1 }]
        for { set ind $dataIndex } { $ind >= 0 } { incr ind -1 } {
            $tbl insert $row [lindex $data $ind]
        }
    }

    proc HandleTblDrop { tbl data } {
        variable sDND

        # puts "HandleTblDrop $tbl $sDND(place) $sDND(row) $data"
        $tbl hidetargetmark

        if { $tbl eq $sDND(DragSource,Table) } {
            # Drag and drop table are the same: Move data.
            set minInd [lindex $sDND(DragSource,selIndList) 0]
            set maxInd [lindex $sDND(DragSource,selIndList) end]
            if { $sDND(row) < $minInd } {
                $tbl delete $sDND(DragSource,selIndList)
                _InsertDropData $tbl $sDND(row) $data
            } elseif { $sDND(row) > $maxInd } {
                _InsertDropData $tbl $sDND(row) $data
                $tbl delete $sDND(DragSource,selIndList)
            }
        } else {
            # Drag and drop table are not the same: Copy data.
            set numDataColumns [llength [lindex $data 0]]
            set numTblColumns  [$tbl columncount]
            if { $numTblColumns < $numDataColumns } {
                for { set i 0 } { $i < [expr { $numDataColumns - $numTblColumns }] } { incr i } {
                    $tbl insertcolumns end 0 " "
                }
            }

            if {$sDND(row) < [$tbl size]} {
                _InsertDropData $tbl $sDND(row) $data
            } else {
                foreach rowData $data {
                    $tbl insert end $rowData
                }
            }
        }
    }

    proc UseAsDropTarget { tbl { allowMove true } } {
        variable ns
        variable sPo

        tkdnd::drop_target register $tbl DND_Text
        bind $tbl <<DropEnter>>    "${ns}::OnTblDropEnterOrPos %W %X %Y %a %b"
        bind $tbl <<DropPosition>> "${ns}::OnTblDropEnterOrPos %W %X %Y %a %b"
        bind $tbl <<DropLeave>>    "%W hidetargetmark"
        bind $tbl <<Drop>>         "${ns}::OnTblDrop %W %A %D"
        set sPo($tbl,AllowMove) $allowMove
    }

    proc UseAsDragTarget { tbl { columnStartIndex 0 } { columnEndIndex end } } {
        variable ns

        set tblBody [$tbl bodypath]
        tkdnd::drag_source register $tblBody DND_Text
        bind $tblBody <<DragInitCmd>> "${ns}::OnTblDragInit %W $columnStartIndex $columnEndIndex"
        bind $tblBody <<DragEndCmd>>  "${ns}::OnTblDragEnd %W %A"
    }
}

proc Reset { dragTable dropTable numRows numCols } {
    $dragTable delete 0 end
    $dropTable delete 0 end
    catch { $dragTable deletecolumns 0 end }
    catch { $dropTable deletecolumns 0 end }

    # Generate column titles.
    for { set c 0 } { $c < $numCols } { incr c } {
        $dragTable insertcolumns end 0 "Col-$c" left
        $dropTable insertcolumns end 0 "Col-$c" left
    }

    # Generate some content for the drag table.
    for { set row 0 } { $row < $numRows } { incr row } {
        set dragList [list]
        for { set col 0 } { $col < $numCols } { incr col } {
            lappend dragList [format "Drag_%d_%d" $row $col]
        }
        $dragTable insert end $dragList
    }
}

# Create 2 tablelists for testing the drag-and-drop functionality.
# Both tables are used as drag and drop sources.
set dropFr .dropFr
set dragFr .dragFr

ttk::labelframe $dragFr -padding 5 -text "Move allowed. Copy all columns."
ttk::labelframe $dropFr -padding 5 -text "No move. Copy columns 0-2."
ttk::button     .reset -text "Reset tables"
ttk::label      .msg
grid $dragFr   -row 0 -column 0 -sticky w
grid $dropFr   -row 0 -column 1 -sticky w
grid .reset    -row 1 -column 0 -sticky news -columnspan 2
grid .msg      -row 2 -column 0 -sticky news -columnspan 2

set dragTable $dragFr.tl
tablelist::tablelist $dragTable -width $width -height [expr $numRows + 5] -selectmode extended
pack $dragTable -side top -fill both -expand true

poDragAndDrop UseAsDropTarget $dragTable
poDragAndDrop UseAsDragTarget $dragTable

set dropTable $dropFr.tl
tablelist::tablelist $dropTable -width $width -height [expr $numRows + 5] -selectmode extended
pack $dropTable -side top -fill both -expand true

poDragAndDrop UseAsDropTarget $dropTable false
poDragAndDrop UseAsDragTarget $dropTable 0 2

.reset configure -command "Reset $dragTable $dropTable $numRows $numCols"

Reset $dragTable $dropTable $numRows $numCols

bind . <Escape> { exit }
.msg configure -text \
    [format "Using tablelist %s and tkdnd %s on %s with Tcl %s-%dbit" \
    [package version tablelist] [package version tkdnd] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
