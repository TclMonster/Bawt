# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the Tkhtml package.
# Read a simple HTML file.

package require Tk
package require Tkhtml

set htmlFile [file join "Data" "bawt.html"]

set fp [open $htmlFile "r"]
set data [read $fp]
close $fp

html .html
.html reset
.html parse -final $data

label .msg -text \
    [format "Using Tkhtml %s on %s with %dbit Tcl %s and Tk %s" \
    [package version Tkhtml] $::tcl_platform(os) \
    [expr $::tcl_platform(pointerSize) * 8] \
    [info patchlevel] [package version Tk]]

grid .html -row 0 -column 0
grid .msg  -row 1 -column 0

bind . <Escape> { exit }

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
