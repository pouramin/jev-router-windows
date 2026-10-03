@echo off
setlocal
cd /d "%~dp0"

if exist "%~dp0src\JevRouter.exe" (
  start "" "%~dp0src\JevRouter.exe"
  exit /b 0
)

start "Jev Router" powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0src\JevRouter.ps1"
exit /b 0
