# Rocket Lab: reports which build tools are installed. Changes nothing.
$ErrorActionPreference = 'Continue'

function Report($name, $phase, $found, $detail) {
    $mark = 'MISSING'
    if ($found) { $mark = 'OK     ' }
    Write-Host ("{0} Phase {1}  {2}  {3}" -f $mark, $phase, $name, $detail)
}

function Get-ToolOutput($command, $arguments) {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) { return $null }
    return (& $command $arguments 2>$null)
}

# Visual Studio 2022 with the C++ tools
$vsPath = $null
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
if (Test-Path $vswhere) {
    $vsPath = & $vswhere -latest -products * -version '[17.0,18.0)' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
}
Report 'Visual Studio 2022 C++ tools' 2 ([bool]$vsPath) $vsPath

# CMake: on PATH, or the copy bundled with Visual Studio
$cmake = (Get-Command cmake -ErrorAction SilentlyContinue).Source
if (-not $cmake -and $vsPath) {
    $bundled = Join-Path $vsPath 'Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
    if (Test-Path $bundled) { $cmake = $bundled }
}
Report 'CMake' 2 ([bool]$cmake) $cmake

# BakkesMod SDK shipped with BakkesMod
$sdk = Join-Path $env:APPDATA 'bakkesmod\bakkesmod\bakkesmodsdk'
$header = Join-Path $sdk 'include\bakkesmod\plugin\bakkesmodsdk.h'
$api = ''
if (Test-Path $header) {
    $match = Select-String -Path $header -Pattern 'define\s+BAKKESMOD_PLUGIN_API_VERSION\s+(\d+)'
    if ($match) { $api = "API version $($match.Matches[0].Groups[1].Value) at $sdk" }
}
Report 'BakkesMod SDK' 2 (Test-Path $header) $api

$dotnet = Get-ToolOutput 'dotnet' '--list-sdks' | Where-Object { $_ -match '^10\.' } | Select-Object -Last 1
Report '.NET 10 SDK' 3 ([bool]$dotnet) $dotnet

$rust = Get-ToolOutput 'rustc' '--version'
$rustOk = $false
if ($rust -match 'rustc (\d+\.\d+\.\d+)') { $rustOk = [version]$Matches[1] -ge [version]'1.88.0' }
Report 'Rust 1.88 or newer' 6 $rustOk $rust

$node = Get-ToolOutput 'node' '--version'
$nodeOk = $false
if ($node -match 'v(\d+)\.') { $nodeOk = [int]$Matches[1] -ge 22 }
Report 'Node.js 22 or newer' 7 $nodeOk $node

Write-Host ''
Write-Host 'Only Phase 2 items are needed right now.'
