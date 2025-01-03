# Copyright 2020-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tdbc::sqlite3 package.
# Open the database created by script sqlite3-Create.tcl
# and issue a query.

package require tdbc::sqlite3

set fileName [file join "TestOut" "sqlite3-Create.db3"]

if { ! [file exists $fileName] } {
    puts "Error: No database available."
    puts "       Run script sqlite3-Create.tcl first."
    exit 1
}

tdbc::sqlite3::connection create myDb $fileName

set sqlStatement "SELECT COUNT(*) FROM Ranges"
set statement [myDb prepare $sqlStatement]
set resultSet [$statement execute]
set foundValue [$resultSet nextlist numRows]
if { $foundValue } {
    puts "Number of rows: $numRows"
    if { $numRows != 10 } {
        puts "Error: Number of rows should be 10."
        exit 1
    }
} else {
    puts "Error: Could not retrieve number of rows."
    exit 1
}

myDb close

puts ""
puts [format "Using tdbc::sqlite3 %s on %s with %dbit Tcl %s" \
     [package version tdbc::sqlite3] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

exit 0
