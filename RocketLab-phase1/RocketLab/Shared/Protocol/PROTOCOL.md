# Plugin <-> companion protocol, version 1

Design only; implemented in Phases 2 and 3.

## Transport
- Pipe: `\\.\pipe\RocketLab.v1`, byte mode, access limited to the current user.
- The companion is the server. The plugin connects and retries with backoff (1 s up to 30 s).
- Frame: 4-byte unsigned little-endian length, then that many bytes of UTF-8 JSON.
- Maximum 65536 bytes. A larger or invalid frame closes the connection.

## Envelope
`{"v":1,"type":"...","id":"<uuid>","ts":"<RFC 3339 UTC>","payload":{...}}`
Replies add `replyTo`. Schema: `message.schema.json`. Unknown payload fields are ignored.

## Messages
| type | direction | purpose |
|---|---|---|
| hello | plugin to app | versions; first message |
| welcome | app to plugin | accepts the connection |
| ping / pong | both | every 10 s when idle; 30 s silence means disconnected |
| status | plugin to app | game mode changed |
| drill.start | app to plugin | run an installed drill |
| drill.stop | app to plugin | stop the current drill |
| drill.state | plugin to app | started, finished, aborted |
| attempt.result | plugin to app | one attempt |
| ack | app to plugin | stored; plugin may drop it from the outbox |
| error | both | code and message |

Delivery of results is at-least-once. The database uses the run and attempt ids as
primary keys, so a resend cannot create a duplicate.
Routine (multi-drill) messages are added in Phase 4.
