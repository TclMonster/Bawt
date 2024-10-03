# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the imgtools package.
# Load a Targa image, rotate and scale it several times.

package require Img
package require imgtools

set numImgs   40
set sleepTime 0

image create photo phImgOrig -file [file join "Data" "rabbit.tga"]
image create photo phImgRot

set w [image width  phImgOrig]
set h [image height phImgOrig]

ttk::label .orig -image phImgOrig
ttk::label .rot  -image phImgRot

ttk::label .msg -text \
    [format "Using imgtools %s on %s with Tcl %s-%dbit" \
    [package version imgtools] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

grid .orig -row 0 -column 0
grid .rot  -row 0 -column 1
grid .msg  -row 1 -column 0 -columnspan 2

bind . <Escape> { exit }
 
puts -nonewline "Rotating image around center $numImgs times: "
set startTime [clock clicks -milliseconds]
set angle 0.0
for { set i 1 } { $i <= $numImgs } { incr i } {
    phImgRot blank
    set angle [expr { $angle - 360.0 / $numImgs }]
    imgtools::rotate phImgOrig $angle -clipping keepsize phImgRot
    .rot configure -image phImgRot
    update
    after $sleepTime
}
set endTime [clock clicks -milliseconds]
puts [format "%.2f seconds" [expr ($endTime - $startTime) / 1000.0]]

puts -nonewline "Scaling image $numImgs times: "
set startTime [clock clicks -milliseconds]
set maxScale 4.0

for { set i 1 } { $i <= $numImgs } { incr i } {
    phImgRot blank
    set scaleFactor [expr { 0.1 + $maxScale / ( 1 - $numImgs ) * ( 1.0 - $i ) }]
    set nw [expr { int ($w * $scaleFactor) }]
    set nh [expr { int ($h * $scaleFactor) }]
    imgtools::scale phImgOrig "${nw}x${nh}" phImgRot
    .rot configure -image phImgRot
    update
    after $sleepTime
}

set endTime [clock clicks -milliseconds]
puts [format "%.2f seconds" [expr ($endTime - $startTime) / 1000.0]]

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
