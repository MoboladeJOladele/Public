@echo off
setlocal
title Uninstalling code.h from Windows...
echo Uninstalling code.h, please wait...
echo.

:: Auto-elevate if not admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting admin permissions...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: === CONFIG ===
set "PROGDATA=%ProgramData%"
set "TARGET_DIR=%PROGDATA%\lib_Code"
set "HEADER_FILE=%TARGET_DIR%\code.h"
set "INCLUDE_VAR=INCLUDE"

:: === Delete header file
if exist "%HEADER_FILE%" (
    del "%HEADER_FILE%" >nul 2>&1
    echo Removed code.h
)

:: === Delete directory
if exist "%TARGET_DIR%" (
    rmdir /S /Q "%TARGET_DIR%" >nul 2>&1
    echo Removed %TARGET_DIR%
)

:: === Remove path from INCLUDE
for /f "tokens=*" %%I in ('powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('%INCLUDE_VAR%', 'Machine')"') do set "INCLUDE=%%I"

echo %INCLUDE% | find /i "%TARGET_DIR%" >nul
if %errorlevel%==0 (
    powershell -NoProfile -Command "[Environment]::SetEnvironmentVariable('%INCLUDE_VAR%', ($env:%INCLUDE_VAR% -replace [regex]::Escape('%TARGET_DIR%;?'), ''), 'Machine')"
    echo Removed %TARGET_DIR% from INCLUDE path
)

:: === Final message
echo.
echo Uninstallation complete.
echo Press any key to exit...
pause >nul
