# Copyright 2020-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tclfpdf package.
# Draw some rotated text strings. 
# Slightly modified example sccript from the tclfpdf distribution.

package require tclfpdf

set fileName [file join "TestOut" "tclfpdf-Rotation.pdf"]
catch { file mkdir "TestOut" }
file delete -force $fileName

puts "Generating file $fileName"

tclfpdf::Init
tclfpdf::AddPage
tclfpdf::SetFont Arial "" 40
tclfpdf::TextWithRotation 50 65 "Hello" 45 -45
tclfpdf::SetFontSize 30
tclfpdf::TextWithDirection 110 50 "world!" L
tclfpdf::TextWithDirection 110 50 "world!" U
tclfpdf::TextWithDirection 110 50 "world!" R
tclfpdf::TextWithDirection 110 50 "world!" D
tclfpdf::Output $fileName

puts ""
puts [format "Using tclfpdf %s on %s with Tcl %s-%dbit" \
     [package version tclfpdf] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
