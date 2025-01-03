# Copyright 2019-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the nsf-XOTcl package.

package require XOTcl

xotcl::Class create Greeter -parameter name

Greeter instproc say_hello {} {
    my instvar name
    puts "Welcome $name"
}

Greeter instproc say_bye {} {
    my instvar name
    puts "Goodbye $name"
}

Greeter create g -name Anna
g say_hello
g say_bye

puts ""
puts [format "Using nsf-XOTcl %s on %s with %dbit Tcl %s" \
     [package version XOTcl] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

exit
