#!/bin/sh

if [ $# -le 1 ] ; then
    echo ""
    echo "Usage: `basename $0` SetupFile Action [Target1] [TargetN]"
    echo "  Actions       : list clean extract configure compile distribute finalize complete update simulate touch"
    echo "  Default target: all"
    echo ""
    exit 1
fi

SETUPFILE=$1
ACTION="$2"
shift 2

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
OUTROOTDIR="../BawtBuild"
TCLKIT="./tclkit-Darwin64"
NUMJOBS=4
ACTION="--${ACTION}"

BAWTOPTS="--rootdir ${OUTROOTDIR} --architecture ${ARCH} --numjobs ${NUMJOBS}"
LIBOPTS="--copt tcllib Critcl=OFF"

# Build all libraries as listed in Setup file.
${TCLKIT} Bawt.tcl ${BAWTOPTS} ${LIBOPTS} ${ACTION} ${SETUPFILE} ${TARGETS}

exit 0
