# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tkpath package.
# Slightly modified tktable example basic.tcl.

package require Tk
package require Tktable

array set table {
    rows	8
    cols	8
    table	.t
    array	t
}

proc fill { array x y } {
    upvar $array f
    for {set i -$x} {$i<$x} {incr i} {
	for {set j -$y} {$j<$y} {incr j} { set f($i,$j) "r$i,c$j" }
    }
}

## Test out the use of a procedure to define tags on rows and columns
proc rowProc row { if {$row>0 && $row%2} { return OddRow } }
proc colProc col { if {$col>0 && $col%2} { return OddCol } }

label .label -text "TkTable Basic Example"

fill $table(array) $table(rows) $table(cols)
table $table(table) -rows $table(rows) -cols $table(cols) \
	-variable $table(array) \
	-width 6 -height 6 \
	-titlerows 1 -titlecols 2 \
	-roworigin -1 -colorigin -2 \
	-yscrollcommand {.sy set} -xscrollcommand {.sx set} \
	-rowtagcommand rowProc -coltagcommand colProc \
	-colstretchmode last -rowstretchmode last \
	-selectmode extended -sparsearray 0

scrollbar .sy -command [list $table(table) yview]
scrollbar .sx -command [list $table(table) xview] -orient horizontal

ttk::label .msg -text \
    [format "Using Tktable %s on %s with Tcl %s-%dbit" \
    [package version Tktable] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

grid .label - -sticky ew
grid $table(table) .sy -sticky news
grid .sx  -sticky ew
grid .msg -sticky ew -columnspan 2
grid columnconfig . 0 -weight 1
grid rowconfig    . 1 -weight 1

bind . <Escape> { exit }

$table(table) tag config OddRow -bg orange -fg purple
$table(table) tag config OddCol -bg brown -fg pink

$table(table) width -2 7 -1 7 1 5 2 8 4 14

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
