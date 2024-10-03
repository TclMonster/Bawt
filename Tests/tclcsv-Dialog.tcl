# Copyright 2020-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tclcsv package.
# Slightly modified version of tclcsv example program:
# https://tclcsv.magicsplat.com/#_example

package require Tk
package require tclcsv
package require widget::dialog

set testFile [file join "Data" "Test.csv"]

wm title . "tclcsv-Dialog"
ttk::label .msg
pack .msg

.msg configure -text \
    [format "Using tclcsv %s on %s with Tcl %s-%dbit" \
    [package version tclcsv] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

widget::dialog .dlg -type okcancel
tclcsv::dialectpicker .dlg.csv $testFile
.dlg setwidget .dlg.csv

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}

set response [.dlg display] 

if { $response eq "ok" } {
    set fd [open $testFile]
    set encoding [.dlg.csv encoding]
    chan configure $fd -encoding $encoding 
    set opts [.dlg.csv dialect]
    set rows [tclcsv::csv_read {*}$opts $fd]
    puts $rows
    close $fd
}
destroy .dlg
exit 0
