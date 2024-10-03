# Copyright 2022-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the pawt package.
# Read and display a FITS 16-bit image file.

package require Tk
package require pawt

# Taken from https://fits.gsfc.nasa.gov/nrao_data/tests/ftt4b/
set fitsFile [file join "Data" "file003.fits"]

proc P { msg } {
    .info.t insert end $msg
    .info.t insert end "\n"
    puts $msg
}

frame .img
pack [label .img.l]
frame .info
pack [text .info.t -width 60 -height 2]

puts "Reading file $fitsFile ..."
set imgDict [pawt::fits::ReadImageFile $fitsFile]
set photo [pawt GetImageAsPhoto imgDict]
.img.l configure -image $photo

P "Width  : [pawt GetImageWidth  imgDict]"
P "Height : [pawt GetImageHeight imgDict]"

# Determine the minimum and maximum pixel values.

label .msg -text \
    [format "Using pawt %s on %s with Tcl %s-%dbit" \
    [package version pawt] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

grid .img  -row 0 -column 0
grid .info -row 1 -column 0
grid .msg  -row 2 -column 0

bind . <Escape> { exit }

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
