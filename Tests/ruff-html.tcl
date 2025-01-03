# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the Ruff! package.
# Generate HTML documentation of namespace poDragAndDrop.

catch { file mkdir "TestOut/Ruff" }

source "Data/poDragAndDrop.tcl"

package require ruff

puts "Generating HTML documentation in TestOut/Ruff ..."
::ruff::document [list \
            ::poDragAndDrop \
        ] \
        -title "RUFF Manual" \
        -pagesplit namespace \
        -includesource true \
        -sortnamespaces false \
        -compact false \
        -excludeprocs {^_} \
        -outdir "TestOut/Ruff" \
        -outfile "poDragAndDrop.html"

puts ""
puts [format "Using ruff %s on %s with %dbit Tcl %s" \
     [package version ruff] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

exit 0
