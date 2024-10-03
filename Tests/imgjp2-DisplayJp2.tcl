# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the imgjp2 package.
# Read JPEG2000 image and display on a label and a button.

package require Tk
package require imgjp2

set img [image create photo -file [file join "Data" "balloon.jp2"] -format jp2]

label .l -image $img
label .li -text "JPEG2000 image on label widget"
button .b -image $img
label .bi -text "JPEG2000 image on button widget"

label .msg -text \
    [format "Using imgjp2 %s on %s with Tcl %s-%dbit" \
    [package version imgjp2] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

pack .l .li .b .bi .msg -expand 1 -fill x

bind . <Escape> { exit }

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
