# # Copyright 2022-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the Snack package playing WAV files.
#
# Slightly modified version of Tcl3D demo "NeHe Lession21".
#
# This Code Was Created By Jeff Molofee 2000
# If You've Found This Code Useful, Please Let Me Know.
# Visit My Site At nehe.gamedev.net
#
# Modified for Tcl3D by Paul Obermeier 2006/03/14
# See www.tcl3d.org for the Tcl3D extension.

if { $tcl_platform(os) eq "Darwin" } {
    puts "Windows/Linux only"
    exit 1
}

package require Tk
package require tcl3d
package require snack

# Determine the directory of this script.
set gDemo(scriptDir) [file dirname [info script]]

# Window size.
set gDemo(winWidth)  640
set gDemo(winHeight) 480

# Initialize administrative arrays.
for { set loop1 0 } { $loop1 < 11 } { incr loop1 } {
    for { set loop2 0 } { $loop2 < 11 } { incr loop2 } {
        set vline($loop1,$loop2) 0
        set hline($loop1,$loop2) 0
    }
}

for { set loop1 0 } { $loop1 < 9 } { incr loop1 } {
    set enemy($loop1,x)    0
    set enemy($loop1,y)    0
    set enemy($loop1,fx)   0
    set enemy($loop1,fy)   0
    set enemy($loop1,spin) 0.0
}

set hourglass(x)    0
set hourglass(y)    0
set hourglass(fx)   0
set hourglass(fy)   0
set hourglass(spin) 0.0

set player(x)    0
set player(y)    0
set player(fx)   0
set player(fy)   0
set player(spin) 0.0

set keys(LEFT)  0
set keys(RIGHT) 0
set keys(UP)    0
set keys(DOWN)  0
set keys(SPACE) 0

set gDemo(filled)   0
set gDemo(gameover) 0
set gDemo(active)   1

set gDemo(delay)  0
set gDemo(adjust) 3
set gDemo(lives)  5
set gDemo(level)  1
set gDemo(level2) $gDemo(level)
set gDemo(stage)  1

set gDemo(steps) { 1 2 4 5 10 20 }

set gDemo(texture) [tcl3dVector GLuint 5]

# Show errors occuring in the Togl callbacks.
proc bgerror { msg } {
    tk_messageBox -icon error -type ok -message "Error: $msg\n\n$::errorInfo"
    ExitProg
}

proc LoadGLTextures {} {
    # Load texture images.
    set imgList { "Font.png" "ColorBand.png" }

    glGenTextures [llength $imgList] $::gDemo(texture)

    set imgInd 0
    foreach imgName $imgList {
        set texName [file join $::gDemo(scriptDir) "Data" $imgName]
        set retVal [catch {set phImg [image create photo -file $texName]} err1]
        if { $retVal != 0 } {
            error "Error reading image $texName ($err1)"
        } else {
            set w [image width  $phImg]
            set h [image height $phImg]
            set n [tcl3dPhotoChans $phImg]
            set TextureImage [tcl3dVectorFromPhoto $phImg]
            image delete $phImg
        }
        if { $n == 3 } {
            set type $::GL_RGB
        } else {
           set type $::GL_RGBA
        }

        glBindTexture GL_TEXTURE_2D [$::gDemo(texture) get $imgInd]
        glTexImage2D GL_TEXTURE_2D 0 $n $w $h 0 $type GL_UNSIGNED_BYTE $TextureImage
        glTexParameteri GL_TEXTURE_2D GL_TEXTURE_MIN_FILTER $::GL_LINEAR
        glTexParameteri GL_TEXTURE_2D GL_TEXTURE_MAG_FILTER $::GL_LINEAR

        $TextureImage delete
        incr imgInd
    }
}

proc IntRand {} {
    return [expr {int (rand() * 32767.0)}]
}

proc PlaySound { wavFile blockingFlag } {
    global gDemo

    if { $wavFile eq "" } {
        # OPA TODO Kill Sound
        return
    }
    set fullName [file join $::gDemo(scriptDir) "Data" $wavFile]
    set snd [snack::sound -load $fullName]
    $snd play -blocking $blockingFlag
}

proc TimerInit {} {
    set ::timer [tcl3dNewSwatch]
    tcl3dResetSwatch $::timer
    tcl3dStartSwatch $::timer
}

proc TimerGetTime {} {
    return [expr {1000.0 * [tcl3dLookupSwatch $::timer]}]
}

proc ResetObjects {} {
    set ::player(x)  0
    set ::player(y)  0
    set ::player(fx) 0
    set ::player(fy) 0

    set num [expr $::gDemo(stage) * $::gDemo(level)]
    for { set loop1 0 } { $loop1 < $num } { incr loop1 } {
        set ::enemy($loop1,x)  [expr 5+[IntRand]%6]
        set ::enemy($loop1,y)  [expr [IntRand]%11]
        set ::enemy($loop1,fx) [expr $::enemy($loop1,x)*60]
        set ::enemy($loop1,fy) [expr $::enemy($loop1,y)*40]
    }
}

# Build Our Font Display List
proc BuildFont {} {
    set ::base [glGenLists 256]
    glBindTexture GL_TEXTURE_2D [$::gDemo(texture) get 0]
    for { set loop1 0 } { $loop1 < 256 } { incr loop1 } {
        set cx [expr double($loop1%16)/16.0]
        set cy [expr double($loop1/16)/16.0]

        glNewList [expr $::base+$loop1] GL_COMPILE
            glBegin GL_QUADS
                glTexCoord2f $cx [expr 1.0-$cy-0.0625]
                glVertex2d 0 16
                glTexCoord2f [expr $cx+0.0625] [expr 1.0-$cy-0.0625]
                glVertex2i 16 16
                glTexCoord2f [expr $cx+0.0625] [expr 1.0-$cy]
                glVertex2i 16 0
                glTexCoord2f $cx [expr 1.0-$cy]
                glVertex2i 0 0
            glEnd
            glTranslated 15 0 0
        glEndList
    }
}

proc KillFont {} {
    glDeleteLists $::base 256
}

proc glPrint { x y cset fmt args } {

    set text [format $fmt $args]
    if { $cset > 1 } {
        # Did User Choose An Invalid Character Set?
        set cset 1
    }
    glEnable GL_TEXTURE_2D
    glLoadIdentity
    glTranslated $x $y 0
    glListBase [expr {$::base+(128*$cset)}]

    if { $cset == 0 } {
        # If Set 0 Is Being Used Enlarge Font
        glScalef 1.5 2.0 1.0
    }

    set len [string length $text]
    set sa [tcl3dVectorFromString GLubyte $text]
    $sa addvec -32  0 $len
    glCallLists $len GL_UNSIGNED_BYTE $sa
    $sa delete
    glDisable GL_TEXTURE_2D
}

proc ReshapeCallback { toglwin { w -1 } { h -1 } } {
    set w [$toglwin width]
    set h [$toglwin height]

    glViewport 0 0 $w $h
    glMatrixMode GL_PROJECTION
    glLoadIdentity

    glOrtho 0.0 $w $h 0.0 -1.0 1.0

    glMatrixMode GL_MODELVIEW
    glLoadIdentity
    set ::gDemo(winWidth)  $w
    set ::gDemo(winHeight) $h
}

proc CreateCallback { toglwin } {
    LoadGLTextures
    BuildFont
    glShadeModel GL_SMOOTH
    glClearColor 0.0 0.0 0.0 0.5
    glClearDepth 1.0
    glHint GL_LINE_SMOOTH_HINT GL_NICEST
    glEnable GL_BLEND
    glBlendFunc GL_SRC_ALPHA GL_ONE_MINUS_SRC_ALPHA
}

proc HandleLogic {} {
    set step [lindex $::gDemo(steps) $::gDemo(adjust)]
    set num [expr {$::gDemo(stage) * $::gDemo(level)}]
    if { ! $::gDemo(gameover) && $::gDemo(active) } {
        # If Game Isn't Over And Programs Active Move Objects
        for { set loop1 0 } { $loop1 < $num } { incr loop1 } {
            if { ($::enemy($loop1,x) < $::player(x)) && \
                 ($::enemy($loop1,fy) == [expr {$::enemy($loop1,y)*40}]) } {
                incr ::enemy($loop1,x)
            }

            if { ($::enemy($loop1,x) > $::player(x)) && \
                 ($::enemy($loop1,fy) == [expr {$::enemy($loop1,y)*40}]) } {
                incr ::enemy($loop1,x) -1
            }

            if { ($::enemy($loop1,y) < $::player(y)) && \
                 ($::enemy($loop1,fx) == [expr {$::enemy($loop1,x)*60}]) } {
                incr ::enemy($loop1,y)
            }

            if { ($::enemy($loop1,y) > $::player(y)) && \
                 ($::enemy($loop1,fx) == [expr {$::enemy($loop1,x)*60}]) } {
                incr ::enemy($loop1,y) -1
            }

            if { ($::gDemo(delay) > [expr {3-$::gDemo(level)}]) && ($::hourglass(fx) != 2) } {
                # If Our Delay Is Done And Player Doesn't Have Hourglass
                set ::gDemo(delay) 0
                for { set loop2 0 } { $loop2 < $num } { incr loop2 } {
                    if { $::enemy($loop2,fx) < [expr {$::enemy($loop2,x)*60}] } {
                        # Is Fine Position On X Axis Lower Than Intended Position?
                        # If So, Increase Fine Position On X Axis
                        set ::enemy($loop2,fx) [expr {$::enemy($loop2,fx) + $step}]
                        # Spin Enemy Clockwise
                        set ::enemy($loop2,spin) [expr {$::enemy($loop2,spin) + $step}]
                    }
                    if { $::enemy($loop2,fx) > [expr {$::enemy($loop2,x)*60}] } {
                        # Is Fine Position On X Axis Higher Than Intended Position?
                        # If So, Decrease Fine Position On X Axis
                        set ::enemy($loop2,fx) [expr {$::enemy($loop2,fx) - $step}]
                        # Spin Enemy Counter Clockwise
                        set ::enemy($loop2,spin) [expr {$::enemy($loop2,spin) - $step}]
                    }
                    if { $::enemy($loop2,fy) < [expr {$::enemy($loop2,y)*40}] } {
                        # Is Fine Position On Y Axis Lower Than Intended Position?
                        # If So, Increase Fine Position On Y Axis
                        set ::enemy($loop2,fy) [expr {$::enemy($loop2,fy) + $step}]
                        # Spin Enemy Clockwise
                        set ::enemy($loop2,spin) [expr {$::enemy($loop2,spin) + $step}]
                    }
                    if { $::enemy($loop2,fy) > [expr {$::enemy($loop2,y)*40}] } {
                        # Is Fine Position On Y Axis Higher Than Intended Position?
                        # If So, Decrease Fine Position On Y Axis
                        set ::enemy($loop2,fy) [expr {$::enemy($loop2,fy) - $step}]
                        # Spin Enemy Counter Clockwise
                        set ::enemy($loop2,spin) [expr {$::enemy($loop2,spin) - $step}]
                    }
                }
            }

            # Are Any Of The Enemies On Top Of The Player?
            if { ($::enemy($loop1,fx) == $::player(fx)) && \
                 ($::enemy($loop1,fy) == $::player(fy)) } {
                incr ::gDemo(lives) -1

                if { $::gDemo(lives) == 0 } {
                    # Are We Out Of Lives?
                    set ::gDemo(gameover) 1
                }

                ResetObjects
                PlaySound "Die.wav" true
            }
        }

        if { $::keys(RIGHT) && ($::player(x) < 10) && \
            ($::player(fx) == [expr {$::player(x)*60}]) && ($::player(fy) == [expr {$::player(y)*40}]) } {
            set ::hline($::player(x),$::player(y)) 1
            incr ::player(x)
        }
        if { $::keys(LEFT) && ($::player(x) > 0) && \
            ($::player(fx) == [expr {$::player(x)*60}]) && ($::player(fy) == [expr {$::player(y)*40}]) } {
            incr ::player(x) -1
            set ::hline($::player(x),$::player(y)) 1
        }
        if { $::keys(DOWN) && ($::player(y) < 10) && \
            ($::player(fx) == [expr {$::player(x)*60}]) && ($::player(fy) == [expr {$::player(y)*40}]) } {
            set ::vline($::player(x),$::player(y)) 1
            incr ::player(y)
        }
        if { $::keys(UP) && ($::player(y) > 0) && \
            ($::player(fx) == [expr {$::player(x)*60}]) && ($::player(fy) == [expr {$::player(y)*40}]) } {
            incr ::player(y) -1
            set ::vline($::player(x),$::player(y)) 1
        }

        if { $::player(fx) < [expr {$::player(x)*60}] } {
            set ::player(fx) [expr {$::player(fx) + $step}]
        }
        if { $::player(fx) > [expr {$::player(x)*60}] } {
            set ::player(fx) [expr {$::player(fx) - $step}]
        }
        if { $::player(fy) < [expr {$::player(y)*40}] } {
            set ::player(fy) [expr {$::player(fy) + $step}]
        }
        if { $::player(fy) > [expr {$::player(y)*40}] } {
            set ::player(fy) [expr {$::player(fy) - $step}]
        }
    } else {
        if { $::keys(SPACE) } {
            # If Spacebar Is Being Pressed
            set ::gDemo(gameover) 0
            set ::gDemo(filled)   1
            set ::gDemo(level)    1
            set ::gDemo(level2)   1
            set ::gDemo(stage)    0
            set ::gDemo(lives)    5
        }
    }

    if { $::gDemo(filled) } {
        # Is The Grid Filled In?
        PlaySound "Complete.wav" true
        incr ::gDemo(stage)
        if { $::gDemo(stage) > 3 } {
            set ::gDemo(stage) 1
            incr ::gDemo(level)
            incr ::gDemo(level2)
            if { $::gDemo(level) > 3 } {
                set ::gDemo(level) 3
                incr ::gDemo(lives)
                if { $::gDemo(lives) > 5 } {
                    # Does The Player Have More Than 5 Lives?
                    set ::gDemo(lives) 5
                }
            } 
        }

        ResetObjects

        for { set loop1 0 } { $loop1 < 11 } { incr loop1 } {
            # Loop Through The Grid X Coordinates
            for { set loop2 0 } { $loop2 < 11 } { incr loop2 } {
                # Loop Through The Grid Y Coordinates
                if { $loop1 < 10 } {
                    set ::hline($loop1,$loop2) 0
                }
                if { $loop2 < 10 } {
                    set ::vline($loop1,$loop2) 0
                }
            }
        }
    }

    # If The Player Hits The Hourglass While It's Being Displayed On The Screen
    if { ($::player(fx) == [expr {$::hourglass(x)*60}]) && \
         ($::player(fy) == [expr {$::hourglass(y)*40}]) && ($::hourglass(fx) == 1) } {
        # Play Freeze Enemy Sound
        PlaySound "Freeze.wav" false
        set ::hourglass(fx) 2
        set ::hourglass(fy) 0
    }

    # Spin The Player Clockwise
    set ::player(spin) [expr {$::player(spin) + 0.5 * $step}]
    if { $::player(spin) > 360.0 } {
        set ::player(spin) [expr {$::player(spin) - 360}]
    }

    # Spin The Hourglass Counter Clockwise
    set ::hourglass(spin) [expr {$::hourglass(spin) - 0.25 * $step}]
    if { $::hourglass(spin) < 0.0 } {
        set ::hourglass(spin) [expr {$::hourglass(spin) + 360}]
    }

    set ::hourglass(fy) [expr {$::hourglass(fy) + $step}]
    if { ($::hourglass(fx) == 0) && ($::hourglass(fy) > [expr {6000/$::gDemo(level)}]) } {
        PlaySound "Hourglass.wav" false
        set ::hourglass(x) [expr [IntRand]%10+1]
        set ::hourglass(y) [expr [IntRand]%11]
        set ::hourglass(fx) 1
        set ::hourglass(fy) 0
    }

    if { ($::hourglass(fx) == 1) && ($::hourglass(fy) > [expr {6000/$::gDemo(level)}]) } {
        set ::hourglass(fx) 0
        set ::hourglass(fy) 0
    }

    if { ($::hourglass(fx) == 2) && ($::hourglass(fy) > [expr {500+(500*$::gDemo(level))}]) } {
        PlaySound "" false
        set ::hourglass(fx) 0
        set ::hourglass(fy) 0
    }

    incr ::gDemo(delay)
}

proc DisplayCallback { toglwin } {
    set start [TimerGetTime]
    set count 0
    while {[TimerGetTime] < [expr {$start + double([lindex $::gDemo(steps) $::gDemo(adjust)])*2.0}] } {
        incr count
    }

    glClear [expr $::GL_COLOR_BUFFER_BIT | $::GL_DEPTH_BUFFER_BIT]

    # Viewport command is not really needed, but has been inserted for
    # Mac OSX. Presentation framework (Tk) does not send a reshape event,
    # when switching from one demo to another.
    glViewport 0 0 [$toglwin width] [$toglwin height]

    glBindTexture GL_TEXTURE_2D [$::gDemo(texture) get 0]
    glColor3f 1.0 0.5 1.0
    glPrint 207 24 0 "GRID CRAZY"
    glColor3f 1.0 1.0 0.0
    glPrint 20 20 1 "Level:%2i" $::gDemo(level2)
    glPrint 20 40 1 "Stage:%2i" $::gDemo(stage)

    if { $::gDemo(gameover) } {
        # Pick A Random Color
        glColor3ub [expr [IntRand]%255] [expr [IntRand]%255] [expr [IntRand]%255]       
        glPrint 472 20 1 "GAME OVER"
        glPrint 456 40 1 "PRESS S"
    }

    for { set loop1 0 } { $loop1 < [expr {$::gDemo(lives)-1}] } { incr loop1 } {
        glLoadIdentity
        glTranslatef [expr {490+($loop1*40.0)}] 40.0 0.0
        glRotatef [expr {-1.0 * $::player(spin)}] 0.0 0.0 1.0
        glColor3f 0.0 1.0 0.0
        glBegin GL_LINES
            glVertex2d -5 -5
            glVertex2d  5  5
            glVertex2d  5 -5
            glVertex2d -5  5
        glEnd
        glRotatef [expr {-1.0 * $::player(spin)*0.5}] 0.0 0.0 1.0
        glColor3f 0.0 0.75 0.0
        glBegin GL_LINES
            glVertex2d -7  0
            glVertex2d  7  0
            glVertex2d  0 -7
            glVertex2d  0  7
        glEnd
    }

    set ::gDemo(filled) 1
    glLineWidth  2.0
    glDisable GL_LINE_SMOOTH
    glLoadIdentity
    for { set loop1 0 } { $loop1 < 11 } { incr loop1 } {
        for { set loop2 0 } { $loop2 < 11 } { incr loop2 } {
            set l1 [expr {$loop1*60}]
            set l2 [expr {$loop2*40}]
            # Loop From Top To Bottom
            if { $::hline($loop1,$loop2) } {
                # Has The Horizontal Line Been Traced
                glColor3f 1.0 1.0 1.0
            } else {
                glColor3f 0.0 0.5 1.0
            }

            if { $loop1 < 10 } {
                # Dont Draw To Far Right
                if { ! $::hline($loop1,$loop2) } {
                    # If A Horizontal Line Isn't Filled
                    set ::gDemo(filled) 0
                }
                glBegin GL_LINES
                    glVertex2d [expr {20+$l1}] [expr {70+$l2}]
                    glVertex2d [expr {80+$l1}] [expr {70+$l2}]
                glEnd
            }

            if { $::vline($loop1,$loop2) } {
                # Has The Horizontal Line Been Traced
                glColor3f 1.0 1.0 1.0
            } else {
                glColor3f 0.0 0.5 1.0
            }
            if { $loop2 < 10 } {
                # Dont Draw To Far Down
                if { ! $::vline($loop1,$loop2) } {
                    # If A Verticle Line Isn't Filled
                    set ::gDemo(filled) 0
                }
                glBegin GL_LINES
                    glVertex2d [expr {20+$l1}] [expr { 70+$l2}]
                    glVertex2d [expr {20+$l1}] [expr {110+$l2}]
                glEnd
            }

            glEnable GL_TEXTURE_2D
            glColor3f 1.0 1.0 1.0
            glBindTexture GL_TEXTURE_2D [$::gDemo(texture) get 1]
            if { ($loop1<10) && ($loop2<10) } {
                # If In Bounds, Fill In Traced Boxes
                # Are All Sides Of The Box Traced?
                if { $::hline($loop1,$loop2) && $::hline($loop1,[expr {$loop2+1}]) && \
                     $::vline($loop1,$loop2) && $::vline([expr {$loop1+1}],$loop2) } {
                    set l1_10 [expr {double($loop1/10.0)}]
                    set l2_10 [expr {double($loop2/10.0)}]
                    glBegin GL_QUADS
                        glTexCoord2f [expr {$l1_10+0.1}] [expr {1.0-$l2_10}]
                        glVertex2d [expr {20+$l1+59}] [expr {70+$l2+1}]
                        glTexCoord2f $l1_10 [expr {1.0-$l2_10}]
                        glVertex2d [expr {20+$l1+1}] [expr {70+$l2+1}]
                        glTexCoord2f $l1_10 [expr {1.0-($l2_10+0.1)}]
                        glVertex2d [expr {20+$l1+1}] [expr {70+$l2+39}]
                        glTexCoord2f [expr {$l1_10+0.1}] [expr {1.0-($l2_10+0.1)}]
                        glVertex2d [expr {20+$l1+59}] [expr {70+$l2+39}]
                    glEnd
                }
            }
            glDisable GL_TEXTURE_2D
        }
    }
    glLineWidth 1.0

    glEnable GL_LINE_SMOOTH

    if { $::hourglass(fx) == 1 } {
        # If fx=1 Draw The Hourglass
        glLoadIdentity
        # Move To The Fine Hourglass Position
        glTranslatef [expr {20.0+($::hourglass(x)*60)}] [expr {70.0+($::hourglass(y)*40)}] 0.0
        glRotatef $::hourglass(spin) 0.0 0.0 1.0
        glColor3ub [expr [IntRand]%255] [expr [IntRand]%255] [expr [IntRand]%255]
        glBegin GL_LINES
            glVertex2d -5 -5
            glVertex2d  5  5
            glVertex2d  5 -5
            glVertex2d -5  5
            glVertex2d -5  5
            glVertex2d  5  5
            glVertex2d -5 -5
            glVertex2d  5 -5
        glEnd
    }

    glLoadIdentity
    # Move To The Fine Player Position
    glTranslatef [expr {$::player(fx)+20.0}] [expr {$::player(fy)+70.0}] 0.0
    glRotatef $::player(spin) 0.0 0.0 1.0
    glColor3f 0.0 1.0 0.0
    glBegin GL_LINES
        glVertex2d -5 -5
        glVertex2d  5  5
        glVertex2d  5 -5
        glVertex2d -5  5
    glEnd
    glRotatef [expr {$::player(spin)*0.5}] 0.0 0.0 1.0
    glColor3f 0.0 0.75 0.0
    glBegin GL_LINES
        glVertex2d -7  0
        glVertex2d  7  0
        glVertex2d  0 -7
        glVertex2d  0  7
    glEnd

    set num [expr {$::gDemo(stage) * $::gDemo(level)}]
    for { set loop1 0 } { $loop1 < $num } { incr loop1 } {
        glLoadIdentity
        glTranslatef [expr {$::enemy($loop1,fx)+20.0}] [expr {$::enemy($loop1,fy)+70.0}] 0.0
        glColor3f 1.0 0.5 0.5
        glBegin GL_LINES
            glVertex2d  0 -7
            glVertex2d -7  0
            glVertex2d -7  0
            glVertex2d  0  7
            glVertex2d  0  7
            glVertex2d  7  0
            glVertex2d  7  0
            glVertex2d  0 -7
        glEnd
        glRotatef $::enemy($loop1,spin) 0.0 0.0 1.0
        glColor3f 1.0 0.0 0.0
        glBegin GL_LINES
            glVertex2d -7 -7
            glVertex2d  7  7
            glVertex2d -7  7
            glVertex2d  7 -7
        glEnd
    }
    $toglwin swapbuffers
    HandleLogic
}

proc Cleanup {} {
    unset ::vline
    unset ::hline
    unset ::enemy
    unset ::hourglass
    unset ::player
    unset ::keys
}

proc ExitProg {} {
    KillFont
    exit
}

proc SetKeys { type onOff } {
    set ::keys($type) $onOff
}

proc Animate {} {
    .fr.toglwin postredisplay
    set ::animateId [tcl3dAfterIdle Animate]
}

proc StartAnimation {} {
    if { ! [info exists ::animateId] } {
        Animate
    }
}

proc StopAnimation {} {
    if { [info exists ::animateId] } {
        after cancel $::animateId 
        unset ::animateId
    }
}

# Create the OpenGL window and some Tk helper widgets.
proc CreateWindow {} {
    frame .fr
    pack .fr -expand 1 -fill both

    togl .fr.toglwin -width $::gDemo(winWidth) -height $::gDemo(winHeight) \
                     -swapinterval 1 \
                     -double true -depth true \
                     -createproc  CreateCallback \
                     -reshapeproc ReshapeCallback \
                     -displayproc DisplayCallback 
    grid .fr.toglwin -row 0 -column 0 -sticky news

    label .fr.l
    grid .fr.l -row 1 -column 0 -sticky news

    grid rowconfigure .fr 0 -weight 1
    grid columnconfigure .fr 0 -weight 1
    wm title . "Snack-Wave: Tcl3D demo with sound"

    wm protocol . WM_DELETE_WINDOW "ExitProg"
    bind . <Key-Escape>       "ExitProg"
    bind . <KeyPress-Left>    "SetKeys LEFT 1"
    bind . <KeyRelease-Left>  "SetKeys LEFT 0"
    bind . <KeyPress-Right>   "SetKeys RIGHT 1"
    bind . <KeyRelease-Right> "SetKeys RIGHT 0"
    bind . <KeyPress-Up>      "SetKeys UP 1"
    bind . <KeyRelease-Up>    "SetKeys UP 0"
    bind . <KeyPress-Down>    "SetKeys DOWN 1"
    bind . <KeyRelease-Down>  "SetKeys DOWN 0"
    bind . <KeyPress-s>       "SetKeys SPACE 1"
    bind . <KeyRelease-s>     "SetKeys SPACE 0"

    bind .fr.toglwin <1> "StartAnimation"
    bind .fr.toglwin <2> "StopAnimation"
    bind .fr.toglwin <3> "StopAnimation"
    bind .fr.toglwin <Control-Button-1> "StopAnimation"
}

CreateWindow
ResetObjects
TimerInit

.fr.l configure -text \
    [format "Using Snack %s on %s with Tcl %s-%dbit" \
    [package version snack] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

update

if { [lindex $argv 0] eq "auto" } {
    PlaySound "Freeze.wav" true
    after 1000
    exit
} else {
    StartAnimation
}
