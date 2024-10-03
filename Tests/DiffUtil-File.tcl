# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the DiffUtilTcl package.
# Compare two files.

package require DiffUtil

set f1 "Data/file1.txt"
set f2 "Data/file2.txt"

puts "Diffing files $f1 and $f2"

set result [DiffUtil::diffFiles -result diff $f1 $f2]
puts "Result with \"-result diff\":"
puts $result

set result [DiffUtil::diffFiles -result match $f1 $f2]
puts "Result with \"-result match\":"
puts $result

puts ""
puts [format "Using DiffUtil %s on %s with Tcl %s-%dbit" \
     [package version DiffUtil] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
