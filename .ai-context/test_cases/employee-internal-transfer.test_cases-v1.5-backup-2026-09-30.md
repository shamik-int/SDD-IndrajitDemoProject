# Test Cases: Employee Internal Transfer

_QA-expanded version of `specs/employee-internal-transfer.spec.md`'s own Unit
Test Cases table (Blueprint §19.1) — same IDs for the AC-derived rows, plus
additional scenario/negative-path coverage the AC table doesn't spell out._

_Revised at spec v1.2 (ADR-0004): no backend, no HTTP — every scenario below
exercises the local repository (`Result<T>` success/error), not a REST call.
Rows that assumed a server (session expiry, cross-employee access via a
shared database) were dropped as not applicable to a local, single-employee
-per-device app; see the note after each removed row._

## Spec-derived (mirrors employee-internal-transfer.spec.md)
| Test ID | Maps to AC | Scenario | Expected |
|---|---|---|---|
| employee-internal-transfer.UT01 | AC3 | Submit with all valid fields + future effective date | `Result.success`, status `PENDING_MANAGER_APPROVAL` |
| employee-internal-transfer.UT02 | AC4 | Submit with `departmentId` missing | `Result.error`, field-level message, no record created |
| employee-internal-transfer.UT03 | AC5 | Submit with `effectiveDate` = today | `Result.error`, "must be in the future" |
| employee-internal-transfer.UT04 | AC5 | Submit with `effectiveDate` in the past | `Result.error` |
| employee-internal-transfer.UT05 | AC2 | Submit while a non-terminal request already exists | `Result.error`, no second record created |
| employee-internal-transfer.UT06 | AC6, AC7 | Read status of a request in `PENDING_MANAGER_APPROVAL` | Submitted fields returned; `pendingStakeholders = ["Manager"]` |
| employee-internal-transfer.UT07 | AC9, AC14 | Simulate Manager reject | status `REJECTED_BY_MANAGER`, `pendingStakeholders = []` |
| employee-internal-transfer.UT08 | AC8, AC14 | Simulate Manager approve | status `PENDING_HR_VALIDATION`, `pendingStakeholders = ["HR"]` |
| employee-internal-transfer.UT09 | AC11, AC14 | Simulate HR reject | status `REJECTED_BY_HR`, `pendingStakeholders = []` |
| employee-internal-transfer.UT10 | AC10, AC14 | Simulate HR approve | status `PENDING_DOWNSTREAM_UPDATES`, `pendingStakeholders = ["Payroll","IT","Facilities"]` |
| employee-internal-transfer.UT11 | AC13, AC14 | Simulate Payroll complete; IT/Facilities still pending | `pendingStakeholders = ["IT","Facilities"]` |
| employee-internal-transfer.UT12 | AC12, AC14 | Simulate all three downstream steps complete | status `COMPLETED`, `pendingStakeholders = []` |
| employee-internal-transfer.UT13 | AC9 | After a manager rejection, employee submits a new request | New request accepted |
| employee-internal-transfer.UT14 | AC14 | Simulate an HR decision while status is still `PENDING_MANAGER_APPROVAL` | `Result.error`, "invalid decision for current state" |

## Additional QA coverage (not individually AC-mapped, still in scope)
| Test ID | Scenario | Expected |
|---|---|---|
| employee-internal-transfer.QA01 | Effective date exactly one day in the future | Accepted (boundary case for AC5's "in the future" rule) |
| employee-internal-transfer.QA02 | Reason field left blank | Accepted — reason is optional per AC1 |
| employee-internal-transfer.QA03 | Double-tap submit (two rapid identical submissions) | Only one record created — second call hits the same "already in progress" error as UT05, not a duplicate |
| employee-internal-transfer.QA05 | `getTransferRequestById` for a non-existent ID | `Result.error`, "no request found" |
| employee-internal-transfer.QA06 | `getActiveTransferRequest` when there is no active request | `Result.success(null)` |
| employee-internal-transfer.QA07 | App killed/restarted mid-submission | No partial/corrupt record left in `LocalDbService`; either the write completed or it didn't — never a half-written record |
| employee-internal-transfer.QA09 | `effectiveDate` in an invalid format | `Result.error`, field-level message naming `effectiveDate` |
| employee-internal-transfer.QA10 | Simulate Payroll and IT complete in immediate succession | `pendingStakeholders` converges to `["Facilities"]` — no dropped/duplicated stakeholder entries regardless of call order |
| employee-internal-transfer.QA11 | Submit with `locationId` missing (AC4, gap noted at Gate 1 — UT02 only covered `departmentId`) | `Result.error`, field-level message naming `locationId`, no record created |
| employee-internal-transfer.QA12 | Submit with `roleId` missing (AC4) | `Result.error`, field-level message naming `roleId`, no record created |
| employee-internal-transfer.QA13 | Submit with `effectiveDate` missing entirely (AC4, distinct from QA09's invalid-format case) | **Reassigned to T03 at implementation** — `SubmitTransferRequestInput.effectiveDate` is a non-null `DateTime`, so "missing" isn't a state the repository layer can ever observe (Dart's type system already prevents it). The real test is at the submission-screen level: the Submit button stays disabled / shows "select an effective date" until the user picks one. |
| employee-internal-transfer.QA14 | Uninstall/reinstall the app (or clear app data) | The transfer request is gone — no multi-device or reinstall persistence exists (ADR-0004); this is an accepted limitation, not a bug, per the spec's Out of Scope |
| employee-internal-transfer.QA15 | Simulate a Manager decision while status is `PENDING_HR_VALIDATION` (added at T02 — same state-machine guard as UT14, different stage/stakeholder combination) | `Result.error`, "invalid decision for current state" |
| employee-internal-transfer.QA16 | Simulate a downstream stakeholder (e.g. Payroll) with an `approved`/`rejected` decision instead of `completed` (added at T02 — guards the decision-type dimension, not just stage/stakeholder) | `Result.error`, "invalid decision for current state" |

**Removed at v1.2 (no longer applicable, ADR-0004):**
- ~~`GET /transfer-requests/{id}` for a request owned by a different
  employee → 403~~ — there is no shared database or session to violate; one
  Hive store per device belongs to exactly one employee by construction.
- ~~`GET /transfer-requests/me/active` → 204 No Content~~ — superseded by
  QA06 above (local-method equivalent).
- ~~Submit while session token expired → 401~~ — there is no session/auth
  layer in a backend-less app.
- ~~Network drop mid-submission~~ — superseded by QA07 above (the local
  equivalent failure mode is an app/process interruption, not a dropped
  network call).

## Cross-feature / integration
_See `.ai-context/test_cases/_integration.md` for the full end-to-end journey
scenario (submit → simulate manager → simulate HR → simulate downstream →
Completed) and the already-flagged regression case for concurrent-request
behaviour._
