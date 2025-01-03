# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the Thread package.
# Simply send data back and forth between two threads.
#
# Slightly modified example from 
# https://wiki.tcl-lang.org/page/two+threads+run+synchronously

package require Thread

set id1 [::thread::create -joinable {
        source Thread-Proc
        run 1
    }]

set id2 [::thread::create -joinable {
        source Thread-Proc
        run 2
    }]

::thread::send -async $id1 [list set ::other $id2]
::thread::send -async $id2 [list set ::other $id1]

puts "Waiting for threads to finish ..."
::thread::join $id1
::thread::join $id2

puts ""
puts [format "Using Thread %s on %s with %dbit Tcl %s" \
     [package version Thread] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]
