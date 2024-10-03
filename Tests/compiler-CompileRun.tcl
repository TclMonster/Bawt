# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
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
puts [format "Using compiler %s on %s with Tcl %s-%dbit" \
     [package version compiler] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

 if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
