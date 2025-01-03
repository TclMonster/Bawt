# Copyright 2019-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the cffi package.

package require cffi
namespace path ::cffi

set zlibName "libz"
if { $tcl_platform(platform) eq "windows" } {
    set zlibName "zlib1"
}
cffi::Wrapper create libzip $zlibName[info sharedlibextension]

puts ""
puts [format "Using cffi %s on %s with %dbit Tcl %s" \
     [package version cffi] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

exit
