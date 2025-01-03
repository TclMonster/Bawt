# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tserialport package.

package require tserialport

set ports [tserialport::getports]
puts "PortCount: [llength [dict keys $ports]]"

dict for {key data} $ports {
  puts "--- $key ---"
  foreach {name value} $data {
    puts "$name = $value"
  }
}

puts ""
puts [format "Using tserialport %s on %s with %dbit Tcl %s" \
     [package version tserialport] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]
