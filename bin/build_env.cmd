@echo off
set errorlevel=
goto :Main
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Script usage
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Usage
echo  Usage: .\BuildEnv SANDBOX [BTYPE [JAVA_HOME [MQ_HOME [PERL_HOME]]]]
echo.
echo  Initialise an IIB v10 or ACE v11 build environment in the current command prompt. SANDBOX must be the full path
echo  to the folder where an RTC workspace has been loaded without folders for root components, i.e. there should be
echo  sub folders called 'messages', 'IntegrationAPI', 'iib.version', and 'WMB'.
echo.
echo  By default this script will read the sandbox.config file to determine the Java home, Perl home, MQ home, and
echo  build type. These can be overridden on the command line in the order specified above. If these are not set
echo  in neither the sandbox.config file or on the command line then the corresponding environment variables values will
echo  be used.
echo.
exit /B 1

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: The vast majority of this script is dedicated to making saving and loading the required environment parameters
:: simple so that they only have to be specified once.
::
:: Jump down to the marker <END OF ARGUMENT PARSING> to see the actual sandbox setup logic.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:Main

set "BUILD_SANDBOX_DIR="

if "%1"=="" (
	echo Error: SANDBOX is required.
	echo.
	goto Usage
) else (
	set "BUILD_SANDBOX_DIR=%~f1"
)
if not exist %BUILD_SANDBOX_DIR%\NUL (
	echo Error: %BUILD_SANDBOX_DIR% is not a valid directory.
	echo.
	goto Usage
)

if "%2"=="" goto FinishedReadingCommandLineOptions
if "%2" neq "P" (
	if "%2" neq "D" (
		echo Error: BTYPE must be either P or D.
		echo.
		goto Usage
	)
)
set "BTYPE=%2"

if [%3]==[] goto FinishedReadingCommandLineOptions
set "JAVA_HOME=%~f3"

if [%4]==[] goto FinishedReadingCommandLineOptions
set "MQ_HOME=%~f4"

if "%5"=="" goto FinishedReadingCommandLineOptions
set "PERL_HOME=%~f5"

:FinishedReadingCommandLineOptions
call :ReadSandboxConfigFile
if ERRORLEVEL 1 exit /B %ERRORLEVEL%

if "%BTYPE%"=="" (
	echo Error: BTYPE is not defined.
	echo.
	goto Usage
)
if "%JAVA_HOME%"=="" (
	echo Error: JAVA_HOME is not specified.
	echo.
	goto Usage
)
if "%MQ_HOME%"=="" (
	echo Error: MQ_HOME is not specified.
	echo.
	goto Usage
)
if "%PERL_HOME%"=="" (
	echo Error: PERL_HOME is not specified.
	echo.
	goto Usage
)

echo   Sandbox root: %BUILD_SANDBOX_DIR%
echo          BTYPE: %BTYPE%
echo      JAVA_HOME: %JAVA_HOME%
echo        MQ_HOME: %MQ_HOME%
echo      PERL_HOME: %PERL_HOME%

echo BTYPE=%BTYPE% > "%BUILD_SANDBOX_DIR%\sandbox.config"
echo JAVA_HOME=%JAVA_HOME% >> "%BUILD_SANDBOX_DIR%\sandbox.config"
echo MQ_HOME=%MQ_HOME% >> "%BUILD_SANDBOX_DIR%\sandbox.config"
echo PERL_HOME=%PERL_HOME% >> "%BUILD_SANDBOX_DIR%\sandbox.config"

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: <END OF ARGUMENT PARSING>
::
:: Now that we have the BTYPE, JAVA_HOME, MQ_HOME, and PERL_HOME variables set, we can derive the rest of the
:: configuration from the sandbox.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

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

echo.
echo        Product: %PRODUCT_NAME% v%PRODUCT_VERSION%

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

echo       Compiler: Microsoft Visual Studio %MSVC_VERSION%
echo.

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

:: ODE sets a SOURCEBASE environment variable like PACKAGEBASE which is
:: also used by some scripts to determine where WMB/src is
set "SOURCEBASE=%BUILD_SANDBOX_DIR%\WMB\src"

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

:: Now that ODE is on the path we can create the sandboxrc file if it is missing
if not exist "%SANDBOXRC%" (
    mkbb -dir "%BUILD_SANDBOX_DIR%" -m "%CONTEXT%" WMB
)


:: I have no idea what this does but I feel like we need to keep it in
set CCVERSION=%VisualStudioVersion%%
if %CCVERSION% LSS 14.0 (
	set "TEMPVAR=C:\Program Files (x86)\Microsoft Visual Studio %CCVERSION%\VC\"
) else (
	set "TEMPVAR=C:\Program Files (x86)\Microsoft Visual Studio\Shared\14.0\VC\"
	rem set DISABLE_WARNINGS_AS_ERRORS=1
)
for /f "delims=" %%P in ("%TEMPVAR%") do set VSLIBROOT=%%~sP

:: Change directory to the WMB\src folder for convenience
cd %BUILD_SANDBOX_DIR%\WMB\src
echo.
echo Build environment ready.

:: Call setreloc for convenience if the devprofile.cmd file exists
if exist "%BUILD_SANDBOX_DIR%\WMB\obj\%CONTEXT%\profiles\devprofile.cmd" (
	.\setreloc.cmd C:\ProgramData\IBM\MQSI "%BUILD_SANDBOX_DIR%\WMB"
)

goto :EOF

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Read the sandbox.config file, if it exists, and load any missing options from it
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:ReadSandboxConfigFile
if exist "%BUILD_SANDBOX_DIR%\sandbox.config" (
	for /F "tokens=1* delims==" %%A in (%BUILD_SANDBOX_DIR%\sandbox.config) do (
		if "%%A"=="JAVA_HOME" (
			if "%JAVA_HOME%"=="" set "JAVA_HOME=%%B"
		)
		if "%%A"=="MQ_HOME" (
			if "%MQ_HOME%"=="" set "MQ_HOME=%%B"
		)
		if "%%A"=="PERL_HOME" (
			if "%PERL_HOME%"=="" set "PERL_HOME=%%B"
		)
		if "%%A"=="BTYPE" (
			if "%BTYPE%"=="" set "BTYPE=%%B"
		)
	)
)
exit /B 0

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check that the given variable is defined or issue an error and exit
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CheckVariable
if not defined %~1 (
	echo %~2
	echo.
	goto Usage
	exit /B 1
)
if "%%%~1_SOURCE%%"=="" set "%~1_SOURCE=environment variable"
exit /B 0


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Check that the BTYPE value is correct
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:CheckBTYPE
if "%BTYPE%"=="" (
	echo A BTYPE of either P or D must be specified.
	echo.
	goto Usage
	exit /B 1
)
if "%BTYPE%" neq "P" (
	if "%BTYPE%" neq "D" (
		echo A BTYPE of either P or D must be specified.
		echo.
		goto Usage
		exit /B 1
	)
)
exit /B 0