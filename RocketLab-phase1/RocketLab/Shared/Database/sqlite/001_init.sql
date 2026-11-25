-- Rocket Lab local database, migration 001.
-- Timestamps are UTC ISO 8601 text. The app must run PRAGMA foreign_keys = ON.
BEGIN;

CREATE TABLE schema_migrations (version INTEGER PRIMARY KEY, applied_at TEXT NOT NULL);
CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT NOT NULL);

CREATE TABLE drills (
    id TEXT PRIMARY KEY,
    version INTEGER NOT NULL CHECK (version >= 1),
    name TEXT NOT NULL,
    category TEXT NOT NULL CHECK (category IN ('aerial','ground','wall','shooting','defense','advanced')),
    difficulty TEXT NOT NULL CHECK (difficulty IN ('beginner','intermediate','advanced','expert')),
    tracking TEXT NOT NULL CHECK (tracking IN ('measured','estimated','practice_only')),
    estimated_minutes INTEGER NOT NULL CHECK (estimated_minutes > 0),
    definition_json TEXT NOT NULL,
    is_favorite INTEGER NOT NULL DEFAULT 0 CHECK (is_favorite IN (0,1))
);

CREATE TABLE routines (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL CHECK (length(name) > 0),
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);
CREATE TABLE routine_steps (
    routine_id TEXT NOT NULL REFERENCES routines(id) ON DELETE CASCADE,
    position INTEGER NOT NULL CHECK (position >= 0),
    drill_id TEXT NOT NULL REFERENCES drills(id),
    time_limit_sec INTEGER CHECK (time_limit_sec > 0),
    rep_target INTEGER CHECK (rep_target > 0),
    PRIMARY KEY (routine_id, position)
);

CREATE TABLE sessions (
    id TEXT PRIMARY KEY,
    routine_id TEXT REFERENCES routines(id) ON DELETE SET NULL,
    started_at TEXT NOT NULL,
    ended_at TEXT,
    status TEXT NOT NULL CHECK (status IN ('active','completed','abandoned'))
);
CREATE TABLE drill_runs (
    id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL REFERENCES sessions(id) ON DELETE CASCADE,
    drill_id TEXT NOT NULL REFERENCES drills(id),
    drill_version INTEGER NOT NULL,
    started_at TEXT NOT NULL,
    duration_ms INTEGER NOT NULL DEFAULT 0 CHECK (duration_ms >= 0),
    status TEXT NOT NULL CHECK (status IN ('active','completed','aborted'))
);
CREATE TABLE attempts (
    id TEXT PRIMARY KEY,
    run_id TEXT NOT NULL REFERENCES drill_runs(id) ON DELETE CASCADE,
    attempt_index INTEGER NOT NULL CHECK (attempt_index >= 1),
    outcome TEXT NOT NULL CHECK (outcome IN ('success','fail','skipped')),
    duration_ms INTEGER NOT NULL CHECK (duration_ms >= 0),
    touches INTEGER CHECK (touches >= 0),
    ball_speed_kph REAL CHECK (ball_speed_kph >= 0),
    estimated INTEGER NOT NULL DEFAULT 0 CHECK (estimated IN (0,1)),
    UNIQUE (run_id, attempt_index)
);
CREATE INDEX ix_runs_drill ON drill_runs(drill_id, started_at);
CREATE INDEX ix_runs_session ON drill_runs(session_id);
CREATE INDEX ix_sessions_started ON sessions(started_at);

CREATE TABLE training_goals (
    id TEXT PRIMARY KEY,
    metric TEXT NOT NULL CHECK (metric IN ('training_minutes','sessions','drill_runs','success_rate')),
    drill_id TEXT REFERENCES drills(id),
    target REAL NOT NULL CHECK (target > 0),
    period TEXT NOT NULL CHECK (period IN ('week','month','all_time')),
    created_at TEXT NOT NULL,
    archived_at TEXT
);

CREATE TABLE matches (
    id TEXT PRIMARY KEY,
    source TEXT NOT NULL CHECK (source IN ('replay','stats_api')),
    game_match_id TEXT,
    played_at TEXT NOT NULL,
    map TEXT,
    duration_sec REAL CHECK (duration_sec >= 0),
    team0_score INTEGER,
    team1_score INTEGER,
    replay_path TEXT,
    replay_sha256 TEXT UNIQUE,
    parser_version TEXT
);
CREATE TABLE match_players (
    match_id TEXT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    slot INTEGER NOT NULL,
    name TEXT NOT NULL,
    platform_id TEXT,
    team INTEGER NOT NULL CHECK (team IN (0,1)),
    is_local_player INTEGER NOT NULL DEFAULT 0 CHECK (is_local_player IN (0,1)),
    score INTEGER, goals INTEGER, assists INTEGER, saves INTEGER, shots INTEGER,
    PRIMARY KEY (match_id, slot)
);
CREATE TABLE match_events (
    id INTEGER PRIMARY KEY,
    match_id TEXT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
    at_sec REAL NOT NULL CHECK (at_sec >= 0),
    kind TEXT NOT NULL,
    player_slot INTEGER,
    data_json TEXT
);
CREATE INDEX ix_events_match ON match_events(match_id, at_sec);

CREATE TABLE sync_outbox (
    entity TEXT NOT NULL,
    entity_id TEXT NOT NULL,
    operation TEXT NOT NULL CHECK (operation IN ('upsert','delete')),
    queued_at TEXT NOT NULL,
    PRIMARY KEY (entity, entity_id)
);

-- Records are derived from stored runs, never stored separately.
CREATE VIEW v_run_results AS
SELECT r.id AS run_id, r.drill_id, r.drill_version, r.started_at,
       SUM(a.outcome = 'success') AS successes,
       SUM(a.outcome IN ('success','fail')) AS counted,
       MIN(CASE WHEN a.outcome = 'success' THEN a.duration_ms END) AS fastest_success_ms,
       MAX(a.ball_speed_kph) AS max_ball_speed_kph
FROM drill_runs r JOIN attempts a ON a.run_id = r.id
GROUP BY r.id;

-- Success rate only counts as a record with at least 10 counted attempts.
CREATE VIEW v_personal_bests AS
SELECT drill_id, drill_version,
       MAX(CASE WHEN counted >= 10 THEN 1.0 * successes / counted END) AS best_success_rate,
       MIN(fastest_success_ms) AS fastest_success_ms,
       MAX(max_ball_speed_kph) AS max_ball_speed_kph
FROM v_run_results
GROUP BY drill_id, drill_version;

INSERT INTO schema_migrations VALUES (1, strftime('%Y-%m-%dT%H:%M:%SZ','now'));
COMMIT;
