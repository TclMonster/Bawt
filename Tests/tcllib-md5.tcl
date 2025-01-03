# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the md5 package (as part of tcllib).
# Generate MD5 based hash string.

package require md5 2

set gString [string repeat "Hello, World!" 10000]

proc GenerateMD5 {} {
    set md5 [md5::md5 -hex $::gString]
    puts -nonewline " $md5   "
    if { $md5 ne "FFF0390AD7ED2225F0A5809D063210C1" } {
        puts "Error: Result should be FFF0390AD7ED2225F0A5809D063210C1."
        exit 1
    }
}

# Switch accelerator critcl off.
puts -nonewline "Using Tcl   :"
set ::md5::accel(critcl) 0
set result [time GenerateMD5 1]
puts $result

if {[::md5::LoadAccelerator critcl]} {
    puts -nonewline "Using Critcl:"
    set result [time GenerateMD5 1]
    puts $result
} else {
    puts "No Critcl version available"
}


puts ""
puts [format "Using md5 %s on %s with %dbit Tcl %s" \
     [package version md5] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]
