@echo off
setlocal
cd /d "%~dp0"

wscript.exe //B "%~dp0START_JEV_ROUTER.vbs"
exit /b 0
