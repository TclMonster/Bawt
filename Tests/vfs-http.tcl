# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tclvfs package.
# Get the content of an URL via vfs::http.

package require http
package require vfs::urltype

vfs::urltype::Mount http
set fd [open http://www.bawt.tcl3d.org/contact.html]
set contents [read $fd]
close $fd
puts $contents

puts ""
puts [format "Using vfs %s on %s with Tcl %s-%dbit" \
     [package version vfs] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
