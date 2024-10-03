# Test program for the Tix package.
# Slightly changed version of PanedWin.tcl from the Tix sources.

package require Tix

proc RunSample {w} {

    # We create the frame at the top of the dialog box
    #
    frame $w.top -relief raised -bd 1

    # Use a LabelEntry widget to show the name of the newsgroup
    # [Hint] We disable the entry widget so that the user can't
    # mess up with the name of the newsgroup
    #
    set msg [format "Using Tix %s on %s with Tcl %s-%dbit" \
            [package version Tix] $::tcl_platform(os) \
            [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

    tixLabelEntry $w.top.name -label "Information: " -options {
	entry.width 25
    }
    $w.top.name subwidget entry insert 0 $msg
    $w.top.name subwidget entry config -state disabled

    pack $w.top.name -side top -anchor c -fill x -padx 14 -pady 6
    # Now use a PanedWindow to contain the list and text widgets
    #
    tixPanedWindow $w.top.pane -paneborderwidth 0
    pack $w.top.pane -side top -expand yes -fill both -padx 10 -pady 10

    set p1 [$w.top.pane add list -min 70 -size 100]
    set p2 [$w.top.pane add text -min 70]

    tixScrolledListBox $p1.list
    $p1.list subwidget listbox config -font [tix option get fixed_font]

    tixScrolledText    $p2.text
    $p2.text subwidget text    config -font [tix option get fixed_font]

    pack $p1.list -expand yes -fill both -padx 4 -pady 6
    pack $p2.text -expand yes -fill both -padx 4 -pady 6

    # Use a ButtonBox to hold the buttons.
    #
    tixButtonBox $w.box -orientation horizontal
    $w.box add ok     -text Ok     -underline 0 -command "destroy $w" \
	-width 8
    $w.box add cancel -text Cancel -underline 0 -command "destroy $w" \
	-width 8

    pack $w.box -side bottom -fill x
    pack $w.top -side top -fill both -expand yes

    # Put the junk inside the listbox and the tetx widget
    #
    $p1.list subwidget listbox insert end \
	"  12324 Re: TK is good for your health" \
	"+ 12325 Re: TK is good for your health" \
	"+ 12326 Re: Tix is even better for your health (Was: TK is good...)" \
	"  12327 Re: Tix is even better for your health (Was: TK is good...)" \
	"+ 12328 Re: Tix is even better for your health (Was: TK is good...)" \
	"  12329 Re: Tix is even better for your health (Was: TK is good...)" \
	"+ 12330 Re: Tix is even better for your health (Was: TK is good...)"

    $p2.text subwidget text config -wrap none -bg \
	[$p1.list subwidget listbox cget -bg]
    $p2.text subwidget text insert end {
Mon, 19 Jun 1995 11:39:52        comp.lang.tcl              Thread   34 of  220
Lines 353       A new way to put text and bitmaps together iNo responses
ioi@blue.seas.upenn.edu                Ioi K. Lam at University of Pennsylvania

Hi,

I have implemented a new image type called "compound". It allows you
to glue together a bunch of bitmaps, images and text strings together
to form a bigger image. Then you can use this image with widgets that
support the -image option. This way you can display very fancy stuffs
in your GUI. For example, you can display a text string string
together with a bitmap, at the same time, inside a TK button widget. A
screenshot of compound images can be found at the bottom of this page:

        http://www.cis.upenn.edu/~ioi/tix/screenshot.html

You can also you is in other places such as putting fancy bitmap+text
in menus, tabs of tixNoteBook widgets, etc. This feature will be
included in the next release of Tix (4.0b1). Count on it to make jazzy
interfaces!}

}

wm withdraw .
set w .demo
toplevel $w; wm transient $w ""
wm title .demo "Tix-PanedWin"
RunSample $w
bind $w <Destroy> { exit }
bind $w <Escape>  { exit }

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
