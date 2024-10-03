# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the uuid package (as part of tcllib).
# Generate 2 unique identifiers.

package require uuid

proc GenerateUuid {} {
    set id1 [uuid::uuid generate]
    set id2 [uuid::uuid generate]
    puts "uuid 1: $id1"
    puts "uuid 2: $id2"
}

GenerateUuid
puts ""
puts [format "Using uuid %s on %s with Tcl %s-%dbit" \
     [package version uuid] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
