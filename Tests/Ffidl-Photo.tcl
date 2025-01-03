# Copyright 2019-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the Ffidl package.
# Create an image using standard Tk methods and using the img::raw extension.
#
# Combined version of package tkphoto (from directory demos) and test program
# tkphoto.test from the Ffidl source code distribution.

package require Ffidl
package require Ffidlrt
package require Tk

# define a type alias for Tk_PhotoHandle
ffidl::typedef Tk_PhotoHandle pointer

# define a structure for Tk_PhotoImageBlock
ffidl::typedef Tk_PhotoImageBlock pointer int int int int int int int int

# bind to tk
ffidl::callout ffidl-find-photo {pointer pointer-utf8} Tk_PhotoHandle \
    [ffidl::stubsymbol tk stubs 64]; #Tk_FindPhoto
ffidl::callout ffidl-photo-put-block {pointer Tk_PhotoHandle pointer-byte int int int int int} void \
    [ffidl::stubsymbol tk stubs 266]; #Tk_PhotoPutBlock
ffidl::callout ffidl-photo-get-image {Tk_PhotoHandle pointer-var} int \
    [ffidl::stubsymbol tk stubs 146]; #Tk_PhotoGetImage
ffidl::callout ffidl-photo-blank {Tk_PhotoHandle} void \
    [ffidl::stubsymbol tk stubs 147]; #Tk_PhotoBlank
ffidl::callout ffidl-photo-get-size {Tk_PhotoHandle pointer-var pointer-var} void \
    [ffidl::stubsymbol tk stubs 149]; #Tk_PhotoGetSize

# use the ffidl::info format for Tk_PhotoImageBlock to get the fields
proc ffidl-photo-block-fields {pib} {
    binary scan $pib [ffidl::info format Tk_PhotoImageBlock] \
	pixelPtr width height pitch pixelSize red green blue reserved
    list $pixelPtr $width $height $pitch $pixelSize $red $green $blue $reserved
}
# define accessors for the fields
foreach {name offset} {
    pixelPtr 0 width 1 height 2 pitch 3 pixelSize 4 red 5 green 6 blue 7 reserved 8
} {
    proc ffidl-photo-block.$name {pib} "lindex \[ffidl-photo-block-fields \$pib] $offset"
}

proc ffidl-photo-get-block-bytes {block} {
    set nbytes [expr {[ffidl-photo-block.height $block]*[ffidl-photo-block.pitch $block]}]
    set bytes [binary format x$nbytes]
    ffidl::memcpy bytes [ffidl-photo-block.pixelPtr $block] $nbytes
    set bytes
}

# make a checkerboard photo image put argument with checker width w,
# checker height h and colors c1 and c2.

proc checkerboard {w h c1 c2} {
    set row1 {}
    set row2 {}
    for {set j 0} {$j < $w*2} {incr j} {
	if {$j < $w} {
	    lappend row1 $c1
	    lappend row2 $c2
	} else {
	    lappend row1 $c2
	    lappend row2 $c1
	}
    }
    set checks {}
    for {set i 0} {$i < $h*2} {incr i} {
	if {$i < $h} {
	    lappend checks $row1
	} else {
	    lappend checks $row2
	}
    }
    set checks
}

set size 256

image create photo p -width $size -height $size
image create photo q -width $size -height $size

label .p -image p
label .q -image q

label .msg -text \
    [format "Using Ffidl %s on %s with %dbit Tcl %s and Tk %s" \
    [package version Ffidl] $::tcl_platform(os) \
    [expr $::tcl_platform(pointerSize) * 8] \
    [info patchlevel] [package version Tk]]

grid .p   -row 0 -column 0
grid .q   -row 0 -column 1
grid .msg -row 1 -column 0 -columnspan 2

bind . <Escape> { exit }

p put [checkerboard 16 16 red blue] -to 0 0 $size $size

# find the image named "p"
set phandle [ffidl-find-photo [ffidl::info interp] p]

# find the image named "q"
set qhandle [ffidl-find-photo [ffidl::info interp] q]

# allocate a Tk_PhotoImageBlock for "p"
set pblock [binary format x[ffidl::info sizeof Tk_PhotoImageBlock]]

# get the Tk_PhotoImageBlock for "p"
ffidl-photo-get-image $phandle pblock

# copy the pixels of "p" into a bytearray
set pbytes [ffidl-photo-get-block-bytes $pblock]

# build a Tk_PhotoImageBlock describing our copy of "p"
set qblock [binary format [ffidl::info format Tk_PhotoImageBlock] \
		[::ffidl::get-bytearray $pbytes] \
		[ffidl-photo-block.width $pblock] \
		[ffidl-photo-block.height $pblock] \
		[ffidl-photo-block.pitch $pblock] \
		[ffidl-photo-block.pixelSize $pblock] \
		[ffidl-photo-block.red $pblock] \
		[ffidl-photo-block.green $pblock] \
		[ffidl-photo-block.blue $pblock] \
		0]

# write our copied pixel data into "q"
for {set x 16} {$x <= $size} {incr x 16} {
    ffidl-photo-put-block [ffidl::info interp] $qhandle $qblock 0 0 $x $x 0
}

if { [lindex $argv 0] eq "auto" } {
    update
    after 500
    exit
}
