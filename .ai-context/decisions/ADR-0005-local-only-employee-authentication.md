# ADR-0005: Local-Only Employee Authentication — Access Gate, Not a Security Boundary

_Author: Indrajit Bhandari | 2026-09-17 | Status: Accepted_

## Context
BRD-002 asks for employee registration and login. This project has no
backend (ADR-0004) — there is no server to verify credentials against, issue
a session token, or protect a credentials store from local file access. Any
"authentication" this feature provides is necessarily a **local access gate**:
it stops the UI from being used without a matching local record, and nothing
more. It does not prevent someone with file-system access to the device from
reading the local employee/credential store directly, nor does it constitute
identity verification in the sense a real backend would provide. This ADR
exists so that limitation is a stated, deliberate fact — not something
discovered later and treated as a bug.

## Decision
1. **Employee accounts live in a new Hive box (`employees`), keyed by
   email** — the natural unique identifier, avoiding a redundant separate ID.
2. **Passwords are hashed before storage — never stored or logged in
   plaintext.** Proposed: SHA-256 with a per-account random salt, via the
   `crypto` package. This is explicitly **not** the same as a real
   password-storage scheme (bcrypt/Argon2/scrypt — deliberately slow,
   adaptive hashes designed to resist brute-force). SHA-256 is fast, which
   is a weakness for password hashing specifically. The tradeoff is
   accepted here *because* this is already a local-only access gate with no
   real security boundary behind it (see Consequences) — a stronger hash
   would harden a door that has no wall around it. If this project ever
   grows a real backend, password handling must be redone there with a real
   adaptive hash, not carried forward from this ADR.
3. **Session state is a single Hive key** (`session` box, `currentEmployeeEmail`
   key) — mirrors the existing `app_state`/`activeRequestId` pattern
   (ADR-0004), set on successful register/login, cleared on logout.
4. **`employee-internal-transfer`'s data model gets `employeeId` back**,
   scoping the single-in-flight-request rule and status/ownership to the
   logged-in employee rather than to the device. This reverses part of
   ADR-0004's reasoning ("one Hive store = one employee, no id needed") —
   correctly so, since that reasoning no longer holds once real accounts
   exist. This change is sequenced into `employee-internal-transfer`'s own
   plan amendment, not this feature's tasks.

## Constitution Check
- [x] No new datastore without an ADR — this ADR is that ADR for the
      `employees` and `session` boxes (still local Hive, per ADR-0001/0004).
- [x] Security posture — passwords never logged in plaintext (constitution.md
      amended alongside this ADR to state this explicitly).
- [x] Root/jailbreak/Frida detection (ADR-0002) remains the app's only real
      device-compromise defence — now more relevant, since credentials are
      stored locally.

## Explicitly Deferred
- A real backend-verified authentication system — this ADR does not attempt
  to simulate one; it is honestly scoped as a local gate.
- Any password-reset flow (requires an email service this project doesn't
  have).
- Migrating pre-existing `employee-internal-transfer` records created before
  `employeeId` existed — no production data exists yet, so there is nothing
  to migrate; explicitly a non-problem, not a silently-skipped one.

## Consequences
An employee's password, hashed or not, is only as protected as the device's
own file-system access controls (and, on a rooted/jailbroken device, ADR-0002's
detection is the last line of defence, not a guarantee). **This must never be
described to a business stakeholder as equivalent to real user
authentication** — it verifies "did the person typing know the password
stored locally," not "is this actually that employee." If this app is ever
given a real backend, this entire ADR is superseded, the way ADR-0003 was by
ADR-0004 — not silently patched in place.
