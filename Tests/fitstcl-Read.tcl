# Copyright 2022-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the fitsTcl package.
# Read and display a FITS 16-bit image file.

package require Tk
package require img::raw
package require fitstcl

# Taken from https://fits.gsfc.nasa.gov/nrao_data/tests/ftt4b/
set fitsFile [file join "Data" "file003.fits"]

proc GetConversionParams { fitsObj } {
    set fmtString ""
    set pixelType ""

    # If the image has BZERO or BSCALE keywords in the header, fitsTcl will
    # do the appropriate thing with them automatically, but the datatype
    # returned will be floating point doubles (isn't FITS fun:)
    if { ( [catch { $fitsObj get keyword BZERO}]  == 0 ) ||
         ( [catch { $fitsObj get keyword BSCALE}] == 0 ) } {
        set fmtString "f*"
        set pixelType "float"
    } else {
        set imgType [$fitsObj info imgType]
        # Note, that 32 and 64 bit integer values are not handled by the RAW
        # image format, so the values are interpreted as shorts and may give
        # wrong results.
        # Similar for double values which exceed the range of float values.
        switch -exact -- $imgType {
              8 { set fmtString "c*" ; set pixeltype "byte" }
             16 { set fmtString "s*" ; set pixelType "short" }
             32 { set fmtString "s*" ; set pixelType "short" }
             64 { set fmtString "s*" ; set pixelType "short" }
            -32 { set fmtString "f*" ; set pixelType "float" }
            -64 { set fmtString "f*" ; set pixelType "float" }
        }
    }
    return [list $fmtString $pixelType]
}

proc P { msg } {
    .info.t insert end $msg
    .info.t insert end "\n"
    puts $msg
}

frame .img
pack [label .img.l]
frame .info
pack [text .info.t -width 60 -height 7]

# Open FITS file and print some information into a text widget.
# Dump header information onto stdout.
set fitsObj [fits open $fitsFile]
puts "dump -e:\n[$fitsObj dump -e]"

P "info chdu    : [$fitsObj info chdu]"
P "info filesize: [expr [$fitsObj info filesize] * 2880]"
P "info hdutype : [$fitsObj info hdutype]"
P "info imgType : [$fitsObj info imgType]"
P "info imgdim  : [$fitsObj info imgdim]"
P "info nkwds   : [$fitsObj info nkwds]"

# Extract image information and create photo image of appropriate size.
lassign [$fitsObj info imgdim] width height numChannels
set photo [image create photo -width $width -height $height]

# Get the format string for "binary format" command and the 
# pixel type for the RAW image format.
lassign [GetConversionParams $fitsObj] fmtString pixelType

# Retrieve the FITS image data as a Tcl list and convert into a byte array.
set imgAsList [$fitsObj get image]
set imgAsByteArray [binary format $fmtString $imgAsList]

# Fill the photo image using the byte array and the RAW image format.
$photo put $imgAsByteArray \
       -format "RAW \
       -useheader false \
       -uuencode false \
       -gamma 1.5 \
       -pixeltype $pixelType \
       -width $width \
       -height $height \
       -nchan $numChannels"

# Display the photo image.
.img.l configure -image $photo

# Determine the minimum and maximum pixel values.
set sortedList [lsort -real $imgAsList]
set minVal [lindex $sortedList 0]
set maxVal [lindex $sortedList end]
P "Value range  : $minVal $maxVal\n"

label .msg -text \
    [format "Using fitstcl %s on %s with Tcl %s-%dbit" \
    [package version fitstcl] $::tcl_platform(os) \
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
