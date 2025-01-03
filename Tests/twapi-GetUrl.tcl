# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the twapi and http package.
# Open a https based URL and print some information.

if { $tcl_platform(platform) ne "windows" } {
    puts "Windows only"
    exit 1
}

package require http
package require twapi

http::register https 443 [list ::twapi::tls_socket]
set token [http::geturl "https://www.tcl3d.org/bawt/"]

upvar #0 $token state
puts "state(url)  = $state(url)"
puts "state(http) = $state(http)"
puts "state(type) = $state(type)"

if { $state(type) ne "text/html" } {
    puts "Error: type should be text/html."
    exit 1
}

http::cleanup $token

puts ""
puts [format "Using twapi %s and http %s on %s with %dbit Tcl %s" \
     [package version twapi] [package version http] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8] [info patchlevel]]

exit 0
