@if not defined ECHO_ON @echo off
setlocal EnableDelayedExpansion

set OldResults=
set NewResults=

:ArgLoop

if /i "%~1" == "" (
    goto DoneParsing
)

if /i "%~1" == "-o" (
    set "OldResults=%~2"
    shift
)

if /i "%~1" == "-n" (
    set "NewResults=%~2"
    shift
)

if /i "%~1" == "-?" goto Help
if /i "%~1" == "-h" goto Help
if /i "%~1" == "--help" goto Help

shift
goto :ArgLoop

:Help

echo Usage: cmp -o [old results] -n [new results]
exit 1

:Error

:: Note: echo doesn't set ERRORLEVEL. It's a builtin.
echo Something went wrong.
exit !ERRORLEVEL!

:DoneParsing

:: Read in both of the files to variables.

set OldContents=
set NewContents=

for /f "delims=" %%C in ('type !OldResults!') do set "OldContents=%%C"
for /f "delims=" %%C in ('type !NewResults!') do set "NewContents=%%C"

:: Count the number of lines in each variable. They should be the same.

set Lines=

for /f %%L in ('echo ^!OldContents^! ^| find /c /v ""') do set "Lines=%%L"
for /f %%L in ('echo ^!NewContents^! ^| find /c /v ""') do (
    if %%L neq !Lines! goto Error
)

:: Read through each of those variables line-by-line.

for /l %%L in (1, 1, !Lines!) do (
    set OldLine=
    set NewLine=

    %= Gave up here. I have no idea how to get the nth line... =%
)
