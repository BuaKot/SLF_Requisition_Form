@echo off
cd /d "%~dp0..\rust-captcha-service"

where rustc >nul 2>nul
if errorlevel 1 (
  echo rustc.exe was not found in PATH.
  pause
  exit /b 1
)

rustc src\main.rs -o slf-captcha-service.exe
if errorlevel 1 (
  pause
  exit /b 1
)

slf-captcha-service.exe

:end
pause
