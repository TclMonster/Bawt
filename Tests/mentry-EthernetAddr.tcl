# Copyright 2020-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the mentry package.
# Slightly modified version of mentry demo program ethernetaddr_tile.tcl.

package require Tk
package require mentry_tile

set title "mentry-ethernetaddr"
wm title . $title

#------------------------------------------------------------------------------
# ethernetAddrMentry
#
# Creates a new mentry widget win that allows to display and edit Ethernet
# addresses.  Sets the type attribute of the widget to EthernetAddr and returns
# the name of the newly created widget.
#------------------------------------------------------------------------------
proc ethernetAddrMentry {win args} {
    #
    # Create a mentry widget consisting of 6 entry children of
    # width 2, separated by colons, and set its type to EthernetAddr
    #
    eval [list mentry::mentry $win] $args
    $win configure -body {2 : 2 : 2 : 2 : 2 : 2}
    $win attrib type EthernetAddr

    #
    # Install automatic uppercase conversion and allow only hexadecimal
    # digits in all entry children; use wcb::cbappend (or wcb::cbprepend)
    # instead of wcb::callback in order to keep the wcb::checkEntryLen
    # callback, registered by mentry::mentry for all entry children
    #

    for {set n 0} {$n < 6} {incr n} {
        set w [$win entrypath $n]
        wcb::cbappend $w before insert wcb::convStrToUpper \
                      {wcb::checkStrForRegExp {^[0-9A-F]*$}}
        $win adjustentry $n "0123456789ABCDEF"
        bindtags $w [linsert [bindtags $w] 1 MentryEthernetAddr]
    }
    return $win
}

bind MentryEthernetAddr <<Paste>> { pasteEthernetAddr %W }

proc pasteEthernetAddr w {
    set win [winfo parent [winfo parent $w]]
    catch { putEthernetAddr [::tk::GetSelection $w CLIPBOARD] $win }
    return -code break ""
}

#------------------------------------------------------------------------------
# putEthernetAddr
#
# Outputs the Ethernet address addr to the mentry widget win of type
# EthernetAddr.  The address must be a string of the form XX:XX:XX:XX:XX:XX,
# where each XX must be a hexadecimal string in the range 0 - 255.  Leading
# zeros are allowed (but not required), hence the components may have more (but
# also less) than two characters; the procedure displays them with exactly two
# digits.
#------------------------------------------------------------------------------
proc putEthernetAddr {addr win} {
    set errorMsg "expected an Ethernet address but got \"$addr\""

    #
    # Check the syntax of addr
    #
    set lst [split $addr :]
    if {[llength $lst] != 6} {
	return -code error $errorMsg
    }

    #
    # Try to convert the 6 components of addr to hexadecimal
    # strings and check whether they are in the range 0 - 255
    #
    for {set n 0} {$n < 6} {incr n} {
	set val 0x[lindex $lst $n]
	if {[catch {format "%02X" $val} str$n] != 0 || $val < 0 || $val > 255} {
	    return -code error $errorMsg
	}
    }

    #
    # Check the widget and display the properly formatted Ethernet address
    #
    checkIfEthernetAddrMentry $win
    $win put 0 $str0 $str1 $str2 $str3 $str4 $str5
}

#------------------------------------------------------------------------------
# getEthernetAddr
#
# Returns the Ethernet address contained in the mentry widget win of type
# EthernetAddr.
#------------------------------------------------------------------------------
proc getEthernetAddr win {
    #
    # Check the widget
    #
    checkIfEthernetAddrMentry $win

    #
    # Generate an error if any entry child is empty
    #
    for {set n 0} {$n < 6} {incr n} {
	if {[$win isempty $n]} {
	    focus [$win entrypath $n]
	    return -code error EMPTY
	}
    }

    #
    # Return the properly formatted Ethernet address built
    # from the values contained in the entry children
    #
    $win getarray strs
    return [format "%02X:%02X:%02X:%02X:%02X:%02X" \
	    0x$strs(0) 0x$strs(1) 0x$strs(2) 0x$strs(3) 0x$strs(4) 0x$strs(5)]
}

#------------------------------------------------------------------------------
# checkIfEthernetAddrMentry
#
# Generates an error if win is not a mentry widget of type EthernetAddr.
#------------------------------------------------------------------------------
proc checkIfEthernetAddrMentry win {
    if {![winfo exists $win]} {
	return -code error "bad window path name \"$win\""
    }

    if {[string compare [winfo class $win] "Mentry"] != 0 ||
	[string compare [$win attrib type] "EthernetAddr"] != 0} {
	return -code error \
	       "window \"$win\" is not a mentry widget for Ethernet addresses"
    }
}

#------------------------------------------------------------------------------

#
# Improve the window's appearance by using a tile
# frame as a container for the other widgets
#
ttk::frame .base

#
# Frame .base.f with a mentry displaying an Ethernet address
#
ttk::frame .base.f
ttk::label .base.f.l -text "A mentry widget for Ethernet addresses,\nwith\
			    automatic uppercase conversion:"
ethernetAddrMentry .base.f.me -justify center
pack .base.f.l .base.f.me

#
# Button .base.get invoking the procedure getEthernetAddr
#
ttk::button .base.get -text "Get from mentry" -command {
    if {[catch {
	set addr ""
	set addr [getEthernetAddr .base.f.me]
    }] != 0} {
	bell
	tk_messageBox -icon error -message "Field value missing" \
		      -title $title -type ok
    }
}

#
# Label .base.addr displaying the result of getEthernetAddr
#
ttk::label .base.addr -textvariable addr

#
# Separator .sep and button .close
#
ttk::separator .base.sep -orient horizontal
ttk::label .base.msg

.base.msg configure -text \
    [format "Using mentry %s on %s with Tcl %s-%dbit" \
    [package version mentry] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
bind . <Escape> { exit }

#
# Manage the widgets
#
pack .base.msg -side bottom -pady 7p
pack .base.sep -side bottom -fill x
pack .base.f -padx 7p -pady 7p
pack .base.get -padx 7p
pack .base.addr -padx 7p -pady 7p
pack .base -expand yes -fill both

putEthernetAddr 0:40:5:E4:99:26 .base.f.me
focus [.base.f.me entrypath 0]

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
