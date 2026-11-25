# Configures, builds and tests the Rocket Lab plugin with Visual Studio 2026.
# The full output is also saved to BakkesModPlugin\build\build_log.txt
$ErrorActionPreference = 'Continue'

$plugin = Join-Path $PSScriptRoot '..\..\BakkesModPlugin'
$buildDir = Join-Path $plugin 'build'

$cmake = (Get-Command cmake -ErrorAction SilentlyContinue).Source
if (-not $cmake) {
    Write-Host 'cmake was not found on PATH. Open a new PowerShell window and try again.'
    exit 1
}
$ctest = Join-Path (Split-Path $cmake) 'ctest.exe'

New-Item -ItemType Directory -Force -Path $buildDir | Out-Null
$buildDir = (Resolve-Path $buildDir).Path
$log = Join-Path $buildDir 'build_log.txt'
Set-Content -Path $log -Value "Rocket Lab plugin build $(Get-Date -Format s)" -Encoding Unicode

function Invoke-Step($title, $exe, $arguments) {
    Write-Host "== $title"
    & $exe @arguments 2>&1 | ForEach-Object { "$_" } | Tee-Object -FilePath $log -Append | Out-Host
    if ($LASTEXITCODE -ne 0) {
        Write-Host ''
        Write-Host "FAILED at: $title"
        Write-Host "Send me this file: $log"
        Pop-Location
        exit 1
    }
}

Push-Location $plugin
Invoke-Step 'Configure' $cmake @('--preset', 'vs2026')
Invoke-Step 'Build' $cmake @('--build', '--preset', 'release')
Invoke-Step 'Unit tests' $ctest @('--preset', 'release')
Pop-Location

$dll = Join-Path $buildDir 'vs2026\Release\RocketLab.dll'
if (-not (Test-Path $dll)) {
    Write-Host "Build finished but the DLL is missing: $dll"
    exit 1
}
Write-Host ''
Write-Host "SUCCESS: $dll"
