# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the trofs package.
# Create an archive.

package require trofs

set fileName [file join "TestOut" "trofs-Archive.trofs"]
catch { file mkdir "TestOut" }
file delete -force $fileName

puts "Archiving directory Data to $fileName"
trofs::archive "Data" $fileName

puts ""
puts [format "Using trofs %s on %s with %dbit Tcl %s" \
     [package version trofs] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

exit 0
