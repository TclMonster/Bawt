# Copyright 2019-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the Trf package.
# Generate a CRC checksum.

package require Trf

set txt "Hello, World!"

if { $tcl_platform(wordSize) == 4 } {
    set refStr "0xec4ac3d0"
} else {
    set refStr "0xffffffffec4ac3d0"
}
set chk [crc-zlib $txt]
binary scan $chk i chksum
puts "Checksum of \"$txt\": [format 0x%x $chksum]"
if { [format 0x%x $chksum] ne $refStr } {
    puts "Error: Invalid checksum [format 0x%x $chksum]. Should be $refStr."
    exit 1
}

puts ""
puts [format "Using Trf %s on %s with %dbit Tcl %s" \
     [package version Trf] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

exit 0
