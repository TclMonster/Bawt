# Copyright 2020-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the awthemes package.
# Slightly modified version of awthemes demo program demoscaled.tcl.

package require Tk

proc setcboxfont { w } {
  set cb [winfo parent [winfo parent [winfo parent $w]]]
  set style [$cb cget -style]
  if { [regexp Small $style] } {
    $w configure -font SmallFont
  }
}

proc setcboxgeom { w } {
  set w [winfo parent $w]
  set w [winfo parent $w]
  set cb [winfo parent $w]
  ::ttk::combobox::PlacePopdown $cb $w
}

proc main { } {
  variable vars

  wm withdraw .
  update idletasks
  set vars(mainW) .demoscaled
  toplevel $vars(mainW) 
  wm title $vars(mainW) "awthemes-demoscaled"

  set ::notksvg false
  set fontscale 1.0 ; # default
  set sf 1.0
  set gc {}
  set fontsize 11

  # now do the requires so that -notksvg has an effect.
  package require colorutils
  package require awthemes


  if { [package vcompare [package version awthemes] "10"] >= 0 } {
      set theme "awwinxpblue"
      package require awwinxpblue
  } else {
      set theme "winxpblue"
      package require winxpblue
  }

  if { $gc ne {} } {
    ::themeutils::setThemeColors $theme \
        graphics.color $gc
  }
  ::themeutils::setThemeColors $theme \
      scale.factor $sf

  if { ! $::notksvg } {
    catch { package require tksvg }
  }

  set calcdpi [expr {round([tk scaling]*72.0)}]
  set scalefactor [expr {$calcdpi/100.0}]

  # Tk defaults to pixels.  Sigh.
  # Use points so that the fonts scale.
  font configure TkDefaultFont -size $fontsize
  set origfontsz [font metrics TkDefaultFont -ascent]
  font configure TkDefaultFont -size \
      [expr {round(double($fontsize)*$fontscale)}]

  set newfontsz [font metrics TkDefaultFont -ascent]
  if { $origfontsz != $newfontsz } {
    set appscale [expr {double($newfontsz)/double($origfontsz)}]
    ::themeutils::setThemeColors $theme \
        scale.factor $appscale
  }

  set loaded false
  if { 1 } {
    set fn [file join $::env(HOME) s ballroomdj code themes themeloader.tcl]
    if { [file exists $fn] } {
      source $fn
      ::themeloader::loadTheme $theme
      set loaded true
    }
  }

  set havetksvg false
  if { ! [catch {package present tksvg}] } {
    set havetksvg true
  }

  set ttheme $theme
  if { ($havetksvg && $theme eq "black") ||
      ($havetksvg && $theme eq "winxpblue") } {
    set ttheme aw${theme}
  }
  if { [file exists $ttheme.tcl] && ! $loaded } {
    source $ttheme.tcl
  }

  ::ttk::style theme use $theme

  set val 55
  set valb $theme
  set off 0
  set on 1

  $vars(mainW) configure -background [::ttk::style lookup TFrame -background]

  if { [info commands ::ttk::theme::${theme}::scaledStyle] ne {} } {
    font create SmallFont
    font configure SmallFont -size [expr {round(8.0*$fontscale)}]
    ::ttk::theme::${theme}::scaledStyle Small TkDefaultFont SmallFont
  }

  ::ttk::style configure TFrame -borderwidth 0

  bind ComboboxListbox <Map> +[list ::setcboxfont %W]
  bind ComboboxListbox <Visibility> +[list after 10 ::setcboxgeom %W]

  foreach {k} {{} Small} {
    set tfont TkDefaultFont
    set s {}
    if { $k ne {} } {
      set tfont SmallFont
      set s Small.
    }

    ::ttk::labelframe $vars(mainW).lf${k} \
        -text " Normal " \
        -style ${s}TLabelframe
    ::ttk::style configure ${s}TLabelframe.Label -font $tfont

    ::ttk::frame $vars(mainW).bf$k
    ::ttk::label $vars(mainW).lb$k -text $theme -style ${s}TLabel
    ::ttk::style configure ${s}TLabel -font $tfont
    ::ttk::button $vars(mainW).b$k -text $theme -style ${s}TButton
    ::ttk::style configure ${s}TButton -font $tfont
    pack $vars(mainW).lb$k $vars(mainW).b$k -in $vars(mainW).bf$k -side left -padx 3p

    ::ttk::combobox $vars(mainW).combo$k -values \
        [list aaa bbb ccc ddd eee fff ggg hhh iii jjj kkk lll mmm nnn ooo ppp] \
        -textvariable valb \
        -width 15 \
        -height 5 \
        -font $tfont \
        -style ${s}TCombobox

    ::ttk::frame $vars(mainW).cbf$k
    ::ttk::checkbutton $vars(mainW).cboff$k -text off -variable off -style ${s}TCheckbutton
    ::ttk::checkbutton $vars(mainW).cbon$k -text on -variable on -style ${s}TCheckbutton
    pack $vars(mainW).cboff$k $vars(mainW).cbon$k -in $vars(mainW).cbf$k -side left -padx 3p

    ::ttk::separator $vars(mainW).sep$k -style ${s}TSeparator

    ::ttk::frame $vars(mainW).rbf$k
    ::ttk::radiobutton $vars(mainW).rboff$k -text off -variable on -value 0 -style ${s}TRadiobutton
    ::ttk::radiobutton $vars(mainW).rbon$k -text on -variable on -value 1 -style ${s}TRadiobutton
    pack $vars(mainW).rboff$k $vars(mainW).rbon$k -in $vars(mainW).rbf$k -side left -padx 3p

    pack $vars(mainW).bf$k $vars(mainW).combo$k $vars(mainW).cbf$k $vars(mainW).sep$k $vars(mainW).rbf$k \
        -in $vars(mainW).lf$k -side top -anchor w -padx 3p -pady 3p
    pack configure $vars(mainW).sep$k -fill x -expand true

    ::ttk::frame $vars(mainW).hf$k
    ::ttk::scale $vars(mainW).sc$k \
        -from 0 \
        -to 100 \
        -variable val \
        -length [expr {round(100*$scalefactor)}] \
        -style ${s}Horizontal.TScale
    ::ttk::progressbar $vars(mainW).pb$k \
        -mode determinate \
        -variable val \
        -length [expr {round(100*$scalefactor)}] \
        -style ${s}Horizontal.TProgressbar
    ::ttk::entry $vars(mainW).ent$k -textvariable valb \
        -width 15 \
        -font $tfont \
        -style ${s}TEntry
    ::ttk::spinbox $vars(mainW).sbox$k -textvariable val \
        -width 5 \
        -from 1 -to 100 -increment 0.1 \
        -font $tfont \
        -style ${s}TSpinbox
    pack $vars(mainW).sc$k $vars(mainW).pb$k $vars(mainW).ent$k $vars(mainW).sbox$k \
        -in $vars(mainW).hf$k -side top -anchor w -padx 3p -pady 3p

    ::ttk::frame $vars(mainW).vf$k
    ::ttk::scale $vars(mainW).scv$k \
        -orient vertical \
        -from 100 -to 0 \
        -variable val \
        -length [expr {round(100*$scalefactor)}] \
        -style ${s}Vertical.TScale
    ::ttk::progressbar $vars(mainW).pbv$k -orient vertical \
        -mode determinate \
        -variable val \
        -length [expr {round(100*$scalefactor)}] \
        -style ${s}Vertical.TProgressbar
    pack $vars(mainW).pbv$k $vars(mainW).scv$k -in $vars(mainW).vf$k -side right -padx 3p -pady 3p

    pack $vars(mainW).hf$k $vars(mainW).vf$k -in $vars(mainW).lf$k -side left -anchor e
  }
  $vars(mainW).lfSmall configure -text " Scaled "
  ttk::label $vars(mainW).msg
  grid $vars(mainW).lf      -row 0 -column 0
  grid $vars(mainW).lfSmall -row 0 -column 1
  grid $vars(mainW).msg     -row 1 -column 0 -columnspan 2
  $vars(mainW).msg configure -text \
    [format "Using awthemes %s on %s with Tcl %s-%dbit" \
    [package version awthemes] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

  bind $vars(mainW) <Escape> { exit }
  focus $vars(mainW)
}

::main

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
