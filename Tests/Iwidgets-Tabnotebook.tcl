# ----------------------------------------------------------------------
#  DEMO: tabnotebook in [incr Widgets]
# ----------------------------------------------------------------------
package require Iwidgets

option add *textBackground seashell
option add *Tabnotebook.backdrop DimGray
option add *Scale.width 8
. configure -background white

iwidgets::tabnotebook .tnb -width 5i -height 3i
pack .tnb -padx 4 -pady 4
 
# Page #1
# ----------------------------------------------------------------------
set page [.tnb add -label "Personal Info"]

iwidgets::entryfield $page.name -labeltext "Name:" -labelpos nw
pack $page.name
iwidgets::entryfield $page.addr -labeltext "Address:" -labelpos nw
pack $page.addr
iwidgets::entryfield $page.addr2 -labeltext "City, State:" -labelpos nw
pack $page.addr2
iwidgets::entryfield $page.email -labeltext "E-mail:" -labelpos nw
pack $page.email


# Page #2
# ----------------------------------------------------------------------
set page [.tnb add -label "Favorite Color"]

frame $page.sample -width 20 -height 20 \
    -borderwidth 2 -relief raised
pack $page.sample -fill both -pady 4
scale $page.r -label "Red" -orient horizontal \
    -from 0 -to 255 -command "set_color $page"
pack $page.r -fill x
scale $page.g -label "Green" -orient horizontal \
    -from 0 -to 255 -command "set_color $page"
pack $page.g -fill x
scale $page.b -label "Blue" -orient horizontal \
    -from 0 -to 255 -command "set_color $page"
pack $page.b -fill x

proc set_color {page {val 0}} {
    set r [$page.r get]
    set g [$page.g get]
    set b [$page.b get]
    set color [format "#%.2x%.2x%.2x" $r $g $b]
    $page.sample configure -background $color
}
set_color $page
 

# Page #3
# ----------------------------------------------------------------------
set page [.tnb add -label "Blank Page"]

label $page.title -text "(put your widgets here)" \
    -background black -foreground white \
    -width 25 -height 3
pack $page.title -expand yes -fill both


iwidgets::optionmenu .orient -labeltext "Tabs:" -command {
    .tnb configure -tabpos [.orient get]
}
pack .orient -padx 4 -pady 4
.orient insert end n s e w

.tnb view "Personal Info"
.tnb configure -tabpos [.orient get]

bind . <Escape> { exit }

puts [format "Using Iwidgets %s on %s with Tcl %s-%dbit" \
     [package version Iwidgets] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

 if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
