# Copyright 2022-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the Snack package.
# Slightly modified version of Snack demo program generator.tcl.

if { $tcl_platform(os) eq "Darwin" } {
    puts "Windows/Linux only"
    exit 1
}

package require Tk
package require snack

proc Config {args} {
    global f v
    set shape 0.0
    set type $v(type)
    switch $type {
        sine {
            set shape 0.0
        }
        rectangle {
            set shape 0.5
        }
        triangle {
            set shape 0.5
        }
        sawtooth {
            set shape 0.0
            set type triangle
        }
    }
    $f configure $v(freq) $v(ampl) $shape $type -1
}

proc Play {} {
    global f
    s stop
    s play -filter $f
}

set f [snack::filter generator 440.0]
snack::sound s

set v(freq) 440.0
set v(ampl) 20000

pack [frame .f] -expand yes -fill both -side top
pack [scale .f.s1 -label Frequency -from 4000 -to 50 -length 200 -orient horizontal \
        -variable v(freq) -command Config] -side top -expand yes -fill both
pack [scale .f.s2 -label Amplitude -from 32767 -to 0 -length 200 -orient horizontal \
        -variable v(ampl) -command Config] -side top -expand yes -fill both

pack [frame .fb] -side top

pack [button .fb.a -bitmap snackPlay -command Play] -side left
pack [button .fb.b -bitmap snackStop -command "s stop"] -side left

tk_optionMenu .fb.m v(type) sine rectangle triangle sawtooth noise
foreach i [list 0 1 2 3 4] {
  .fb.m.menu entryconfigure $i -command Config
}
pack .fb.m -side left

pack [label .l] -side top

Config

bind . <Escape> { exit }
.l configure -text \
    [format "Using Snack %s on %s with Tcl %s-%dbit" \
    [package version snack] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

if { [lindex $argv 0] eq "auto" } {
    Play
    update
    after 1000
    exit
}
