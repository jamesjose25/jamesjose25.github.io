# Source PreReqs

The Source PreReqs are a collection of libraries that IIB/ACE depends on but historically did not have ownership of the source code. The Source PreReqs comprises the following components:

* ICU - This is used for internationalisation and codepage conversions in ACE and a number of other dependencies. Source is not owned by ACE L3
* XML4C - IBM internal fork of the Xerces-C++ project, previously owned by another team. Now abandonware owned by ACE L3
* XLXP - IBM internal XML parser and validator, previously owned by another team. Now abandonware owned by ACE L3
* Node.js - The JavaScript runtime used by IIB/ACE. Source is not owned by ACE L3
* libevent - Event loop library used by the new HTTP listener framework in ACE. Soruce is not owned by ACE L3.

The Source PreReqs are built using `ant` wrapper builds that hides all the messy differences between the different build systems so that ACE engineers can easily build the various components. The source code for these components is stored in the `IB Source PreReqs` stream in the `EnterpriseConnectivity Service (Change Management)` project area:

![Screenshot showing the IB Source PreReqs stream in RTC](./images/ib_source_prereqs.png)

Each different prereq is stored in a separate component that matches its name. I recommend loading an IB Source PreReqs workspace into a subfolder called `src` of your desired sandbox location, for example I extract mine to `~/localbuilds/IBSPR/src` on UNIX and `C:\IBSPR\src` on Windows. When combined with the build scripts below, this ensures that the build output does not clutter up the sandbox folder and cause issues for RTC. A correctly loaded workspace should consist of the following folders

* `ibsourceprereqs_build`
* `icu`
* `libevent`
* `nodejs`
* `openssl`
* `xlxp`
* `xml4c`

To build one of the prereq components, copy either `build.sh` or `build.cmd` below into your sandbox folder and then run it as follows:

```
$ ./build.sh <STREAM> <COMPONENT>
```
where `STREAM` should be either S1000 for IIB v10 prereqs or S1100 for ACE v11/v12 prereqs, and `COMPONENT` should one of the prereq subdirectories (excluding `ibsourceprereqs_build`), e.g.
```
./build.sh S1100 icu
```
to build ICU for ACE v11/v12 or
```
./build.sh S1000 xlxp
```
to build XLXP for IIB v10.

## Linux/macOS/AIX build script
```
#!/bin/bash

if [ -z "$2" ]; then
    echo "Usage: $0 <S1000|S1100> component"
    exit 1
fi

TARGET_CODESTREAM="$1"
COMPONENT="$2"

if [ -z "$CONTEXT" ]; then
    echo ERROR: CONTEXT environment variable not set
    exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

export PATH="${SCRIPT_DIR}/ibsourceprereqs_build/build/apache-ant-1.9.4/bin:${PATH}"

if [ ! -d "${SCRIPT_DIR}/../obj/${CONTEXT}/logs" ]; then
    mkdir -p "${SCRIPT_DIR}/../obj/${CONTEXT}/logs"
fi

if [ ! -d "${SCRIPT_DIR}/../inst.images/${CONTEXT}/logs" ]; then
    mkdir -p "${SCRIPT_DIR}/../inst.images/${CONTEXT}/logs"
fi

export EXT_MAIN_SOURCE_ROOT="${SCRIPT_DIR}/ibsourceprereqs_build"

exec ant -f ibsourceprereqs_build/build/build.xml \
         -Drunning.from.automation=1 \
         "-Dbuild.location=${SCRIPT_DIR}/../obj/$CONTEXT" \
         "-Doutput.location=${SCRIPT_DIR}/../inst.images/$CONTEXT" \
         "-Dsource.location=${SCRIPT_DIR}" \
         "-Dtarget.ib.server.codestream=${TARGET_CODESTREAM}" \
         "-Dparallel.jobs=8" \
         "-Dplatform.odename=${CONTEXT}" \
         "-Dbuild.component=$COMPONENT"
```

## Windows build script
```
@echo off

set "PATH=%CD%\ibsourceprereqs_build\build\apache-ant-1.9.4\bin;%PATH%"

mkdir "%CD%\..\obj\%CONTEXT%\logs"
mkdir "%CD%\..\inst.images\%CONTEXT%\logs"

set CONTEXT=amd64_nt_4
set "EXT_MAIN_SOURCE_ROOT=%CD%\ibsourceprereqs_build"

ant -f ibsourceprereqs_build\build\build.xml -Drunning.from.automation=1 "-Dbuild.location=%CD%/../obj/%CONTEXT%" "-Doutput.location=%CD%/../inst.images/%CONTEXT%" "-Dsource.location=%CD%" "-Dtarget.ib.server.codestream=%~1" "-Dparallel.jobs=8" "-Dplatform.odename=%CONTEXT%" "-Dbuild.component=%~2"
```

# Dependencies between components

The components have interlinked dependencies on each other, you must build a component's prereqs before you can build the component itself. 

* For IIB v10 there are only 4 components that can be built, `icu`, `xml4c`, `xlxp`, and `nodejs` and the only dependency is that `icu` must be built before `xml4c`. 
* For ACE v11/v12 there are 5 components that can be built, `icu`, `xml4c`, `xlxp`, `nodejs`, and `libevent`. The dependency chains you must be aware of are:
    * `xml4c` depends on `icu`
    * `nodejs` depends on `icu`
    * `libevent` depends on `nodejs`
