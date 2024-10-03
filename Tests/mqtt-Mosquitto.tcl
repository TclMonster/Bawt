# Copyright 2019-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the mqtt package.
# Watch the German river and sea levels using the mosquitto test broker.
# Taken from https://wiki.tcl-lang.org/page/MQTT

package require mqtt

set gMsgCount 0

proc callback { topic content status } {
    puts [format "%-6s %-55s %s" $status $topic [encoding convertfrom utf-8 $content]]
    incr ::gMsgCount
    if { $::gMsgCount >= 10 } {
        set ::gTenMsgsReceived true
    }
}

puts "Connecting to test.mosquitto.org and receiving 10 messages ..."
set client [mqtt new]
$client connect test-client test.mosquitto.org 1883
# This service is deprecated.
#puts [format "%-6s %-55s %s" "Status" "Topic" "Content"]
#$client subscribe "de.wsv/pegel/cm/#" callback

#vwait gTenMsgsReceived

puts ""
puts [format "Using mqtt %s on %s with Tcl %s-%dbit" \
     [package version mqtt] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
