#!/bin/bash

######################################################################
# Parts you need to configure
######################################################################

# Choose P or D here for a production or debug build respectively
export BTYPE=P

# The full path to where you extracted the Java SDK, the Java binary
# should be at $JAVA_HOME/bin/java
export JAVA_HOME="/full/path/to/java"

# The full path to your loaded RTC workspace, i.e. the one containing
# the messages, IntegrationAPI, and WMB directories
export BUILD_SANDBOX_DIR="/full/path/to/rtc/extract"

# These are extra flags to pass to the compiler. You will only need
# to keep this if your distribution is Ubuntu 16.04 or later.
# You'll know if you need these if you can't compile
#   WMB/src/DataFlowEngine/ImbRdl/ImbXPathFunctionTable.cpp
export CFLAGS="-DUBUNTU16 $CFLAGS"
export CXXFLAGS="$CFLAGS"

######################################################################
# The rest is inferred from the details given above
######################################################################

# Auto detect the ODE context for the current machine
UNAME=$(uname)
UNAME_M=$(uname -m)

case "${UNAME}/${UNAME_M}" in
Linux/x86_64)
    export CONTEXT="amd64_linux_2"
    ;;
Linux/ppc64)
    export CONTEXT="ppc_linux_2"
    ;;
Linux/ppc64le)
    export CONTEXT="ppcle_linux_2"
    ;;
Linux/s390x)
    export CONTEXT="s390x_linux_2"
    ;;
AIX/*)
    export CONTEXT="rios_aix_4"
    ;;
SunOS/sparc)
    export CONTEXT="sparc_solaris_2"
    ;;
SunOS/i386)
    export CONTEXT="amd64_solaris_2"
    ;;
HP-UX/ia64)
    export CONTEXT="ia64_hpux_11"
    ;;
Darwin/x86_64)
    export CONTEXT="amd64_macos_x"
    ;;
*)
    echo "ERROR: Unknown platform/CPU type combination: ${UNAME}/${UNAME_M}"
    return 1
    ;;
esac

# These are also used by the build system for some reason
export MACHINE=$CONTEXT
export PLATFORM=$CONTEXT

# Some old parts of the build system apparently need us to define this
# despite this path not having changed in a long time
export PACKAGEBASE="$BUILD_SANDBOX_DIR/WMB/inst.images/$CONTEXT"

# This tries to prevent the build system from scrambling the compiler
# output too badly
export MAKEJOBBUFFERING=99

# You almost certainly want to force the build system to use bash
# rather than ksh as the default shell. Don't be fancy and try to
# change this to something better than bash (zsh, fish, etc.) as
# they won't work :(
export ODEMAKE_SHELL="/bin/bash -c"

# This is the path to the folder containing the ODE libraries and
# build executables, we do it via find as the precise location
# varies based on which CPU you are using
export ODE_DIR=`find $BUILD_SANDBOX_DIR/MBBuildPreReqs/ode -type d -path "*$CONTEXT*" | tail -n 1`

# Ant is used to build Java related parts of the product. We need to
# use the version we bundle in tree, rather than any version your
# OS may already have installed
export ANT_HOME="$BUILD_SANDBOX_DIR/MBBuildPreReqs/ant/apache-ant-1.9.4"

# We need to add ODE, Java and Ant to the executable path, and
# ODE to the library path
if ! [ "${CONTEXT}" = "amd64_macos_x" ]; then
    export LD_LIBRARY_PATH="${ODE_DIR}:${LD_LIBRARY_PATH}"
fi
export PATH="$ANT_HOME/bin:$ODE_DIR:$JAVA_HOME/bin:$PATH"
export PATH="${BUILD_SANDBOX_DIR}/WMB/src/build:${PATH}"

# This will disable the v10 WebUI unit tests from running during
# the WebUI build as they are completely broken
export SUPPRESS="webui_junit"

# This skips building the Db2 switch files. If you need these
# then you need to install Db2, set the envvar DB2_HOME to the
# full path to the Db2 installation location, and comment out
# the line below.
export SUPPRESS_DB2=YES

# This tells the build system where it should look for our
# sandboxrc file
export SANDBOXRC="$BUILD_SANDBOX_DIR/sandboxrc"
