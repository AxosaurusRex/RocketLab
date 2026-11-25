# BakkesMod SDK research

Source: https://github.com/bakkesmodorg/BakkesModSDK
Commit: `479e8f571cf554b25f4eeb64d611dec4133edcaf` ("BM218 SDK", 22 Jan 2026)
`BAKKESMOD_PLUGIN_API_VERSION` = 95

Every class member Rocket Lab plans to use is listed in `sdk_symbols.json` and can be
rechecked with `Scripts/Development/verify_sdk_symbols.py`. That check proves the name
is declared in the header. It does **not** prove the call behaves as expected in game.

## What the SDK gives us

- Plugin lifecycle: `BAKKESMOD_PLUGIN` macro, `onLoad`, `onUnload`
- Commands and settings: `registerNotifier`, `registerCvar`
- Mode checks: `IsInFreeplay`, `IsInOnlineGame`, `IsInCustomTraining`, `IsInReplay`
- Scenario setup: `SetLocation`, `SetVelocity`, `SetAngularVelocity`, `SetCarRotation`
- Car state: `IsOnGround`, `IsOnWall`, `HasFlip`, `IsDodging`, `GetInput`, boost amount
- Ball and goal: `GetBall`, `IsInGoal`, `GetGoalLocation`, `GenerateShot`
- Timing and drawing: `SetTimeout`, `Execute`, `RegisterDrawable`, `CanvasWrapper`
- Events: `HookEvent`, `HookEventWithCaller`

## Event names: NOT verified

Hook names are game function strings. They are not declared in the SDK headers, so
they cannot be checked here. Phase 2 includes a diagnostic command that logs whether
each one fires. Candidates:

- `Function TAGame.Car_TA.OnHitBall` (ball touch)
- `Function TAGame.Ball_TA.OnHitGoal` (goal)
- `Function TAGame.Car_TA.SetVehicleInput` (per-tick sampling)

## Other things to confirm in game

- The `load_freeplay` console command (used to start Free Play on request)
- Whether goal reset can be suppressed reliably during a drill

## Notes

- SDK `#include` paths differ in letter case from file names. This is fine on Windows
  and breaks on case-sensitive filesystems, so the plugin must be built on Windows.
- Plugin DLLs go in `%APPDATA%\bakkesmod\bakkesmod\plugins`; load with `plugin load <name>`.
- Publishing on bakkesplugins.com requires a manual source review. Not needed for personal use.
