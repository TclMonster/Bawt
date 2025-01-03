# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tclcompiler and tbcload packages.
# Compile a Tcl script into a TBC file and source that file.

package require compiler

set prefix "BWidget-DragAndDrop"
set tclFile "$prefix.tcl"
set tbcFile "TestOut/$prefix.tbc"
catch { file mkdir "TestOut" }

puts "Compiling file $tclFile"
compiler::compile $tclFile $tbcFile

puts "Sourcing file $tbcFile"
source $tbcFile

puts ""
puts [format "Using compiler %s on %s with %dbit Tcl %s" \
     [package version compiler] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

 if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
