# Architecture

Researched 24 November 2026. Items marked **(verify)** are not yet confirmed on a real PC.

## 1. Two ways of playing, two data paths

| | Training mode | Match mode |
|---|---|---|
| How the game is launched | Without Easy Anti-Cheat | Normally (EAC on) |
| BakkesMod plugin | Works | Does not run |
| Online play | Not available | Available |
| Data source | Plugin over a named pipe | Official Stats API, replay files |
| What you get | Drills, attempts, records | Match statistics |

The Stats API is a **proposed addition** that was not in the original brief. It is
Rocket League's own local feed (https://www.rocketleague.com/developer/stats-api).

## 2. Components

```
 TRAINING MODE                              MATCH MODE
 Rocket League + BakkesMod                  Rocket League (EAC on)
   RocketLab plugin (C++)                     Stats API          *.replay files
        |  named pipe                            | localhost TCP        |
        v                                        v                      v
 +------------------------ Windows companion (C#/WPF) --------------------------+
 |  pipe server | Stats API client | replay extractor (child process) | SQLite  |
 +-----------------------------------+------------------------------------------+
                                     | HTTPS, opt-in, summaries only
                                     v
                       Web dashboard (Next.js) + PostgreSQL
```

## 3. Decisions and reasons

| Area | Choice | Why |
|---|---|---|
| Plugin | C++20, Visual Studio 2026, x64, CMake | Required by the SDK (`pluginsdk.lib`, API version 95) |
| Desktop | C# on .NET 10 LTS, WPF | .NET 8 and 9 support ended 10 Nov 2026; .NET 10 is supported to Nov 2028. WPF is mature and does tray apps without packaging requirements |
| IPC | Windows named pipe | No network port, no firewall prompt, access can be limited to the current user |
| Local data | SQLite | One file, no server, easy backup |
| Replays | Own small Rust CLI on `boxcars` (0.13.1, MIT) | Actively maintained; a separate process cannot freeze or crash the app |
| Web | Next.js, TypeScript, PostgreSQL | One deployable unit |
| Drills | Versioned JSON files | Same definitions for plugin and companion; new drills without recompiling |

## 4. Plugin threading

- Game thread: reads game state and appends events to a bounded queue. No file or pipe I/O.
- Worker thread: owns the pipe and the offline outbox. Never touches game objects.
- Incoming commands are passed to the game thread with `GameWrapper::Execute`.
- Unload: signal stop, cancel pending I/O, join the worker, unhook events.
- Settings UI runs on the render thread; the SDK header warns to use `Execute` for game calls.

## 5. Safety rules

Scenario control (moving the ball or car) runs only when all are true:
`IsInFreeplay()`, `!IsInOnlineGame()`, and the car and ball wrappers are valid.
The check is repeated every time, not cached.

## 6. Offline behaviour

- Companion closed: the plugin writes results to an outbox file in BakkesMod's data
  folder and sends them on reconnect. Records are removed only after acknowledgement.
- Plugin absent: history, replay analysis, routines and charts still work.
- No internet: everything except cloud sync works.

## 7. Privacy and security

- Sync is off by default. Raw replays and individual attempts are never uploaded.
- Other players' names in matches stay local unless you explicitly allow upload.
- Web passwords are hashed with Argon2id; sessions use HttpOnly, Secure cookies.
- The companion pairs with a one-time code and stores its token with Windows DPAPI.
- Enabling the Stats API means editing a game config file. The app will ask first
  and keep a backup.

## 8. Risks

| Risk | Effect | Response |
|---|---|---|
| A game update breaks BakkesMod or hook names | Training stops until updated | Keep SDK calls in one layer; show plugin status clearly |
| Replay format changes | New replays fail to parse | Update `boxcars`; keep the file and retry later |
| Rocket League is announced to move to Unreal Engine 6 (date not firm) | BakkesMod may not carry over | Companion, replays and web do not depend on BakkesMod |
| Unsigned installer | Windows SmartScreen warning | Code signing needs a certificate you would buy |
| Game run as administrator but companion not (or the reverse) | Pipe may be refused | Test in Phase 3; document **(verify)** |
