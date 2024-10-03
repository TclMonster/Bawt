# Copyright 2005-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the Tcl3D subpackages tcl3dogl and tcl3dgl2ps.
# Tcl3D demo displaying spheres in various modes.

if { $tcl_platform(os) eq "Darwin" } {
    puts "Windows/Linux only"
    exit 1
}

package require Tk
package require tcl3d

catch { file mkdir "TestOut" }

set no_mat { 0.0 0.0 0.0 1.0 }
set mat_ambient { 0.7 0.7 0.7 1.0 }
set mat_ambient_color { 0.8 0.8 0.2 1.0 }
set mat_diffuse { 0.1 0.5 0.8 1.0 }
set mat_specular { 1.0 1.0 1.0 1.0 }
set no_shininess { 0.0 }
set low_shininess { 5.0 }
set high_shininess { 100.0 }
set mat_emission {0.3 0.2 0.2 0.0}

set frameCount  0

# Create a stop watch for time measurement.
set stopwatch [tcl3dNewSwatch]

# Set the name of the PDF output file.
set scriptFile [info script]
set pdfFile [format "%s.%s" [file rootname $scriptFile] "pdf"]
set pdfFile [file join "TestOut" $pdfFile]

proc bgerror { msg } {
    tk_messageBox -icon error -type ok -message "Error: $msg\n\n$::errorInfo"
    exit
}

proc PostRedisplay { w args } {
    $w postredisplay
}

proc RotX { w angle } {
    set ::xRotate [expr {$::xRotate + $angle}]
    $w postredisplay
}

proc RotY { w angle } {
    set ::yRotate [expr {$::yRotate + $angle}]
    $w postredisplay
}

proc RotZ { w angle } {
    set ::zRotate [expr {$::zRotate + $angle}]
    $w postredisplay
}

proc DrawSpheres {} {
    if { $::shadeModel == $::GL_SMOOTH } {
        glMaterialfv GL_FRONT GL_AMBIENT   $::mat_ambient_color
        glMaterialfv GL_FRONT GL_DIFFUSE   $::mat_diffuse
        glMaterialfv GL_FRONT GL_SPECULAR  $::mat_specular
        glMaterialfv GL_FRONT GL_SHININESS $::high_shininess
        glMaterialfv GL_FRONT GL_EMISSION  $::no_mat
    }

    set quadObj [gluNewQuadric]
    for { set x 0 } { $x < $::numSpheresPerDim } { incr x } {
        for { set y 0 } { $y < $::numSpheresPerDim } { incr y } {
            for { set z 0 } { $z < $::numSpheresPerDim } { incr z } {
                glPushMatrix
                glTranslatef $x $y [expr {-1.0 * $z}]
                if { $::lineMode } {
                    gluQuadricDrawStyle $quadObj GLU_LINE
                } else {
                    gluQuadricDrawStyle $quadObj GLU_FILL
                    if { $::shadeModel == $::GL_SMOOTH } {
                        gluQuadricNormals $quadObj GLU_SMOOTH
                    } else {
                        gluQuadricNormals $quadObj GLU_FLAT
                    }
                }
                gluSphere $quadObj $::sphereSize $::numSlices $::numStacks
                glPopMatrix
            }
        }
    }
    gluDeleteQuadric $quadObj
}

proc ToggleDisplayList {} {
    if { $::useDisplayList } {
        if { ! [info exists ::sphereList] } {
            CreateDisplayList
        }
    } else {
        if { [info exists ::sphereList] } {
            glDeleteLists $::sphereList 1
            unset ::sphereList
        }
    }
}

proc CreateDisplayList {} {
    if { $::useDisplayList } {
        if { [info exists ::sphereList] } {
            glDeleteLists $::sphereList 1
        }
        set ::sphereList [glGenLists 1]
        glNewList $::sphereList GL_COMPILE
        DrawSpheres
        glEndList
    }
}

proc GetFPS { { elapsedFrames 1 } } {
    set currentTime [tcl3dLookupSwatch $::stopwatch]
    set fps [expr $elapsedFrames / ($currentTime - $::s_lastTime)]
    set ::s_lastTime $currentTime
    return $fps
}

proc DisplayFPS {} {
    global frameCount

    incr frameCount
    if { $frameCount == 100 } {
        set msg [format "%s (%.0f fps)" $::appName [GetFPS $frameCount]]
        wm title . $msg 
        set frameCount 0
    }
}

proc Animate { w } {
    if { $::animStarted == 0 } {
        return
    }
    set ::yRotate [expr {$::yRotate + 1}]
    set ::zRotate [expr {$::zRotate + 1}]
    $w postredisplay
    set ::animateId [tcl3dAfterIdle Animate $w]
}

proc StartAnimation {} {
    if { ! [info exists ::animateId] } {
        Animate $::frTogl.toglwin
    }
}

proc StopAnimation {} {
    if { [info exists ::animateId] } {
        after cancel $::animateId 
        unset ::animateId
        set ::animStarted 0
    }
}

proc CreateCallback { w } {
    set ambient { 0.0 0.0 0.0 1.0 }
    set diffuse { 1.0 1.0 1.0 1.0 }
    set specular { 1.0 1.0 1.0 1.0 }
    set position { 0.0 3.0 2.0 0.0 }
    set lmodel_ambient { 0.4 0.4 0.4 1.0 }
    set local_view { 0.0 }

    glClearColor 0.0 0.1 0.1 0
    glEnable GL_DEPTH_TEST

    glLightfv GL_LIGHT0 GL_AMBIENT $ambient
    glLightfv GL_LIGHT0 GL_DIFFUSE $diffuse
    glLightfv GL_LIGHT0 GL_POSITION $position
    glLightModelfv GL_LIGHT_MODEL_AMBIENT $lmodel_ambient
    glLightModelfv GL_LIGHT_MODEL_LOCAL_VIEWER $local_view
 
    glEnable GL_LIGHTING
    glEnable GL_LIGHT0

    CreateDisplayList

    tcl3dStartSwatch $::stopwatch
    set startTime [tcl3dLookupSwatch $::stopwatch]
    set ::s_lastTime $startTime
}

proc DisplayCallback { w } {
    glShadeModel $::shadeModel
    glClear [expr $::GL_COLOR_BUFFER_BIT | $::GL_DEPTH_BUFFER_BIT]
    glPushMatrix
    glTranslatef $::xdist $::ydist [expr {-1.0 * $::zdist}]
    glRotatef $::xRotate 1.0 0.0 0.0
    glRotatef $::yRotate 0.0 1.0 0.0
    glRotatef $::zRotate 0.0 0.0 1.0
    if { $::useDisplayList } {
        if { ! [info exists ::sphereList] } {
            CreateDisplayList
        }
        glCallList $::sphereList
    } else {
        DrawSpheres 
    }
    glPopMatrix

    if { $::animStarted } {
        DisplayFPS
    }

    $w swapbuffers
}

proc ReshapeCallback { toglwin { w -1 } { h -1 } } {
    set w [$toglwin width]
    set h [$toglwin height]

    glViewport 0 0 $w $h
    glMatrixMode GL_PROJECTION
    glLoadIdentity
    gluPerspective 60.0 [expr double($w)/double($h)] 1.0 2000.0
    glMatrixMode GL_MODELVIEW
    glLoadIdentity
    gluLookAt 0.0 0.0 5.0 0.0 0.0 0.0 0.0 1.0 0.0
}

proc UpdateNumSpheres { name1 name2 op } {
    set numSpheres [expr $::numSpheresPerDim*$::numSpheresPerDim*$::numSpheresPerDim]
    set ::numPgons [expr $numSpheres * $::numStacks * $::numSlices]
    $::infoLabel configure -text "$numSpheres ($::numPgons polygons)"
    set ::frameCount 0
}

proc HandleRot {x y win} {
    global cx cy

    RotY $win [expr {180 * (double($x - $cx) / [winfo width $win])}]
    RotX $win [expr {180 * (double($y - $cy) / [winfo height $win])}]

    set cx $x
    set cy $y
}

proc HandleTrans {axis x y win} {
    global cx cy

    if { $axis != "Z" } {
        set ::xdist [expr {$::xdist + 0.1 * double($x - $cx)}]
        set ::ydist [expr {$::ydist - 0.1 * double($y - $cy)}]
    } else {
        set ::zdist [expr {$::zdist + 0.1 * (double($x - $cx))}]
    }

    set cx $x
    set cy $y

    $win postredisplay
}

# Create a PDF file of the OpenGL window content.
proc CreatePdf { toglwin } {
    . configure -cursor watch
    if { $::animStarted } {
        set tempStopped 1
        set ::animStarted 0
    }
    update
    if { ([info procs tcl3dHaveGl2ps] eq "tcl3dHaveGl2ps") && \
          [tcl3dHaveGl2ps] } {
        tcl3dGl2psCreatePdf $toglwin $::pdfFile "[wm title .]"
    } else {
        tk_messageBox -icon info -type ok -title "Info" \
                      -message "PDF creation needs the gl2ps extension.\n\
                                Available in Tcl3D versions greater than 0.3."
    }
    set ::pdfStarted 0
    . configure -cursor top_left_arrow
    if { [info exists tempStopped] } {
        set ::animStarted 1
        Animate $toglwin
    }
}

set ::xdist 0
set ::ydist 0
set ::zdist 5
set ::xRotate 0.0
set ::yRotate 0.0
set ::zRotate 0.0

set ::shadeModel $::GL_SMOOTH
set ::lineMode 0
set ::useDisplayList 0
set ::animStarted 0
set ::pdfStarted 0
 
set appName "tcl3d-Spheres"
wm title . $appName

set frMast [frame .fr]
set frTogl [frame .fr.togl]
set frSlid [frame .fr.slid]
set frBttn [frame .fr.bttn]
set frInfo [frame .fr.info]
pack $frMast -expand 1 -fill both

grid $frTogl -row 0 -column 0 -sticky news
grid $frSlid -row 1 -column 0 -sticky news
grid $frBttn -row 2 -column 0 -sticky nws 
grid $frInfo -row 3 -column 0 -sticky news
grid rowconfigure .fr 0 -weight 1
grid columnconfigure .fr 0 -weight 1

togl $frTogl.toglwin -width 500 -height 500 \
        -double true -depth true \
        -displayproc DisplayCallback \
        -reshapeproc ReshapeCallback \
        -createproc  CreateCallback
pack $frTogl.toglwin -side top -expand 1 -fill both

set frSett [frame $frSlid.sett]
set frTfms [frame $frSlid.tfms]
pack $frSett $frTfms -side left -expand 1 -fill both

frame $frSett.fr1
label $frSett.fr1.l1 -text "Number of slices per sphere:"
spinbox $frSett.fr1.s1 -from 4 -to 30 \
                       -textvariable ::numSlices -width 4 \
                       -command { CreateDisplayList ; $frTogl.toglwin postredisplay }
eval pack [winfo children $frSett.fr1] -side left -anchor w -expand 1
pack $frSett.fr1 -expand 1 -anchor w

frame $frSett.fr2
label $frSett.fr2.l1 -text "Number of stacks per sphere:"
spinbox $frSett.fr2.s1 -from 4 -to 30 \
                       -textvariable ::numStacks -width 4 \
                       -command { CreateDisplayList ; $frTogl.toglwin postredisplay }
eval pack [winfo children $frSett.fr2] -side left -anchor w -expand 1
pack $frSett.fr2 -expand 1 -anchor w

frame $frSett.fr3
label $frSett.fr3.l1 -text "Number of spheres per side:"
spinbox $frSett.fr3.s1 -from 1 -to 50 \
                       -textvariable ::numSpheresPerDim -width 4 \
                       -command { CreateDisplayList ; $frTogl.toglwin postredisplay }
eval pack [winfo children $frSett.fr3] -side left -anchor w -expand 1
pack $frSett.fr3 -expand 1 -anchor w

frame $frSett.fr4
label $frSett.fr4.l2 -text "Number of spheres:"
label $frSett.fr4.info -text "-1"
set ::infoLabel $frSett.fr4.info
eval pack [winfo children $frSett.fr4] -side left -anchor w -expand 1
pack $frSett.fr4 -expand 1 -anchor w

frame $frTfms.fr1
label $frTfms.fr1.lx -text "X translate:"
scale $frTfms.fr1.sx -from -50 -to 50 -length 200 -resolution 0.5 \
                     -orient horiz -showvalue true \
                     -variable xdist \
                     -command { PostRedisplay $frTogl.toglwin }
eval pack [winfo children $frTfms.fr1] -side left -anchor nw -expand 1
pack $frTfms.fr1 -expand 1 -anchor w

frame $frTfms.fr2
label $frTfms.fr2.ly -text "Y translate:"
scale $frTfms.fr2.sy -from -50 -to 50 -length 200 -resolution 0.5 \
                     -orient horiz -showvalue true \
                     -variable ydist \
                     -command { PostRedisplay $frTogl.toglwin }
eval pack [winfo children $frTfms.fr2] -side left -anchor nw -expand 1
pack $frTfms.fr2 -expand 1 -anchor w

frame $frTfms.fr3
label $frTfms.fr3.lz -text "Z translate:"
scale $frTfms.fr3.sz -from -50 -to 50 -length 200 -resolution 0.5 \
                     -orient horiz -showvalue true \
                     -variable zdist \
                     -command { PostRedisplay $frTogl.toglwin }
eval pack [winfo children $frTfms.fr3] -side left -anchor nw -expand 1
pack $frTfms.fr3 -expand 1 -anchor w

checkbutton $frBttn.b1 -text "Use display list" -indicatoron 1 \
                       -variable ::useDisplayList \
                       -command ToggleDisplayList
checkbutton $frBttn.b2 -text "Use flat shading" -indicatoron 1 \
                       -variable ::shadeModel \
                       -offvalue $::GL_SMOOTH -onvalue $::GL_FLAT \
                       -command { $frTogl.toglwin postredisplay }
checkbutton $frBttn.b3 -text "Use line mode" -indicatoron 1 \
                       -variable ::lineMode \
                       -command { CreateDisplayList ; $frTogl.toglwin postredisplay } 
checkbutton $frBttn.b4 -text "Animate" -indicatoron [tcl3dShowIndicator] \
                       -variable ::animStarted \
                       -command { Animate $frTogl.toglwin }
checkbutton $frBttn.b5 -text "Save as PDF" -indicatoron [tcl3dShowIndicator] \
                       -variable ::pdfStarted \
                       -command { CreatePdf $frTogl.toglwin }
eval pack [winfo children $frBttn] -side left -expand 1 -fill x
tcl3dToolhelpAddBinding $frBttn.b5 "Save OpenGL window to file $pdfFile"

set glInfo [format "Using Tcl3D %s on %s with a %s (OpenGL %s, Tcl %s-%dbit)" \
           [package version tcl3d] $::tcl_platform(os) [glGetString GL_RENDERER] \
           [glGetString GL_VERSION] [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
label $frInfo.l1 -text $glInfo
eval pack [winfo children $frInfo] -pady 2 -side top -expand 1 -fill x

trace add variable ::numSpheresPerDim write UpdateNumSpheres
trace add variable ::numStacks write UpdateNumSpheres
trace add variable ::numSlices write UpdateNumSpheres

set ::sphereSize 0.4
set ::numSlices 15
set ::numStacks 15
set ::numSpheresPerDim 5

bind $frTogl.toglwin <1> {set cx %x; set cy %y}
bind $frTogl.toglwin <2> {set cx %x; set cy %y}
bind $frTogl.toglwin <3> {set cx %x; set cy %y}

bind $frTogl.toglwin <B1-Motion> {HandleRot %x %y %W}
bind $frTogl.toglwin <B2-Motion> {HandleTrans X %x %y %W}
bind $frTogl.toglwin <B3-Motion> {HandleTrans Z %x %y %W}

bind . <Key-Escape> { exit }

focus .

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
