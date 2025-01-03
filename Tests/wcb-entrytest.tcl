# Copyright 2020-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the wcb package.
# Slightly modified version of wcb demo program entrytest.tcl.

package require Tk
package require wcb

wm title . "wcb-entrytest"

option add *Entry.font          TkFixedFont
option add *Entry.background    white

frame .f1 -height 10
label .l1 -text "An entry for alphanumeric characters,\nwith automatic\
                 uppercase conversion:"
entry .e1 -width 10
focus .e1

wcb::callback .e1 before insert wcb::checkStrForAlnum wcb::convStrToUpper

frame .f2 -height 10
label .l2 -text "An entry of max. length 10, for an integer:"
entry .e2 -width 10

wcb::callback .e2 before insert {wcb::checkEntryLen 10} wcb::checkEntryForInt

frame .f3 -height 10
label .l3 -text "An entry of max. length 10, for an unsigned real\nnumber\
                 with at most 2 digits after the decimal point:"
entry .e3 -width 10

wcb::callback .e3 before insert {wcb::checkEntryLen 10} checkNumber

proc checkNumber {w idx str} {
    set newText [wcb::postInsertEntryText $w $idx $str]
    if {![regexp {^[0-9]*\.?[0-9]?[0-9]?$} $newText]} {
        wcb::cancel
    }
}

frame .sep -height 2 -bd 1 -relief sunken
label .msg
frame .bottom -height 10

pack .bottom .msg -side bottom
pack .sep -side bottom -pady 7p -fill x
pack .f1 .l1 .e1 -padx 7p
pack .f2 .l2 .e2 -padx 7p
pack .f3 .l3 .e3 -padx 7p

.msg configure -text \
    [format "Using wcb %s on %s with %dbit Tcl %s and Tk %s" \
    [package version wcb] $::tcl_platform(os) \
    [expr $::tcl_platform(pointerSize) * 8] \
    [info patchlevel] [package version Tk]]

bind . <Escape> { exit }

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
