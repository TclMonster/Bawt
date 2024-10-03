# Copyright 2017-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tclMuPDF package.
# Read PDF files generated with LaTex and Word and extract text.

package require tclMuPDF

set inFileWord  [file join "Data" "PdfFromWord.pdf"]
set inFileLatex [file join "Data" "PdfFromLatex.pdf"]

foreach f [list $inFileWord $inFileLatex] {
    puts "Extracting text from PDF file $f ..."
    set pdfObj [mupdf::open $f]
    puts "PDF version [$pdfObj version] ([$pdfObj npages] page)"
    set pageObj [$pdfObj getpage 0] ; # page 0 is the first page
    set str($f) [$pageObj text]
    puts "<[string trim $str($f) "\n"]>"
    puts ""
    $pdfObj quit
}

set infoDict [mupdf::libinfo]
puts [format "Using tclMuPDF %s (MuPDF %s) on %s with Tcl %s-%dbit" \
     [package version tclMuPDF] [dict get $infoDict version] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
