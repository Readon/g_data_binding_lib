#!/bin/sh

# This script is convenience run when library is not installed in order to
# make demo and tutorial as accessible as possible

# Temporary hack
export LD_LIBRARY_PATH=../..

# Temporary hack as I don't really have time to play with embedding resources
# right now
DIR=`pwd`
cd ./demos/demo_and_tutorial/
./demo_and_tutorial
cd "$DIR"
