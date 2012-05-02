@echo off

call build-paths

set ARGS=-DCPATH%DMD_DIR%\bin -T%OUT_FILE% -od%CD%\obj -full -D -Dd%CD%/docs standard.ddoc
set MODE_ARGS=-gui4.0 -release -inline -O

@echo on
%BUD_DIR%\bud -Xtango tango-user-dmd.lib %MAIN_FILE% cursors.res %ARGS% %MODE_ARGS%
@echo off
if errorlevel 1 goto end

rem Any other build tasks go here

:end
if not "%1" == "-nopause" pause
exit /B %ERRORLEVEL%

