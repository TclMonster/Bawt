# Copyright 2019-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the MaterialIcons package.
# Slightly modified version of PuppyIcons demo program show.tcl.

package require Tk
package require PuppyIcons

wm title . "puppyicons-Show"

proc showname {flag} {
    if {$flag} {
	set ::name [lindex [.v gettags current] 1]
    } else {
	set ::name ""
    }
}

proc showicons {{isconf 0}} {
    if {![winfo exists .v]} {
	set ::pattern *
	frame .f
	label .f.s -text "Search: "
	entry .f.e -textvariable ::pattern -width 30
	pack .f.s .f.e -side left
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
	bind .f.e <Return> {showicons ; break}
	bind .f.e <KP_Enter> {showicons ; break}
	bind . <Configure> {
	    after cancel {showicons 1}
	    after idle {showicons 1}
	    break
	}
	.f.e icursor end
	.v bind _icons <Enter> {showname 1}
	.v bind _icons <Leave> {showname 0}
	bind .v <2> {%W scan mark %x %y}
	bind .v <B2-Motion> {%W scan dragto %x %y}
	if {[tk windowingsystem] eq "aqua"} {
	    bind .v <MouseWheel> {
		%W yview scroll [expr {-1 * (%D)}] units
	    }
	    bind .v <Shift-MouseWheel> {
		%W xview scroll [expr {-1 * (%D)}] units
	    }
	} else {
	    bind .v <MouseWheel> {
		if {%D >= 0} {
		    %W yview scroll [expr {-%D / 20}] units
		} else {
		    %W yview scroll [expr {(2-%D) / 20}] units
		}
	    }
	    bind .v <Shift-MouseWheel> {
		if {%D >= 0} {
		    %W xview scroll [expr {-%D / 20}] units
		} else {
		    %W xview scroll [expr {(2-%D) / 20}] units
		}
	    }
	}
	if {[tk windowingsystem] eq "x11"} {
	    bind .v <4> {%W yview scroll -5 units}
	    bind .v <5> {%W yview scroll  5 units}
	    bind .v <Shift-4> {%W xview scroll -5 units}
	    bind .v <Shift-5> {%W xview scroll  5 units}
	}
	bind all <Control-plus>  {zoom +1}
	bind all <Control-minus> {zoom -1}
    } else {
	if {$isconf &&
	    [winfo width .] == $::dim(w) &&
	    [winfo height .] == $::dim(h)} {
	    return
	}
	.v delete all
    }

    set ::name ""
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
    if {![info exists ::isize]} {
	set ::isize 28
    }
    set isize2 [expr {$::isize / 2}]
    set x $::isize
    set y 20
    foreach n [PuppyIcons names $::pattern] {
	set i [PuppyIcons image $n $::isize]
	set c [.v create image $x $y -anchor nw -image $i \
	    -tags [list _icons $n]]
	lassign [.v bbox $c] x1 y1 x2 y2
	if {$x1 > $xmax} {
	    set y [expr {$y2 + $isize2}]
	    set x $::isize
	    .v coords $c $x $y
	    lassign [.v bbox $c] x1 y1 x2 y2
	}
	set x [expr {$x2 + $isize2}]
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

proc zoom {dir} {
    set isize $::isize
    incr isize $dir
    if {$isize < 10 || $isize > 50} {
	return
    }
    set ::isize $isize
    after cancel showicons
    after idle showicons
}

showicons

bind . <Escape> { exit }
.msg configure -text \
    [format "Using PuppyIcons %s on %s with Tcl %s-%dbit" \
    [package version PuppyIcons] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
