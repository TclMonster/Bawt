# Copyright 2019-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the nsf-nx package.

package require nx

nx::Class create Greeter {
    :property name:required

    :public method "say hello" {} {
        puts "Welcome ${:name}"
    }
    :public method "say bye" {} {
        puts "Goodbye ${:name}"
    }
}

Greeter create g -name Anna
g say hello
g say bye

puts ""
puts [format "Using nsf-nx %s on %s with %dbit Tcl %s" \
     [package version nx] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

exit
