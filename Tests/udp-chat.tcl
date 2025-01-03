# Copyright 2020-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the udp package.
# Slightly modified version of udp demo program chat.tcl.
#
# Illustrates the use of multicast UDP messages to implement a
# primitive chat application.

package require Tk
package require udp

variable Address  224.5.1.21
variable Port     7771

proc Receive {sock} {
    set pkt [read $sock]
    set peer [fconfigure $sock -peer]
    AddMessage $peer $pkt
    return
}

proc Start {addr port} {
    set s [udp_open $port]
    fconfigure $s -blocking 0 -buffering none -translation binary \
        -mcastadd $addr -remote [list $addr $port]
    fileevent $s readable [list ::Receive $s]
    return $s
}

proc CreateGui {socket} {
    text .t -yscrollcommand {.s set}
    scrollbar .s -command {.t yview}
    frame .f -border 0
    entry .f.e -textvariable ::_msg
    button .f.ok -text Send -underline 0 \
        -command "SendMessage $socket \$::_msg"
    pack .f.ok -side right
    pack .f.e -side left -expand 1 -fill x
    frame .m -border 0
    label .m.m
    pack .m.m -expand 1 -fill x
    grid .t .s -sticky news
    grid .f -  -sticky ew
    grid .m -  -sticky ew
    grid columnconfigure . 0 -weight 1
    grid rowconfigure . 0 -weight 1
    bind .f.e <Return> {.f.ok invoke}
    .t tag configure CLNT -foreground red
    .t configure -tabs {90}

    bind . <Escape> { exit }

    .m.m configure -text \
        [format "Using udp %s on %s with %dbit Tcl %s and Tk %s" \
        [package version udp] $::tcl_platform(os) \
        [expr $::tcl_platform(pointerSize) * 8] \
        [info patchlevel] [package version Tk]]
}

proc SendMessage {sock msg} {
    puts -nonewline $sock $msg
}

proc AddMessage {client msg} {
    set msg [string map [list "\r\n" "" "\r" "" "\n" ""] $msg]
    set client [lindex $client 0]
    if {[string length $msg] > 0} {
        .t insert end "$client\t" CLNT "$msg\n" MSG
        .t see end
    }
}

proc Main {} {
    variable Address
    variable Port
    variable sock

    set sock [Start $Address $Port]    
    CreateGui $sock
    after idle [list SendMessage $sock \
                    "$::tcl_platform(user)@[info hostname] connected"]

    if { [lindex $::argv 0] eq "auto" } {
        update
        after 500
        exit
    }
    tkwait window .
    close $sock
}

Main
