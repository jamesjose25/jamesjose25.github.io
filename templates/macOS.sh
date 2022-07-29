#!/bin/bash

######################################################################
# Parts you need to configure
######################################################################

# Choose P or D here for a production or debug build
export BTYPE=P

# The full path to where you extracted the Java SDK, the Java binary
# should be at $JAVA_HOME/bin/java
export JAVA_HOME=/full/path/to/java

# The full path to your loaded RTC workspace, i.e. the one containing
# the messages, IntegrationAPI, and WMB directories
export BUILD_SANDBOX_DIR=/full/path/to/rtc/extract

# This tells the build system what CPU and OS you are building on,
# the only supported value for macOS is amd64_macos_x for x64 CPUs
export CONTEXT=amd64_macos_x


######################################################################
# The rest is inferred from the details given above
######################################################################

# These are also used by the build system for some reason
export MACHINE=$CONTEXT
export PLATFORM=$CONTEXT

# Some old parts of the build system apparently need us to define this
# despite this path not having changed in a long time
export PACKAGEBASE="$BUILD_SANDBOX_DIR/WMB/inst.images/$CONTEXT"

# This tries to prevent the build system from scrambling the compiler
# output too badly
export MAKEJOBBUFFERING=99

# This is the path to the folder containing the ODE libraries and
# build executables, we do it via find as the precise location
# varies based on which CPU you are using
export ODE_DIR=`find $BUILD_SANDBOX_DIR/MBBuildPreReqs/ode -type d -path "*$CONTEXT*" | tail -n 1`

# Ant is used to build Java related parts of the product. We need to
# use the version we bundle in tree, rather than any version your
# OS may already have installed
export ANT_HOME="$BUILD_SANDBOX_DIR/MBBuildPreReqs/ant/apache-ant-1.9.4"

# We need to add ODE, Java and Ant to the executable path
export PATH="$ANT_HOME/bin:$ODE_DIR:$JAVA_HOME/bin:$PATH"

# This will disable the v10 WebUI unit tests from running during
# the WebUI build as they are completely broken
export SUPPRESS="webui_junit"

# This tells the build system where it should look for our
# sandboxrc file
export SANDBOXRC="$BUILD_SANDBOX_DIR/sandboxrc"