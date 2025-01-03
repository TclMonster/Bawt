# Copyright 2020-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the Memchan package.
# Redefine stdout and stderr.
# Slightly modified example from
# https://wiki.tcl-lang.org/page/redefining+stdout

package require Tk
package require Memchan

# Create text widget with tags.
text .t
.t tag configure stdout -font {Courier 10}
.t tag configure stderr -font {Courier 10} -foreground red
pack .t

# Install new stdout.
close stdout
set stdout [fifo]
fileevent $stdout readable ".t insert end \[read $stdout\] stdout; .t see end"

# Install new stderr.
close stderr
set stderr [fifo]
fileevent $stderr readable ".t insert end \[read $stderr\] stderr; .t see end"

# Test it.
puts stdout "This is stdout"
puts stderr "This is stderr"

puts ""
puts [format "Using Memchan %s on %s with %dbit Tcl %s" \
     [package version Memchan] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

bind . <Escape> { exit }
 
if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
