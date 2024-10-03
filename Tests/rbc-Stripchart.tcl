# Copyright 2019-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the rbc package.
# Slightly modified version of demo program found at:
# https://wiki.tcl-lang.org/page/BLT+%2D+stripchart+%2D+with+realtime+update

if { $tcl_platform(os) eq "Darwin" } {
    puts "Windows/Linux only"
    exit 1
}

package require Tk
package require rbc

# vector and stripchart are rbc components.
# if you have a vector v, you can update it in realtime with
# v set $list

# init the vectors to a fixed size.
set Hz 200

rbc::vector create xvec($Hz) y1vec($Hz) y2vec($Hz)

# fill xvec with 0 .. $Hz-1
xvec seq 0 [expr {$Hz - 1}]

rbc::stripchart .s1 -height 2i -width 8i -bufferelements no
rbc::stripchart .s2 -height 2i -width 8i -bufferelements no

pack .s1 .s2

.s1 element create line1 -xdata xvec -ydata y1vec -symbol none
.s2 element create line2 -xdata xvec -ydata y2vec -symbol none -color red

# update $Hz values with random data once per second
proc proc1sec {} {

    # this can be done more concisely with vector random,
    # but if you need to fill a vector from scalar calculations,
    # do it this way:
    for {set i 0} {$i < $::Hz} {incr i} {
        lappend y1list [expr {rand()}]
        lappend y2list [expr {rand()}]
    }
    y1vec set $y1list
    y2vec set $y2list

    after 1000 proc1sec
}

label .l 
pack .l

bind . <Escape> { exit }
.l configure -text \
    [format "Using rbc %s on %s with Tcl %s-%dbit" \
    [package version rbc] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

proc1sec

if { [lindex $argv 0] eq "auto" } {
    update
    after 2000
    exit
}
