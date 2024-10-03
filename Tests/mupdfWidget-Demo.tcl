# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the MuPDFWidget package.
# Slightly modified version of the MuPDFWidget demo.tcl script.

package require MuPDF
package require mupdf::widget

namespace eval GUI {
    variable textSearch {}

    # page up/down
    bind MuPDFWidget <Key-Next>  {%W nextpage}
    bind MuPDFWidget <Key-Prior> {%W prevpage}
    # Button-1 and drag, scroll the page
    bind MuPDFWidget <ButtonPress-1> { focus %W ; %W scan mark %x %y }
    bind MuPDFWidget <B1-Motion> { %W scan dragto %x %y 1 }

    # zoom +/-
    bind MuPDFWidget <Key-plus>  { %W rzoom +1 }
    bind MuPDFWidget <Key-minus> { %W rzoom -1 }
    bind MuPDFWidget <Key-x> { %W zoomfit x }
    bind MuPDFWidget <Key-y> { %W zoomfit y }
    bind MuPDFWidget <Key-z> { %W zoomfit xy }
         
    bind MuPDFWidget <Control-Key-f> { GUI::openSearchPanel %W }

    bind . <Escape> { exit }
}

proc GUI::doSearch { pdfW } {
    variable textSearch
    $pdfW search $textSearch            
}

proc GUI::openSearchPanel { pdfW } {
    variable textSearch
    
    set textSearch {}
    
    set panelW [toplevel $pdfW.searchPanel -padx 20 -pady 20]
    wm title $panelW "Search ..."
    wm attributes $panelW -topmost true
     
    # don't use ttk::entry, since it cannot change the text color !
    entry $panelW.search -textvariable GUI::textSearch  
    button $panelW.ok -text "Search" 
    pack $panelW.search -fill x
    pack $panelW.ok

    $panelW.ok configure -command [list GUI::doSearch $pdfW]
    bind $panelW.search <Return> [list GUI::doSearch $pdfW] 

    # place the new panel close to the pdfW widget
    set x0 [winfo rootx $pdfW]
    set y0 [winfo rooty $pdfW]
    wm geometry $panelW +[expr {$x0-10}]+[expr {$y0-10}] 

    # when this panel is closed, reset the search
    bind $panelW <Destroy> [list apply { 
        { W panelW pdfW } {
            # NOTE: since <Destroy> is propagated to all children,
            #  the following "if", ensure that this core script is executed
            #  just once.
            if {  $W != $panelW } return
            $pdfW search ""
        }} %W $panelW $pdfW]
    focus $panelW.search        
}

proc formatCoords {L} {
    lassign $L x y
    format "%.1f, %.1lf" $x $y
}

bind MuPDFWidget <Motion> { 
    set coordsPdfStr "PDF coords (points): [formatCoords [.c win2PDFcoords %x %y]]"
}

proc GUI::main { filename } {
    wm title . "MuPDFWidget-demo"

    label .coords -textvariable coordsPdfStr
    grid .coords -row 0 -column 0 -sticky news

    set pdf [mupdf::open $filename]
    mupdf::widget .c $pdf
    grid .c -row 1 -column 0 -sticky news

    label .msg -text \
        [format "Using MuPDFWidget %s on %s with Tcl %s-%dbit" \
        [package version mupdf::widget] $::tcl_platform(os) \
        [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
    grid .msg -row 2 -column 0 -sticky news

    grid rowconfigure    . 1 -weight 1
}

GUI::main [file join "Data" "demo.pdf"]
update
.c zoomfit xy
focus .c

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
