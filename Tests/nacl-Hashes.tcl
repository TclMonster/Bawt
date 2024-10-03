# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the nacl package.
# Generate a hash and some random numbers.

package require nacl

puts "Available hashes: [nacl::hash info]"
nacl::hash -sha256 hash {Tcl does SHA256}
puts "SHA256 hash     : [binary encode hex $hash]"

set randomNumbers [nacl::randombytes 10]
binary scan $randomNumbers "c10" randomList
puts "Random numbers  : $randomList"

puts ""
puts [format "Using nacl %s on %s with Tcl %s-%dbit" \
     [package version nacl] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
