# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the poImg package.
# Load a Targa image, rotate and scale it several times.

package require Img
package require poImg

set numImgs   40
set sleepTime 0

image create photo phImgOrig
image create photo phImgRot

ttk::label .orig -image phImgOrig
ttk::label .rot  -image phImgRot

ttk::label .msg -text \
    [format "Using poImg %s on %s with Tcl %s-%dbit" \
    [package version poImg] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

grid .orig -row 0 -column 0
grid .rot  -row 0 -column 1
grid .msg  -row 1 -column 0 -columnspan 2

bind . <Escape> { exit }
 
proc DegToRad { phi } {
    return [expr {$phi * 3.1415926535 / 180.0}]
}

set srcImg [poImage NewImageFromFile [file join "Data" "rabbit.tga"]]
$srcImg GetImgInfo w h a g
set dstImg [poImage NewImage $w $h $a $g]
$srcImg AsPhoto phImgOrig
.orig configure -image phImgOrig

puts -nonewline "Rotating images around center: "
set startTime [clock clicks -milliseconds]
set angle  0.0
for { set i 1 } { $i <= $numImgs } { incr i } {
    set angle [expr { $angle + 360.0 / $numImgs }]
    poImgRotate $srcImg $dstImg [DegToRad $angle]
    $dstImg AsPhoto phImgRot
    .rot configure -image phImgRot
    update
    after $sleepTime
    $dstImg Blank
}
set endTime [clock clicks -milliseconds]
puts [format "%.2f seconds" [expr ($endTime - $startTime) / 1000.0]]

puts -nonewline "Rotating images around moving center: "
set startTime [clock clicks -milliseconds]
set angle   0.0
set xCenter 0.5
set yCenter 0.5
for { set i 1 } { $i <= $numImgs } { incr i } {
    set angle [expr { $angle + 360.0 / $numImgs }]
    poImgRotate $srcImg $dstImg [DegToRad $angle] $xCenter $yCenter
    $dstImg AsPhoto phImgRot
    .rot configure -image phImgRot
    update
    after $sleepTime
    $dstImg Blank
    set xCenter [expr { $xCenter + 0.03 * $i / $numImgs }]
    set yCenter [expr { $yCenter + 0.03 * $i / $numImgs }]
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

    set poImgScale [poImage NewImage $nw $nh]
    $poImgScale ScaleRect $srcImg 0 0 $w $h 0 0 $nw $nh true
    $poImgScale AsPhoto phImgRot

    poImgUtil DeleteImg $poImgScale

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
