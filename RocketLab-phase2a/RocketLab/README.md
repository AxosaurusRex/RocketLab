# Rocket Lab

A Rocket League training platform: BakkesMod plugin, Windows companion, web dashboard.

**Current state: Phase 2, batch A. A diagnostic plugin is written; it has not yet been built or run on Windows.**

Start here:
1. `CHECKLIST.md` - what is done and what is not
2. `Documentation/Installation/PHASE2A-VERIFY.md` - build and test the current batch
3. `Documentation/Architecture/ARCHITECTURE.md` - how the parts fit together
4. `Documentation/Architecture/FEASIBILITY.md` - what can and cannot be measured

## Read this first: Easy Anti-Cheat

Since 28 April 2026, online play on PC requires Easy Anti-Cheat (EAC), and mods do
not run with it enabled. So the plugin works only when Rocket League is launched
without EAC (training, offline matches, LAN, replays). Never try to get around this.

## Folders

| Folder | Contents | Code starts in |
|---|---|---|
| BakkesModPlugin | C++ plugin | Phase 2 (started) |
| WindowsCompanion | C# / WPF desktop app | Phase 3 |
| ReplayExtractor | Rust command-line replay parser | Phase 6 |
| WebDashboard | Next.js site and API | Phase 7 |
| Shared | Protocol and database schemas | Phase 1 (done) |
| Documentation | Architecture, install, API | ongoing |
| Scripts | Build, install, development | ongoing |
