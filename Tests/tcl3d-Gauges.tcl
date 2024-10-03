# Copyright 2005-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the Tcl3D extension package gauge.
# The program allows to show the 4 gauges at different sizes.

if { $tcl_platform(os) eq "Darwin" } {
    puts "Windows/Linux only"
    exit 1
}

package require Tk
package require tcl3d

set numWidgets 4
set numTests   500

set stopWatch [tcl3dNewSwatch]
tcl3dStartSwatch $stopWatch

proc bgerror { msg } {
    tk_messageBox -icon error -type ok -message "Error: $msg\n\n$::errorInfo"
    exit
}

proc TestWidget { toglWidget ind minVal maxVal } {
    set startTime [tcl3dLookupSwatch $::stopWatch]
    set inc [expr ($maxVal - $minVal) / double ($::numTests)]
    for { set val $minVal } { $val <= $maxVal } { set val [expr $val + $inc] } {
        set ::myValue($ind) $val
        update
    }
    for { set val $maxVal } { $val >= $minVal } { set val [expr $val - $inc] } {
        set ::myValue($ind) $val
        update
    }
    set endTime [tcl3dLookupSwatch $::stopWatch]
    set elapsedTime [expr $endTime - $startTime]
    set fps [expr 2*$::numTests / $elapsedTime]
    wm title . [format "%s %.1f seconds (%.0f fps)" \
                $::appTitle $elapsedTime $fps]
    puts [format "%s-%d: %.1f seconds (%.0f fps)" \
                   $::cmdType $ind $elapsedTime $fps]
}

proc GetValue { toglWidget labelWidget scaleVal } {
    set cmd [format "::%s::getValue" $::cmdType]
    set val [$cmd $toglWidget]
    $labelWidget configure -text $val
}

proc Cleanup {} {
    global numWidgets

    set cmdDel [format "::%s::delete" $::cmdType]
    for { set i 0 } { $i < $numWidgets } { incr i } {
        $cmdDel .fr.toglwin_$i
    }
}

proc CreateWidgets { resMin resMax resIncr } {
    global numWidgets

    set size 64
    set colors { red green blue magenta }

    set cmdNew   [format "::%s::new"    $::cmdType]
    set cmdReset [format "::%s::reset"  $::cmdType]
    set cmdDel   [format "::%s::delete" $::cmdType]
    for { set i 0 } { $i < $numWidgets } { incr i } {
        $cmdDel .fr.toglwin_$i
        destroy .fr.label_$i
        destroy .fr.scale_$i
        destroy .fr.test_$i
    }
    destroy .fr.info

    for { set i 0 } { $i < $numWidgets } { incr i } {
        set actSize [expr $size * ($i + 1)]
        set tcl3dWidget [$cmdNew .fr.toglwin_$i \
                         -width $actSize -height $actSize \
                         -background [lindex $colors $i] \
                         -variable ::myValue($i)]
        grid $tcl3dWidget -row 1 -column $i -sticky se
        $cmdReset $tcl3dWidget
        set ::myValue($i) $resMin

        set labelWidget [label .fr.label_$i]
        grid $labelWidget -row 2 -column $i -sticky news

        set scaleWidget [scale .fr.scale_$i -variable ::myValue($i) \
                        -from $resMin -to $resMax -resolution $resIncr \
                        -orient horizontal -showvalue 0 \
                        -command "GetValue $tcl3dWidget $labelWidget"]
        grid $scaleWidget -row 3 -column $i -sticky news

        set testWidget [button .fr.test_$i -text "Test" \
                        -command "TestWidget $tcl3dWidget $i $resMin $resMax"]
        grid $testWidget -row 4 -column $i -sticky news
    }
    label .fr.info
    grid .fr.info -row 5 -columnspan $numWidgets
    .fr.info configure -text \
        [format "Using Tcl3D %s on %s with a %s (OpenGL %s, Tcl %s-%dbit)" \
           [package version tcl3d] $::tcl_platform(os) [glGetString GL_RENDERER] \
           [glGetString GL_VERSION] [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
}

frame .fr
pack .fr -fill both -expand 1

set appTitle "tcl3d-Gauges"
wm title . $appTitle
wm minsize . 100 100
set sw [winfo screenwidth .]
set sh [winfo screenheight .]
wm maxsize . [expr $sw -20] [expr $sh -40]

set i 0
foreach { cmd resMin resMax resIncr } { \
              airspeed    0   750  0.25 \
              altimeter   0 10000 10 \
              compass     0   360  0.25 \
              tiltmeter -90    90  0.25 } {
    radiobutton .fr.b_$cmd -command "CreateWidgets $resMin $resMax $resIncr" \
                -text $cmd -value $cmd -variable cmdType
    grid .fr.b_$cmd -row 0 -column $i -sticky ew
    incr i
}

bind . <Escape> { exit }

set cmdType "airspeed"
.fr.b_airspeed invoke

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
