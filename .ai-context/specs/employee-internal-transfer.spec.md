# Spec: Employee Internal Transfer

## Spec ID
employee-internal-transfer

## Status
**Changes in progress (v1.5)** — self-reviewed against Gate 1 checklist (see
`.ai-context/reviews/employee-internal-transfer.gate1-review.md`) at v1.1,
revised at v1.2 to correct an architecture assumption (no backend, ADR-0004
supersedes ADR-0003), revised at v1.3 to make an implicit scoping call
explicit (see "Scope Decision" below), revised at v1.4 purely for a reviewer
reassignment (no ACs, contracts, or behavior changed at v1.3 or v1.4), and
revised at v1.5 to resolve the genuinely-open Gate 1 items from Shamik
Bhattacharya's decision register (G1-07, G1-12, G1-17, G1-22, G1-24, G1-28) —
new `FAILED` status, Decision History (OP05, AC17), `managerName` field
(via `employee-registration-login`), and explicit out-of-scope statements
for data ownership and inactive employees. v1.5 has **not** been re-reviewed
by Shamik yet — do not treat these additions as Gate-1-approved until he
confirms them. Ratified by the Author (Indrajit Bhandari) in lieu of an
independent Gate 1 sign-off at the time, by explicit instruction — departs
from constitution.md's Review Authority ("reviewer ≠ author"), logged here
rather than silently applied.

**Gate 1 reviewer reassigned 2026-09-17:** at the time of the v1.1–v1.3
self-review/ratification above, Subhajit Mukherjee was the assigned Gate 1
reviewer (hence the earlier references to him in this file and in
`reviews/employee-internal-transfer.gate1-review.md`) — that history is
accurate and left as-is. **Subhajit Mukherjee is now the Gate 2 reviewer**;
**Gate 1 for this project is now Shamik Bhattacharya**
(shamik.bhattacharya@intglobal.com). No independent Gate 1 review has
actually happened yet for any version of this spec — recommend **Shamik**
performs it before this ships to production, and that Gate 2 code review is
performed by **Subhajit Mukherjee** — see constitution.md's Review Authority
section: no one else's sign-off satisfies either gate.

## Linked BRD
`.ai-context/BRD.md#BRD-001`

> **Cross-reference note, added 2026-09-17 (not a version bump — nothing in
> this spec's own ACs/contract changes yet):** `BRD-002` /
> `specs/employee-registration-login.spec.md` introduces real employee
> accounts, which invalidates this spec's "one Hive store = one employee"
> assumption (originally ADR-0004). This spec will need an `employeeId` field
> added to its data model and its single-in-flight-request/ownership logic
> scoped per employee — tracked as this feature's own upcoming plan
> amendment, not implemented here yet. See that spec's "Cross-Feature
> Impact" section.

## Intent
Enable an employee to submit an internal transfer request — proposed
department/business unit, location, role, effective date, and an optional
reason — through the One-Point Employee Portal, and to see, at any time, the
request's current overall status and which stakeholder(s) (Manager, HR,
Payroll, IT, Facilities) currently hold the pending action. This replaces
today's manual, multi-team coordination with a single, trackable, locally
persisted journey. There is no backend for this project (ADR-0004) — "the
portal orchestrates downstream activities" from BRD-001 is realized here as a
locally-tracked state machine, not a real integration with those systems.

## Context
- Builds on: `.ai-context/architecture.md` (Integrations table), `ADR-0001`
  (Flutter client architecture), `ADR-0002` (mobile security hardening),
  `ADR-0004` (no backend — local DB as system of record)
- Related: none — this is the first feature spec in this project
- External API contract consumed: none. There is no backend, and no real
  integration with Manager/HR/Payroll/IT/Facilities systems (ADR-0004) — this
  spec's Local Data Contract below is the only contract in play, and it's
  between the presentation layer and the local repository, not a network call

## Scope Decision — One Spec, Not Multiple
_(v1.3) This feature bundles concerns that can look like they belong in
separate specs: employee-facing submission/status (AC1–AC13) and a demo-only
Simulate Decision control (AC14). Both the Author and an external reviewer
raised the question directly — "why is there only one spec, shouldn't there
be more?" This section is the answer, made explicit rather than left as an
undocumented assumption (which it was through v1.2)._

- **BRD-001 describes one cohesive business capability** — one intent, one
  journey, one set of "Decided" bullets. There is no second BRD entry for a
  second spec to trace back to, and the Blueprint requires a spec never be
  "the first place a requirement is written down" (§7) — splitting here would
  mean inventing a spec with no BRD behind it, which is its own anti-pattern,
  not a fix for one.
- **AC14 is not a business requirement in its own right.** It exists only
  because ADR-0004 (no backend) removed the real mechanism by which AC7–AC13's
  state transitions would occur. Without AC14, AC8–AC13 are undeliverable and
  untestable — it is a technical necessity of *this* spec, not a separable
  feature with its own "for whom."
- The status screen (AC6–AC13) and the Simulate control that drives it (AC14)
  are used together, by the same person, in the same session. A real
  per-stakeholder split would only make sense if this app had actual per-role
  interfaces for Manager/HR/Payroll/IT/Facilities — it explicitly does not
  (Explicitly Out of Scope).

**This is a judgment call, not a default — confirm or reject it at Gate 1.**
If a future BRD entry introduces a genuinely separate capability (e.g. a
manager-facing approval app), that gets its own slug and spec; it would not
retroactively justify splitting this one.

## Status Definitions
- **Non-terminal** (an "active" request, per AC2/AC9/AC11): `PENDING_MANAGER_APPROVAL`, `PENDING_HR_VALIDATION`, `PENDING_DOWNSTREAM_UPDATES`.
- **Terminal**: `COMPLETED`, `REJECTED_BY_MANAGER`, `REJECTED_BY_HR`. A terminal request never counts toward the single-in-flight-request rule (AC2) and never has a pending stakeholder.
- **`FAILED`** (v1.5, terminal) — a per-request status meaning one or more
  downstream stakeholders (Payroll/IT/Facilities) was simulated as `REJECTED`
  during `PENDING_DOWNSTREAM_UPDATES` (see AC15/AC16, Gate 1 G1-12/G1-24).
  Distinct from `REJECTED_BY_MANAGER`/`REJECTED_BY_HR`, which happen *before*
  downstream fan-out — `FAILED` means the request was approved by both Manager
  and HR but could not fully complete.

## Manager Identification (v1.5, Gate 1 G1-07)
BRD-001/this spec previously treated "the employee's current manager" as an
approver with no defined source — the Simulate Decision control let a tester
record a manager decision without the app ever knowing *who* that manager is.
Resolved for v1: `employee-registration-login.OP01` (register) captures a
`managerName: String` field alongside current department/location/role (see
that spec's Cross-Feature Impact section, added at the same time as this
change). This is a plain text field, not a lookup against an org-chart system
— there is no HRIS integration (ADR-0004) to validate it against, so it is
display-only: the status screen (AC7) shows this name as the pending
approver, and the Simulate Decision control's "Manager" action is unchanged.
No manager-identity verification is implied or performed, consistent with
this project's local-access-gate posture (ADR-0005).

## Decision History (v1.5, Gate 1 G1-17)
Previously, `transfer_requests` records were overwritten in place on every
state transition, with no record of what happened before the current state —
there was no way to answer "who decided what, and when" after the fact.
Resolved for v1: every successful state transition (AC8–AC13, AC15, AC16)
appends one immutable entry to a new **Decision History** local record (see
`plans/employee-internal-transfer.plan.md`'s Data Model for the storage
shape) — it is never edited or deleted, only appended to. AC17 below defines
the employee-visible behavior; the append itself is a repository-layer
side-effect of `OP04`, not a separate operation the employee triggers.

## How Stakeholder Actions Are Recorded
**Revised at v1.2 (ADR-0004).** This project has no backend, so there is no
server for Manager/HR/Payroll/IT/Facilities to call into, and no real
integration with their systems. Their decisions are recorded through a
**Simulate Decision control** (AC14), a clearly-labeled, non-production
affordance backed by `employee-internal-transfer.OP04`, that writes a state
transition directly to the local store. This is a deliberate, flagged
stand-in for a real integration that does not exist in this project's scope
— it does not claim to verify that a real Manager/HR/Payroll/IT/Facilities
decision occurred.

## Assumptions Requiring Gate 1 Confirmation
BRD-001 left several questions open. Each is resolved below with a specific,
testable v1 default so the Acceptance Criteria aren't built on an ambiguity —
Gate 1 should explicitly confirm or reject each, not wave them through:

1. **Approver** — only the employee's *current* manager approves in v1; the
   receiving department's manager is not consulted. (BRD-001 open question 1)
2. **Downstream fan-out** — Payroll, IT, and Facilities are **always** all
   three triggered once HR approves, regardless of what actually changed
   (e.g. a same-location role change still raises a Facilities step). No
   conditional skipping in v1. (BRD-001 open question 3)
3. **HR eligibility rule is intentionally opaque to this app** — revised at
   Gate 1 self-review (Finding 2): no AC in this spec depends on knowing HR's
   actual eligibility rule; every AC treats HR's decision as a black box
   ("given HR approves"/"given HR rejects"). The rule itself is HR's own
   internal process and is out of scope for this spec — it does not need
   business sign-off to Approve this spec.
4. **Single in-flight request** — an employee may have exactly one
   non-terminal transfer request at a time; a second submission attempt is
   rejected. (BRD-001 open question 6 — resolved, not deferred)
5. **No amend/withdraw** — a submitted request cannot be edited or withdrawn
   by the employee in v1. (BRD-001 open question 4 — resolved: out of scope)
6. **No SLA enforcement** — no reminders or escalation on stakeholder
   inaction in v1; the employee only sees elapsed pending time, not a
   breach state. (BRD-001 open question 5 — resolved: out of scope)
7. **In-portal status only** — no email/push notification in v1. (BRD-001
   open question 7 — resolved: out of scope)
8. **No backend, no real stakeholder integration (v1.2, ADR-0004)** — all
   Manager/HR/Payroll/IT/Facilities decisions are recorded via the in-app
   Simulate Decision control (AC14). This app cannot, on its own, guarantee a
   decision reflects a real stakeholder action — that limitation is inherent
   to this project's backend-less scope.
9. **Partial downstream failure (v1.5, Gate 1 G1-12/G1-24)** — if any of
   Payroll/IT/Facilities is simulated as `REJECTED` while
   `PENDING_DOWNSTREAM_UPDATES`, the request moves to `FAILED` (terminal)
   rather than being left stuck with no valid next state. There is no retry,
   automatic compensation, or partial-undo of the other two stakeholders'
   already-completed work — v1 surfaces the failure and stops there. Manual
   resolution (e.g. a corrected Simulate Decision, or the employee submitting
   a new request once this one is terminal) is the only recovery path;
   building real retry/compensation logic against real Payroll/IT/Facilities
   systems is out of scope until this project has real integrations
   (ADR-0004).
10. **Manager identification (v1.5, Gate 1 G1-07)** — the employee's manager
    is a plain-text `managerName` captured at registration
    (`employee-registration-login.OP01`), display-only, not verified against
    any authoritative source. See "Manager Identification" above.
11. **Field-level data ownership (v1.5, Gate 1 G1-22)** — for v1, the
    employee-submitted fields (department/location/role/effective
    date/reason) are owned and editable only by the submitting employee, via
    this spec's own OP01. Stakeholder-reported fields (each stakeholder's
    decision/status) are owned by the Simulate Decision control standing in
    for that stakeholder (OP04) — no other actor writes them. There is no
    real Payroll/IT/Facilities/HR system in this project to dispute or
    reconcile ownership against (ADR-0004); this ownership statement exists
    so a future real-backend project doesn't have to reverse-engineer intent
    from silence.
12. **Inactive/terminated employees (v1.5, Gate 1 G1-28)** — explicitly out
    of scope for v1. There is no HRIS integration or termination event
    feed (ADR-0004), so this app has no way to learn an employee has left;
    an inactive employee's account and any in-flight request simply remain
    as last written. Handling this correctly requires a real backend/HRIS
    integration and is deferred alongside the rest of ADR-0004's Explicitly
    Deferred items.

## Local Data Contract
No network API — every operation below is a local method call against the
repository (`data/repositories/`), backed by `LocalDbService` (Hive,
ADR-0004). All return the shared `Result<T>` type (ADR-0001 §4).

### employee-internal-transfer.OP01 — submitTransferRequest
**Input:**
```dart
{
  departmentId: String,
  locationId: String,
  roleId: String,
  effectiveDate: DateTime,
  reason: String?,
}
```
**Success:** `Result.success(TransferRequest)` — new record created, `status = PENDING_MANAGER_APPROVAL`.
**Errors (`Result.error(message)`):**
| Condition | Message |
|---|---|
| A mandatory field is missing/invalid | field-specific validation message |
| `effectiveDate` is not in the future | "Effective date must be in the future." |
| An active (non-terminal) request already exists | "You already have a transfer request in progress." |

### employee-internal-transfer.OP02 — getTransferRequestById
**Input:** `requestId: String`
**Success:** `Result.success(TransferRequest)`
**Errors:** "No request found for this ID." if absent from local storage.

### employee-internal-transfer.OP03 — getActiveTransferRequest
**Input:** none.
**Success:** `Result.success(TransferRequest)` if an active (non-terminal)
request exists locally, or `Result.success(null)` if there is none.

### employee-internal-transfer.OP04 — recordStakeholderDecision
_Backs the Simulate Decision control (AC14) only — not a real stakeholder-facing operation._
**Input:**
```dart
{
  requestId: String,
  stakeholder: MANAGER | HR | PAYROLL | IT | FACILITIES,
  decision: APPROVED | REJECTED | COMPLETED,
}
```
**Success:** `Result.success(TransferRequest)` — updated record, status
recalculated per the state machine (see `plans/employee-internal-transfer.plan.md`),
and one entry appended to Decision History (v1.5, see "Decision History"
above) recording `stakeholder`, `decision`, and a timestamp.
**Errors:** "Invalid decision for the request's current state." if the
stakeholder/decision combination doesn't match the expected next step (e.g.
simulating an HR decision while still `PENDING_MANAGER_APPROVAL`, or any
decision once the request is already terminal — including `FAILED`).

**v1.5 addition:** `REJECTED` is now a valid `decision` for `PAYROLL`, `IT`,
or `FACILITIES` while `PENDING_DOWNSTREAM_UPDATES` (previously only
`COMPLETED` was valid for those three) — see AC16.

### employee-internal-transfer.OP05 — getDecisionHistory (v1.5, Gate 1 G1-17)
**Input:** `requestId: String`
**Success:** `Result.success(List<DecisionHistoryEntry>)` — ordered
oldest-first, one entry per state transition ever recorded for this request
(including the initial submission). Empty list is never returned for a valid
`requestId` — submission itself is the first entry.
**Errors:** "No request found for this ID." if `requestId` doesn't exist —
same wording as OP02.

## Acceptance Criteria
1. **employee-internal-transfer.AC1** — Given an employee with no active
   transfer request, when they open the Internal Transfer Request screen,
   then they can select proposed department, location, role, enter an
   effective date, and optionally enter a reason.
2. **employee-internal-transfer.AC2** — Given an employee already has a
   non-terminal transfer request, when they attempt to open the submission
   screen, then they see a message that a request is already in progress and
   cannot submit a new one.
3. **employee-internal-transfer.AC3** — Given all mandatory fields are valid
   and the effective date is in the future, when the employee submits, then
   the request is created with status `PENDING_MANAGER_APPROVAL` and the
   employee sees a confirmation.
4. **employee-internal-transfer.AC4** — Given department, location, role, or
   effective date is missing, when the employee attempts to submit, then
   submission is blocked with a field-level validation message and no
   request is created.
5. **employee-internal-transfer.AC5** — Given an effective date that is today
   or in the past, when the employee attempts to submit, then submission is
   blocked with a message stating the effective date must be in the future.
6. **employee-internal-transfer.AC6** — Given a submitted request, when the
   employee views "My Transfer Request" status, then they see the overall
   status and the department/location/role/effective date/reason they
   submitted.
7. **employee-internal-transfer.AC7** — Given a request in
   `PENDING_MANAGER_APPROVAL`, when the employee views pending actions, then
   "Manager" is shown as the sole pending stakeholder.
8. **employee-internal-transfer.AC8** — Given the manager approves, when HR
   validation begins, then status moves to `PENDING_HR_VALIDATION` and the
   pending stakeholder becomes "HR".
9. **employee-internal-transfer.AC9** — Given the manager rejects, when the
   employee views status, then the request shows `REJECTED_BY_MANAGER`, no
   stakeholder is pending, and the employee may submit a new request (AC2's
   "active request" check no longer blocks them).
10. **employee-internal-transfer.AC10** — Given HR approves, when downstream
    updates are triggered, then status moves to `PENDING_DOWNSTREAM_UPDATES`
    and the pending stakeholders shown are exactly Payroll, IT, and
    Facilities.
11. **employee-internal-transfer.AC11** — Given HR rejects, when the employee
    views status, then the request shows `REJECTED_BY_HR`, no stakeholder is
    pending, and the employee may submit a new request.
12. **employee-internal-transfer.AC12** — Given Payroll, IT, and Facilities
    have all reported their step complete, when the employee views status,
    then the request shows `COMPLETED` and no stakeholder is pending.
13. **employee-internal-transfer.AC13** — Given Payroll has completed but IT
    and Facilities have not, when the employee views pending actions, then
    only IT and Facilities are shown as pending.
14. **employee-internal-transfer.AC14** (new, v1.2) — Given this app has no
    backend, when Manager/HR/Payroll/IT/Facilities need to act on a request,
    then a clearly-labeled Simulate Decision control (never presented as a
    real stakeholder-facing feature) lets a tester record that decision
    locally via `OP04`, driving the same state transitions described in
    AC8–AC13.
15. **employee-internal-transfer.AC15** (new, v1.5) — Given a request in
    `PENDING_DOWNSTREAM_UPDATES`, when any one of Payroll, IT, or Facilities
    is simulated as `REJECTED`, then the request's status becomes `FAILED`
    (terminal), no stakeholder remains pending, and the employee may submit a
    new request (same as AC9/AC11's "active request" release).
16. **employee-internal-transfer.AC16** (new, v1.5) — Given a request already
    in a terminal status (`COMPLETED`, `REJECTED_BY_MANAGER`,
    `REJECTED_BY_HR`, or `FAILED`), when any further Simulate Decision is
    attempted against it, then `OP04` returns `Result.error` and the
    request's status does not change.
17. **employee-internal-transfer.AC17** (new, v1.5) — Given a request with at
    least one recorded state transition, when the employee views its
    Decision History, then they see every transition in chronological order
    (stakeholder, decision, timestamp), and this history is read-only —
    nothing on this screen lets the employee edit or delete an entry.

## Unit Test Cases (spec-derived)
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
| employee-internal-transfer.UT13 | AC9 | After a manager rejection, employee submits a new request | New request accepted (rejected request does not count as "active") |
| employee-internal-transfer.UT14 | AC14 | Simulate an HR decision while status is still `PENDING_MANAGER_APPROVAL` | `Result.error`, "invalid decision for current state" |
| employee-internal-transfer.UT15 | AC15 | Simulate IT `REJECTED` while `PENDING_DOWNSTREAM_UPDATES` (Payroll/Facilities still pending) | status `FAILED`, `pendingStakeholders = []` |
| employee-internal-transfer.UT16 | AC16 | Simulate any decision against a request already `COMPLETED` (or `FAILED`, `REJECTED_BY_MANAGER`, `REJECTED_BY_HR`) | `Result.error`, status unchanged |
| employee-internal-transfer.UT17 | AC17 | `getDecisionHistory` after manager approve + HR approve | Two ordered entries returned, oldest first |
| employee-internal-transfer.UT18 | AC15 | After a downstream `FAILED` request, employee submits a new request | New request accepted (`FAILED` does not count as "active") |

## Explicitly Out of Scope
- Editing or withdrawing a submitted request.
- SLA timers, reminders, or escalation for stakeholder inaction.
- Email/push notification (in-portal status view only).
- Conditional skipping of Payroll/IT/Facilities based on what actually
  changed — all three always run in v1.
- Receiving-department manager approval — only the current manager approves.
- More than one non-terminal request per employee at a time.
- International or cross-legal-entity transfers (per BRD-001 notes).
- A production-grade, authenticated, per-stakeholder action interface — the
  Simulate Decision control (AC14) is a single, unauthenticated, in-app
  stand-in for demo/test purposes only.
- Any real backend, real datastore, or real integration with Manager/HR/
  Payroll/IT/Facilities systems (ADR-0004) — none exist for this project.
- Multi-device sync — a request lives on the device it was submitted from.
- Automatic retry, escalation, or compensation on a downstream `FAILED`
  request (v1.5) — the employee's only recovery path is submitting a new
  request once the failed one is terminal (AC15).
- Manager-identity verification — `managerName` (v1.5) is a plain-text,
  unverified field; there is no org-chart/HRIS lookup (ADR-0004).
- Any handling for inactive/terminated employee accounts (v1.5, Gate 1
  G1-28) — deferred alongside the rest of ADR-0004's Explicitly Deferred
  items; requires a real HRIS integration this project does not have.

## Non-Functional Constraints (from constitution.md)
- Local read (status view) and write (submission, Simulate Decision) complete
  well under 500ms on a mid-range device — no network latency applies, since
  this feature has no backend (ADR-0004).
- No employee PII beyond what's operationally necessary appears in any log,
  at any level.
- Ownership ("may only read/act on a request they own") is inherent to the
  local, single-employee-per-device data model (ADR-0004) — not a
  server-enforced rule, since there is no server.
- Every mandatory field (department, location, role, effective date) has a
  client-side validator (`core/utils/validators.dart`); since the local
  repository is the only boundary (no separate API layer), it is also
  re-validated there before writing to `LocalDbService`.
