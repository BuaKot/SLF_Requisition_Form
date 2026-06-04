$repoRoot = Resolve-Path "$PSScriptRoot\.."
$serviceRoot = Join-Path $repoRoot "rust-captcha-service"
Set-Location $serviceRoot

function Test-CaptchaPort {
    try {
        $client = New-Object System.Net.Sockets.TcpClient
        $connect = $client.BeginConnect("127.0.0.1", 8787, $null, $null)
        $ready = $connect.AsyncWaitHandle.WaitOne(500)
        if (-not $ready) {
            $client.Close()
            return $false
        }
        $client.EndConnect($connect)
        $client.Close()
        return $true
    } catch {
        return $false
    }
}

if (Test-CaptchaPort) {
    Write-Host "SLF CAPTCHA service is already listening on http://127.0.0.1:8787"
    while ($true) {
        Start-Sleep -Seconds 60
    }
}

$cmdCargo = Join-Path $env:USERPROFILE ".cargo\bin\cargo.exe"
if (Test-Path $cmdCargo) {
    cmd.exe /c "`"$cmdCargo`" run"
    if ($LASTEXITCODE -eq 0) {
        exit 0
    }
}

cmd.exe /c "cargo run"
if ($LASTEXITCODE -eq 0) {
    exit 0
}

$fallbackRustc = "C:\tmp\slf-rustup\toolchains\stable-x86_64-pc-windows-msvc\bin\rustc.exe"
if (Test-Path $fallbackRustc) {
    $buildDir = Join-Path $repoRoot "target\rust-temp"
    $runtimeDir = Join-Path $repoRoot "target\captcha-runtime"
    New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
    New-Item -ItemType Directory -Path $runtimeDir -Force | Out-Null
    $env:TEMP = $buildDir
    $env:TMP = $buildDir
    $exeName = "slf_captcha_service_runtime_{0}.exe" -f (Get-Date -Format "yyyyMMddHHmmss")
    $exePath = Join-Path $runtimeDir $exeName
    & $fallbackRustc "src\main.rs" -o $exePath
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    & $exePath
    exit $LASTEXITCODE
}

$cargo = Get-Command cargo -ErrorAction SilentlyContinue
if ($cargo) {
    & $cargo.Source --version | Out-Null
    if ($LASTEXITCODE -eq 0) {
        & $cargo.Source run
        exit $LASTEXITCODE
    }
}

$fallbackCargo = "$env:USERPROFILE\.cargo\bin\cargo.exe"
if (Test-Path $fallbackCargo) {
    & $fallbackCargo --version | Out-Null
    if ($LASTEXITCODE -eq 0) {
        & $fallbackCargo run
        exit $LASTEXITCODE
    }
}

Write-Error "Rust is not ready. Install Rust with rustup, or fix cargo/rustc in PATH."
exit 1
