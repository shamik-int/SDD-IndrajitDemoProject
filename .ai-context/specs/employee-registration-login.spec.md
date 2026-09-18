# Spec: Employee Registration & Login

## Spec ID
employee-registration-login

## Status
**Approved (v1.1)** — self-reviewed by the Author at v1.0 (see "Author
Self-Review Notes" below), then independently reviewed at Gate 1 by
**Shamik Bhattacharya** (see
`.ai-context/reviews/employee-registration-login.gate1-review.md`): 3
findings, 2 blocking (fixed, spec → v1.1), 1 non-blocking sequencing note
for Plan/Tasks. **Identity caveat, logged not hidden:** the reviewing
session's account metadata identified it as subhajit.mukherjee@intglobal.com,
not Shamik's own email; the person in that session explicitly confirmed
being Shamik when asked directly, and approval is recorded on that basis —
see the Gate 1 review file and `prompt_history.md` for the full exchange.
This is the same category of authority gap already acknowledged in
`employee-internal-transfer`'s Author-ratification history, applied
consistently rather than selectively.

## Linked BRD
`.ai-context/BRD.md#BRD-002`

## Intent
Require an employee to register (Name, Email, Password, current Department/
Location/Role) and log in (Email, Password) before they can reach the
existing `employee-internal-transfer` journey, so a submitted request and its
status belong to an identified employee rather than to whichever device has
the app installed. This is a local access gate only (ADR-0005) — there is no
backend to verify identity against.

## Context
- Builds on: `ADR-0001` (Flutter client architecture), `ADR-0004` (local DB
  as system of record), `ADR-0005` (local-only authentication — read this
  before reviewing the Non-Functional Constraints below)
- Related: `.ai-context/specs/employee-internal-transfer.spec.md` — this
  feature sits in front of it and changes one of its assumptions (see Cross-
  Feature Impact)
- Bundling note: registration and login are one spec, not two, because
  neither is usable without the other — the same reasoning
  `employee-internal-transfer`'s own "Scope Decision" section already used
  for a comparable bundling call
- External API contract consumed: none — same as `employee-internal-transfer`,
  this is a Local Data Contract only (no backend, ADR-0004/0005)

## Cross-Feature Impact — `employee-internal-transfer`
`employee-internal-transfer`'s data model currently has **no** `employeeId`
field, on ADR-0004's reasoning that "one Hive store = one employee." That
reasoning stops holding once real, distinct employee accounts exist on one
device/install. Shipping this feature requires `employee-internal-transfer`
to add `employeeId` back and scope its single-in-flight-request rule and
status/ownership checks to the logged-in employee, not the device. **This
change is explicitly not part of this spec's own Acceptance Criteria or
tasks** — it is `employee-internal-transfer`'s own plan amendment, sequenced
after this feature, and tracked there, not invented here as scope creep in
the other direction. **(Gate 1 Finding 1)** Consequently: **AC9 and its test
(UT11) must not be marked done in this feature's own Tasks file until
`employee-internal-transfer`'s `employeeId` change has actually landed** —
not merely been planned. This spec being honest about the dependency isn't
sufficient on its own to stop that sequencing mistake at Tasks stage;
calling it out explicitly here is.

## Local Data Contract
No network API — same pattern as `employee-internal-transfer`: local method
calls against a repository, backed by Hive, returning the shared `Result<T>`
(ADR-0001 §4). **(Gate 1 Finding 2)** Email comparisons are case-insensitive
throughout — for uniqueness at registration (OP01) and for lookup at login
(OP02) — so `A@x.com` and `a@x.com` are the same account.

### employee-registration-login.OP01 — register
**Input:**
```dart
{
  name: String,
  email: String,
  password: String,
  currentDepartmentId: String,
  currentLocationId: String,
  currentRoleId: String,
}
```
**Success:** `Result.success(EmployeeAccount)` — account created, session set
to this employee (auto-login).
**Errors (`Result.error(message)`):**
| Condition | Message |
|---|---|
| A mandatory field is missing/blank | field-specific validation message |
| Email is not a valid format | "Enter a valid email address." |
| Password fails the complexity rule (≥8 chars, ≥1 letter, ≥1 number) | "Password must be at least 8 characters and include a letter and a number." |
| Email is already registered | "An account with this email already exists." |

### employee-registration-login.OP02 — login
**Input:** `{ email: String, password: String }`
**Success:** `Result.success(EmployeeAccount)` — session set to this employee.
**Errors:** `Result.error("Invalid email or password.")` for *both* "no
account with this email" and "password doesn't match" — deliberately
identical wording, so a failed login never reveals whether an email is
registered.

### employee-registration-login.OP03 — getCurrentSession
**Input:** none.
**Success:** `Result.success(EmployeeAccount)` if a session is active, or
`Result.success(null)` if no one is logged in.

### employee-registration-login.OP04 — logout
**Input:** none.
**Success:** `Result.success(true)` — clears the session. The employee's
account and any transfer request they've made are untouched; only the
active-session pointer is cleared.

`EmployeeAccount` (returned by OP01–OP03) never carries the password hash —
that stays internal to the repository, never surfaced past the data layer.

## Acceptance Criteria
1. **employee-registration-login.AC1** — Given no session is active, when the
   app launches, then the employee sees the Login screen, not any
   `employee-internal-transfer` screen.
2. **employee-registration-login.AC2** — Given an employee has no account yet,
   when they choose to register, then they can enter Name, Email, Password,
   and select their current Department, Location, and Role.
3. **employee-registration-login.AC3** — Given all mandatory registration
   fields are valid and the email isn't already registered, when the
   employee submits, then an account is created, the employee is
   automatically logged in, and control passes to
   `employee-internal-transfer`'s existing entry logic.
4. **employee-registration-login.AC4** — Given a mandatory registration field
   is missing, the email is malformed, or the password fails the complexity
   rule, when the employee submits, then registration is blocked with a
   field-level validation message and no account is created.
5. **employee-registration-login.AC5** — Given the email is already
   registered, when the employee attempts to register with it again, then
   registration is blocked with a message that the email is already in use,
   and no second account is created.
6. **employee-registration-login.AC6** — Given a registered employee enters
   their correct email and password, when they submit login, then they are
   authenticated and control passes to `employee-internal-transfer`'s
   existing entry logic, scoped to their own identity.
7. **employee-registration-login.AC7** — Given an employee enters an
   unregistered email, or a registered email with the wrong password, when
   they submit login, then login is blocked with the same generic "invalid
   email or password" message in both cases.
8. **employee-registration-login.AC8** — Given a logged-in employee chooses
   to log out, then their session ends and they return to the Login screen;
   their account and any transfer request they've made remain stored for
   their next login.
9. **employee-registration-login.AC9** — Given two different employees have
   registered on the same device, when each is logged in separately, then
   each only ever sees and is scoped to their own transfer request — one
   employee's active request never blocks or appears for the other.

## Unit Test Cases (spec-derived)
| Test ID | Maps to AC | Scenario | Expected |
|---|---|---|---|
| employee-registration-login.UT01 | AC3 | Register with all valid fields | `Result.success`, session set |
| employee-registration-login.UT02 | AC4 | Register with name missing | `Result.error`, field-level message, no account created |
| employee-registration-login.UT03 | AC4 | Register with malformed email | `Result.error`, "valid email address" |
| employee-registration-login.UT04 | AC4 | Register with a 4-character password | `Result.error`, complexity message |
| employee-registration-login.UT05 | AC5 | Register with an already-registered email | `Result.error`, "already exists", no second account created |
| employee-registration-login.UT06 | AC6 | Login with correct email + password | `Result.success`, session set |
| employee-registration-login.UT07 | AC7 | Login with an unregistered email | `Result.error`, "Invalid email or password." |
| employee-registration-login.UT08 | AC7 | Login with a registered email, wrong password | `Result.error`, identical "Invalid email or password." message as UT07 |
| employee-registration-login.UT09 | AC1, AC8 | `getCurrentSession` with no prior login | `Result.success(null)` |
| employee-registration-login.UT10 | AC8 | Logout after a successful login | Session cleared; account/request data untouched |
| employee-registration-login.UT11 | AC9 | Two accounts register and each submits a transfer request | Each account's `employee-internal-transfer` active-request check is independent of the other's |

## Explicitly Out of Scope
- Password reset / forgot password (no email service, no backend — deferred
  indefinitely, not just v1).
- Real, server-verified identity (ADR-0005) — this is a local access gate.
- Session expiry or auto-logout on inactivity.
- Editing registered profile fields (current department/location/role) after
  account creation.
- Role-based access control beyond "logged in or not" — no admin/manager
  account type; Manager/HR/Payroll/IT/Facilities remain simulated via
  `employee-internal-transfer`'s existing Simulate Decision control,
  unaffected by this feature.
- Multi-device sync of an account (consistent with ADR-0004).
- Migrating any pre-existing `employee-internal-transfer` records created
  before `employeeId` existed — no production data exists, so there is
  nothing to migrate (ADR-0005 Explicitly Deferred).

## Non-Functional Constraints (from constitution.md, as amended by ADR-0005)
- Passwords are hashed (never plaintext) before storage or in any log, at
  any level. **(Gate 1 Finding 3)** This explicitly includes a *failed*
  login or registration attempt — the raw password the employee typed is
  never logged even when rejected, not just on success.
- This feature is **not** a real security boundary — it is a local access
  gate only (ADR-0005). Do not describe it to a business stakeholder as
  equivalent to server-verified authentication.
- No employee PII (name, email) appears in logs at any level.
- Local read/write operations complete well under 500ms on a mid-range
  device — same baseline as `employee-internal-transfer`, no network
  variability to budget for.

## Author Self-Review Notes (pre-Gate-1)
Read as a reviewer would, before presenting this spec, rather than
presenting a first draft unexamined:
- **Caught:** an earlier draft used SHA-256 alone with no salt — a rainbow-
  table risk even before considering SHA-256's unsuitability as a password
  hash generally. Fixed to per-account salt + SHA-256, with ADR-0005 stating
  outright that even that is weaker than a real password hash, rather than
  presenting salted-SHA-256 as if it were sufficient.
- **Caught:** AC9 (multi-account scoping) has no corresponding change in
  *this* spec's own contract — it's entirely dependent on
  `employee-internal-transfer` adding `employeeId` back. Made this explicit
  in "Cross-Feature Impact" rather than letting AC9 imply this spec alone
  delivers it.
- **Open, flagged for Gate 1, not resolved unilaterally:** the password
  complexity rule (≥8 chars, letter+number) is an engineering placeholder,
  same treatment as BRD-001's HR eligibility rule — Shamik should confirm or
  replace it, not treat it as final.
