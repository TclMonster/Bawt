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
        # Handle table drop data.
        #
        # tbl  - tablelist.
        # data - Data being dropped.
        #
        # See also: OnTblDrop

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
