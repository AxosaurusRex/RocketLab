# Sync API (design only, built in Phase 7)

Base path `/api/v1`, HTTPS only, JSON. Request bodies are validated; unknown fields are rejected.

| Method and path | Auth | Purpose |
|---|---|---|
| POST /auth/register, /auth/login, /auth/logout | none / cookie | web accounts, rate limited |
| POST /devices/pairing-codes | cookie | one-time code, expires in 10 minutes |
| POST /devices/pair | code | returns a device token once |
| DELETE /devices/{id} | cookie | revoke a computer |
| POST /sync/batch | device token | idempotent upserts and deletes, size limited |
| GET /me/export | cookie | download all cloud data |
| DELETE /me/data | cookie | delete synced data |
| DELETE /me | cookie | delete the account |

Errors: `{"error":{"code":"...","message":"..."}}` with a matching HTTP status.
Full request and response schemas are written with the implementation.
