# Copyright 2017-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tclgd package.
# Read and write images with different formats.

package require Tk
package require Img
package require base64

package require tclgd

set inPrefix  [file join "Data" "rabbit"]
set outPrefix [file join "TestOut" "tclgd-ReadWrite"]
catch { file mkdir "TestOut" }

set fmtList { "gif"  "jpeg"  "png" "webp" }
set fmtExts { "gif"  "jpg"   "png" "webp" }
#             None   Quality Compr Quality
set fmtOpts { ""     90      9     90 }

frame .top
frame .bot
pack .top .bot -side top

foreach fmt $fmtList fmtExt $fmtExts fmtOpt $fmtOpts {
    set inFile  [format "%s.%s" $inPrefix  $fmtExt]
    puts "Read GD image $inFile"
    set inFp [open $inFile "r"]
    fconfigure $inFp -translation binary
    set catchVal [catch { GD create_from_$fmt img1$fmt $inFp } retVal]
    close $inFp
    if { $catchVal != 0 } {
        puts $retVal
        puts ""
        continue
    }

    set outFile [format "%s-1.%s" $outPrefix $fmtExt]
    puts "Write GD image $outFile with option \"$fmtOpt\""
    set outFp [open $outFile "w"]
    fconfigure $outFp -translation binary
    if { $fmtOpt eq "" } {
        img1$fmt write_$fmt $outFp
    } else {
        img1$fmt write_$fmt $outFp $fmtOpt
    }
    close $outFp

    puts "Copy GD image to Tk photo"
    set imgData [img1$fmt png_data 9]
    set phImg [image create photo -data $imgData -format png]
    label .top.$fmt -image $phImg
    pack  .top.$fmt -side left

    puts "Copy Tk photo to GD image"
    set phData [$phImg data -format png]
    if { [package vsatisfies [package require Img] "2.0-"] } {
	# Img 2.0 returns image data as binary string.
        GD create_from_png_data img2$fmt $phData
    } else {
	# Img 1.4 returns image data as base64 encoded string.
        GD create_from_png_data img2$fmt [base64::decode $phData]
    }
    set outFile [format "%s-2.%s" $outPrefix $fmtExt]
    set outFp [open $outFile "w"]
    fconfigure $outFp -translation binary
    if { $fmtOpt eq "" } {
        img2$fmt write_$fmt $outFp
    } else {
        img2$fmt write_$fmt $outFp $fmtOpt
    }
    close $outFp
    puts ""
}

label .bot.msg -text \
    [format "Using tclgd %s on %s with %dbit Tcl %s and Tk %s" \
    [package version tclgd] $::tcl_platform(os) \
    [expr $::tcl_platform(pointerSize) * 8] \
    [info patchlevel] [package version Tk]]
pack .bot.msg -side bottom

bind . <Escape> { exit }

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
