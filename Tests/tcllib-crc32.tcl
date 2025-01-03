# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the crc32 package (as part of tcllib).
# Generate CRC32 encoding.

package require crc32

proc GenerateCrc32 {} {
    set crc [crc::crc32 -format "0x%X" "Hello, World!"]
    puts "crc: $crc"
    if { $crc ne "0xEC4AC3D0" } {
        puts "Error: Result should be 0xEC4AC3D0."
        exit 1
    }
}

GenerateCrc32

puts ""
puts [format "Using crc32 %s on %s with %dbit Tcl %s" \
     [package version crc32] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]
