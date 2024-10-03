# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tdom package.

package require tdom

proc _GetNodeValue { node } {
    set value "Undefined"
    foreach attr [$node attributes] {
        switch -exact -- $attr {
            "Value" {
                set value [$node getAttribute $attr]
            }
        }
    }
    return $value
}

set environmentFile [file join "Data" "Environment.xml"]

set retVal [catch {open $environmentFile r} fp]
if { $retVal != 0 } {
    error "Could not open environment file $environmentFile for reading."
}
set xmlStr [read $fp]
close $fp

set retVal [catch {dom parse $xmlStr} domDoc]
if { $retVal != 0 } {
    error "Invalid XML document: [string map {"\n" " "} $domDoc]."
}
set domRoot [$domDoc documentElement]

set topNode [$domDoc childNodes]
if { [llength $topNode] > 1 } {
    error "Only one top level node expected in file $environmentFile"
}

foreach node [$topNode childNodes] {
    set nodeName [$node nodeName]
    switch -exact -- $nodeName {
        "Location" {
            foreach subNode [$node childNodes] {
                set subNodeName [$subNode nodeName]
                switch -exact -- $subNodeName {
                    "Latitude" {
                        set lat [_GetNodeValue $subNode]
                    }
                    "Longitude" {
                        set lon [_GetNodeValue $subNode]
                    }
                    "Altitude" {
                        set alt [_GetNodeValue $subNode]
                    }
                }
            }
            if { [info exists lat] && [info exists lon] && [info exists alt] } {
                puts "Location complete: $lat $lon $alt"
            }
        }
    }
}

puts ""
puts [format "Using tdom %s on %s with Tcl %s-%dbit" \
     [package version tdom] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
