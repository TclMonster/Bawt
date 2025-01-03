# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tls package.
# Slightly modified TclTLS example keytest2.tcl.

package require tls

set s [tls::socket 127.0.0.1 12300]
puts $s "A line"
flush $s
puts [join [tls::status $s] \n]

puts ""
puts [format "Using tls %s on %s with %dbit Tcl %s" \
     [package version tls] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]


exit
