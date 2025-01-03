# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the DiffUtilTcl package.
# Compare two files.

package require DiffUtil

set f1 "Data/file1.txt"
set f2 "Data/file2.txt"

puts "Diffing files $f1 and $f2"

set result [DiffUtil::diffFiles -result diff $f1 $f2]
puts "Result with \"-result diff\": $result"
if { $result != "{3 1 3 0}" } {
    puts "Error: Result should be {3 1 3 0}."
    exit 1
}

set result [DiffUtil::diffFiles -result match $f1 $f2]
puts "Result with \"-result match\": $result"
if { $result != "{1 2 4} {1 2 3}" } {
    puts "Error: Result should be {1 2 4} {1 2 3}."
    exit 1
}

puts ""
puts [format "Using DiffUtil %s on %s with %dbit Tcl %s" \
     [package version DiffUtil] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

exit 0
