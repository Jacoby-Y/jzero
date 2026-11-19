@echo off
rem JZero commands for cmd and PowerShell: runs zero.ps1 beside this file.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0zero.ps1" %*
