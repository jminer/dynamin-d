@echo off

call build-paths

set ARGS=-allinst -of%OUT_FILE% -od%CD%\obj -D -Dd%CD%\docs -I%TANGO_DIR% %TANGO_DIR%\libtango-dmd.lib cursors.res -L/EXETYPE:NT -L/SUBSYSTEM:WINDOWS:4.0
set MODE_ARGS=-release -inline -O

@echo on
%DMD_DIR%\windows\bin\rdmd --build-only %ARGS% %MODE_ARGS% %MAIN_FILE% standard.dd
@echo off
if errorlevel 1 goto end

rem Any other build tasks go here

:end
if not "%1" == "-nopause" pause
exit /B %ERRORLEVEL%

