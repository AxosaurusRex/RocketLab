# Development checklist

Status words: **Done** (built and tested here), **Done, unverified** (written, not tested
where it will run), **Partial**, **Not started**, **Blocked**.

## Phase 1 - research and architecture
| Item | Status |
|---|---|
| Inspect official SDK, check planned names against headers | Done |
| Research anti-cheat, Stats API, replay parser, framework support | Done |
| Choose frameworks, document architecture and feasibility | Done |
| IPC protocol schema and examples | Done (schema tested; no pipe code yet) |
| SQLite schema | Done (tested) |
| PostgreSQL schema | Done (tested here) |
| Sync API | Partial (outline only; schemas in Phase 7) |
| Project structure | Done |
| Environment check script for Windows | Done, unverified |
| Your PC checks (PHASE1-VERIFY.md) | Not started - **gate for Phase 2** |

## Later phases (a phase starts only after the previous one is verified)
| Phase | Scope | Status | Exit test |
|---|---|---|---|
| 2 | Plugin: load, commands, game state, safe Free Play control, pipe client, outbox | Not started | DLL builds; loads in game; diagnostic confirms hooks |
| 3 | Companion: WPF shell, tray, start with Windows, pipe server, detection, SQLite | Not started | Builds; connects and reconnects with the game |
| 4 | Drill framework, first drills, routines, records, library, favorites | Not started | A drill run in game appears in the app |
| 5 | Dashboard, charts, streaks, goals, recommendations | Not started | Numbers match stored runs |
| 6 | Replay extractor, library, timeline; Stats API client | Not started | Your replays parse correctly |
| 7 | Web accounts, API, dashboard, optional sync, export, delete | Not started | Sync round trip; auth tests |
| 8 | Polish, performance, installer, guides, release builds | Not started | Clean install on your PC |

Settings, update handling, notifications, backup and export are scheduled with
phases 3, 5 and 8. Nothing from the brief has been dropped.

## Blocked by technical limits
| Item | Reason | Alternative |
|---|---|---|
| Plugin features during online play | Mods do not run with EAC on | Stats API and replays |
| Reliable automatic detection of some freestyle mechanics | No direct game signal | Practice-only drills, self-marked |
| Recorded possession statistic | Not in replay data | Labelled estimate, or omit |

## Where builds can be verified
| Part | In Claude's sandbox | Needs |
|---|---|---|
| Schemas, protocol | Yes | - |
| Plugin DLL, WPF app | **No** (no MSVC or .NET SDK) | your PC, or a GitHub Actions Windows runner |
| In-game behaviour | **No** | your PC |
