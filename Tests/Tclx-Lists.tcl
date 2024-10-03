# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the TclX package.
# List handling functionality in pure Tcl and with the corresponding TclX procedures.

# lrmdups functionalilty in pure Tcl.
# Taken from https://wiki.tcl-lang.org/page/lrmdups.
interp alias {} mylrmdups {} lsort -unique

package require struct

set isectTcl [::struct::set intersect3 {a b c d e} {d e d f g c} ]
set lrmTcl [mylrmdups {foo bar grill bar foo} ]

package require Tclx

set isectTclX [intersect3 {a b c d e} {d e d f g c} ]
set lrmTclX   [lrmdups {foo bar grill bar foo} ]

# ==> {d e c} {a b} {f g} with Tcl
# ==> {a b} {c d e} {f g} with TclX
puts "intersect3 with Tcl : $isectTcl"
puts "intersect3 with TclX: $isectTclX"

# ==> bar foo grill
puts "lrmdups with Tcl : $lrmTcl"
puts "lrmdups with TclX: $lrmTclX"

puts ""
puts [format "Using TclX %s on %s with Tcl %s-%dbit" \
     [package version Tclx] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
