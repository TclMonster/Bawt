# Copyright 2017-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tclgd package.
# Create an animated GIF.

package require tclgd

set font [file join "Data" "Vera.ttf"]
set outFile [file join "TestOut" "tclgd-Anigif.gif"]
catch { file mkdir "TestOut" }
puts "Writing animated GIF to file $outFile"

GD create img 200 200
set white [img allocate_color 255 255 255]
set black [img allocate_color 0 0 0]

img text $black $font 20 0 10 30 Hey

set ofp [open $outFile "w"]
fconfigure $ofp -encoding binary -translation binary

img gif_anim_begin $ofp 1 0

img gif_anim_add $ofp 0 0 0 50 0

GD create img2 200 200
set white [img2 allocate_color 255 255 255]
img2 copy_palette img

img2 text $black $font 20 0 10 30 DOES

img2 gif_anim_add $ofp 0 0 0 100 0 img

img filled_rectangle 0 0 199 199 0
img text $black $font 20 0 10 30 THIS
img gif_anim_add $ofp 0 0 0 25 0 img2

img2 filled_rectangle 0 0 199 199 0
img2 text $black $font 20 0 10 30 WORK
img2 gif_anim_add $ofp 0 0 0 50 0 img

img filled_rectangle 0 0 199 199 0
img gif_anim_add $ofp 0 0 0 50 0 img2

img gif_anim_end $ofp

close $ofp

puts [format "Using tclgd %s on %s with Tcl %s-%dbit" \
     [package version tclgd] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
