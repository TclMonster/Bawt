# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the mpexpr package.
# Do some calculations with extended precision.

package require Mpexpr

set mp_precision 50
puts "Using precision: $mp_precision"
puts ""

puts "Calculating 2.0/3.0:"
puts [mpexpr 2.0/3.0]
puts ""

puts "PI approximation:"
puts [mpexpr atan(1.0)*4]
puts ""

puts "Fibonnaci number of 129:"
puts [mpexpr {fib(129)}]
puts ""

puts "Factorial of 34:"
puts [mpexpr {fact(34)}]
puts ""

puts [format "Using Mpexpr %s on %s with Tcl %s-%dbit" \
     [package version Mpexpr] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
