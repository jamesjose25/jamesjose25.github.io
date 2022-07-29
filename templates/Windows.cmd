@echo off
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Edit these four values below
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: The full path to the Java SDK installation:
set "JAVA_HOME=C:\Program Files\IBM\Java80"
:: The full path to your installation of Strawberry Perl
set "PERL_HOME=C:\Strawberry\perl"
:: The full path to your MQ installation, this default is correct for MQ 9 but not earlier
set "MQ_HOME=C:\Program Files\IBM\MQ"
:: The build type you want, either D for development/debug builds or P for production builds
set "BTYPE=D"

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Do not edit below this line
::
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

:: We currently only support running on Windows for AMD64 processors. We may eventually want to run on Windows for ARM64
:: but for now we explicitly bail out if we're not on an AMD64 processor.
if "%PROCESSOR_ARCHITECTURE%"=="AMD64" set CONTEXT=amd64_nt_4
if not "%CONTEXT%"=="amd64_nt_4" (
	echo Only Windows on x86_64 is supported at this time.
	exit /B 1
)
set MACHINE=%CONTEXT%

:: ACE v11 and IIB v10 use different compiler versions, we need to find and read the version.properties file to determine
:: which compiler version is appropriate
if not exist "%BUILD_SANDBOX_DIR%\iib.version\version.properties" (
	echo Could not find the version.properties file, have you loaded the iib.version component to %BUILD_SANDBOX_DIR%\iib.version correctly?
	echo.
	goto Usage
)
for /F "tokens=1* delims==" %%A in (%BUILD_SANDBOX_DIR%\iib.version\version.properties) do (
	if "%%A"=="version_v" set "PRODUCT_VERSION=%%B"
	if "%%A"=="product_name_full" set "PRODUCT_NAME=%%B"
)

:: ACE v11 uses VS 2017 as standard
if "%VERSION_VRM%"=="11.0.0" (
	set MSVC_VERSION=2017
)
:: whereas IIB v10 uses VS 2013 as standard
if "%VERSION_VRM%"=="10.0.0" (
	set MSVC_VERSION=2013
)

:: Additionally the complier version can be overridden by the build.overrides file, for example at
:: IIB 10.0.0.22 and above since they require VS 2019
if exist "%BUILD_SANDBOX_DIR%\iib.version\build.overrides" (
	for /F "tokens=1* delims==" %%A in (%BUILD_SANDBOX_DIR%\iib.version\build.overrides) do (
		if "%%A"=="VS_VERSION" set "MSVC_VERSION=%%B"
	)
)

:: Now that we know the compiler version, find and run vcvarsall.bat.
setlocal
if "%MSVC_VERSION%" == "2019" (
    set "MSVC_VCVARSALL=C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\VC\Auxiliary\Build\vcvarsall.bat"
    set MQSI_WIN32_VS2019=1
)
if "%MSVC_VERSION%" == "2017" set "MSVC_VCVARSALL=C:\Program Files (x86)\Microsoft Visual Studio\2017\Professional\VC\Auxiliary\Build\vcvarsall.bat"
if "%MSVC_VERSION%" == "2013" set "MSVC_VCVARSALL=C:\Program Files (x86)\Microsoft Visual Studio 12.0\VC\vcvarsall.bat"
if "%MSVC_VCVARSALL%" == "" echo ERROR: MVSC_VERSION is not set to a known value, cannot determine which vcvarsall.bat to use & exit /b 1
endlocal & for /f "delims=" %%A in ("%MSVC_VCVARSALL%") do @(
	if exist "%%A" (
		set VCVARSALL=%%~sA
	) else (
		echo ERROR: Failed to find vcvarsall.bat - is Visual Studio %MSVC_VERSION% installed into the default location?
		exit /b 1
	)
)

:: Ensure we have the MQ includes and JNI includes available to us
set "INCLUDE=%MQ_HOME%\tools\c\include;%MQ_HOME%\tools\cplus\include;%JAVA_HOME%\include"
set LIB=
set LIBPATH=
set errorlevel=
:: Call vcvarsall to setup a Visual Studio command line environment
call %VCVARSALL% amd64
if %errorlevel% NEQ 0 echo Calling vcvarsall.bat failed! && exit /b 1

:: Some of our unit tests rely on PACKAGEBASE being set on Windows
set "PACKAGEBASE=%BUILD_SANDBOX_DIR%\WMB\inst.images\%CONTEXT%"

:: This tells the old ODE build system where to find its config file
set "SANDBOXRC=%BUILD_SANDBOX_DIR%\sandboxrc"

:: This disables the v10 webui unit tests that have never worked
set "SUPPRESS=webui_junit"

:: This block adds various tools to the PATH which we need
setlocal
set "MQSI_BUILD_PREREQ_PATH=%BUILD_SANDBOX_DIR%\MBBuildPreReqs"
set "ODE_PATH=%MQSI_BUILD_PREREQ_PATH%\ode\5.0_b2\amd64_nt_4"
set "ANT_BIN=%MQSI_BUILD_PREREQ_PATH%\ant\apache-ant-1.9.4\bin"
set "BLD_TOOLS=%MQSI_BUILD_PREREQ_PATH%\bldtools\amd64_nt_4"
endlocal & set "PATH=%ODE_PATH%;%ANT_BIN%;%JAVA_HOME%\bin;%PERL_BIN%;%BLD_TOOLS%;%PATH%"


:: I have no idea what this does but I feel like we need to keep it in
set CCVERSION=%VisualStudioVersion%%
if %CCVERSION% LSS 14.0 (
	set "TEMPVAR=C:\Program Files (x86)\Microsoft Visual Studio %CCVERSION%\VC\"
) else (
	set "TEMPVAR=C:\Program Files (x86)\Microsoft Visual Studio\Shared\14.0\VC\"
	rem set DISABLE_WARNINGS_AS_ERRORS=1
)
for /f "delims=" %%P in ("%TEMPVAR%") do set VSLIBROOT=%%~sP

goto :eof
:usage
@echo Usage: %0 ^<Path to RTC workspace^>
exit 1