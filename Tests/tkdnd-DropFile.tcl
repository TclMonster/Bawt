# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the tkdnd package.
# Generate a listbox for dropping files from a file browser.

package require Tk
package require tkdnd

proc DropCmd { w dropContent callback action } {
    # puts "Action: $action Dropped files: \"[join $dropContent {, }]\""
    $callback $w $dropContent
    return $action
}

proc AddBinding { w callback } {
    tkdnd::drop_target register $w DND_Files
    bind $w <<Drop:DND_Files>> "DropCmd %W %D $callback %A" 
}

proc SetFileByDrop { w fileList } {
    .drop delete 0 end
    foreach f $fileList {
	.drop insert end $f
    }
}

# Create a listbox for testing the drag-and-drop functionality.
listbox .drop -height 10 -background yellow
label .msg
grid .drop -row 0 -column 0 -sticky news
grid .msg  -row 1 -column 0 -sticky ew
grid rowconfigure . 0 -weight 1
grid columnconfigure . 0 -weight 1

.drop insert end "Drop files here"

AddBinding .drop SetFileByDrop

bind . <Escape> { exit }
.msg configure -text \
    [format "Using tkdnd %s on %s with %dbit Tcl %s and Tk %s" \
    [package version tkdnd] $::tcl_platform(os) \
    [expr $::tcl_platform(pointerSize) * 8] \
    [info patchlevel] [package version Tk]]

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
