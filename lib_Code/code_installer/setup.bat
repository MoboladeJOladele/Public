@echo off
setlocal
title Installing code.h globally...
echo Installing code.h, please wait...
echo.

:: === CONFIG ===
set "SCRIPT_NAME=install-code.ps1"
set "ORIG_SCRIPT=%~dp0%SCRIPT_NAME%"
set "TEMP_SCRIPT=%TEMP%\install-code-temp.ps1"
set "LOG=%TEMP%\code-install-log.txt"

:: === CLEANUP OLD
del "%TEMP_SCRIPT%" >nul 2>&1
del "%LOG%" >nul 2>&1

:: === COPY SCRIPT TO TEMP
copy /Y "%ORIG_SCRIPT%" "%TEMP_SCRIPT%" >nul

:: === RUN POWERSHELL WITH ADMIN AND SILENT WINDOW, LOGGING TO FILE
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%TEMP_SCRIPT%\" ^> \"%LOG%\" 2^>^&1' -Verb RunAs -WindowStyle Hidden"

:: === WAIT A MOMENT FOR COMPLETION
timeout /t 2 >nul

:: === DISPLAY OUTPUT FROM THE LOG FILE (IF ANY)
if exist "%LOG%" type "%LOG%"

:: === UNIVERSAL POST-INSTALL MESSAGE
echo.
echo Finished setup. If successful, you can now use:
echo     #include ^<code.h^>
echo     make hello

:: Extract actual install path
for /f "tokens=*" %%A in ('powershell -NoProfile -Command "Write-Output $env:ProgramData"') do set "PROGDATA=%%A"
set "HEADER_PATH=%PROGDATA%\lib_Code\code.h"

echo.
echo code.h installed to: %HEADER_PATH%
echo Accessible globally via INCLUDE path
echo.
echo Press any key to exit...
pause >nul
