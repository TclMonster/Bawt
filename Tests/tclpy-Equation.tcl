# Test program for the tclpy package.
# Taken from https://wiki.tcl-lang.org/page/Experimenting+with+numPy
#
# chkpde.tcl --
#     Use NumPy and libtclpy to solve a simple PDE
#
#     The PDE in question is a reaction-diffusion equation defined
#     on a square grid. The equation:
#
#     dC/dt = D nabla C - k C + 1
#
#     The discretisation is straightforward:
#
#     Cij(new) = Cij + Dt * (D/Dx^2 (Ci-1,j + Ci+1,j + Ci,j-1 + Ci,j+1 - 4 Cij) - k Cij + 1)
#
#     Defined on a square grid and the boundary conditions on the four sides are
#     simply: C = 0.
#
#     D  =  1.0e-3     m2/s
#     Dx =  0.1/size   m
#     Dt =  0.1/size   s
#     k  =  0.1        /s
#     T  = 10          s

if { $tcl_platform(os) eq "Darwin" } {
    puts "Windows/Linux only"
    exit 1
}

package require tclpy

proc setMatrix {name matrix} {
    set content {}

    foreach row $matrix {
        lappend content "\[[join $row ,]\]"
    }
    set pythonMatrix "\[[join $content ,]\]"

    py eval "$name\[:,:\] = $pythonMatrix"
}

proc setByElement {size} {

    for {set r 0} {$r < $size} {incr r} {
        for {set c 0} {$c < $size} {incr c} {
            set rnd [expr {rand()}]
            py eval "matrix\[$r,$c\] = $r"
        }
    }
}

proc getMatrix {name} {
    py call tolist $name
}

proc calculateReaction {conc} {
    global decay

    set reaction {}
    foreach row $conc {
        set newrow {}
        foreach col $row {
            lappend newrow [expr {-$decay * $col + 1.0}]
        }
        lappend reaction $newrow
    }

    return $reaction
}

py eval {import numpy as np}
py eval {def tolist(array): aa = globals().get(array); return aa.tolist()}
py eval {def tostr(array,r,c): aa = globals().get(array); rr = int(r); cc = int(c); return aa[rr,cc]}

#
# Try different grid sizes
#

set T 10.0

foreach size {5 10 30 } {
    puts "Size: $size"

    set size2 [expr {$size * $size}]

    set dt    [expr {1.0 / $size}]
    set dx    [expr {1.0 / $size}]
    set diff  1.0e-3
    set decay 0.1

    #
    # Set the parameters
    #
    py eval "dt    = $dt"
    py eval "dx    = $dx"
    py eval "diff  = $diff"
    py eval "decay = $decay"

    set rcentre [expr { $size / 2 }]
    set ccentre [expr { $size / 2 }]

    #
    # Initial condition
    #
    py eval "matrix   = np.zeros($size2).reshape($size,$size)"
    py eval "dmatrix  = np.zeros($size2).reshape($size,$size)"
    py eval "reaction = np.zeros($size2).reshape($size,$size)"

    #
    # Loop over time
    #
    set t 0.0
    while { $t < $T } {

        #
        # Set a time step
        #
        set reaction [calculateReaction [getMatrix "matrix"]]
        setMatrix "reaction" $reaction

        py eval {dmatrix[1:-1,1:-1] = diff / (dx*dx) * ( matrix[0:-2,1:-1] + matrix[2:,1:-1] + matrix[1:-1,0:-2] + matrix[1:-1,2:] - 4.0 * matrix[1:-1,1:-1] ) + reaction[1:-1,1:-1]}
        py eval {matrix[1:-1,1:-1] = matrix[1:-1,1:-1] + dt * dmatrix[1:-1,1:-1]}
        set t [expr {$t + $dt}]

        #
        # Examine the midpoint
        #
        set centre [py call tostr matrix $rcentre $ccentre]
        if { abs($t - int($t+0.5)) < 0.5 * $dt } {
            puts "$t\t$centre"
        }
    }
}

puts ""
puts [format "Using tclpy %s on %s with Tcl %s-%dbit" \
     [package version tclpy] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
