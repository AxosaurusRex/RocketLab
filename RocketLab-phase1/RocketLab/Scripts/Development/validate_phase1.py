"""Test the Phase 1 protocol schema and local database schema.

Needs Python 3.10+ and, for the protocol tests:  pip install jsonschema
"""
import json
import sqlite3
import sys
from pathlib import Path

try:
    from jsonschema import Draft202012Validator
except ImportError:
    sys.exit("Missing package. Run: pip install jsonschema")

ROOT = Path(__file__).resolve().parents[2]
failures: list[str] = []
passed = 0


def check(condition: bool, label: str) -> None:
    global passed
    if condition:
        passed += 1
    else:
        failures.append(label)


def test_protocol() -> None:
    folder = ROOT / "Shared" / "Protocol"
    schema = json.loads((folder / "message.schema.json").read_text(encoding="utf-8"))
    Draft202012Validator.check_schema(schema)
    validator = Draft202012Validator(schema)
    examples = {p.stem: json.loads(p.read_text(encoding="utf-8")) for p in (folder / "examples").glob("*.json")}
    check(len(examples) >= 6, "examples present")
    for name, message in examples.items():
        check(validator.is_valid(message), f"example {name} is valid")

    def broken(name, change, label):
        message = json.loads(json.dumps(examples[name]))
        change(message)
        check(not validator.is_valid(message), f"rejects {label}")

    broken("hello", lambda m: m.update(v=2), "wrong version")
    broken("hello", lambda m: m.update(type="shell.run"), "unknown type")
    broken("hello", lambda m: m.pop("id"), "missing id")
    broken("ack", lambda m: m.pop("replyTo"), "ack without replyTo")
    broken("status", lambda m: m["payload"].update(mode="ranked"), "unknown mode")
    broken("drill_start", lambda m: m["payload"].update(repTarget=0), "zero repetitions")
    broken("attempt_result", lambda m: m["payload"].update(durationMs=-1), "negative duration")


def test_database() -> None:
    db = sqlite3.connect(":memory:")
    db.execute("PRAGMA foreign_keys = ON")
    db.executescript((ROOT / "Shared/Database/sqlite/001_init.sql").read_text(encoding="utf-8"))
    check(db.execute("SELECT version FROM schema_migrations").fetchone() == (1,), "migration recorded")

    now = "2026-01-01T00:00:00Z"
    # Throwaway rows in an in-memory database, used only to test the schema.
    db.execute("INSERT INTO drills VALUES ('d',1,'T','aerial','beginner','measured',5,'{}',0)")
    db.execute("INSERT INTO sessions VALUES ('s',NULL,?,NULL,'active')", (now,))
    check(db.execute("SELECT COUNT(*) FROM v_personal_bests").fetchone() == (0,), "no data means no records")

    def run(run_id, successes, fails):
        db.execute("INSERT INTO drill_runs VALUES (?,'s','d',1,?,1000,'completed')", (run_id, now))
        for i in range(successes + fails):
            ok = i < successes
            db.execute("INSERT INTO attempts VALUES (?,?,?,?,?,1,NULL,0)",
                       (f"{run_id}-{i}", run_id, i + 1, "success" if ok else "fail", 900 + i))

    def best():
        return db.execute("SELECT best_success_rate, fastest_success_ms FROM v_personal_bests").fetchone()

    run("short", 3, 0)
    check(best() == (None, 900), "3 attempts do not set a success-rate record")
    run("long", 7, 3)
    check(best() == (0.7, 900), "10 attempts set a success-rate record")

    def rejects(sql, label):
        try:
            db.execute(sql)
            check(False, f"rejects {label}")
        except sqlite3.IntegrityError:
            check(True, label)

    rejects("INSERT INTO attempts VALUES ('long-0','long',99,'fail',1,0,NULL,0)", "duplicate attempt id")
    rejects("INSERT INTO attempts VALUES ('x','nope',1,'fail',1,0,NULL,0)", "attempt without a run")
    rejects("INSERT INTO attempts VALUES ('y','long',50,'maybe',1,0,NULL,0)", "unknown outcome")
    rejects("DELETE FROM drills WHERE id='d'", "deleting a drill that has history")

    db.execute("DELETE FROM sessions")
    check(db.execute("SELECT COUNT(*) FROM attempts").fetchone() == (0,), "deleting a session removes attempts")


test_protocol()
test_database()
for item in failures:
    print("FAIL", item)
print(f"{passed} passed, {len(failures)} failed")
sys.exit(1 if failures else 0)
