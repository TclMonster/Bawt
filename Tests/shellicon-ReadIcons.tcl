# Copyright 2017-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the shellicon package.

if { $tcl_platform(platform) ne "windows" } {
    puts "Windows only"
    exit 1
}

package require Tk
package require shellicon

# Default values for command line options.
set gOpts(Auto) false

if { $argc == 0 } {
    set fileName "C:/Windows"
} else {
    if { [lindex $argv 0] eq "auto" } {
        set gOpts(Auto) true
        set fileName "C:/Windows"
    } else {
        set fileName [lindex $argv 0]
    }
}

proc GetIcon { fileName args } {
    global gImgNum

    set img [shellicon::get {*}$args $fileName]
    label .li_$gImgNum -image $img
    label .lt_$gImgNum -text  $args -justify left
    grid .li_$gImgNum -row $gImgNum -column 0
    grid .lt_$gImgNum -row $gImgNum -column 1 -sticky w
    incr gImgNum
}

set gImgNum 1

label .content -text "Icons of $fileName"
grid .content -row 0 -column 0 -columnspan 2

label .li_$gImgNum -text "Icon"
label .lt_$gImgNum -text "Options" 
grid .li_$gImgNum -row $gImgNum -column 0 
grid .lt_$gImgNum -row $gImgNum -column 1
incr gImgNum

GetIcon $fileName
GetIcon $fileName -large
GetIcon $fileName -selected
GetIcon $fileName -selected -large
GetIcon $fileName -open
GetIcon $fileName -open -large
GetIcon $fileName -open -selected
GetIcon $fileName -open -selected -large

wm title . "shellicon" 
bind . <Escape> { exit }

ttk::label .msg -text \
    [format "Using shellicon %s on %s with Tcl %s-%dbit" \
    [package version shellicon] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
grid .msg -row $gImgNum -column 0 -columnspan 2

if { $gOpts(Auto) } {
    update
    after 500
    exit
}
