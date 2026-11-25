# Phase 1: what to check on your PC

Unzip so that you have, for example, `C:\Dev\RocketLab\README.md`.

## 1. Tools (required before Phase 2)

Open PowerShell in `C:\Dev\RocketLab` and run:

    powershell -ExecutionPolicy Bypass -File .\Scripts\Development\check_environment.ps1

This script has **not been run on Windows yet**. If it errors, send me the whole output.

For Phase 2 you need:
- Visual Studio 2022 with the workload **Desktop development with C++** (includes CMake).
  If you only have a newer Visual Studio, tell me; the script looks for 2022 specifically.
- BakkesMod from https://bakkesmod.com, run once so that it installs its SDK

## 2. The game (required before Phase 2)

1. Start BakkesMod, then launch Rocket League **without Easy Anti-Cheat**.
   On Epic, one reported route is: Library, right-click Rocket League,
   "Launch without Anti-Cheat". Check your own launcher's options if it differs.
2. Enter Free Play.
3. Press F6 to open the BakkesMod console and confirm it appears.

If step 3 fails, stop here: the plugin cannot work until BakkesMod does.

## 3. Optional: rerun my checks (needs Python 3.10+)

    pip install jsonschema
    python .\Scripts\Development\validate_phase1.py
    python .\Scripts\Development\verify_sdk_symbols.py "$env:APPDATA\bakkesmod\bakkesmod\bakkesmodsdk\include"

## Send me
- The output of step 1
- Whether step 2 worked
- Whether you play on Steam or Epic
