# Test program for the BWidget package.
# Drag and Drop demo taken from http://wiki.tcl-lang.org/16126

# dnd_button_demo.tcl ---
# A minmal example for a DnD demo with buttons.
# Johann Oberdorfer at gmail dot com 

package require BWidget

proc dragbuttonCmd {wtarget x y top} {
    set txt [$wtarget cget -text]
    set img [$wtarget cget -image]

    label $top.label -text $txt -image $img -compound left -bd 0
    pack $top.label

    return [list BUTTON_ITEM move $txt]
}

proc dropbuttonCmd {args} {
    set wSource   [lindex $args 0]
    set wTarget   [lindex $args 1]
    set sourceTxt [$wSource cget -text]
    set sourceImg [$wSource cget -image]
    set sourceCmd [$wSource cget -command]

    set targetTxt [$wTarget cget -text]
    set targetImg [$wTarget cget -image]
    set targetCmd [$wTarget cget -command]

    # so something fancy with the button...

    $wSource configure -text $targetTxt -image $targetImg -command $targetCmd
    $wTarget configure -text $sourceTxt -image $sourceImg -command $sourceCmd
}

proc droppedOntoButtonCmd {args} {
}

proc enableDnD { wList } {
    foreach w $wList {
        # Here we register the widget as a dropsite.
        DropSite::register $w \
            -dropcmd {dropbuttonCmd} \
            -droptypes {
                BUTTON_ITEM  {copy {} move {} link {}}
            }

        # Here we register the widget as a dragsite.
        DragSite::register $w \
            -dragevent 1 \
            -draginitcmd dragbuttonCmd \
            -dragendcmd  droppedOntoButtonCmd

        # Here we have to bind the data type BUTTON_ITEM to the mouse.
        DragSite::include Widget BUTTON_ITEM <B1-Motion>
    }
}

proc wrap {wtype wpath args} {
    if { [catch {uplevel "#0" package require tile}] == 0 } {
        return [eval ttk::${wtype} $wpath $args]
    } else {
        return [eval $wtype $wpath $args]
    }
}

proc drawGUI {} {
    variable wList
    
    wm withdraw .
    set t [toplevel .t]
    wm title $t "BWidget-DragAndDrop"

    pack [set f [wrap frame $t.f]] -fill both -expand true

    pack [wrap button $f.b1 \
             -text "1.) Drag" -image [Bitmap::get new] -compound left \
             -command {tk_messageBox -message "Drag"}] -padx 5 -pady 5

    pack [wrap button $f.b2 \
             -text "2.) and"  -image [Bitmap::get file] -compound left \
             -command {tk_messageBox -message "and"}] -padx 5 -pady 5

    pack [wrap button $f.b3 \
             -text "3.) Drop" -image [Bitmap::get copy] -compound left \
             -command {tk_messageBox -message "Drop"}] -padx 5 -pady 5

    pack [wrap button $f.b4 \
             -text "4.) Demo" -image [Bitmap::get redo] -compound left \
             -command {tk_messageBox -message "Demo"}] -padx 5 -pady 5

    enableDnD [list $f.b1 $f.b2 $f.b3 $f.b4]

    pack [wrap label $f.msg -text \
        [format "Using BWidget %s on %s with Tcl %s-%dbit" \
        [package version BWidget] $::tcl_platform(os) \
        [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]]

    bind $t <Escape> { exit }
}

drawGUI

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
