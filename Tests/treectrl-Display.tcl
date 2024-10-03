# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the treectrl package.

package require Tk
package require treectrl

treectrl .t -width 500 -height 200

ttk::label .msg -text \
    [format "Using treectrl %s on %s with Tcl %s-%dbit" \
    [package version treectrl] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

grid .t   -row 0 -column 0 -sticky news
grid .msg -row 1 -column 0 -sticky news
grid rowconfigure    . 0  -weight 1
grid columnconfigure . 0  -weight 1

.t element create e1 text -text "Hello,"
.t element create e2 window -destroy yes
.t element create e3 text -text " world!"

.t style create S1
.t style elements S1 {e1 e2 e3}
.t style layout S1 e2 -iexpand x -squeeze x

.t column create -text "Column 0" -tags C0 -itemstyle S1
.t column create -text "Column 1" -tags C1 -itemstyle S1
.t column create -text "Column 2" -tags C2 -itemstyle S1

foreach I [.t item create -count 10 -parent root] {
    foreach C [.t column list] {
        .t item element configure $I $C e2 -window [entry .t.w${I}C$C]
    }
}

bind . <Escape> { exit }

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
