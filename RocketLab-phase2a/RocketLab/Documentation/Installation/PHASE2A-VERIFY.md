# Phase 2, batch A: build, install, test

None of this has been built or run on Windows yet. Expect that something may fail;
send me the output and I will return complete replacement files.

All commands are run in PowerShell from `C:\Dev\RocketLab`.

## 1. Build

    powershell -ExecutionPolicy Bypass -File .\Scripts\Build\build_plugin.ps1

Expected end: `100% tests passed`, then `SUCCESS: ...\RocketLab.dll`.
On failure, send `BakkesModPlugin\build\build_log.txt`.

## 2. Install

    powershell -ExecutionPolicy Bypass -File .\Scripts\Install\install_plugin.ps1

## 3. Load

Start BakkesMod, launch Rocket League **without Easy Anti-Cheat**, press F6 and type:

    plugin load rocketlab

Expected: `[RocketLab] loaded v0.2.0`

## 4. Test, and note the result of each line

| # | Do | Expect |
|---|---|---|
| a | In the main menu: `rocketlab_status` | `mode: other`, car and ball not available |
| b | Enter Free Play, sit still: `rocketlab_status` | `mode: freeplay`, speed about 0, on ground yes |
| c | With unlimited boost on, check the boost number | 100 |
| d | `rocketlab_overlay 1`, close the console, drive | text top-left; numbers change; speed tops out near 83 |
| e | Drive up a wall; jump | "on wall" and "on ground" change to match |
| f | `rocketlab_overlay 0` | text disappears |
| g | `rocketlab_probe_start`, touch the ball 3 separate times, score 1 goal, `rocketlab_probe_stop` | a count for each of four events |
| h | `plugin unload rocketlab`, then `plugin load rocketlab` | no crash |
| i | Leave Free Play and exit the game with the plugin loaded | no crash |

## 5. Send me

- Build result (or the log)
- Anything in the table that did not match
- The probe report:
  `%APPDATA%\bakkesmod\bakkesmod\data\rocketlab\probe_report.txt`

The probe counts do not need to equal your touches or goals. They are there to show
which events fire, and how often, before drills depend on them.

## Remove

    powershell -ExecutionPolicy Bypass -File .\Scripts\Install\install_plugin.ps1 -Uninstall
