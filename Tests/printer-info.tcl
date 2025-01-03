# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the printer and gdi packages.
# Simplified version of printer test script prnttest.tcl.

if { $tcl_platform(platform) ne "windows" } {
    puts "Windows only"
    exit 1
}

package require Tk
package require printer
package require gdi

puts ""
puts "Available printers:"
foreach name [lsort -index 0 [printer list]] {
    puts "    $name"
}

puts ""
printer open
set attr [printer attr -get device]
set defaultPrinter [lindex [lindex $attr 0 ] 1]
puts "Default printer: $defaultPrinter"

puts ""
puts "Attributes of default printer:"
set attrs [printer attr]
foreach pair $attrs {
    set tag [lindex $pair 0]
    set val [lindex $pair 1]
    puts [format "    %-20s: %s" $tag $val]
}

puts ""
puts [format "Using printer %s and gdi %s on %s with %dbit Tcl %s" \
     [package version printer] [package version gdi] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

exit 0
