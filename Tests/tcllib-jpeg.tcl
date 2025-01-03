# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the jpeg package (as part of tcllib).
# Generate 2 unique identifiers.

package require jpeg

set inFile [file join "Data" "wall.jpg"]

proc GetExifInfo { fileName } {
    return [::jpeg::getExif $fileName]
}

proc FormatExifInfo { exifInfo } {
    return [::jpeg::formatExif $exifInfo]
}

puts "EXIF informations:"
foreach { key value } [FormatExifInfo [GetExifInfo $inFile]] {
    if { $key ne "MakerNote" } {
        puts [format "%-25s: %s" $key $value]
    }
}

puts ""
puts [format "Using jpeg %s on %s with %dbit Tcl %s" \
     [package version jpeg] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]
