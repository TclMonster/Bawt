# Copyright 2019-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the winhelp package.

if { $tcl_platform(platform) ne "windows" } {
    puts "Windows only"
    exit 1
}

package require winhelp

proc ShowHelp {} {
    winhelp . [file normalize [file join "Data" "sample.chm"]]
}

label .l -text "Press F1 to show HTML help"
label .msg -text \
    [format "Using winhelp %s on %s with Tcl %s-%dbit" \
    [package version winhelp] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

pack .l .msg -expand 1 -fill x

bind . <F1>     { ShowHelp }
bind . <Escape> { exit }

update
ShowHelp

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
