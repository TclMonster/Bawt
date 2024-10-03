# # Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the iocp package.
# Detect Bluetooth radios and devices.
#
# Code inspired by Ashok's article at
# https://www.magicsplat.com/blog/exploring-bluetooth/

if { $tcl_platform(platform) ne "windows" } {
    puts "Windows only"
    exit 1
}

package require iocp_bt

set addressList [iocp::bt::radios]
if { [llength $addressList] > 0 } {
    set radioAddr [lindex $addressList 0]
    set radioInfo [iocp::bt::radio info $radioAddr]
    set radioName [dict get $radioInfo Name]
    puts "Radio $radioName"
    puts "  Address      : $radioAddr"
    puts "  DeviceClasses: [dict get $radioInfo DeviceClasses]"
    puts "  Configuration: [iocp::bt::radio configure $radioAddr]"
    set addr [iocp::bt::device address $radioName]
    if { $radioAddr != $addr } {
        puts "Error: $radioAddr not equal to $addr"
    }
    puts ""
    # Enable for rescanning of devices. Can take up to 10 seconds.
    # set devs [iocp::bt::devices -inquire]
    set devs [iocp::bt::devices]
    foreach dev $devs {
        puts "Device [dict get $dev Name]"
        puts "  Address      : [dict get $dev Address]"
        puts "  DeviceClasses: [dict get $dev DeviceClasses]"
    }
} else {
    puts "No Bluetooth radios found"
}

puts ""
puts [format "Using iocp %s on %s with Tcl %s-%dbit" \
     [package version iocp] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
