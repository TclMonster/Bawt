# Copyright 2022-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the fitsTcl package.
# Generate and write a 16-bit FITS image file.

package require Tk
package require img::raw
package require fitstcl

catch { file mkdir "TestOut" }

set fitsFile [file join "TestOut" "fitstcl-Write.fits"]

proc PO { msg } {
    .infoOut.t insert end $msg
    .infoOut.t insert end "\n"
    puts $msg
}

proc PI { msg } {
    .infoIn.t insert end $msg
    .infoIn.t insert end "\n"
    puts $msg
}

# Create a label and a text widget for the generated output image
# and the image read back (input).
frame .imgOut
pack [label .imgOut.l]
frame .infoOut
pack [text .infoOut.t -width 40 -height 8]

frame .imgIn
pack [label .imgIn.l]
frame .infoIn
pack [text .infoIn.t -width 40 -height 8]

# Generate test image as Tcl list and display it.
# The image contains unsigned short values from 0 to 65535.
set w 256
set h 256
for { set y 0 } { $y < $h } { incr y } {
    for { set x 0 } { $x < $w } { incr x } {
        lappend usImgAsList [expr { $y * $h + $x }] 
    }
}

# Create a photo image from the pixel list and display it.
set imgAsByteArray [binary format "su*" $usImgAsList]
set photoOut [image create photo -width $w -height $h]
$photoOut put $imgAsByteArray \
    -format "RAW \
    -useheader false \
    -uuencode false \
    -scanorder BottomUp \
    -pixeltype short \
    -width $w \
    -height $h \
    -nchan 1"
.imgOut.l configure -image $photoOut

# Create new FITS file (mode=2), insert an image and copy the 
# image data into the FITS image as Tcl list.
set fitsObjOut [fits open $fitsFile 2]

# Bitdepth          : 16
# Channels/Axes     : 2
# Channel/Axes sizes: $w and $h
$fitsObjOut insert image 16 2 [list $w $h]

# FITS uses signed short values, so map the unsigned short pixel values.
set sImgAsList [lmap a $usImgAsList { expr { $a - 32768 }}]
$fitsObjOut put image 1 $sImgAsList

# Insert a new keyword.
$fitsObjOut put keyword "OBJECT TestImage NoComment"
$fitsObjOut flush

# Show information about the new FITS image.
puts "dump -e:\n[$fitsObjOut dump -e]"

PO "Generated image"
PO "info chdu    : [$fitsObjOut info chdu]"
PO "info filesize: [expr [$fitsObjOut info filesize] * 2880]"
PO "info hdutype : [$fitsObjOut info hdutype]"
PO "info imgType : [$fitsObjOut info imgType]"
PO "info imgdim  : [$fitsObjOut info imgdim]"
PO "info nkwds   : [$fitsObjOut info nkwds]"

# Determine the minimum and maximum pixel values.
set sortedList [lsort -real $sImgAsList]
set minVal [lindex $sortedList 0]
set maxVal [lindex $sortedList end]
PO "Value range  : $minVal $maxVal\n"

# Close the new FITS file.
$fitsObjOut close


# Read the new generated FITS file and print some information.
set fitsObjIn [fits open $fitsFile]
puts "dump -e:\n[$fitsObjIn dump -e]"

PI "Read back image"
PI "info chdu    : [$fitsObjIn info chdu]"
PI "info filesize: [expr [$fitsObjIn info filesize] * 2880]"
PI "info hdutype : [$fitsObjIn info hdutype]"
PI "info imgType : [$fitsObjIn info imgType]"
PI "info imgdim  : [$fitsObjIn info imgdim]"
PI "info nkwds   : [$fitsObjIn info nkwds]"

# Get the image data as Tcl list.
set sImgAsList [$fitsObjIn get image]

# FITS uses signed short values, so map the values to unsigned short for usage as RAW image.
set usImgAsList [lmap a $sImgAsList { expr { $a + 32768 }}]

lassign [$fitsObjIn info imgdim] width height numChannels
if { $w != $width } {
    puts "Error: Width of generated and read file do not match."
}
if { $h != $height } {
    puts "Error: Height of generated and read file do not match."
}

# Create a photo image from the pixel list and display it.
set imgAsByteArray [binary format "su*" $usImgAsList]
set photoIn [image create photo -width $width -height $height]
$photoIn put $imgAsByteArray \
    -format "RAW \
    -useheader false \
    -uuencode false \
    -scanorder BottomUp \
    -pixeltype short \
    -width $width \
    -height $height \
    -nchan 1"

# Display the photo image.
.imgIn.l configure -image $photoIn

# Determine the minimum and maximum pixel values.
set sortedList [lsort -real $sImgAsList]
set minVal [lindex $sortedList 0]
set maxVal [lindex $sortedList end]
PI "Value range  : $minVal $maxVal\n"

label .msg -text \
    [format "Using fitstcl %s on %s with Tcl %s-%dbit" \
    [package version fitstcl] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

grid .imgOut  -row 0 -column 0
grid .infoOut -row 1 -column 0
grid .imgIn   -row 0 -column 1
grid .infoIn  -row 1 -column 1
grid .msg     -row 2 -column 0 -columnspan 2

bind . <Escape> { exit }

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
