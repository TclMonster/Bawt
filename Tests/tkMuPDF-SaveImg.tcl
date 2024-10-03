# Copyright 2017-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tclMuPDF package.
# Read PDF file and write first page as PNG.

package require Tk
package require tkMuPDF

set inFile  [file join "Data" "demo.pdf"]
set outFile [file join "TestOut" "tkMuPDF-SaveImg.ppm"]
catch { file mkdir "TestOut" }

puts "Reading PDF file $inFile ..."
set pdfObj [mupdf::open $inFile]
set pageObj [$pdfObj getpage 0] ; # page 0 is the first page

puts "Saving first page as $outFile ..."
image create photo myPhoto
$pageObj saveImage myPhoto -zoom 1
myPhoto write $outFile

puts "Page size (1/72 inch): [$pageObj size]"
puts "Image size (pixel)   : [image width myPhoto] [image height myPhoto]"

$pdfObj quit

puts ""
puts [format "Using tkMuPDF %s on %s with Tcl %s-%dbit" \
     [package version tkMuPDF] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
