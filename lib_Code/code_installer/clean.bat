@echo off
setlocal
title Uninstalling code.h...

echo ================================
echo   Starting code.h Uninstaller...
echo ================================
echo.

set "SCRIPT_NAME=uninstall-code.ps1"
set "ORIG_SCRIPT=%~dp0%SCRIPT_NAME%"
set "TEMP_SCRIPT=%TEMP%\uninstall-code-temp.ps1"
set "LOG=%TEMP%\code-uninstall-log.txt"

:: Clean old
del "%TEMP_SCRIPT%" >nul 2>&1
del "%LOG%" >nul 2>&1

:: Copy to temp
copy /Y "%ORIG_SCRIPT%" "%TEMP_SCRIPT%" >nul

:: Run uninstall as admin and log output
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%TEMP_SCRIPT%\" ^> \"%LOG%\" 2^>^&1' -Verb RunAs -WindowStyle Hidden"

:: Wait a bit to allow script to complete
timeout /t 2 >nul

echo.
echo ================================
echo    UNINSTALL LOG:
echo ================================
if exist "%LOG%" (
    type "%LOG%"
) else (
    echo No uninstall log found.
)
echo ================================

echo.
echo Finished uninstall process.
echo Press any key to exit...
pause >nul
