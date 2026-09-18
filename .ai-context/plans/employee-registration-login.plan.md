# Plan: Employee Registration & Login

## Derived From
`.ai-context/specs/employee-registration-login.spec.md` (v1.1, Approved)

## Architecture Approach
- **No backend (ADR-0004/0005).** Same Clean Architecture + GetX pattern as
  `employee-internal-transfer` (ADR-0001) — this is a second slug, not a
  special case.
- **New Hive boxes:** `employees` (keyed by *normalized* email — trimmed,
  lowercased, so `A@x.com`/`a@x.com` collide as intended, per Gate 1 Finding
  2) and `session` (single key `currentEmployeeEmail`, mirroring the
  existing `app_state`/`activeRequestId` pattern from ADR-0004).
- **Password hashing:** SHA-256 + a per-account random salt, via the
  `crypto` package (new dependency) and `dart:math`'s `Random.secure()` for
  salt generation. Per ADR-0005, this is explicitly weaker than a real
  password hash (bcrypt/Argon2) — accepted because this is a local access
  gate with no real security boundary behind it either way.
- **Validators:** extend the existing `core/utils/validators.dart` (not a
  new file) with a `password` validator (≥8 chars, ≥1 letter, ≥1 number,
  per the spec's placeholder complexity rule) — same shared-validators
  principle ADR-0001 already established, not a one-off.
- **Registration reuses `ReferenceData`** (departments/locations/roles) for
  the employee's *current* selections — no new reference dataset.
- **Entry-flow integration (the real design decision this plan makes):**
  `AppEntryController.resolveInitialRoute()` gets a session check
  *prepended* to its existing active-request check:
  1. `GetCurrentSession()` — no session → Login route.
  2. Session exists → fall through to the *existing* logic (status vs.
     submission), now itself dependent on the cross-feature `employeeId`
     change below.
  Login and Registration success both route back through `AppEntryPage`
  (`Get.offAll`) rather than duplicating the status-vs-submission decision
  in two more places — one canonical "decide where to go" gate, reused.
- **Logout** is added to the status screen's `AppBar` (the natural "home
  base" for a logged-in employee) — calls `LogoutEmployee()`, then routes
  back through `AppEntryPage`, which will now correctly find no session and
  land on Login.

## Cross-Feature Amendment — `employee-internal-transfer` (not this feature's own tasks)
Per the spec's Cross-Feature Impact section and Gate 1 Finding 1:
`employee-internal-transfer`'s data model needs `employeeId` added to
`transfer_requests`, and its single-in-flight-request key changes from a
single `activeRequestId` to a per-employee composite key
(`activeRequestId:<employeeEmail>`) in the `app_state` box — no box
restructuring needed, just a keying convention change. `submit()`,
`getActive()`, and `recordStakeholderDecision()` in
`TransferRequestRepositoryImpl` all take an `employeeId` parameter, threaded
from the currently logged-in session.
**This work is filed as `employee-internal-transfer.T07` in that feature's
own tasks file, amending that feature's own plan — not as a task under this
feature's slug**, even though it's sequenced as part of *this* plan's
rollout (see Sequencing). Filing it under the wrong feature's task-ID
namespace would break the traceability the slug system exists for.
**AC9/UT11 of this spec cannot be verified until that task actually lands**
— re-stating Gate 1 Finding 1's resolution here so it isn't lost between
planning documents.

## Data Model
- **`employees` box** — keyed by normalized email. Value: `name`, `email`
  (normalized), `passwordHash`, `passwordSalt`, `currentDepartmentId`,
  `currentLocationId`, `currentRoleId`, `registeredAt`. The domain-level
  `EmployeeAccount` entity returned to the presentation layer **never**
  carries `passwordHash`/`passwordSalt` — those stay internal to the data
  layer's model, matching the spec's explicit contract note.
- **`session` box** — single key `currentEmployeeEmail`, cleared on logout.
- **`employee-internal-transfer` (cross-feature, T07):** `transfer_requests`
  records gain `employeeId`; `app_state` keys become
  `activeRequestId:<employeeEmail>`.

## Constitution Check
- [x] No new datastore without an ADR — `employees`/`session` boxes covered
      by ADR-0005.
- [x] Testing discipline — `flutter_test`, `Get.testMode`, test-first,
      same as `employee-internal-transfer`.
- [x] Security posture (v1.2 amendment) — passwords hashed, never logged
      plaintext on success or failure (Gate 1 Finding 3); this is a local
      access gate, not real authentication (ADR-0005) — not described as
      more than that anywhere in the UI copy either.
- [x] Root/jailbreak/Frida detection (ADR-0002) — unaffected, already wired
      at `main.dart` level; more relevant now that real credentials are
      stored locally, but no new work needed here.
- [x] Rate-limit decision: **not applicable** — no network endpoint exists.

## Explicitly Deferred
- Password reset (no email service/backend — ADR-0005, deferred
  indefinitely, not just v1).
- Session expiry / auto-logout on inactivity.
- Editing registered profile fields post-registration.
- Migrating any pre-existing `employee-internal-transfer` records that
  predate `employeeId` — no production data exists, nothing to migrate
  (same reasoning as ADR-0005's own Explicitly Deferred).

## Sequencing
1. `employee-registration-login` domain layer — `EmployeeAccount` entity,
   `RegisterEmployeeInput`/`LoginInput` value objects, repository contract,
   4 usecases (`RegisterEmployee`, `LoginEmployee`, `GetCurrentSession`,
   `LogoutEmployee`).
2. `employee-registration-login` data layer — Hive-backed datasource +
   repository implementation (validation, email normalization, uniqueness
   check, password hashing/verification, session read/write).
3. `employee-registration-login` presentation — Login screen + controller,
   Register screen + controller (reusing `ReferenceData` dropdowns and the
   new `password` validator).
4. Entry-flow integration — amend `AppEntryController`/`AppEntryPage` to
   check session first; add the Logout action to the status screen.
5. **Cross-feature amendment** — `employee-internal-transfer.T07`:
   `employeeId` added to its data model, single-in-flight-request key
   becomes per-employee. Filed under that feature's own tasks/plan, not
   this one's, per the Cross-Feature Amendment section above.
6. Integration test — register → auto-login → submit a transfer request →
   logout → login again → status still visible; a second registered
   account never sees or is blocked by the first account's request (AC9,
   only verifiable once step 5 has landed).

Task generation (`tasks/employee-registration-login.tasks.md`) follows this
directly — steps 1–4 and 6 become this feature's own tasks (T01–T05); step 5
becomes `employee-internal-transfer.T07`, cross-referenced but not
duplicated.
