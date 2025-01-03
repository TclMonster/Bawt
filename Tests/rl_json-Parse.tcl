# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the rl_json package.
# Parse JSON and convert to closest Tcl value.

package require rl_json

set json {
    {
        "foo": "bar",
        "baz": ["str", 123, 123.4, true, false, null, {"inner": "obj"}]
    }
}

set jsonDict [rl_json::json parse $json]
puts "JSON dict: $jsonDict"

puts ""
puts [format "Using rl_json %s on %s with %dbit Tcl %s" \
     [package version rl_json] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

exit
