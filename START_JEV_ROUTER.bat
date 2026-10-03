@echo off
setlocal
cd /d "%~dp0"

start "Jev Router" powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0src\JevRouter.ps1"
exit /b 0
