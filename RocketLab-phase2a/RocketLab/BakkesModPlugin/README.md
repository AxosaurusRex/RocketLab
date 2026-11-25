# BakkesMod plugin

Phase 2, batch A (version 0.2.0): load/unload, commands, read-only game state,
status overlay, event hook probe. Nothing in this version changes the game.

Build, install and test: `Documentation/Installation/PHASE2A-VERIFY.md`.

| Command | Effect |
|---|---|
| `rocketlab_version` | print the version |
| `rocketlab_status` | print mode, car and ball state |
| `rocketlab_overlay 1` / `0` | show or hide the diagnostic overlay (Free Play) |
| `rocketlab_probe_start` / `rocketlab_probe_stop` | count candidate game events |

Layout: `include/rocketlab` and `src/core` have no SDK dependency and are unit tested;
`src/plugin` is the only code that touches the SDK.
