# Copyright 2017-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tclMuPDF package.
# Read PDF file and write first page as PNG.

package require tclMuPDF

set inFile  [file join "Data" "demo.pdf"]
set outFile [file join "TestOut" "tclMuPDF-SavePng.png"]
catch { file mkdir "TestOut" }

puts "Reading PDF file $inFile ..."
set pdfObj [mupdf::open $inFile]
set pageObj [$pdfObj getpage 0] ; # page 0 is the first page

puts "Saving first page as $outFile ..."
$pageObj savePNG $outFile -zoom 0.5

puts "PDF version     : [$pdfObj version]"
puts "Number of pages : [$pdfObj npages]"
puts "Number of annots: [llength [$pageObj annots]]"

$pdfObj quit

puts ""
set infoDict [mupdf::libinfo]
puts [format "Using tclMuPDF %s (MuPDF %s) on %s with Tcl %s-%dbit" \
     [package version tclMuPDF] [dict get $infoDict version] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
