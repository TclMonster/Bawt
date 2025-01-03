# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tls package.
# Slightly modified TclTLS example keytest1.tcl.

package require tls

proc creadable {s} {
    puts "LINE=[gets $s]"
    after 2000
    exit
}

proc myserv {s args} {
    fileevent $s readable [list creadable $s]
}

close [file tempfile keyfile]
close [file tempfile certfile]
tls::misc req 1024 $keyfile $certfile [list C CCC ST STTT L LLLL O OOOO OU OUUUU CN CNNNN Email some@email.com days 730 serial 12]

tls::socket -keyfile $keyfile -certfile $certfile -server myserv 12300

puts [format "Using tls %s on %s with %dbit Tcl %s" \
     [package version tls] $::tcl_platform(os) \
     [expr $::tcl_platform(pointerSize) * 8]  [info patchlevel]]

puts "Now run keytest2.tcl"
vwait forever

