# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tzint package.
# Generate QR image and display it on a label.

package require Tk
package require tzint

puts "Symbologies available:"
foreach sym [lsort -dictionary [tzint::Encode symbologies]] {
    puts "  $sym"
}

set msg "tzint@BAWT"
tzint::Encode xbm xbmVal $msg -symbol qr -stat statsVal
puts "Stats: $statsVal"
set img [image create bitmap -data $xbmVal]

label .l -image $img
label .li -text "$msg encoded as QR"

label .msg -text \
    [format "Using tzint %s on %s with Tcl %s-%dbit" \
    [package version tzint] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

pack .l .li .msg -expand 1 -fill x

bind . <Escape> { exit }

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
