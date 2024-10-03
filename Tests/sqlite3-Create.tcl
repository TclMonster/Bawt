# Copyright 2020-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the sqlite3 package.
# Create a database and issue a query.

package require sqlite3

set fileName [file join "TestOut" "sqlite3-Create.db3"]
catch { file mkdir "TestOut" }
file delete -force $fileName

sqlite3 myDb $fileName

set date [clock format [clock scan now] -format "%Y-%m-%d"]

myDb eval {CREATE TABLE "Overview" (
    "Date"    VARCHAR NOT NULL, \
    "Version" INTEGER NOT NULL  \
)}
myDb eval {INSERT INTO "Overview" VALUES( $date, 1 )}

myDb eval {CREATE TABLE "Ranges" (
    "Min" DOUBLE NOT NULL, \
    "Max" DOUBLE NOT NULL  \
)}

myDb eval { BEGIN TRANSACTION }
for { set i 0 } { $i < 10 } { incr i } {
    set min $i
    set max [expr $i + 0.5]
    myDb eval {INSERT INTO "Ranges" VALUES( $min, $max )}
}
myDb eval { COMMIT }

set sqlStatement "SELECT COUNT(*) FROM Ranges"
set numRows [myDb eval $sqlStatement]
puts "Number of rows: $numRows"

myDb close

puts ""
puts [format "Using sqlite3 %s on %s with Tcl %s-%dbit" \
     [package version sqlite3] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
