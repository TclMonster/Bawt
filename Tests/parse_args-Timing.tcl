# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the parse_args package.
# Run timing example.

package require parse_args

# Strange function signature is to allow the benchmarking machinery to
# pass the same args to both procs
proc native {t_a title c_a category w_a wiki {r_a rating} {rating 1.0}} {
    list $title $category $wiki $rating
}

proc using_parse_args args {
    parse_args::parse_args $args {
        -title {-required}
        -category {-default {}}
        -wiki {-required}
        -rating {-default 1.0 -validate {string is double -strict}}
    }
    list $title $category $wiki $rating
}

puts "Positional parameters:"
puts "  [native t_a "Title" c_a "Category" w_a "Wiki"]"
puts "  [time { native t_a "Title" c_a "Category" w_a "Wiki" } 10000]"

puts "parse_args parameters:"
puts "  [using_parse_args -title "Title" -category "Category" -wiki "Wiki"]"
puts "  [time { using_parse_args -title "Title" -category "Category" -wiki "Wiki" } 10000]"

puts ""
puts [format "Using parse_args %s on %s with Tcl %s-%dbit" \
     [package version parse_args] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
