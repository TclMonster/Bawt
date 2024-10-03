# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tksvg package.
# Read SVG image and display on a label and a button.

package require Tk
package require tksvg

set img [image create photo -file [file join "Data" "orb.svg"]]

label .l -image $img
label .li -text "SVG image on label widget"
button .b -image $img
label .bi -text "SVG image on button widget"

label .msg -text \
    [format "Using tksvg %s on %s with Tcl %s-%dbit" \
    [package version tksvg] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

pack .l .li .b .bi .msg -expand 1 -fill x

bind . <Escape> { exit }

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
