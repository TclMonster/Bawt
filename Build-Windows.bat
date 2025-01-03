@echo off
setlocal

rem Default values for some often used options.
set OUTROOTDIR=../BawtBuild
set NUMJOBS=%NUMBER_OF_PROCESSORS%

rem First 5 parameters are mandatory.
if "%1" == "" goto ERROR
if "%2" == "" goto ERROR
if "%3" == "" goto ERROR
if "%4" == "" goto ERROR
if "%5" == "" goto ERROR

set MACHINE=%1
set BITS=%2
set COMPILER=%3
set SETUPFILE=%4
set ACTION=%5
shift
shift
shift
shift
shift

rem If no target is given, use target "all".
if "%1"=="" goto BUILDALL

rem Loop through the rest of the parameter list for targets.
set TARGETS=
:PARAMLOOP
rem There is a trailing space in the next line. It's there for formatting.
set TARGETS=%TARGETS%%1 
shift
if not "%1"=="" goto PARAMLOOP
goto BUILD

:BUILDALL
if "%ACTION%"=="clean"    goto WARNING
if "%ACTION%"=="complete" goto WARNING

set TARGETS=all

:BUILD

if "%BITS%"=="32" set ARCH=x86
if "%BITS%"=="64" set ARCH=x64
if "X%ARCH%"=="X" goto ERROR

if "X%TCLKIT%"=="X" set TCLKIT=tclkit-win32-intel.exe

set ACTION=--%ACTION%
set BAWTOPTS=--rootdir %OUTROOTDIR% ^
             --architecture %ARCH% ^
             --compiler %COMPILER% ^
             --numjobs %NUMJOBS% ^
             --logviewer

rem Build all libraries as listed in Setup file.
CALL %TCLKIT% Bawt.tcl %BAWTOPTS% %ACTION% %SETUPFILE% %TARGETS%

goto EOF

:WARNING
echo Warning: This may clean or rebuild everything.
echo Use "clean all" or "complete all" to allow this operation.

:ERROR
echo.
echo Usage: %0 Machine Bits Compiler SetupFile Action [Target1] [TargetN]
echo   Machine         : intel
echo   Bits            : 32 64
echo   Compiler        : gcc vs2013 vs2015 vs2017 vs2019 vs2022
echo                     gcc+vs20XX vs20XX+gcc
echo   Actions         : list clean extract configure compile distribute
echo                     finalize complete update simulate touch test
echo   Default target  : all
echo.
echo   Output directory: %OUTROOTDIR%
echo.
echo Specify variable TCLKIT on the command line to use a separate bootstrap program.
echo   Example:
echo   set TCLKIT=tclsh ^&^& Build-Windows.bat intel 64 gcc Setup\Tcl_Basic.bawt update
echo.
:EOF
