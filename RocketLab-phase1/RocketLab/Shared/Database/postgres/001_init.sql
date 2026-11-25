-- Rocket Lab cloud database, migration 001. Holds only what a user chose to sync.
BEGIN;

CREATE TABLE schema_migrations (version integer PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now());

CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email text NOT NULL,
    password_hash text NOT NULL,
    display_name text NOT NULL CHECK (char_length(display_name) BETWEEN 1 AND 40),
    created_at timestamptz NOT NULL DEFAULT now()
);
CREATE UNIQUE INDEX ux_users_email ON users (lower(email));

CREATE TABLE web_sessions (
    token_hash bytea PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at timestamptz NOT NULL
);
CREATE TABLE pairing_codes (
    code_hash bytea PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    expires_at timestamptz NOT NULL
);
CREATE TABLE devices (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name text NOT NULL,
    token_hash bytea NOT NULL UNIQUE,
    created_at timestamptz NOT NULL DEFAULT now(),
    revoked_at timestamptz
);

-- Ids come from the desktop app, so every key includes user_id.
CREATE TABLE training_sessions (
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    id uuid NOT NULL,
    started_at timestamptz NOT NULL,
    ended_at timestamptz,
    status text NOT NULL CHECK (status IN ('completed','abandoned')),
    PRIMARY KEY (user_id, id)
);
CREATE TABLE drill_runs (
    user_id uuid NOT NULL,
    id uuid NOT NULL,
    session_id uuid NOT NULL,
    drill_id text NOT NULL,
    drill_version integer NOT NULL,
    started_at timestamptz NOT NULL,
    duration_ms integer NOT NULL CHECK (duration_ms >= 0),
    status text NOT NULL CHECK (status IN ('completed','aborted')),
    successes integer NOT NULL CHECK (successes >= 0),
    counted integer NOT NULL CHECK (counted >= successes),
    fastest_success_ms integer,
    max_ball_speed_kph real,
    PRIMARY KEY (user_id, id),
    FOREIGN KEY (user_id, session_id) REFERENCES training_sessions(user_id, id) ON DELETE CASCADE
);
CREATE INDEX ix_runs_user_time ON drill_runs (user_id, started_at);

CREATE TABLE match_summaries (
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    id uuid NOT NULL,
    played_at timestamptz NOT NULL,
    map text,
    duration_sec real,
    team smallint CHECK (team IN (0,1)),
    team0_score integer,
    team1_score integer,
    score integer, goals integer, assists integer, saves integer, shots integer,
    PRIMARY KEY (user_id, id)
);
CREATE TABLE training_goals (
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    id uuid NOT NULL,
    metric text NOT NULL CHECK (metric IN ('training_minutes','sessions','drill_runs','success_rate')),
    drill_id text,
    target real NOT NULL CHECK (target > 0),
    period text NOT NULL CHECK (period IN ('week','month','all_time')),
    updated_at timestamptz NOT NULL,
    PRIMARY KEY (user_id, id)
);

INSERT INTO schema_migrations (version) VALUES (1);
COMMIT;
