# Copyright 2019-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the scrollutil package.
# Slightly modified version of scrollutil demo program ScrolledTablelist2.tcl.

package require tablelist_tile
package require scrollutil_tile

set f [ttk::frame .f]

#
# Create the tablelist within a scrollarea
#
set sa [scrollutil::scrollarea $f.sa]
set tbl $sa.tbl
tablelist::tablelist $tbl -columntitles \
	{"Column 0" "Column 1" "Column 2" "Column 3"
	 "Column 4" "Column 5" "Column 6" "Column 7"} \
    -titlecolumns 1
switch [tk windowingsystem] {
    x11   { set width 53 }
    win32 { set width 58 }
    aqua  { set width 52 }
}
$tbl configure -width $width
$sa setwidget $tbl

#
# Populate the tablelist widget
#
set itemList {}
for {set row 0} {$row < 2} {incr row} {
    set item {}
    for {set col 0} {$col < 8} {incr col} {
	lappend item "header cell $row,$col"
    }
    lappend itemList $item
}
$tbl header insertlist end $itemList
set itemList {}
for {set row 0} {$row < 40} {incr row} {
    set item {}
    for {set col 0} {$col < 8} {incr col} {
	lappend item "body cell $row,$col"
    }
    lappend itemList $item
}
$tbl insertlist end $itemList

ttk::label $f.msg
pack $f.msg -side bottom -pady {0 10}

#
# Manage the scrollarea
#
pack $sa -expand yes -fill both -padx 10 -pady 10

pack $f -expand yes -fill both

bind . <Escape> { exit }
$f.msg configure -text \
    [format "Using scrollutil %s on %s with Tcl %s-%dbit" \
    [package version scrollutil] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
