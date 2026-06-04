$scriptPath = Resolve-Path "$PSScriptRoot\run-captcha-service.ps1"
cmd.exe /c start "SLF CAPTCHA Service" powershell -NoExit -ExecutionPolicy Bypass -File "`"$scriptPath`""
