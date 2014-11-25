#!/bin/bash
ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$ROOT/../../"
RES_DIR="measures"
export LD_BIND_NOW=1

# Check number of arguments
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "usage: $0 [BENCH_DIR] BINARY_CMD COMPILE_CMD"
    echo "If [BENCH_DIR] not given, this will test the current working directory"
    exit 1
fi

if [ $# -eq 2 ] ; then
    BENCH_DIR=${PWD}
else
    BENCH_DIR=$(readlink -f $1) # convert BENCH_DIR to absolute path
    shift
fi
BIN_CMD=$1
COMPILE_CMD=$2

cd $BENCH_DIR 2> /dev/null
if [ "$?" != "0" ] ; then
    echo "Could not change directory to $BENCH_DIR" > /dev/stderr
    exit 1
fi

#1) Create measures and plots folder
# if there is already a measure dir, backup it
# and creates a new one.
if [[ -d $RES_DIR ]]
then
    rm -f regions.csv *.html *_log realmain.c out dump_generation
    echo "Keeping previous coverage results"
    exit 0
else
    mkdir $RES_DIR
fi


#2) Measure application cycles
make clean && rm -f *.ll
${COMPILE_CMD} MODE="original --instrument"
eval ${BIN_CMD}
if [[ ! -f rdtsc_result.csv ]]; then
    error="\tMeasuring application failed!\n"
else
    mv rdtsc_result.csv $RES_DIR/app_cycles.csv
fi

if [[ ! -z $warning ]]
then
    echo "Warning, you may have wrong results because:"
    echo -e $warning
    echo -e $warning >  ${RES_DIR}/warning
fi
if [[ ! -z $error ]]
then
    echo "Error, can't compute coverage and/or matching because:"
    echo -e $error
    echo -e $error >  ${RES_DIR}/error
    rm -rf $RES_DIR
    exit 1
else
    exit 0
fi
