#!/bin/sh

OUTROOTDIR="../BawtBuild"
NUMJOBS=`sysctl -n hw.ncpu`

usage () {
    echo ""
    echo "Usage: `basename $0` Machine SetupFile Action [Target1] [TargetN]"
    echo "  Machine       : native universal"
    echo "  Actions       : list clean extract configure compile distribute"
    echo "                  finalize complete update simulate touch test"
    echo "  Default target: all"
    echo ""
    echo "  Output directory: ${OUTROOTDIR}"
    echo ""
    echo "Specify variable TCLKIT on the command line to use a separate bootstrap program."
    echo "  Examples:"
    echo "  TCLKIT=tclsh ./Build-Darwin.sh intel Setup/Tcl_Basic.bawt update"
    echo "  TCLKIT=tclkit-Darwin64 ./Build-Darwin.sh arm Setup/Tcl_Basic.bawt update"
    exit 1
}

if [ $# -le 2 ] ; then
    usage `basename $0`
fi

MACHINE=$1
SETUPFILE=$2
ACTION="$3"
shift 3

if [ $# -eq 0 ] ; then
    if [ "${ACTION}" == "clean" ] ; then
        echo "Warning: This may clean everything. Use \"clean all\" to allow this operation."
        exit 1
    fi
    if [ "${ACTION}" == "complete" ] ; then
        echo "Warning: This may rebuild everything. Use \"complete all\" to allow this operation."
        exit 1
    fi
    TARGETS=all
else
    TARGETS=$@
fi

ARCH=x64

if [ -z "$TCLKIT" ] ; then
    TCLKIT="./tclkit-Darwin64"
fi

ACTION="--${ACTION}"

UNIVERSALOPTS=""
if [ "${MACHINE}" == "universal" ] ; then
    UNIVERSALOPTS="--universal"
fi
BAWTOPTS="--rootdir ${OUTROOTDIR} --architecture ${ARCH} --numjobs ${NUMJOBS}"

# Build all libraries as listed in Setup file.
${TCLKIT} Bawt.tcl ${BAWTOPTS} ${UNIVERSALOPTS} ${ACTION} ${SETUPFILE} ${TARGETS}

exit 0
