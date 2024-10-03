# Copyright 2021-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the apave package.
# Slightly modified apave test program test0_pave.tcl.

package require Tk
package require apave

set msg \
    [format "Using apave %s on %s with Tcl %s-%dbit" \
    [package version apave] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

apave::initWM
apave::APave create pave
set win .win
pave makeWindow $win.fra "Find and Replace"
set v1 [set v2 1]
set c1 [set c2 [set c3 0]]
set en1 [set en2 ""]
pave paveWindow $win.fra {
  {lab1 - - 1 1    {-st es}  {-t "Find: "}}
  {ent1 lab1 L 1 9 {-st wes} {-tvar ::en1}}
  {lab2 lab1 T 1 1 {-st es}  {-t "Replace: "}}
  {ent2 lab2 L 1 9 {-st wes} {-tvar ::en2}}
  {labm lab2 T 1 1 {-st es} {-t "Match: "}}
  {radA labm L 1 1 {-st ws} {-t "Exact" -var ::v1 -value 1}}
  {radB radA L 1 1 {-st ws} {-t "Glob" -var ::v1 -value 2}}
  {radC radB L 1 1 {-st es} {-t "RE  " -var ::v1 -value 3}}
  {h_2 radC L 1 2  {-cw 1}}
  {h_3 labm T 1 9  {-st es -rw 1}}
  {seh  h_3 T 1 9  {-st ews}}
  {chb1 seh  T 1 2 {-st w} {-t "Match whole word only" -var ::c1}}
  {chb2 chb1 T 1 2 {-st w} {-t "Match case"  -var ::c2}}
  {chb3 chb2 T 1 2 {-st w} {-t "Wrap around" -var ::c3}}
  {sev1 chb1 L 3 1 }
  {lab3 sev1 L 1 2 {-st w} {-t "Direction:"}}
  {rad1 lab3 T 1 1 {-st we} {-t "Down" -var ::v2 -value 1}}
  {rad2 rad1 L 1 1 {-st we} {-t "Up"   -var ::v2 -value 2}}
  {sev2 ent1 L 8 1 }
  {but1 sev2 L 1 1 {-st we} {-t "Find" -com "::pave res $win 1"}}
  {but2 but1 T 1 1 {-st we} {-t "Find All" -com "::pave res $win 2"}}
  {lab_ but2 T 2 1}
  {but3 lab_ T 1 1 {-st we} {-t "Replace"  -com "::pave res $win 3"}}
  {but4 but3 T 1 1 {-st nwe} {-t "Replace All" -com "::pave res $win 4"}}
  {seh3 but4 T 1 1 {-st ewn}}
  {but5 seh3 T 3 1 {-st we} {-t "Close" -com "exit"}}
  {lab4 chb3 T 1 9 {-st news}  {-t {$msg} }}
}

if { [lindex $argv 0] eq "auto" } {
    after 1000 exit
}

set res [pave showModal $win -focus $win.fra.ent1 -geometry +200+200]
bind $win <Escape> { exit }

