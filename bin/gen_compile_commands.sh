#!/bin/bash

set -e

cd ~/localbuilds
source ./build_env --no-shell "$1"

export SUBDIR_ENTER_STRING='make[1]: Entering directory "${CURDIR}${DIRSEP}${.TARGET:T:S|;|/|g}"'
export SUBDIR_LEAVE_STRING='make[1]: Leaving directory "${CURDIR}${DIRSEP}${.TARGET:T:S|;|/|g}"'

build -akin MAKEFILE_PASS=OBJECTS | tee build.log
compiledb -p build.log -o compile_commands.json --no-strict