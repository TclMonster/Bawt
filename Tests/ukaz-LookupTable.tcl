# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the ukaz package.
# Create lookup tables and plot the curve.

package require Tk
package require ukaz

proc CreateLut { prec min max gamma } {
    set numVals [expr { 1 << $prec }]
    set valList [list]
    for { set row 0 } { $row < $numVals } { incr row } {
        set scale [expr { $max - $min }]
        set val [expr { $min + $scale * pow( double($row) / double($numVals - 1), 1.0 / $gamma ) }]
        lappend valList $val
    }
    return $valList
}

proc Plot { plotWidget valList { color green } } {
    set ind 0
    foreach val $valList {
        lappend dataList $val $ind
        incr ind
    }
    $plotWidget plot $dataList with lines color $color
}

proc PointerInfo { x y } {
    global gOpt

    set gOpt(Info1) "[format %.5f $x] -> [format %.5f $y]"
}

proc Click { x y xtr ytr } {
    global gOpt

    # output the position of the click and transformed coords
    puts "Click at $x, $y (graph [format %.5g $xtr], [format %.5g $ytr])"
    # look for data point nearby
    lassign [.g pickpoint $x $y] id dpnr xd yd
    if {$id != {}} {
        set gOpt(Info2) "Data point $dpnr, set $id, ([format %.5g $xd], [format %.5g $yd])"
    } else {
        set gOpt(Info2) "No data point nearby"
    }
}

proc Redisplay {} {
    global gOpt

    Clear
    set valList [CreateLut $gOpt(prec) $gOpt(min) $gOpt(max) $gOpt(gamma)]
    Plot .g $valList
}

proc Clear {} {
    .g clear
    .g set auto x
    .g set auto y
}

set gOpt(min)    0.0
set gOpt(max)   20.0
set gOpt(gamma)  2.0
set gOpt(prec)   8

label .lmin   -text "Minimum:"
label .lmax   -text "Maximum:"
label .lgamma -text "Gamma:"
label .lprec  -text "Precision:"

entry .min   -textvariable gOpt(min)
entry .max   -textvariable gOpt(max)
entry .gamma -textvariable gOpt(gamma)
entry .prec  -textvariable gOpt(prec)

grid .lmin   -row 0 -column 0 -sticky w
grid .lmax   -row 1 -column 0 -sticky w
grid .lgamma -row 2 -column 0 -sticky w
grid .lprec  -row 3 -column 0 -sticky w

grid .min   -row 0 -column 1 -sticky w
grid .max   -row 1 -column 1 -sticky w
grid .gamma -row 2 -column 1 -sticky w
grid .prec  -row 3 -column 1 -sticky w

button .display -text "Redisplay" -command "Redisplay"
grid .display -row 4 -column 0 -sticky news -columnspan 2

set fontOptions "-family Courier -size 8 -weight normal"
ukaz::graph .g -font $fontOptions
bind .g <<MotionEvent>> { PointerInfo {*}%d }
bind .g <<Click>>       { Click %x %y {*}%d }

bind . <Escape> { exit }

grid .g -row 5 -column 0 -columnspan 2 -sticky news

label .info2 -textvariable gOpt(Info2)
label .info1 -textvariable gOpt(Info1)
grid .info2 -row 6 -column 0 -sticky w
grid .info1 -row 6 -column 1 -sticky e

label .msg -text \
    [format "Using ukaz %s on %s with Tcl %s-%dbit" \
    [package version ukaz] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
grid .msg -row 7 -column 0 -columnspan 2 -sticky news

grid columnconfigure . 1 -weight 1
grid rowconfigure . 5 -weight 1

Redisplay

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
