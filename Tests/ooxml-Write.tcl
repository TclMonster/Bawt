# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the ooxml package.
# Write a simple Excel file.

package require ooxml

catch { file mkdir "TestOut" }

set outFile [file join "TestOut" "ooxml-Write.xlsx"]

set spreadsheet [::ooxml::xl_write new -creator "ooxml from BAWT test"]
if {[set sheet [$spreadsheet worksheet {Tabelle 1}]] > -1} {
    set date [$spreadsheet style -numfmt [$spreadsheet numberformat -datetime]]
    $spreadsheet defaultdatestyle $date
    $spreadsheet cell $sheet "2018-03-02 17:39" -index 0,0
}
$spreadsheet write $outFile
$spreadsheet destroy

puts "Written file $outFile"

puts ""
puts [format "Using ooxml %s on %s with Tcl %s-%dbit" \
     [package version ooxml] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
