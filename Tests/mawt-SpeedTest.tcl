# Copyright:   2018-2023 Paul Obermeier (obermeier@poSoft.de)
#
#              See the file "Mawt_License.txt" for information on 
#              usage and redistribution of this file, and for a
#              DISCLAIMER OF ALL WARRANTIES.
#
# Description: Tcl script implementing a simple movie player to test the
#              speed of movie playback using different methods.

package require Tk
package require img::raw
set retVal [catch {package require mawt} gMawtVersion]
if { $retVal != 0 } {
    puts "Error: $gMawtVersion"
    exit 1
}

proc PlayMovie { movieFile } {
    global gContinuePlay gStartTime gOpts gMawtVersion

    set videoObj [mawt Video new $movieFile "r"]

    set movieWidth  [$videoObj GetWidth]
    set movieHeight [$videoObj GetHeight]

    set displayWidth  [expr { int ($movieWidth  * $gOpts(Zoom) / 100.0) }]
    set displayHeight [expr { int ($movieHeight * $gOpts(Zoom) / 100.0) }]
    set displayWidth  [expr { $displayWidth  - ($displayWidth  % $gOpts(Align)) }]
    set displayHeight [expr { $displayHeight - ($displayHeight % $gOpts(Align)) }]

    set numBytes [$videoObj Start $displayWidth $displayHeight]
    if { $numBytes < 0 } {
        puts [$videoObj GetErrorMessage]
        exit 1
    }

    set vectorObj [mawt Vector new $numBytes]

    set numFrames  [$videoObj GetNumFrames]
    set ffmpegFrameRate [$videoObj GetFramerate]
    set frameRate [expr int($ffmpegFrameRate + 0.5)]

    if { $numFrames < $gOpts(Frames) } {
        set gOpts(Frames) $numFrames
    }
    
    puts "MAWT version           : $gMawtVersion"
    puts "FFmpeg version         : [mawt GetFfmpegVersion]"
    puts "Movie file             : $movieFile"
    puts "Frame rate             : $frameRate"
    puts "Number of frames       : $numFrames"
    puts "Movie   (w x h)        : $movieWidth $movieHeight"
    puts ""
    puts "Display (w x h)        : $displayWidth $displayHeight"
    puts "Zoom factor (%)        : $gOpts(Zoom)"
    puts "Alignment              : $gOpts(Align)"
    puts "Display mode           : $gOpts(Mode)"
    puts "Display frames         : $gOpts(Frames)"
    puts ""
    
    set gContinuePlay $gOpts(Frames)

    set gStartTime [clock milliseconds]
    UpdateImg $videoObj $vectorObj $displayWidth $displayHeight $frameRate
}

proc UpdateImg { videoObj vectorObj tx ty fps } {
    global gContinuePlay gStartTime gOpts gSum

    # Grab next frame from video stream.
    set t1 [clock microseconds]
    $videoObj Lock
    $videoObj GetNextImage [$vectorObj Get] 0
    $videoObj Unlock
    set t2 [clock microseconds]
    set gSum(vid) [expr { $gSum(vid) + ($t2 - $t1)}]
   
    # Copy frame data into a Tcl bytearray.
    set t1 [clock microseconds]
    if { $gOpts(Mode) eq "create" || $gOpts(Mode) eq "put" } {
         set imgBinVar [$vectorObj ToByteArray [expr {3 * $tx * $ty}]]
    }
    set t2 [clock microseconds]
    set gSum(bin) [expr { $gSum(bin) + ($t2 - $t1)}]

    # Copy the Tcl bytearray into a photo image with the img::raw extension.
    set t1 [clock microseconds]
    if { $gOpts(Mode) eq "put" } {
        VideoFrame put $imgBinVar -format \
            "raw -nomap 1 -width $tx -height $ty -nchan 3 -useheader 0 -uuencode 0"
    } elseif { $gOpts(Mode) eq "create" } {
        catch { image delete VideoFrame }
        image create photo VideoFrame -data $imgBinVar -format \
            "raw -nomap 1 -width $tx -height $ty -nchan 3 -useheader 0 -uuencode 0"
    } elseif { $gOpts(Mode) eq "mawt" } {
        $vectorObj ToPhoto VideoFrame $tx $ty
    }
    set t2 [clock microseconds]
    set gSum(img) [expr { $gSum(img) + ($t2 - $t1)}]

    set t1 [clock microseconds]
    if { $gOpts(Mode) eq "create" } {
        .l configure -image VideoFrame
    }
    update
    set t2 [clock microseconds]
    set gSum(dis) [expr { $gSum(dis) + ($t2 - $t1)}]
   
    if { $gContinuePlay } {
        incr gContinuePlay -1
        after idle [list UpdateImg $videoObj $vectorObj $tx $ty $fps]
    } else {
        set endTime [clock milliseconds]
        set totalTime [expr $endTime - $gStartTime]
        set frameTime [expr $totalTime / double($gOpts(Frames))]
        puts [format "Time for %4d frames   : %6.2f sec" \
              $gOpts(Frames) [expr $totalTime / 1000.0]]
        puts [format "Time for    1 frame    : %6.2f msec"  $frameTime]
        puts [format "Time for    1 pixel    : %6.2f usec"  [expr $frameTime / $tx / $ty * 1000.0]]
        puts ""
        puts [format "Time for video decoding: %6.2f sec" [expr $gSum(vid) / 1.0E6]]
        puts [format "Time for bytearray     : %6.2f sec" [expr $gSum(bin) / 1.0E6]]
        puts [format "Time for photo image   : %6.2f sec" [expr $gSum(img) / 1.0E6]]
        puts [format "Time for display       : %6.2f sec" [expr $gSum(dis) / 1.0E6]]
        puts [format "Total time             : %6.2f sec" \
              [expr ($gSum(vid) + $gSum(bin) + $gSum(img) + $gSum(dis)) / 1.0E6]]
        puts ""
        puts [format "Faster than needed     : %6.2f times (%d fps)" \
              [expr 1000.0/$fps/$frameTime] \
              [expr int($gOpts(Frames) / ($totalTime / 1000.0) + 0.5)]]
    }
}

proc PrintUsage { prog } {
    global gOpts gModeList

    puts ""
    puts "Usage: $prog MovieFile \[Options\]"
    puts ""
    puts "Options:"
    puts "--mode <string>: Select image transfer mode. Default: $gOpts(Mode)"
    puts "                 Possible values: $gModeList"
    puts "--frames <int> : Number of frames to play. Default: $gOpts(Frames)"
    puts "--zoom <float> : Zoom factor in percent. Default: $gOpts(Zoom)"
    puts "--align <int>  : Align movie size to specified value. Default: $gOpts(Align)"
    exit 1
}

set gModeList [list "mawt" "create" "put"]

# Default values for command line options.
set gOpts(Auto)   false
set gOpts(Align)  8
set gOpts(Frames) 100
set gOpts(Zoom)   100
set gOpts(Mode)   [lindex $gModeList 0]
set gOpts(Movie)  [file join "Data" "640x464.mp4"]

set curArg 0
while { $curArg < $argc } {
    set curParam [lindex $argv $curArg]
    if { [string compare -length 1 $curParam "-"]  == 0 || \
         [string compare -length 2 $curParam "--"] == 0 } {
        set curOpt [string tolower [string trimleft $curParam "-"]]
        if { $curOpt eq "help" } {
            PrintUsage $argv0
        } elseif { $curOpt eq "mode" } {
            incr curArg
            set gOpts(Mode) [lindex $argv $curArg]
        } elseif { $curOpt eq "frames" } {
            incr curArg
            set gOpts(Frames) [lindex $argv $curArg]
        } elseif { $curOpt eq "zoom" } {
            incr curArg
            set gOpts(Zoom) [lindex $argv $curArg]
        } elseif { $curOpt eq "align" } {
            incr curArg
            set gOpts(Align) [lindex $argv $curArg]
        } else {
            puts "Unknown option \"$curParam\"."
            PrintUsage $argv0
        }
    } else {
        if { $curParam eq "auto" } {
            set gOpts(Auto) true
        } else {
            set gOpts(Movie) $curParam
        }
    }
    incr curArg
}

if { $gOpts(Frames) <= 0 } {
    set gOpts(Frames) 1
}
if { [lsearch $gModeList $gOpts(Mode)] < 0 } {
    puts "Wrong display mode: $gOpts(Mode)"
    PrintUsage $argv0
    exit 1
}
if { $gOpts(Zoom) <= 0 } {
    set gOpts(Zoom) 100
}

wm title . "mawt-speedTest"

label .l
pack .l

label .msg -text \
    [format "Using mawt %s on %s with Tcl %s-%dbit" \
    [package version mawt] $::tcl_platform(os) \
    [info patchlevel] [expr $::tcl_platform(pointerSize) * 8]]
pack .msg

bind . <Escape> { exit }

if { $gOpts(Mode) eq "put" || $gOpts(Mode) eq "mawt" } {
    # Create a photo image only once and attach it to the label.
    image create photo VideoFrame
    .l configure -image VideoFrame
}

set gSum(vid) 0.0
set gSum(bin) 0.0
set gSum(img) 0.0
set gSum(dis) 0.0

PlayMovie $gOpts(Movie)

if { $gOpts(Auto) } {
    update
    after 500
    exit
}
