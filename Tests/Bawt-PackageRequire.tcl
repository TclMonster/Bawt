# Copyright 2016-2023 Paul Obermeier (obermeier@tcl3d.org)
#
# Test program for the BAWT framework regarding Tcl/Tk packages.
# Try to load all supported packages and print status onto stdout.

proc InitPkgs { args } {
    foreach pkg $args {
        set retVal [catch {package require $pkg} version]
        set loaded [expr ! $retVal]
        if { $loaded } {
            puts [format "  %-20s: %-10s" $pkg $version]
        } else {
            puts [format "  %-20s: %-10s (%s)" $pkg "N/A"  $version]
        }
    }
}

# Print basic information
parray tcl_platform
puts ""
puts "auto_path = $auto_path"
puts ""

puts "Base Tcl and Tk packages:"
puts [format "  %-20s: %-10s" "Tcl" [info patchlevel]]
InitPkgs Tk itcl sqlite3 tdbc Thread

puts "Compiled Tcl packages:"
InitPkgs compiler critcl DiffUtil fitstcl Memchan Mpexpr nacl nx Oratcl \
         parse_args parser rl_json tbcload tclcsv tcllibc Tclx tdom \
         Trf trofs tserialport udp vectcl vfs

puts "Compiled Tk packages:"
InitPkgs Img imgjp2 imgtools itk tkMuPDF mupdf::widget photoresize \
         poImg Tix tkdnd Tkhtml tksvg Tktable treectrl

puts "Pure Tcl/Tk packages:"
InitPkgs apave argp awthemes BWidget Iwidgets MaterialIcons mentry mqtt ooxml \
         pdf4tcl pgintcl PuppyIcons ruff scrollutil shtmlview::shtmlview \
         tablelist tclfpdf tkcon ukaz wcb WS::Client

puts "Some packages from tcllib and tklib:"
InitPkgs base64 jpeg textutil autoscroll

puts "Extended packages (need 3rd party libs):"
InitPkgs cffi Ffidl mawt pawt tclgd tls tzint

puts "Windows/Linux only packages:"
InitPkgs Canvas3d rbc snack tcl3d tclpy tkpath windetect tkwintrack

puts "Linux/Darwin only packages:"
InitPkgs Expect

puts "Windows only packages:"
InitPkgs cawt gdi hdc iocp printer shellicon twapi winhelp

puts "Darwin only packages:"
InitPkgs addressbook tclAE Tclapplescript

exit
