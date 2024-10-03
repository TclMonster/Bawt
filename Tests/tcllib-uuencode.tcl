# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the uuencode package (as part of tcllib).
# Encode a file several times.

package require uuencode

catch { file mkdir "TestOut" }

set inFile  [file join "Data" "orb.svg"]
set outFile [file join "TestOut" "tcllib-uuencode_orb.svg.uu"]

proc Encode { inFile outFile } {
    set fp [open $inFile "r"]
    fconfigure $fp -translation binary
    set data [read $fp]
    close $fp

    set uudata [uuencode::encode $data]

    set fp [open $outFile "w"]
    puts $fp $uudata
    close $fp
}

proc DoEncode {} {
    global inFile outFile

    Encode $inFile $outFile
}

puts [time DoEncode 5]
puts "Written file $outFile"

puts ""
puts [format "Using uuencode %s on %s with Tcl %s-%dbit" \
     [package version uuencode] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
