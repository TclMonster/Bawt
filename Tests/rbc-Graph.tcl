# Copyright 2019-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the rbc package.
# Slightly modified version of demo program found at:
# https://wiki.tcl-lang.org/page/BLT+%2D+graph+%2D+how+to+draw+a+sophisticated+time+axis

if { $tcl_platform(os) eq "Darwin" } {
    puts "Windows/Linux only"
    exit 1
}

package require Tk
package require rbc

pack [rbc::graph .g -width 10i]

# Proc passed as a callback to BLT to draw custom tick labels.
proc format_timeAxis_tick {win seconds} {
    set hour [clock format $seconds -format "%H"]
    regsub {^0*} $hour {} label
    if { $label eq "" } {
        set label 0
    }
    if {$label} {
        return $label
    } else {
        return "$label\n[string repeat { } $::nSpaces]\
                [clock format $seconds -format "%d/%m"]"
    }
}

# Construct a list of major tick positions in seconds - the
# month, year and the range of days can be varied to suit
# the application.
for {set day 20} {$day <= 23} {incr day} {
    foreach hours {0 4 8 12 16 20} {
        lappend majorticks [clock scan "3/$day/2001 $hours:00"]
    }
}
lappend majorticks [clock scan "3/$day/2001 00:00"]

# Create the graph.
.g axis configure x                            \
        -min          [lindex $majorticks 0]   \
        -max          [lindex $majorticks end] \
        -title        "Day"                    \
        -majorticks   $majorticks

# Need to do an update to display the graph before the
# distance can be measured.
update idletasks

# Measure the width of a day on the graph - the example
# dates need not be in the displayed range.
set dayFieldWidth [expr {
        [.g axis transform x [clock scan 3/2/2001]] -
        [.g axis transform x [clock scan 3/1/2001]]}]

# Work out how many spaces this corresponds to in the
# font for the tick labels.
set nSpaces [expr {$dayFieldWidth /
                   [font measure [.g axis cget x -tickfont] " "]}]

# Configure the axis to use the custom label command.
.g axis configure x -command format_timeAxis_tick

label .l 
pack .l

bind . <Escape> { exit }
.l configure -text \
    [format "Using rbc %s on %s with Tcl %s-%dbit" \
    [package version rbc] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
