# Test program for the pdf4tcl package.
# Save images to PDF file. Demo taken from http://wiki.tcl-lang.org/42563

package require pdf4tcl

set inFile1  [file join "Data" "rabbit.jpg"]
set inFile2  [file join "Data" "rabbit.png"]
set inFile3  [file join "Data" "rabbit-CCITTFax.tif"]
set inFiles  [list $inFile1 $inFile2 $inFile3]
set ftypes   [list jpeg png tif]

set outFile [file join "TestOut" "pdf4tcl-Image.pdf"]

set outPrefix "pdf4tcl-Temp"

set dims {}
set orient {}
set maxheight -1
set maxwidth 800

pdf4tcl::new mypdf

foreach infile $inFiles ftype $ftypes {
    switch $ftype {
        jpeg - png - tif {
            # first run is just to get image dimensions
            set id [mypdf addImage $infile -type $ftype]
            set width [mypdf getImageWidth $id]
            set height [mypdf getImageHeight $id]
            puts "In : $infile Type: $ftype Height: $height Width: $width"
            while {($maxwidth > -1 && $width > $maxwidth) 
                || ($maxheight > -1 && $height > $maxheight)} {
                set height [expr {$height / 2}]
                set width [expr {$width / 2}]
            }
            lappend dims [list $width $height]
        }
        default {
            lappend dims {}
        }
    }
}
mypdf destroy

set tmpfiles {}
set idx -1
foreach infile $inFiles dim $dims ftype $ftypes {
    switch $ftype {
        jpeg - png - tif {
            pdf4tcl::new mypdf -paper $dim
            set id [mypdf addImage $infile -type $ftype]
            mypdf putImage $id 0 0 -width [lindex $dim 0] -height [lindex $dim 1]
            set fname $outPrefix-[incr idx].pdf
            mypdf write -file $fname 
            lappend tmpfiles $fname
            mypdf destroy
        }
        pdf {
            lappend tmpfiles $infile
        }
        default {
            return -code error [list {unknown file type} $ftype {for file}  $infile]
        }
    }
}

puts "Out: $outFile"
catch { file mkdir "TestOut" }
if {[file exists $outFile]} {
    file delete $outFile
}
pdf4tcl::catPdf {*}$tmpfiles $outFile
file delete {*}$tmpfiles

puts ""
puts [format "Using pdf4tcl %s on %s with Tcl %s-%dbit" \
     [package version pdf4tcl] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit

