# 99 bottles of beer on the wall, Expect-style
# Author: Don Libes <libes@nist.gov>

# Unlike programs (http://www.ionet.net/~timtroyr/funhouse/beer.html)
# which merely print out the 99 verses, this one SIMULATES a human
# typing the beer song.  Like a real human, typing mistakes and timing
# becomes more erratic with each beer - the final verse is barely
# recognizable and it is really like watching a typist hunt and peck
# while drunk.

# Finally, no humans actually sing all 99 verses - particularly when
# drunk.  In reality, they occasionally lose their place (or just get
# bored) and skip verses, so this program does likewise.

# Because the output is timed, just looking at the output isn't enough
# - you really have to see the program running to appreciate it.
# Nonetheless, for convenience, output from one run (it's different
# every time of course) can be found in the file beer.exp.out
# But it won't show the erratic timing; you have to run it for that.

# For an even fancier version, see http://expect.nist.gov/scripts/superbeer.exp

if { $tcl_platform(platform) eq "windows" } {
    puts "Linux/Darwin only"
    exit 1
}

package require Expect

proc bottles {i} {
    return "$i bottle[expr {$i!=1?"s":""}] of beer"
}

proc line123 {i} {
    out $i "[bottles $i] on the wall,\n"
    out $i "[bottles $i],\n"
    out $i "take one down, pass it around,\n"
}

proc line4 {i} {
    out $i "[bottles $i] on the wall.\n\n"
}

proc out {i s} {
    foreach c [split $s ""] {
	# don't touch punctuation; just looks too strange if you do
	if {[regexp "\[,. \n\]" $c]} {
	    append d $c
	    continue
	}

	# keep first couple of verses straight
	if {$i > 97} {append d $c; continue}

	# +3 prevents it from degenerating too far
	# /2 makes it degenerate faster though

	set r [rand [expr {$i/2+3}]]
	if {$r} {append d $c; continue}

	# do something strange
	switch [rand 3] {
	    0 {
		# substitute another letter

		if {[regexp \[aeiou\] $c]} {
		    # if vowel, substitute another
		    append d [string index aeiou [rand 5]]
		} elseif {[regexp \[0-9\] $c]} {
		    # if number, substitute another
		    append d [string index 123456789 [rand 9]]
		} else {
		    # if consonant, substitute another
		    append d [string index bcdfghjklmnpqrstvwxyz [rand 21]]
		}
	    } 1 {
		# duplicate a letter
		append d $c$c
	    } 2 {
		# drop a letter
	    }
	}
    }

    set arr1 [expr {.4 - ($i/333.)}]
    set arr2 [expr {.6 - ($i/333.)}]
    set shape [expr {log(($i+2)/2.)+.1}]
    set min 0
    set max [expr {6-$i/20.}]

    set send_human "$arr1 $arr2 $shape $min $max"
    set send_human "0.002 0.004 1 0 0.03"

    send -h $d
}

set _ran [pid]

proc rand {m} {
    global _ran

    set period 259200
    set _ran [expr {($_ran*7141 + 54773) % $period}]
    expr {int($m*($_ran/double($period)))}
}

for {set i 99} {$i>0} {} {
    line123 $i
    incr i -1
    line4 $i

    # get bored and skip ahead
    if {$i == 92} {
	set i [expr {52+[rand 5]}]
    }
    if {$i == 51} {
	set i [expr {12+[rand 5]}]
    }
    if {$i == 10} {
	set i [expr {6+[rand 3]}]
    }
}

puts ""
puts [format "Using Expect %s on %s with Tcl %s-%dbit" \
     [package version Expect] $::tcl_platform(os) \
     [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]

exit
