@echo off
set SCRIPT=install-code.ps1

echo Running code.h installer...

:: Check if running as admin
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Requesting administrator privileges...
    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
     "Start-Process -FilePath 'powershell.exe' -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0%SCRIPT%\"' -Verb RunAs"
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0%SCRIPT%"
)

pause
