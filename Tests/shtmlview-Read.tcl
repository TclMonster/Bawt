# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the shtmlview package.
# Read a simple HTML file.

package require Tk
package require snit
package require shtmlview::shtmlview

set htmlFile [file join "Data" "bawt.html"]

shtmlview::shtmlview .html -toolbar true
.html browse $htmlFile

label .msg -text \
    [format "Using shtmlview %s on %s with Tcl %s-%dbit" \
    [package version shtmlview::shtmlview] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

grid .html -row 0 -column 0
grid .msg  -row 1 -column 0

bind . <Escape> { exit }

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
