#!/bin/bash

OUTROOTDIR="../BawtBuild"
NUMJOBS=`nproc`

usage () {
    echo ""
    echo "Usage: $1 Machine Bits SetupFile Action [Target1] [TargetN]"
    echo "  Machine       : intel arm riscv"
    echo "  Bits          : 32 64"
    echo "  Actions       : list clean extract configure compile distribute"
    echo "                  finalize complete update simulate touch test"
    echo "  Default target: all"
    echo ""
    echo "  Output directory: ${OUTROOTDIR}"
    echo ""
    echo "Specify variable TCLKIT on the command line to use a separate bootstrap program."
    echo "  Examples:"
    echo "  TCLKIT=tclsh ./Build-Linux.sh intel 64 Setup/Tcl_Basic.bawt update"
    echo "  TCLKIT=tclkit-Linux64-arm ./Build-Linux.sh arm 64 Setup/Tcl_Basic.bawt update"
    exit 1
}

if [ $# -le 3 ] ; then
    usage `basename $0`
fi

MACHINE=$1
BITS=$2
SETUPFILE=$3
ACTION="$4"
shift 4

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

if [ "${BITS}" == "64" ] ; then 
    ARCH=x64
fi
if [ "${BITS}" == "32" ] ; then
    ARCH=x86
fi
if [ -z "$ARCH" ] ; then
    usage `basename $0`
fi

if [ -z "$TCLKIT" ] ; then
    TCLKIT="./tclkit-Linux${BITS}-${MACHINE}"
fi

ACTION="--${ACTION}"

BAWTOPTS="--rootdir ${OUTROOTDIR} --architecture ${ARCH} --numjobs ${NUMJOBS}"

# Build all libraries as listed in Setup file.
${TCLKIT} Bawt.tcl ${BAWTOPTS} ${ACTION} ${SETUPFILE} ${TARGETS}

exit 0
