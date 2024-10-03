# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the crc32 package (as part of tcllib).
# Generate CRC32 encoding.

package require crc32

proc GenerateCrc32 {} {
    set crc [crc::crc32 -format "0x%X" "Hello, World!"]
    puts "crc: $crc"
}

GenerateCrc32

puts ""
puts [format "Using crc32 %s on %s with Tcl %s-%dbit" \
     [package version crc32] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
