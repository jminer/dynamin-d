@echo off

call build-debug -nopause
if errorlevel 1 goto end

@echo on
%OUT_FILE%
@echo off

:end
if not "%1" == "-nopause" pause
exit /B %ERRORLEVEL%

