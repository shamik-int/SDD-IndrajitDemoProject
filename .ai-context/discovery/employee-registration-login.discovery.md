# Discovery Analysis: Employee Registration & Login

_Companion to `BRD-002`. Format mirrors
`discovery/employee-internal-transfer.discovery.md` per Blueprint §7._

## Business Objective
Require an employee to register and log in before they can access the
One-Point Employee Portal's transfer-request journey — replacing today's open
(no-identity) access with an identified employee session, so a submitted
request, its status, and its history all belong to a specific employee
rather than to whichever device happens to have the app installed.

## Primary Users
| Actor | Role in the journey |
|---|---|
| Employee (new) | Registers an account the first time they use the app |
| Employee (returning) | Logs in with the email/password they registered with |

No new actor types beyond the existing employee — this feature doesn't
introduce a Manager/HR/admin login; those remain simulated (AC14 of
`employee-internal-transfer`), unaffected by this feature.

## Journey Stages
1. **App launch, no session** — employee sees a Login screen, not the
   transfer-request screens.
2. **Registration** (first time only) — employee provides Name, Email,
   Password, and their *current* Department/Location/Role (reusing the same
   reference-data lists the transfer form already uses for *proposed*
   values).
3. **Login** (every subsequent launch, or after logout) — email + password.
4. **Authenticated session** — falls through to the existing
   `employee-internal-transfer` entry logic (status vs. submission), now
   scoped to the logged-in employee's own identity.
5. **Logout** — ends the session; the employee's account and any request
   they've made persist locally for next login.

## Business Rules
- An employee must register before they can log in.
- Email is the unique identifier — one account per email, on a given device.
- A login failure never reveals whether the *email* or the *password* was
  wrong (generic "invalid email or password") — a deliberate hygiene choice,
  not an oversight.
- Once logged in, a session persists across app restarts until explicit
  logout (no expiry — there is no backend to refresh a token against).

## Known Decisions (v1 defaults, mirroring how BRD-001/spec resolved its own open questions)
- Registration auto-logs the employee in — no separate first login required.
- Password minimum complexity: placeholder rule (≥8 characters, at least one
  letter and one number) — a business/security policy call, not an
  engineering one; flagged for Gate 1, same treatment as BRD-001's HR
  eligibility placeholder.
- Multiple employee accounts are supported on one device/install (not
  merged into "whoever installed the app") — each account's transfer
  requests are scoped to that account. This is a deliberate correction to
  `employee-internal-transfer`'s original assumption (see Cross-Feature
  Impact below), not an assumption made lightly.

## Open Questions
- Should a promoted/transferred employee be able to edit their stored
  Current Department/Location/Role after registration? — deferred, v1 has
  no profile-edit screen.
- Is there ever a need to de-register / delete an account? — deferred, out
  of scope for v1.
- Real password reset (forgot password) — impossible without a backend/email
  service; deferred indefinitely, not just to v1.1.

## Assumptions
- Reuses the existing `ReferenceData` (departments/locations/roles) — no new
  reference dataset needed, per ADR-0001's already-flagged placeholder status
  for that list.
- No production data exists yet for `employee-internal-transfer`, so there is
  no real migration concern for records that predate this feature (dev/test
  data only) — explicitly not a problem to solve, not silently ignored.

## Dependencies
- `employee-internal-transfer`'s data model needs an `employeeId` field
  added back (ADR-0004 originally dropped it, reasoning that one Hive store
  belonged to exactly one employee — this feature invalidates that
  reasoning). This is a **cross-feature impact**, sequenced as a plan-stage
  change to `employee-internal-transfer`, not implemented as part of this
  feature's own tasks.

## Explicitly Out of Scope
- Password reset / forgot password.
- Real (server-verified) identity — this remains a local access gate, not
  authentication in the enterprise sense (ADR-0005).
- Session expiry / auto-logout on inactivity.
- Editing registered profile fields after account creation.
- Role-based access control beyond "logged in or not" — no admin/manager
  account type.
- Multi-device sync of an account (consistent with ADR-0004's existing
  local-only limitation).

## Business Decision vs. Technical Decision
| Business decisions | Technical decisions |
|---|---|
| What fields are captured at registration | Password hashing scheme (ADR-0005) |
| Real password complexity policy | Local session storage mechanism (Hive, mirroring `app_state`) |
| Whether multiple accounts per device matters in practice | `employeeId` scoping added back to `employee-internal-transfer` |
| Login failure messaging (generic, not field-specific) | Reuse of `ReferenceData` for current-role fields |
