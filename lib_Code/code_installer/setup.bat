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

:: === CLEANUP OLD FILES
del "%TEMP_SCRIPT%" >nul 2>&1
del "%LOG%" >nul 2>&1

:: === COPY SCRIPT TO TEMP
copy /Y "%ORIG_SCRIPT%" "%TEMP_SCRIPT%" >nul

:: === RUN POWERHELL (ADMIN, VISIBLE)
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit','-NoProfile','-ExecutionPolicy Bypass','-File \"%TEMP_SCRIPT%\"'"

echo.
echo If the window closes immediately, run this script manually:
echo powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP_SCRIPT%"
echo.

pause
