# Test program for the tclpy package.
# Taken from https://wiki.tcl-lang.org/page/Experimenting+with+numPy
#
# perform.tcl --
#     Simple checks on the performance of the interface to Python
#
#     Check: setting up matrices of different sizes
#     Idea:
#     Does it make a difference if you fill the matrix all at once or
#     fill it one element at a time?
#     What about filling it by row or by column?
#     Matrix sizes: 10x10, 30x30 and 100x100
#
#     Clear result:
#     Setting the values in the whole matrix at once is 3x faster
#     than setting the entries one by one
#
#     Further checks:
#     - Getting back the matrix
#     - Solving a linear system (comparing with math::linearalgebra?)
#

if { $tcl_platform(os) eq "Darwin" } {
    puts "Windows/Linux only"
    exit 1
}

package require tclpy

proc setMatrix {size} {
    set matrix {}

    for {set r 0} {$r < $size} {incr r} {
        set row {}
        for {set c 0} {$c < $size} {incr c} {
            lappend row [expr {rand()}]
        }
        lappend matrix "\[[join $row ,]\]"
    }
    set pythonMatrix "\[[join $matrix ,]\]"

    py eval "matrix = np.array($pythonMatrix)"
}

proc setByElement {size} {

    for {set r 0} {$r < $size} {incr r} {
        for {set c 0} {$c < $size} {incr c} {
            set rnd [expr {rand()}]
            py eval "matrix\[$r,$c\] = $r"
        }
    }
}

proc getMatrix {size} {
    py call tolist matrix
}

proc getByElement {size} {

    for {set r 0} {$r < $size} {incr r} {
        for {set c 0} {$c < $size} {incr c} {
            py call tostr matrix $r $c
        }
    }
}

proc solveEquations {} {

    py eval "x = np.linalg.solve(matrix,b)"

    set x [py call tolist x]
}

py eval {import numpy as np}
py eval {def tolist(array): aa = globals().get(array); return aa.tolist()}
py eval {def tostr(array,r,c): aa = globals().get(array); rr = int(r); cc = int(c); return aa[rr,cc]}


# Test:
#     First set up the matrix on the Python side, then
#     use the interface to fill the entries
#     Use random numbers to make sure no string representation
#     exists.
#
foreach size {10 30 100} counts {100 30 10} {
    set size2 [expr {$size * $size}]
    py eval "matrix = np.zeros($size2).reshape($size,$size)"

    set result1 [time {setMatrix    $size} $counts]
    set result2 [time {setByElement $size} $counts]

    puts "Size: $size"
    puts "    Fill the matrix at once:              $result1"
    puts "    Fill the matrix one entry at a time:  $result2"
}

#
# Now retrieve the values of a matrix
#
foreach size {10 30 100} counts {100 30 10} {
    set size2 [expr {$size * $size}]
    py eval "matrix = np.random.random(($size,$size))"

    set result1 [time {getMatrix    $size} $counts]
    set result2 [time {getByElement $size} $counts]

    puts "Size: $size"
    puts "    Retrieve the matrix at once:              $result1"
    puts "    Retrieve the matrix one entry at a time:  $result2"
}

#
# Solve a linear system
#
foreach size {10 30 100} counts {100 30 10} {
    py eval "matrix = np.random.random(($size,$size))"
    py eval "b      = np.random.random($size)"

    set result [time {solveEquations} $counts]

    puts "Size: $size"
    puts "    Solve a linear system: $result"
}

puts ""
puts [format "Using tclpy %s on %s with Tcl %s-%dbit" \
     [package version tclpy] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
