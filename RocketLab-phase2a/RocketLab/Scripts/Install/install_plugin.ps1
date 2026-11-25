# Copies RocketLab.dll into BakkesMod's plugins folder. Use -Uninstall to remove it.
param([switch]$Uninstall)
$ErrorActionPreference = 'Stop'

$plugins = Join-Path $env:APPDATA 'bakkesmod\bakkesmod\plugins'
$target = Join-Path $plugins 'RocketLab.dll'
$source = Join-Path $PSScriptRoot '..\..\BakkesModPlugin\build\vs2026\Release\RocketLab.dll'

if (-not (Test-Path $plugins)) {
    Write-Host "BakkesMod plugins folder not found: $plugins"
    exit 1
}

try {
    if ($Uninstall) {
        if (Test-Path $target) { Remove-Item $target }
        Write-Host "Removed $target"
    } else {
        if (-not (Test-Path $source)) {
            Write-Host 'No built DLL. Run Scripts\Build\build_plugin.ps1 first.'
            exit 1
        }
        Copy-Item $source $target -Force
        Write-Host "Installed $target"
        Write-Host 'In the BakkesMod console (F6) type: plugin load rocketlab'
    }
} catch {
    Write-Host "Failed: $($_.Exception.Message)"
    Write-Host 'If the game is running, type "plugin unload rocketlab" in the console and try again.'
    exit 1
}
