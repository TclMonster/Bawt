# Copyright 2019-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the mqtt package.
# Get the CalculatorStatus using the mosquitto test broker.

package require mqtt

proc callback { topic content status } {
    puts [format "%-6s %-20s %s" $status $topic [encoding convertfrom utf-8 $content]]
    set ::gMsgReceived true
}

proc timeout {} {
    puts "Timeout"
    set ::gMsgReceived true
}

puts "Connecting to test.mosquitto.org ..."
set client [mqtt new]
$client connect test-client test.mosquitto.org 1883

puts [format "%-6s %-20s %s" "Status" "Topic" "Content"]
$client subscribe "gewaechshaus_fuerth" callback

after 5000 timeout
vwait gMsgReceived

puts ""
puts [format "Using mqtt %s on %s with %dbit Tcl %s" \
     [package version mqtt] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

exit
