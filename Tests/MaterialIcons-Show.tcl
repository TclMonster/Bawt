# Copyright 2019-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the MaterialIcons package.
# Slightly modified version of MaterialIcons demo program show.tcl.

package require Tk
package require MaterialIcons

wm title . "MaterialIcons-Show"

proc showname {flag} {
    if {$flag} {
        set ::name [lindex [.v gettags current] 1]
    } else {
        set ::name ""
    }
}

proc showicons {{isconf 0}} {
    set ::pattern *
    frame .f
    grid .f -row 0 -column 0 -padx 4 -pady 4 -columnspan 2 -sticky w
    canvas .v -yscrollcommand {.y set} -xscrollcommand {.x set} -bg white
    grid .v -row 1 -column 0 -sticky news
    ttk::scrollbar .y -orient vertical -command {.v yview}
    grid .y -row 1 -column 1 -sticky ns
    ttk::scrollbar .x -orient horizontal -command {.v xview}
    grid .x -row 2 -column 0 -sticky ew
    label .l -textvariable name
    grid .l -row 3 -column 0 -sticky ew
    label .msg
    grid .msg -row 4 -column 0 -sticky ew
    grid rowconfigure . 1 -weight 1
    grid columnconfigure . 0 -weight 1
    .v bind _icons <Enter> {showname 1}
    .v bind _icons <Leave> {showname 0}

    set ::name ""
    set x 20
    set y 20
    set xmax [winfo width .]
    if {$xmax == 1} {
        set ::dim(w) [winfo reqwidth .]
        set ::dim(h) [winfo reqheight .]
        set xmax [expr {[winfo reqwidth .v] + [winfo reqwidth .y]}]
    } else {
        set ::dim(w) [winfo width .]
        set ::dim(h) [winfo height .]
    }
    set xmax [expr {$xmax - 64}]
    if {$xmax < 200} {
        set xmax 200
    }

    foreach n [MaterialIcons names $::pattern] {
        set i [MaterialIcons image $n 20]
        set c [.v create image $x $y -anchor nw -image $i \
            -tags [list _icons $n]]
        lassign [.v bbox $c] x1 y1 x2 y2
        if {$x1 > $xmax} {
            set y [expr {$y2 + 10}]
            set x 20
            .v coords $c $x $y
            lassign [.v bbox $c] x1 y1 x2 y2
        }
        set x [expr {$x2 + 10}]
    }

    set bbox [.v bbox _icons]
    if {[llength $bbox]} {
        lassign [.v bbox _icons] x1 y1 x2 y2
        .v configure -scrollregion [list [expr {$x1 - 20}] [expr {$y1 - 20}] \
            [expr {$x2 + 20}] [expr {$y2 + 20}]]
    } else {
        .v configure -scrollregion {}
    }
}

showicons

bind . <Escape> { exit }
.msg configure -text \
    [format "Using MaterialIcons %s on %s with Tcl %s-%dbit" \
    [package version MaterialIcons] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
