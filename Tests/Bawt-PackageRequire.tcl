# Copyright 2016-2024 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the BAWT framework regarding Tcl/Tk packages.
# Try to load all supported packages and print status onto stdout.

proc IgnoreForTcl9 { pkg } {
    set ignList [list \
    ]
    set ignFlag false
    if { [lindex [split [info tclversion] "."] 0] >=9 } {
        set ignFlag [expr [lsearch $ignList $pkg] >= 0]
    }
    return $ignFlag
}

proc InitPkgs { args } {
    foreach pkg $args {
        if { [IgnoreForTcl9 $pkg] } {
            puts [format "  %-20s: %-10s (%s)" $pkg "N/A" "Ignored for Tcl9"]
            continue
        }
        set retVal [catch {package require $pkg} version]
        set loaded [expr ! $retVal]
        if { $loaded } {
            puts [format "  %-20s: %-10s" $pkg $version]
        } else {
            puts [format "  %-20s: %-10s (%s)" $pkg "N/A" $version]
        }
    }
}

# Print basic information
parray tcl_platform
puts ""
puts "auto_path:"
foreach val $auto_path {
    puts "  $val"
}
puts ""

puts "Base Tcl and Tk packages:"
puts [format "  %-20s: %-10s" "Tcl" [info patchlevel]]
InitPkgs Tk itcl Thread sqlite3

puts "Compiled Tcl packages:"
InitPkgs compiler critcl DiffUtil fitstcl Memchan Mpexpr nacl nx \
         parse_args parser poMemory rl_json rtext tbcload tclcsv \
         tcllibc Tclx tdom Trf trofs tserialport udp vectcl vfs

puts "Compiled Tk packages:"
InitPkgs Img imgjp2 imgtools itk tkMuPDF mupdf::widget photoresize \
         poImg Tix tkdnd Tkhtml tkpath tksvg Tktable treectrl

puts "Pure Tcl/Tk packages:"
InitPkgs apave argp awthemes BWidget Iwidgets MaterialIcons mentry mqtt ooxml \
         pdf4tcl pgintcl publisher PuppyIcons ruff scrollutil shtmlview::shtmlview \
         thtmlview::thtmlview tablelist tclfpdf tkcon ukaz wcb WS::Client

puts "Some packages from tcllib and tklib:"
InitPkgs base64 jpeg struct textutil autoscroll

puts "Extended packages (need 3rd party libs):"
InitPkgs cffi Ffidl mawt pawt tclgd tls tzint

puts "Database packages (need 3rd party libs):"
InitPkgs tdbc tdbc::mysql tdbc::odbc tdbc::postgres tdbc::sqlite3 Oratcl

puts "Windows/Linux only packages:"
InitPkgs Canvas3d rbc snack tcl3d tclpy tko windetect tkwintrack

puts "Linux/Darwin only packages:"
InitPkgs Expect

puts "Windows only packages:"
InitPkgs cawt gdi hdc iocp printer shellicon tkribbon twapi winhelp

puts "Linux only packages:"
InitPkgs tcluvc

puts "Darwin only packages:"
InitPkgs addressbook tclAE Tclapplescript

exit
