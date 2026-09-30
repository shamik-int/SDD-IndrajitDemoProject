# Spec: Employee Internal Transfer

## Spec ID
employee-internal-transfer

## Status
**v2.4 — Gate 1 Approved (Shamik Bhattacharya, 2026-09-30).**
Approved by the named Gate 1 reviewer, including CL-01 and CL-02 as the
spec's reading of BRD-001 v5.2 (BRD 5.2 unchanged). Plan, tasks and the
implementation test cases
(`.ai-context/test_cases/employee-internal-transfer.test_cases.md`) may now
be written from this spec. The acceptance scenarios in this spec (UT01–UT70,
XF01–XF09) are part of the spec itself, not implementation test cases; see
"Acceptance scenarios".

| | |
|---|---|
| Author | Indrajit Bhandari |
| Gate 1 reviewer | Shamik Bhattacharya |
| Updated | 2026-09-30 |
| Gate 1 decision | **Approved**, Shamik Bhattacharya (shamik.bhattacharya@intglobal.com), 2026-09-30. Recorded in `.ai-context/reviews/employee-internal-transfer.spec-v2.1.gate1-review.md` |
| Linked BRD | `.ai-context/BRD.md#BRD-001`, **v5.2, Gate 1 Approved 2026-09-28** |
| Previous versions | `employee-internal-transfer.spec-v2.3-backup-2026-09-29.md` (v2.3), `employee-internal-transfer.spec-v2.2-draft-backup-2026-09-29.md` (v2.2 draft, incomplete), `…spec-v2.1-backup-2026-09-28.md` (v2.1), `…spec-v2.0-backup-2026-09-28.md`, `…spec-v1.5-backup-2026-09-28.md` |
| Gate 1 review answered | `.ai-context/reviews/employee-internal-transfer.spec-v2.1.gate1-review.md`: 11 mandatory items and 8 scenarios (Shamik Bhattacharya). See "Gate 1 review response" |
| Points not in BRD 5.2 | `reviews/employee-internal-transfer.spec-v2.4.not-in-BRD-5.2.md` (reference note; BRD 5.2 is not changed) |

**How v2.4 was written.** v2.4 is the Author's (Indrajit Bhandari)
revision of v2.3. It keeps every v2.3 answer to the reviewer's 11 items and
8 scenarios, cross-checks the spec against the approved BRD-001 v5.2, and:
- **leaves BRD-001 v5.2 unchanged**: the two points that go beyond it
  (CL-01, CL-02) are kept in the spec because the reviewer's items 1, 2
  and 6 ask for them, and are recorded as **points not in BRD 5.2**; no BRD
  change is requested;
- marks every review item, spec decision and acceptance criterion that
  BRD 5.2 does not mention with **"Not mentioned in BRD 5.2"**;
- lists all of them in the reference note `reviews/employee-internal-transfer.spec-v2.4.not-in-BRD-5.2.md`.

No behaviour, AC, scenario or ID from v2.3 is removed or renumbered.

**How v2.3 was written.** v2.3 answers every one of the Gate 1 reviewer's
11 mandatory items and 8 scenarios. The v2.2 draft started this work but
applied it only to the Definitions and the Consumed contract. OP06, the
history shape, the acceptance criteria, the spec decisions and the scenarios
still described v2.1 behaviour, and some referenced sections did not exist.
v2.3 applies the changes to the whole document. The v2.2 draft is kept for
reference only and must not be reviewed or built from.

**What changes, in short:**
- The organisational change is scheduled only when the whole request
  completes. A downstream failure therefore never leaves a transfer
  scheduled (SD-16).
- A new request is blocked until a completed transfer has taken effect, so
  two future transfers can never be scheduled for one employee (SD-17).
- Only a demo tester can use the simulation. An employee never sees it and
  cannot call it (SD-18).
- The history has a `SYSTEM` actor for every automatic change (SD-19).
- `scheduleOrganisationalChange` is idempotent by `requestId` (SD-20).
- The spec now defines what happens when the effective date passes while a
  request is still pending (SD-05, revised).
- The Security boundary section states that V1 has application-level
  protection only.
- Cross-flow scenarios XF01–XF09 are added.

**BRD-001 v5.2 is not changed.** CL-01 and CL-02 read or narrow BRD 5.2
rules (BR-07, BR-13, BR-15, BR-16, BR-17). They follow the reviewer's items
1, 2 and 6 and are recorded as **points not in BRD 5.2** (see "Points not in
BRD 5.2" and the reference note), not as a BRD change.

**Earlier versions.** v2.1 added the stakeholder contract, actors, status
labels, AC27–AC30, UT33–UT50 and SD-10 to SD-15 after a rule-by-rule check of
BRD-001 v5.2. v2.0 was rebuilt from **BRD-001 v5.2 only** (review comment
#16). It carries nothing over from spec v1.5, BRD-002 or
`employee-registration-login`. Every acceptance criterion cites the BRD-001
rule it implements (see Traceability).

**The existing code implements spec v1.5, not v2.x.** It must not be
treated as meeting this spec. This revision changes the spec only. No code
has been changed.

## Gate 1 review response
Every reviewer item, and where v2.3 answers it.

| # | Priority | Reviewer item | Spec answer | Where | In BRD 5.2? |
|---|---|---|---|---|---|
| 1 | 🔴 Critical | Downstream step fails after the org change is scheduled | The change is scheduled only when the request becomes `COMPLETED`, which means every required step has completed. A `FAILED` request never has a scheduled change, and the profile never changes. Point not in BRD 5.2 (CL-01) | Three moments; OP06 effects; AC16, AC17, AC20; SD-16; XF01, XF08 | 💬 **Not mentioned in BRD 5.2.** Differs from BR-13/BR-16 (CL-01) |
| 2 | 🔴 Critical | Conflicting future transfers | Blocked. A new request cannot be submitted while a `COMPLETED` transfer has not yet taken effect. The contract also refuses a second schedule for the same employee. Point not in BRD 5.2 (CL-02) | OP01 error 6; AC18, AC34; SD-17, SD-20; XF02, XF09 | 💬 **Not mentioned in BRD 5.2.** Differs from BR-07/BR-17 (CL-02) |
| 3 | 🔴 Critical | Restrict the simulation controls | The simulation is available only to a demo account with the `TESTER` role. An `EMPLOYEE` never sees it, and OP06/OP07 refuse them. A tester cannot own or submit a request | Actors; Access rules; OP06, OP07; AC24, AC32; SD-18; XF03 | ⚠️ Partly: BR-23, BR-24. 💬 **The `TESTER` role is not mentioned in BRD 5.2.** |
| 4 | 🔴 Critical | Audit actor for system changes | `SYSTEM` actor. Every status change, every step the portal starts, stops or marks not required, and the schedule entry are recorded by `SYSTEM` | Data shapes (history entry and "Which actor records which entry" table); OP06 effects; AC23; SD-19; UT30, UT55–UT57; XF04 | ⚠️ Partly: BR-27. 💬 **The `SYSTEM` actor is not mentioned in BRD 5.2.** |
| 5 | 🟠 High | Effective date passed, workflow still pending | The request carries on and the effective date never changes. The employee sees a "date has passed" note. If the request completes, the new values show from the day it completes | Request status (effective date passed); AC33; SD-05; XF05 | 💬 **Not mentioned in BRD 5.2.** BR-05 covers the check at submission only |
| 6 | 🟠 High | Meaning of `ORG_RECORD_UPDATE` = `COMPLETED` | "Recorded": HR confirmed the new values for the date. It is not "scheduled" and not "effective". Three moments are defined | Three moments; AC16 | ✅ BR-13 (recorded, effective from the effective date); scheduling only on `COMPLETED` is CL-01 |
| 7 | 🟠 High | `scheduleOrganisationalChange()` called twice | The unique key is `requestId`. A repeat call with the same values returns the existing change. A call with different values, or for another request while a change is pending, is refused | Consumed contract (SD-20); AC35; XF06 | 💬 **Not mentioned in BRD 5.2.** |
| 8 | 🟠 High | Negative tests: employee A vs B; logout/login | Scenarios for listing, opening, history and operating on another employee's request. A sign-out clears all shown and held request data | Access rules; AC22, AC31, AC32; UT28, UT52, UT67, UT68; XF07 | ⚠️ Partly: BR-23. 💬 **Sign-out clearing is not mentioned in BRD 5.2.** |
| 9 | 🟠 High | Separate demo security from production | Security boundary section: V1 protection is application-level only and is not production-grade authorization | Security boundary; Non-Functional Constraints | ✅ BR-26 (not production-ready; server-side needed for production) |
| 10 | 🟡 Medium | Test-case statement vs UT01–UT50 | UT and XF are **acceptance scenarios**, part of the spec. Implementation test cases are written after Gate 1 and must cover every one | Status; Acceptance scenarios | 💬 **Not mentioned in BRD 5.2.** Document structure |
| 11 | 🟡 Medium | Cross-flow scenarios | XF01–XF09, covering the reviewer's 8 scenarios plus the "future date + failure + new request" example | Cross-flow scenarios | 💬 **Not mentioned in BRD 5.2.** Scenario structure |

| Reviewer scenario | Covered by |
|---|---|
| Transfer scheduled → Payroll fails | XF01 |
| Transfer scheduled for Oct 15 → another for Oct 30 | XF02 |
| Employee tries Manager/HR simulation | XF03 |
| Manager approves → audit shows SYSTEM | XF04 |
| Effective date passes while HR pending | XF05 |
| Same org change triggered twice | XF06 |
| Employee A logs out → Employee B logs in | XF07 |
| One downstream step fails after others completed | XF08 |
| (Item 11 example) Future date + downstream failure + new request | XF09 |

## Intent
An employee raises an internal transfer request in the One-Point Employee
Portal and tracks it in one digital journey (BRD-001 §1). The portal runs
the journey: current manager approval, HR eligibility, then the
organisational record update and whichever of Payroll, IT and Facilities
the change requires. The employee sees one view of progress: the overall
status, each stakeholder step and its pending action, the reason for any
rejection, an append-only history, and a confirmation for every final
outcome.

## Context
- Business requirement: BRD-001 v5.2 (§1–§14). No other BRD applies.
- Architecture constraints already decided:
  - ADR-0001: Flutter client, Clean Architecture, GetX; every operation
    returns the shared `Result<T>`.
  - ADR-0002: runtime security hardening (root/jailbreak/hook detection).
  - ADR-0004: no backend. Stakeholder outcomes are recorded through a
    demo-only simulation (BRD-001 BR-24, §9). Storage and data model are
    decided in the Plan, not here.
- Depends on (BRD-001 §11), outside this spec:
  - **D-01 sign-in:** the user is signed in to the portal, with a role
    (`EMPLOYEE`, or `TESTER` in V1 demo builds only; SD-18). Demo-level in
    V1 (BR-26). This spec only consumes the signed-in user's ID and role.
  - **D-02 profile:** the portal profile supplies the employee's current
    department, location, role and current manager (BR-03, BR-10). It also
    holds the scheduled organisational change (BR-13).
  - **D-03 reference lists:** departments/business units, locations and
    roles (BR-02; A-02, A-03). Demo lists in V1.
  - **D-04 manager conversation:** journey step 1 happens before the
    employee uses the portal. It is not captured or verified; the manager's
    approval (AC10) is the recorded confirmation. Nothing in this spec
    depends on it.
- Inherited BRD-001 assumptions: A-01 (portal, sign-in and profile exist;
  demo-level in V1), A-02 (department/business unit is one selection),
  A-03 (reference lists available; demo lists in V1), A-06 (trigger rules
  confirmed by the Sponsor before production), A-07 (downstream steps are
  independent and can complete in any order, AC15). A-04 and A-05 (Sponsor,
  priority) do not affect the spec.
- The Plan decides how D-01 to D-03 are provided in V1, including how the
  demo `TESTER` account is seeded. This spec defines only what it needs from
  them (Consumed contract, below).

## Scope Decision — one spec
BRD-001 describes one capability with one journey, so there is one spec.
The demo-only simulation (AC24–AC26, AC32) is part of this spec because,
with no backend (ADR-0004), it is the only way stakeholder outcomes reach
the journey (BR-24). It is not a separate feature and not a stakeholder
interface.

## Definitions

### Actors (BRD-001 §2)
| Actor | In this spec |
|---|---|
| Employee (primary user) | Signed-in user with role `EMPLOYEE` (D-01). Submits and views only their own requests (OP01–OP05, BR-23). Cannot use the simulation (OP06, OP07) |
| Current manager | Owns `MANAGER_APPROVAL` (simulated in V1) |
| HR | Owns `HR_ELIGIBILITY` and `ORG_RECORD_UPDATE` (simulated) |
| Payroll | Owns `PAYROLL_UPDATE` (simulated) |
| IT | Owns `IT_ACCESS_CHANGE` (simulated) |
| Facilities | Owns `FACILITIES_WORKSPACE` (simulated) |
| Demo tester (V1 only) | Signed-in user with role `TESTER` (D-01). The only user who can open the simulation and record stakeholder outcomes (OP06, OP07; SD-18). Has no employee profile, cannot submit or own a request, and cannot use OP01–OP05. Not a BRD-001 actor: it stands in for the stakeholders because V1 has no real integration (BR-24). The role is set in the demo account data and cannot be chosen at sign-in or sign-up |
| System | The portal itself. Records every status change, every step it starts, stops or marks not required, and the scheduling of the organisational change (SD-19). Never records a stakeholder decision |

The history `actor` of each stakeholder outcome is the stakeholder that owns
the step, never the employee, the tester or `SYSTEM` (BR-24). An outcome
entered through the simulation also records `simulatedBy`, the tester's
user ID. The history therefore shows both who owns the decision and who
actually entered it in the demo.

### Access rules (BR-23, BR-24; SD-18)
| Operation | No one signed in | `EMPLOYEE` | `TESTER` |
|---|---|---|---|
| OP01–OP05 (submit, view own requests and history) | "Please sign in." | Own requests only | "This action is for employees only." |
| OP06 (record outcome), OP07 (list open tasks) | "Please sign in." | "Only a demo tester can record stakeholder outcomes." | All requests |

The checks are done in the repository, in this order: signed in, then role,
then ownership. They are not only hidden in the UI. A refused call changes
nothing and adds no history entry.

### Request status (BR-06, BR-11 to BR-17)
| Status | Final? | Label shown to the employee (SD-14) | Meaning |
|---|---|---|---|
| `PENDING_MANAGER_APPROVAL` | No | Pending manager approval | Submitted; waiting for the current manager |
| `PENDING_HR_ELIGIBILITY` | No | Pending HR eligibility check | Manager approved; waiting for HR |
| `IN_PROGRESS` | No | In progress | HR approved; downstream steps running |
| `COMPLETED` | Yes | Completed | Org record update and every required step completed; organisational change scheduled (BR-15, SD-16) |
| `REJECTED_BY_MANAGER` | Yes | Rejected by Manager | Manager rejected, with reason (BR-11, BR-28) |
| `REJECTED_BY_HR` | Yes | Rejected by HR | HR rejected, with reason (BR-12, BR-28) |
| `FAILED` | Yes | Failed | A required downstream step failed. Nothing was scheduled (BR-16, SD-16) |

A request is **in progress** when its status is not final (BR-07, BR-17).

Two conditions are derived from the device local date. Neither is a status
or is stored:

- **Awaiting effect** (SD-17): the status is `COMPLETED` and today is
  before the effective date. The transfer is approved and scheduled, but the
  profile still shows the current values (BR-13). Shown as "Completed:
  takes effect on <effective date>". A new request is blocked while this
  holds.
- **Effective date passed** (SD-05): the request is in progress and today is
  on or after the effective date. The status and the effective date do not
  change. The request screen shows: "The effective date (<effective date>)
  has passed. Your request continues and the date is not changed. If it
  completes, your new department, location and role will show from the day
  it completes."

### The three moments of the organisational change (SD-16)
The reviewer asked what `ORG_RECORD_UPDATE` = `COMPLETED` means. There are
three separate moments, and only the third changes what the profile shows.

| Moment | When | What it means | What changes |
|---|---|---|---|
| **Recorded** | HR records `ORG_RECORD_UPDATE` = `COMPLETED` | HR has confirmed the new department, location and role for the effective date. The step is done | Step state only. The profile does **not** change, and nothing is scheduled |
| **Scheduled** | The request becomes `COMPLETED`, when the last required step completes, whichever step that is | The portal calls `scheduleOrganisationalChange` once, in the same save as the status change | One scheduled change exists, effective from the effective date. `SYSTEM` records a `CHANGE_SCHEDULED` history entry |
| **Effective** | The device local date reaches the effective date, or it has already passed at scheduling (SD-05) | The scheduled change takes effect | The profile (`getCurrentValues`) shows the new values |

"Effective" is not a history entry. Nothing happens in the app at that
moment: the date is reached, and `getCurrentValues` starts returning the
new values. The `CHANGE_SCHEDULED` entry records the date.

A request that ends `FAILED` never reaches "Scheduled", so no transfer is
scheduled and the profile never changes. This keeps BR-16: the completed
`ORG_RECORD_UPDATE` step is not rolled back. It stays `COMPLETED` in the
request and the history. There is nothing to roll back, because the change
is applied only when the whole transfer succeeds. This reading of BR-13 and
BR-16 is **CL-01**.
> 💬 **Not mentioned in BRD 5.2** (CL-01). BRD 5.2 is not changed; see the
> reference note.

### Steps (BRD-001 §3, §6)
| Step ID | Stakeholder | Pending action shown (§6) | Required |
|---|---|---|---|
| `MANAGER_APPROVAL` | Current manager | Manager approval | Always |
| `HR_ELIGIBILITY` | HR | HR eligibility check | Always |
| `ORG_RECORD_UPDATE` | HR | Organisational record update | Always, once HR approves (BR-13) |
| `PAYROLL_UPDATE` | Payroll | Payroll update | Role **or** location changes (§5) |
| `IT_ACCESS_CHANGE` | IT | IT access change: provision new access, remove old access | Department **or** role changes (§5) |
| `FACILITIES_WORKSPACE` | Facilities | Facilities: workspace at the new location | Location changes (§5) |

### Step state (BR-19)
`PENDING`, `COMPLETED`, `REJECTED`, `FAILED`, `STOPPED`, `NOT_REQUIRED`,
shown as "Pending", "Completed", "Rejected", "Failed", "Stopped" and "Not
required". An approved manager or HR step is shown as "Completed
(Approved)". No other state is used (spec decision SD-01).

- An approval by the manager or HR records that step as `COMPLETED` with
  decision `APPROVED` (SD-02).
- `REJECTED` applies only to `MANAGER_APPROVAL` and `HR_ELIGIBILITY`.
- `FAILED` and `STOPPED` apply only to the four downstream steps.

### Downstream triggers (BRD-001 §5)
Computed when HR approves, by comparing the proposed values with the
**current values snapshot** taken at submission (SD-03):

| Changed | Org record | Payroll | IT | Facilities |
|---|---|---|---|---|
| Department only | Required | Not required | Required | Not required |
| Location only | Required | Required | Not required | Required |
| Role only | Required | Required | Required | Not required |
| Department + location | Required | Required | Required | Required |
| Department + role | Required | Required | Required | Not required |
| Location + role | Required | Required | Required | Required |
| All three | Required | Required | Required | Required |

These are the V1 business rule. The Sponsor confirms them before production
(BRD-001 A-06).

## Consumed contract (dependencies D-01 to D-03)
What this feature needs from the portal. How it is provided in V1 is a Plan
decision.

```dart
// D-01 — the signed-in user. null when nobody is signed in.
CurrentUser? currentUser();
// { userId, role: EMPLOYEE | TESTER }   (TESTER exists in V1 demo builds only, SD-18)

// D-02 — the employee's current values, as of a given date.
EmployeeCurrentValues getCurrentValues(String employeeId, {required DateTime asOf});
// { departmentId, locationId, roleId, managerName }

// D-02 — schedule an organisational change that takes effect from a date (BR-13).
// Called only when a request becomes COMPLETED (SD-16). Idempotent by requestId (SD-20).
// effectiveFrom may be today or in the past when the effective date passed while pending (SD-05).
Result<ScheduledChange> scheduleOrganisationalChange(String employeeId, {
  required String requestId,
  required String departmentId, required String locationId,
  required String roleId, required DateTime effectiveFrom,
});
// ScheduledChange { requestId, employeeId, departmentId, locationId, roleId, effectiveFrom, scheduledAt }

// D-02 — the employee's scheduled change that has not taken effect yet, if any (SD-17).
ScheduledChange? pendingScheduledChange(String employeeId, {required DateTime asOf});

// D-03 — reference lists.
List<ReferenceItem> departments();  // { id, name }
List<ReferenceItem> locations();
List<ReferenceItem> roles();
```

`getCurrentValues` returns the scheduled values only when `asOf` is on or
after **both** `effectiveFrom` and the date of `scheduledAt`. Before that it
returns the previous values (BR-13). So a change completed after its
effective date (SD-05) shows from the completion day and never
retroactively: a read for an earlier date still returns the previous
values.
`pendingScheduledChange` returns a change only while `asOf` is before its
`effectiveFrom`. `managerName` is demo data, not verified, and grants no
authority outside the request (BR-10).

**`scheduleOrganisationalChange` idempotency and conflicts (SD-20).** The
unique key is `requestId`: at most one scheduled change exists per request.

| Call | Result |
|---|---|
| First call for this `requestId` | `Result.success(ScheduledChange)`; one change is scheduled |
| Repeat call, same `requestId`, same values and date | `Result.success` with the **existing** `ScheduledChange` (same `scheduledAt`). Nothing new is created |
| Repeat call, same `requestId`, different values or date | `Result.error("A different change is already scheduled for this request.")`. The existing change is kept |
| Call for another `requestId` while this employee has a change that has not taken effect | `Result.error("Another transfer is already scheduled for this employee.")`. Nothing is scheduled |

If the call returns an error, the request does not become `COMPLETED`. The
last step's outcome, its history entries, the status change and the schedule
are saved together or not at all. OP06 returns the error, and the step stays
`PENDING`. With SD-17 in force, the last two rows cannot happen through the
journey. They protect the contract against misuse.

## Security boundary (V1) — not production authorization
V1 has no backend (ADR-0004). Every protection in this spec runs **inside
the app, on the device**:

- The ownership, role and sign-in checks (Access rules) are
  **application-level protection only**. They stop the app's own screens
  and repository from showing or changing another employee's data. They
  are **not production-grade authorization** and must not be described as
  such.
- The role, the signed-in identity and the local data are all demo-level
  (BR-26). Anyone with access to the device, its storage or a modified app
  can bypass them. V1 cannot prove who took any decision (BR-24).
- The `TESTER` role stops an employee from approving their own transfer
  **through the app**. It is not a control against a person who also holds
  a tester account. The demo accounts are test data (BR-25).
- A production release needs server-side authentication and authorization
  for every operation (BR-26), real stakeholder integrations in place of
  the simulation (SD-13), and removal of the `TESTER` role. None of these is
  part of V1.

## Local Data Contract
Local operations between the presentation layer and the repository. No
network API (ADR-0004). Every operation returns `Result<T>` (ADR-0001) and
applies the Access rules before anything else.

### employee-internal-transfer.OP01 — submitTransferRequest
**Input:**
```dart
{
  submissionId: String,     // generated once per submit action (BR-08)
  departmentId: String,
  locationId: String,
  roleId: String,
  effectiveDate: DateTime,  // date only
  reason: String?,          // optional free text, at most 500 characters (SD-10)
}
```
**Success:** `Result.success(TransferRequest)`. The new request:
- belongs to the signed-in employee;
- holds a snapshot of the current department, location, role and manager
  name, read from D-02 as of today (BR-03);
- has status `PENDING_MANAGER_APPROVAL`, step `MANAGER_APPROVAL` =
  `PENDING` (BR-06);
- has one `SUBMITTED` history entry, actor `EMPLOYEE` (BR-27).

**Idempotency (BR-08):** if a request with the same `submissionId` already
exists for this employee, OP01 returns that request unchanged. No second
request and no second history entry are created. This check comes before
the errors below.

**Errors**, after the Access rules, checked in this order. No request and
no history entry is created:
| # | Condition | Message |
|---|---|---|
| 1 | Department, location or role missing, or not in its reference list | Field-level message, e.g. "Select a department." |
| 2 | Effective date missing | "Enter an effective date." |
| 3 | Effective date is today or earlier (device local date) | "Effective date must be in the future." |
| 4 | Department, location and role all equal the current values | "Change at least one of department, location or role." |
| 5 | The employee already has a request in progress | "You already have a transfer request in progress." |
| 6 | The employee has a `COMPLETED` request awaiting effect (SD-17) | "Your previous transfer takes effect on <effective date>. You can submit a new request from that date." |
| 7 | Reason longer than 500 characters | "Reason must be 500 characters or fewer." |

A reason that is empty or only spaces is stored as no reason. There is no
maximum effective date (SD-11). The request and its `SUBMITTED` history
entry are saved together or not at all.

### employee-internal-transfer.OP02 — getMyActiveTransferRequest
**Input:** none.
**Success:** `Result.success(ActiveState)`:
`{ inProgress: TransferRequest?, awaitingEffect: TransferRequest? }`. At most
one of the two is set. When both are `null`, the employee can submit. The
form uses this to show the OP01 error 5 or 6 message before the employee
fills anything in.

### employee-internal-transfer.OP03 — listMyTransferRequests
**Input:** none.
**Success:** `Result.success(List<TransferRequestSummary>)`: all of the
employee's requests, newest first (`requestId`, submitted date, status).
Empty list if none.

### employee-internal-transfer.OP04 — getMyTransferRequest
**Input:** `requestId: String`
**Success:** `Result.success(TransferRequest)` with its steps.
**Errors:** "No request found." when the ID does not exist **or belongs to
another employee**. The two cases give the same message (SD-04).

### employee-internal-transfer.OP05 — getRequestHistory
**Input:** `requestId: String`
**Success:** `Result.success(List<HistoryEntry>)`, oldest first. Never empty
for a valid request: `SUBMITTED` is always the first entry.
**Errors:** "No request found.", same rule as OP04.

### employee-internal-transfer.OP06 — recordStakeholderOutcome (demo-only, `TESTER` only)
_Backs the demo-only simulation (AC24–AC26, AC32). Not a stakeholder
interface (BR-24)._

**Input:**
```dart
{
  requestId: String,
  stepId: MANAGER_APPROVAL | HR_ELIGIBILITY | ORG_RECORD_UPDATE
        | PAYROLL_UPDATE | IT_ACCESS_CHANGE | FACILITIES_WORKSPACE,
  outcome: APPROVED | REJECTED | COMPLETED | FAILED,
  reason: String?,   // mandatory when outcome == REJECTED (BR-28); at most 500 characters (SD-10)
}
```

**Valid outcomes per step:**
| Step | Valid outcomes |
|---|---|
| `MANAGER_APPROVAL`, `HR_ELIGIBILITY` | `APPROVED`, `REJECTED` (with reason) |
| `ORG_RECORD_UPDATE`, `PAYROLL_UPDATE`, `IT_ACCESS_CHANGE`, `FACILITIES_WORKSPACE` | `COMPLETED`, `FAILED` |

**Effects.** Each outcome, all its history entries, any status change and
any schedule are saved together or not at all. History entries are written
in the order listed.
| Outcome | Effect | History entries (actor) |
|---|---|---|
| Manager `APPROVED` | Step `COMPLETED`; status → `PENDING_HR_ELIGIBILITY`; `HR_ELIGIBILITY` = `PENDING` | `STEP_OUTCOME` (MANAGER); `STATUS_CHANGED` (SYSTEM); `STEP_SET` HR → `PENDING` (SYSTEM) |
| Manager `REJECTED` | Step `REJECTED` with reason; status → `REJECTED_BY_MANAGER` | `STEP_OUTCOME` with reason (MANAGER); `STATUS_CHANGED` (SYSTEM) |
| HR `APPROVED` | Step `COMPLETED`; status → `IN_PROGRESS`; `ORG_RECORD_UPDATE` = `PENDING`; Payroll/IT/Facilities = `PENDING` or `NOT_REQUIRED` per the triggers table | `STEP_OUTCOME` (HR); `STATUS_CHANGED` (SYSTEM); one `STEP_SET` per downstream step, → `PENDING` or `NOT_REQUIRED` (SYSTEM) |
| HR `REJECTED` | Step `REJECTED` with reason; status → `REJECTED_BY_HR` | `STEP_OUTCOME` with reason (HR); `STATUS_CHANGED` (SYSTEM) |
| Downstream `COMPLETED`, other steps still pending | Step `COMPLETED`. Nothing is scheduled, including when the step is `ORG_RECORD_UPDATE` (SD-16) | `STEP_OUTCOME` (step owner) |
| Downstream `COMPLETED`, last pending step | Step `COMPLETED`; `scheduleOrganisationalChange` is called with the proposed values and `effectiveFrom = effectiveDate`; status → `COMPLETED`. If the schedule call fails, nothing is saved and OP06 returns its error | `STEP_OUTCOME` (step owner); `STATUS_CHANGED` (SYSTEM); `CHANGE_SCHEDULED` with `effectiveFrom` (SYSTEM) |
| Downstream `FAILED` | Step `FAILED`; every other `PENDING` step → `STOPPED`; `COMPLETED` steps stay `COMPLETED` (not rolled back); status → `FAILED`; nothing is scheduled (BR-16, SD-16) | `STEP_OUTCOME` (step owner); one `STEP_SET` → `STOPPED` per stopped step (SYSTEM); `STATUS_CHANGED` (SYSTEM) |

Every `STEP_OUTCOME` entry records `simulatedBy` (the tester's user ID).

**Errors** (after the Access rules; nothing is changed and no history entry
is added):
| Condition | Message |
|---|---|
| Request not found | "No request found." |
| Request is in a final outcome | "This request is already closed." |
| The step is not `PENDING` (not reached, already recorded, `STOPPED` or `NOT_REQUIRED`) | "This step is not pending." |
| Outcome not valid for the step | "This outcome is not valid for this step." |
| `REJECTED` with no reason, or a reason of only spaces | "A rejection reason is required." |
| Reason longer than 500 characters | "Reason must be 500 characters or fewer." |
| `scheduleOrganisationalChange` returned an error (last step only) | The schedule error message (SD-20) |

### employee-internal-transfer.OP07 — listOpenStakeholderTasks (demo-only, `TESTER` only)
**Input:** none.
**Success:** `Result.success(List<StakeholderTask>)`: the task of every step
that is currently `PENDING`, across all requests, oldest first. Each task
shows only its Stakeholder contract content (BR-25). A task whose effective
date has passed is marked "Effective date passed" (SD-05).
**Errors:** Access rules only.

### Stakeholder contract (BRD-001 §8)
What the portal sends to each stakeholder when its step becomes `PENDING`,
and what it needs back. In V1 there is no real integration (ADR-0004): the
task is created locally, **shown to the tester in the demo-only simulation**
(OP07, AC29), and answered through OP06. The same shapes are the contract
for a future real integration. The task content is fixed when the step
becomes `PENDING` (SD-15).

```dart
StakeholderTask {
  taskId, requestId, stepId, stakeholder,
  employeeId, employeeName,
  effectiveDate,
  payload,          // per step, below
  createdAt,
}
StakeholderResponse {
  taskId, outcome, reason?,   // reason mandatory for REJECTED (BR-28)
}
```

| Step | Payload sent (§8 "Portal sends") | Response needed (§8 "Portal needs back") |
|---|---|---|
| `MANAGER_APPROVAL` | current and proposed department, location, role; effective date; employee's reason | `APPROVED` / `REJECTED` + reason |
| `HR_ELIGIBILITY` | same as manager | `APPROVED` / `REJECTED` + reason |
| `ORG_RECORD_UPDATE` | new department, location, role; effective date | `COMPLETED` / `FAILED` |
| `PAYROLL_UPDATE` | new role and new location; effective date | `COMPLETED` / `FAILED` |
| `IT_ACCESS_CHANGE` | **provision**: new department and role; **remove**: current department and role; effective date | `COMPLETED` / `FAILED` |
| `FACILITIES_WORKSPACE` | new location; effective date | `COMPLETED` / `FAILED` |

**Idempotency:** one task per step per request. A second response to a
task whose step is no longer `PENDING` is refused ("This step is not
pending."), so a repeated response never changes the request twice.
**Errors:** OP06's error table applies to every response.

### Data shapes
```dart
TransferRequest {
  requestId, employeeId, submissionId,
  current:  { departmentId, locationId, roleId, managerName },  // snapshot (BR-03)
  proposed: { departmentId, locationId, roleId },
  effectiveDate, reason?, submittedAt,
  status: RequestStatus,
  steps: List<Step>,   // only steps that have been reached (SD-01)
}
Step { stepId, stakeholder, state: StepState, decision?, reason?, recordedAt?, task?: StakeholderTask }
HistoryEntry {
  sequence, recordedAt,
  actor: EMPLOYEE | MANAGER | HR | PAYROLL | IT | FACILITIES | SYSTEM,   // SD-19
  type: SUBMITTED | STEP_OUTCOME | STEP_SET | STATUS_CHANGED | CHANGE_SCHEDULED,
  stepId?, outcome?, reason?,        // STEP_OUTCOME
  toState?,                          // STEP_SET: PENDING | NOT_REQUIRED | STOPPED
  fromStatus?, toStatus?,            // STATUS_CHANGED (SUBMITTED carries toStatus)
  effectiveFrom?,                    // CHANGE_SCHEDULED
  simulatedBy?,                      // STEP_OUTCOME entered through the simulation
}
```

**Which actor records which entry (SD-19):**
| Entry type | Actor |
|---|---|
| `SUBMITTED` | `EMPLOYEE` |
| `STEP_OUTCOME` | The step's stakeholder (`MANAGER`, `HR`, `PAYROLL`, `IT`, `FACILITIES`) |
| `STEP_SET`, `STATUS_CHANGED`, `CHANGE_SCHEDULED` | `SYSTEM` |

## Acceptance Criteria

### Request capture
1. **employee-internal-transfer.AC01** — Given a signed-in employee who can
   submit (OP02 returns neither `inProgress` nor `awaitingEffect`), when
   they open the transfer request form, then they can select a proposed
   department/business unit, location and role from the reference lists,
   pick an effective date, and optionally enter a reason. *(BR-01, BR-02)*
2. **employee-internal-transfer.AC02** — Given the form is open, then it
   shows the employee's current department, location, role and manager,
   read-only, from their portal profile. *(BR-03)*
3. **employee-internal-transfer.AC03** — Given valid values that change at
   least one of department, location or role, and a future effective date,
   when the employee submits, then one request is created with status
   `PENDING_MANAGER_APPROVAL`, the manager step shows the pending action
   "Manager approval", and the employee sees that the request was
   submitted. *(BR-06, BR-19)*
4. **employee-internal-transfer.AC04** — Given department, location, role
   or effective date is missing, when the employee submits, then submission
   is blocked with a field-level message and no request is created.
   *(BR-02)*
5. **employee-internal-transfer.AC05** — Given an effective date of today or
   earlier, when the employee submits, then submission is blocked with
   "Effective date must be in the future." Given any future date, including
   tomorrow, the date is accepted: there is no minimum lead time. *(BR-05)*
6. **employee-internal-transfer.AC06** — Given proposed department, location
   and role all equal the current values, when the employee submits, then
   submission is blocked with "Change at least one of department, location
   or role." and no request is created. *(BR-04)*
7. **employee-internal-transfer.AC07** — Given the employee has a request in
   progress, when they try to start a new one, then they see "You already
   have a transfer request in progress." and cannot submit. *(BR-07)*
8. **employee-internal-transfer.AC08** — Given the employee has submitted,
   while the submission is being processed the submit action is disabled;
   and a repeated submit with the same `submissionId` returns the existing
   request. Either way exactly one request and one `SUBMITTED` history
   entry exist. *(BR-08)*
9. **employee-internal-transfer.AC09** — Given a submitted request, then the
   request screen offers no way to edit or withdraw it. *(BR-09)*

### Approval and orchestration
10. **employee-internal-transfer.AC10** — Given `PENDING_MANAGER_APPROVAL`,
    when the manager approves, then the manager step is `COMPLETED`
    (Approved), status becomes `PENDING_HR_ELIGIBILITY`, and the HR step
    shows "HR eligibility check". *(BR-10, BR-11)*
11. **employee-internal-transfer.AC11** — Given `PENDING_MANAGER_APPROVAL`,
    when the manager rejects with a reason, then the manager step is
    `REJECTED` with that reason, status becomes `REJECTED_BY_MANAGER`, and
    no further step starts. *(BR-11, BR-28)*
12. **employee-internal-transfer.AC12** — Given `PENDING_HR_ELIGIBILITY`,
    when HR rejects with a reason, then the HR step is `REJECTED` with that
    reason, status becomes `REJECTED_BY_HR`, and no further step starts.
    The portal applies no eligibility rule of its own. *(BR-12, BR-28)*
13. **employee-internal-transfer.AC13** — Given `PENDING_HR_ELIGIBILITY`,
    when HR approves, then status becomes `IN_PROGRESS`, the organisational
    record update is `PENDING`, and Payroll, IT and Facilities are each
    `PENDING` or `NOT_REQUIRED` exactly as the triggers table gives for the
    change. *(BR-13, §5)*
14. **employee-internal-transfer.AC14** — Given a step is `NOT_REQUIRED`,
    then it never becomes `PENDING`, accepts no outcome, and is shown as
    "Not required". *(BR-14)*
15. **employee-internal-transfer.AC15** — Given `IN_PROGRESS`, when the
    organisational record update and every required step are `COMPLETED`,
    in any order, then status becomes `COMPLETED`. *(BR-15; A-07)*
16. **employee-internal-transfer.AC16** — Given the organisational record
    update is recorded as `COMPLETED` while other required steps are still
    pending, then nothing is scheduled and the profile does not change.
    When the request becomes `COMPLETED`, exactly one organisational change
    is scheduled with the proposed values from the effective date. Before
    that date the profile shows the current values; from that date it shows
    the new values. *(BR-13, BR-15; SD-16; CL-01)*
    > 💬 Scheduling only on `COMPLETED` is **not mentioned in BRD 5.2** (CL-01).
17. **employee-internal-transfer.AC17** — Given `IN_PROGRESS`, when any
    required step fails, then that step is `FAILED`, every other pending
    step is `STOPPED`, completed steps (including a completed
    organisational record update) stay `COMPLETED`, status becomes `FAILED`,
    no organisational change is scheduled, the profile never shows the
    proposed values, and stopped steps accept no further outcome. No retry,
    undo or compensation action is offered. *(BR-16; SD-16; CL-01)*
    > 💬 "Nothing scheduled on `FAILED`" is **not mentioned in BRD 5.2** (CL-01).
18. **employee-internal-transfer.AC18** — Given a request in any final
    outcome, then no step accepts an outcome. The employee can submit a new
    request straight away after `REJECTED_BY_MANAGER`, `REJECTED_BY_HR` or
    `FAILED`, and after `COMPLETED` from the effective date (AC34).
    *(BR-17; SD-17; CL-02)*
    > 💬 Waiting for the effective date after `COMPLETED` is **not mentioned in BRD 5.2** (CL-02).

### Visibility and confirmation
19. **employee-internal-transfer.AC19** — Given a request, when the employee
    opens it, then they see the overall status, the proposed values,
    effective date and reason they submitted, and each step that has been
    reached with its state; each pending step shows its pending action as
    named in the Steps table; each rejected step shows its rejection
    reason. *(BR-18, BR-19, §6)*
20. **employee-internal-transfer.AC20** — Given a final outcome, when the
    employee opens the request, then they see the confirmation for that
    outcome: *(BR-20, §7)*
    - `COMPLETED`: transfer confirmed, the new department, location and
      role, "effective from <effective date>", and the completed steps.
      While awaiting effect it ends with "You can submit a new request from
      <effective date>." Otherwise it ends with "You may submit a new
      request." If the effective date had passed when the request completed,
      it adds "This date had passed when your transfer completed, so the new
      values show in your profile from <completion date>." (SD-05);
    - `REJECTED_BY_MANAGER`: not approved by the manager, the manager's
      reason, that no further steps were taken, and "You may submit a new
      request.";
    - `REJECTED_BY_HR`: not approved by HR, HR's reason, that no further
      steps were taken, and "You may submit a new request.";
    - `FAILED`: which step failed, which steps had completed (not undone),
      which steps were stopped, "Your department, location and role have
      not changed.", and "You may submit a new request." (SD-16).
21. **employee-internal-transfer.AC21** — Given any status change, then the
    employee is informed only inside the portal; no email or push
    notification is sent, and no SLA timer, reminder or escalation is
    shown or run. *(BR-21, BR-22)*

### Security, ownership and audit
22. **employee-internal-transfer.AC22** — Given two employees, when one
    lists, opens or reads the history of requests, then only their own
    requests are returned; another employee's request ID gives "No request
    found."; and neither can record an outcome on any request (OP06 gives
    "Only a demo tester can record stakeholder outcomes."). *(BR-23, BR-24)*
23. **employee-internal-transfer.AC23** — Given any submission, stakeholder
    outcome, step change or status change, then an entry is appended to the
    request's history with its actor, per the actor table (SD-19). Each
    entry holds the step, outcome, state or status change, the reason for a
    rejection, and the time. A stakeholder outcome is never recorded with
    actor `SYSTEM`, `EMPLOYEE` or the tester, and an automatic change is
    always recorded with actor `SYSTEM`. The employee can view the history
    oldest first. No entry is ever edited or deleted, and the screen offers
    no way to do so. *(BR-24, BR-27, BR-28)*

### Demo-only simulation (V1, `TESTER` only)
24. **employee-internal-transfer.AC24** — Given a user signed in as
    `TESTER`, then a screen labelled "Demo only: simulate stakeholder
    outcome" lists the open stakeholder tasks (OP07) and lets the tester
    record an outcome for **pending** steps only, offering just the valid
    outcomes for each step (Approve / Reject for manager and HR; Complete /
    Fail for downstream steps). It is never presented as a real stakeholder
    interface. Given a user signed in as `EMPLOYEE`, the screen and every
    entry point to it are not shown. *(BR-24, §9; SD-18)*
    > 💬 The `TESTER` role is **not mentioned in BRD 5.2** (SD-18). The rest is BR-24.
25. **employee-internal-transfer.AC25** — Given the tester chooses Reject,
    then a reason is required: the rejection cannot be recorded while the
    reason is empty or only spaces. *(BR-28)*
26. **employee-internal-transfer.AC26** — Given an outcome for a step that is
    not pending, not valid for that step, or on a closed request, then it
    is refused with the matching OP06 error and nothing changes. *(BR-17,
    BR-24)*

### Access, demo posture, stakeholder tasks and request list (added in v2.1)
27. **employee-internal-transfer.AC27** — Given nobody is signed in, when
    the transfer feature is opened, then the user is asked to sign in, no
    request data is shown, and every operation returns "Please sign in."
    *(BR-26, D-01)*
28. **employee-internal-transfer.AC28** — Given the V1 app, then the
    transfer form, the request screen and the simulation screen show a
    visible "Demo — test data only" indicator, so no one mistakes V1 for a
    production system holding real employee records. *(BR-25, §9; SD-12)*
    > 💬 The visible indicator is **not mentioned in BRD 5.2** (SD-12). "Test/demo data only" is BR-25.
29. **employee-internal-transfer.AC29** — Given a step becomes `PENDING`,
    then a stakeholder task is created with exactly the payload in the
    Stakeholder contract for that step, and the simulation screen shows it
    to the tester before an outcome is recorded. For `IT_ACCESS_CHANGE` the
    task lists both the access to provision and the access to remove.
    *(§8, BR-13, BR-24)*
30. **employee-internal-transfer.AC30** — Given an employee with one or more
    requests, when they open their request list, then they see only their
    own requests, newest first, each with its submitted date and status
    label, and can open any of them and its history. *(BR-23, BR-27;
    SD-08)*
    > 💬 A list of all the employee's requests is **not mentioned in BRD 5.2** (SD-08).

### Review items (added in v2.3)
31. **employee-internal-transfer.AC31** — Given employee A is signed in and
    has viewed their requests, when A signs out and employee B signs in on
    the same device, then no data of A's is shown to B anywhere. That
    covers the form, the request list, a request screen, the history,
    back navigation, and any data held in memory from A's session. B's
    operations return only B's data, and A's request IDs give B "No request
    found." After sign-out and before any sign-in, every operation returns
    "Please sign in." *(BR-23, BR-25, BR-26)*
    > 💬 Sign-out clearing is **not mentioned in BRD 5.2**. Not seeing another employee's data is BR-23 (reviewer item 8).
32. **employee-internal-transfer.AC32** — Given a user signed in as
    `TESTER`, then OP01–OP05 return "This action is for employees only.",
    no transfer form is offered, and the tester owns no request. Given a
    user signed in as `EMPLOYEE`, OP06 and OP07 return "Only a demo tester
    can record stakeholder outcomes." and nothing changes. *(BR-23, BR-24;
    SD-18)*
    > 💬 The `TESTER` role is **not mentioned in BRD 5.2** (SD-18; reviewer item 3).
33. **employee-internal-transfer.AC33** — Given a request in progress whose
    effective date is today or has passed, then its status and effective
    date are unchanged, the request screen shows the "effective date passed"
    note, the tester's task is marked "Effective date passed", and every
    pending step still accepts its valid outcomes. If the request then
    completes, the change is scheduled with the original effective date and
    the profile shows the new values from that day. *(BR-05, BR-12, BR-13;
    SD-05)*
    > 💬 Behaviour after the effective date passes is **not mentioned in BRD 5.2** (SD-05; reviewer item 5).
34. **employee-internal-transfer.AC34** — Given the employee has a
    `COMPLETED` request awaiting effect, when they open the form or submit,
    then submission is blocked with "Your previous transfer takes effect on
    <effective date>. You can submit a new request from that date." and no
    request is created. From the effective date, submission is accepted
    and its current values snapshot holds the new values. *(BR-07, BR-13,
    BR-17; SD-17; CL-02)*
    > 💬 **Not mentioned in BRD 5.2**; differs from BR-07/BR-17 (CL-02; reviewer item 2).
35. **employee-internal-transfer.AC35** — Given one request, however many
    times the completion of its last step or `scheduleOrganisationalChange`
    is triggered, then at most one scheduled change and one
    `CHANGE_SCHEDULED` history entry exist for it, with the results given in
    the SD-20 table. *(BR-08, BR-13; SD-20)*
    > 💬 Schedule idempotency is **not mentioned in BRD 5.2** (SD-20; reviewer item 7). BR-08 covers submission only.

## Acceptance scenarios
**What these are.** The UT and XF scenarios are **acceptance scenarios**:
part of the spec, defining the expected behaviour for Gate 1 review. They
are not the implementation test cases. After Gate 1 approval, the test
cases file (`.ai-context/test_cases/employee-internal-transfer.test_cases.md`)
is written from them. It must cover every UT and XF ID, and it maps each one
to its unit, widget or integration test. The IDs are kept stable across spec
versions for traceability.

### Single-requirement scenarios (UT)
| ID | AC | Scenario | Expected |
|---|---|---|---|
| UT01 | AC03 | Submit valid request changing role only | Success; `PENDING_MANAGER_APPROVAL`; 1 `SUBMITTED` entry, actor `EMPLOYEE` |
| UT02 | AC02, AC03 | Submit | Request snapshot equals profile current values as of today |
| UT03 | AC04 | Submit with `departmentId` missing | Error "Select a department."; no request |
| UT04 | AC04 | Submit with a location not in the reference list | Field error; no request |
| UT05 | AC05 | Effective date = today | Error "must be in the future" |
| UT06 | AC05 | Effective date = yesterday | Same error |
| UT07 | AC05 | Effective date = tomorrow | Success |
| UT08 | AC06 | Proposed values equal current values | Error "Change at least one…"; no request |
| UT09 | AC07 | Submit while a request is in progress | Error "already in progress"; still one request |
| UT10 | AC08 | Submit twice with the same `submissionId` | Same request returned; 1 request, 1 history entry |
| UT11 | AC10 | Manager approves | `PENDING_HR_ELIGIBILITY`; HR step `PENDING` |
| UT12 | AC11 | Manager rejects with reason | `REJECTED_BY_MANAGER`; reason stored on step and in history |
| UT13 | AC25 | Manager rejects with blank reason | Error "A rejection reason is required."; nothing changes |
| UT14 | AC12 | HR rejects with reason | `REJECTED_BY_HR`; reason stored |
| UT15 | AC13 | HR approves; department only changed | Org `PENDING`, IT `PENDING`, Payroll and Facilities `NOT_REQUIRED` |
| UT16 | AC13 | HR approves; location only changed | Org, Payroll, Facilities `PENDING`; IT `NOT_REQUIRED` |
| UT17 | AC13 | HR approves; role only changed | Org, Payroll, IT `PENDING`; Facilities `NOT_REQUIRED` |
| UT18 | AC13 | HR approves; all three changed | All four downstream steps `PENDING` |
| UT19 | AC14 | Outcome recorded on a `NOT_REQUIRED` step | Error "This step is not pending." |
| UT20 | AC15 | All required steps complete in a different order each run | `COMPLETED` after the last one, whichever step it is |
| UT21 | AC16 | Request completes; read profile before and on the effective date | Old values before; new values on the date |
| UT22 | AC17 | Payroll completes, then IT fails; Org and Facilities pending | IT `FAILED`; Org and Facilities `STOPPED`; Payroll stays `COMPLETED`; `FAILED`; nothing scheduled |
| UT23 | AC17 | Outcome recorded on a `STOPPED` step | Error; nothing changes |
| UT24 | AC18 | New submission after `REJECTED_BY_MANAGER`, `REJECTED_BY_HR`, `FAILED` (same day), and after `COMPLETED` on its effective date | Accepted in all 4 cases |
| UT25 | AC18, AC26 | Any outcome on a closed request | Error "already closed"; nothing changes |
| UT26 | AC26 | HR outcome while `PENDING_MANAGER_APPROVAL` | Error "not pending" |
| UT27 | AC26 | `COMPLETED` outcome on `MANAGER_APPROVAL` | Error "not valid for this step" |
| UT28 | AC22 | Employee B lists, opens and reads the history of employee A's request | "No request found."; B's list excludes A's request |
| UT29 | AC27 | No user signed in | Every operation OP01–OP07 returns "Please sign in." |
| UT30 | AC23 | Full journey to `COMPLETED` (role only changed) | History in order: `SUBMITTED` (EMPLOYEE); manager `STEP_OUTCOME` (MANAGER); `STATUS_CHANGED` (SYSTEM); `STEP_SET` HR (SYSTEM); HR `STEP_OUTCOME` (HR); `STATUS_CHANGED` (SYSTEM); 4× `STEP_SET` (SYSTEM); 3× `STEP_OUTCOME` (owners); `STATUS_CHANGED` (SYSTEM); `CHANGE_SCHEDULED` (SYSTEM) |
| UT31 | AC23 | Outcome that fails validation | No history entry added |
| UT32 | AC20 | Confirmation content for each of the 4 final outcomes | Matches §7 of BRD-001 and AC20, including the `FAILED` "have not changed" line |
| UT33 | AC13 | HR approves; department and location changed | All four downstream steps `PENDING` |
| UT34 | AC13 | HR approves; department and role changed | Org, Payroll, IT `PENDING`; Facilities `NOT_REQUIRED` |
| UT35 | AC13 | HR approves; location and role changed | All four downstream steps `PENDING` |
| UT36 | AC25 | HR rejects with blank reason | Error "A rejection reason is required."; nothing changes |
| UT37 | AC08 | Widget: tap submit, then tap again while processing | Submit disabled while processing; one request |
| UT38 | AC09 | Widget: open a submitted request | No edit or withdraw action shown |
| UT39 | AC19 | Widget: each of the six steps when `PENDING`; a rejected step | Pending action label matches the Steps table; rejected step shows its reason; states use the defined labels |
| UT40 | AC01 | Widget: open the form; submit without a reason | Lists come from D-03; submission succeeds with no reason |
| UT41 | AC24 | Widget, as `TESTER`: simulation screen for requests in each status | Only pending steps offered, only their valid outcomes; labelled "Demo only" |
| UT42 | AC27 | Widget: open the feature with nobody signed in | Sign-in prompt; no request data shown |
| UT43 | AC28 | Widget: form, request screen, simulation screen | "Demo — test data only" indicator visible on each |
| UT44 | AC29 | Each of the six steps becomes `PENDING` | Task payload matches the Stakeholder contract; IT lists provision and remove |
| UT45 | AC30 | Employee with three requests; another employee with one | Own three, newest first; other employee's not listed |
| UT46 | OP01, OP06 | Reason of 501 characters on submit; rejection reason of 501 characters | "Reason must be 500 characters or fewer."; nothing saved |
| UT47 | AC05 | Effective date 5 years ahead | Accepted (no maximum, SD-11) |
| UT48 | AC34 | Request `COMPLETED`, effective date in the future; submit on its effective date | Accepted; snapshot holds the new values (replaces the v2.1 "submit before effective date" scenario) |
| UT49 | AC17 | Widget: request `FAILED` | No retry, undo or compensation action shown |
| UT50 | AC29 | Second response to a task whose step is no longer pending | "This step is not pending."; request unchanged |
| UT51 | AC24, AC32 | Widget, as `EMPLOYEE`: every transfer screen | No simulation screen, entry point or outcome button shown |
| UT52 | AC32 | `EMPLOYEE` calls OP06 on their own pending request (manager step) | "Only a demo tester can record stakeholder outcomes."; request and history unchanged |
| UT53 | AC32 | `EMPLOYEE` calls OP07 | Same error; no task returned |
| UT54 | AC32 | `TESTER` calls OP01 to OP05 | "This action is for employees only." for each; no request created |
| UT55 | AC23 | Manager approves | `STEP_OUTCOME` actor `MANAGER` with `simulatedBy` = tester ID; `STATUS_CHANGED` actor `SYSTEM`; `STEP_SET` HR `PENDING` actor `SYSTEM` |
| UT56 | AC23 | HR approves, department only changed | Four `STEP_SET` entries, actor `SYSTEM`: Org and IT `PENDING`, Payroll and Facilities `NOT_REQUIRED` |
| UT57 | AC23, AC17 | Facilities fails with Org and Payroll pending | `STEP_SET` → `STOPPED` for Org and Payroll, actor `SYSTEM`; `STATUS_CHANGED` → `FAILED`, actor `SYSTEM` |
| UT58 | AC16 | Org record completed first; Payroll and IT still pending | `pendingScheduledChange` is `null`; profile unchanged; no `CHANGE_SCHEDULED` entry |
| UT59 | AC16, AC35 | Last pending step completes | Exactly one scheduled change with the proposed values and `effectiveFrom` = effective date; one `CHANGE_SCHEDULED` entry (SYSTEM) |
| UT60 | AC35 | `scheduleOrganisationalChange` called twice, same `requestId` and values | Second call returns the existing change (same `scheduledAt`); one change exists |
| UT61 | AC35 | Same `requestId`, different values | Error "A different change is already scheduled for this request."; original kept |
| UT62 | AC35 | Another `requestId` while the employee has a change not yet in effect | Error "Another transfer is already scheduled for this employee."; nothing scheduled |
| UT63 | AC35 | Schedule call returns an error when the last step completes | OP06 returns the error; step stays `PENDING`; status stays `IN_PROGRESS`; no history entry added |
| UT64 | AC34 | Request `COMPLETED`, effective date 15 Oct; on 1 Oct open form and submit | Form shows, and OP01 returns, "Your previous transfer takes effect on 15 Oct 2026…"; no request |
| UT65 | AC33 | Effective date reached while `PENDING_HR_ELIGIBILITY` | Status and effective date unchanged; "effective date passed" note shown; task marked; HR can approve or reject |
| UT66 | AC33 | Request completes after its effective date | Scheduled with the original `effectiveFrom`; profile shows new values today; confirmation shows the "date had passed" line |
| UT67 | AC31 | A signs in and opens a request; signs out; B signs in | B sees only B's data on every screen and after back navigation; OP04/OP05 with A's ID → "No request found." |
| UT68 | AC31 | A signs out; operations called before anyone signs in | Every operation returns "Please sign in."; no A data shown |
| UT69 | AC20, AC17 | Widget: `FAILED` after Org record completed | Confirmation lists Org as completed (not undone) and says "Your department, location and role have not changed." |
| UT70 | OP07 | `TESTER` lists open tasks with requests from two employees | Only `PENDING` steps' tasks, oldest first, each with contract content only |

### Cross-flow scenarios (XF)
Each scenario runs several rules together and states the full end state.
Dates are device local dates in 2026.

**XF01 — Org record recorded, then Payroll fails** (reviewer scenario 1)
*Answer to S1:* under SD-16 a transfer is scheduled only when **every**
required step has completed, so "scheduled, then Payroll fails" cannot
happen. The nearest real case is below: the organisational record update is
recorded, and then Payroll fails before the request completes.
Request: department and location change, effective 15 Oct. HR approves (all
four downstream steps `PENDING`). Org record `COMPLETED`, IT `COMPLETED`,
then Payroll `FAILED` while Facilities is `PENDING`.
- Status `FAILED`. Payroll `FAILED`; Facilities `STOPPED`; Org and IT stay
  `COMPLETED`.
- No scheduled change ever exists (`pendingScheduledChange` is `null` before
  and after 15 Oct). On 15 Oct and after, the profile still shows the old
  values.
- The history has no `CHANGE_SCHEDULED` entry. The `STEP_SET` `STOPPED`
  entry for Facilities and the `STATUS_CHANGED` entry are both actor
  `SYSTEM`.
- The confirmation lists Payroll failed, Org and IT completed (not undone),
  Facilities stopped, and "Your department, location and role have not
  changed."
- The employee can submit a new request the same day.

**XF02 — Scheduled transfer, then a second request** (reviewer scenario 2)
Request A `COMPLETED` on 1 Oct, effective 15 Oct.
- On 1 Oct the employee opens the form and submits a request for 30 Oct.
  It is blocked with "Your previous transfer takes effect on 15 Oct 2026.
  You can submit a new request from that date." No request is created, and
  only one scheduled change exists.
- On 15 Oct the profile shows A's values and the employee submits request B
  for 30 Oct. It is accepted, and B's snapshot holds A's new values.
- The two transfers are never scheduled at the same time.

**XF03 — Employee tries to use the simulation** (reviewer scenario 3)
Employee E has a request `PENDING_MANAGER_APPROVAL`.
- Signed in as E: no simulation screen or entry point is shown. A direct
  OP06 call to approve the manager step and an OP07 call return "Only a
  demo tester can record stakeholder outcomes." The request and history are
  unchanged.
- Signed in as tester T: OP07 lists E's manager task, and T approves it. The
  history shows actor `MANAGER` with `simulatedBy` = T.
- T calls OP01 and gets "This action is for employees only."

**XF04 — Manager approves; audit actors** (reviewer scenario 4)
Tester approves the manager step. The history gains exactly, in order:
`STEP_OUTCOME` `MANAGER_APPROVAL` `APPROVED` (actor `MANAGER`,
`simulatedBy` T); `STATUS_CHANGED` `PENDING_MANAGER_APPROVAL` →
`PENDING_HR_ELIGIBILITY` (actor `SYSTEM`); `STEP_SET` `HR_ELIGIBILITY` →
`PENDING` (actor `SYSTEM`). No entry has actor `EMPLOYEE` or the tester.

**XF05 — Effective date passes while HR is pending** (reviewer scenario 5)
Request effective 10 Oct; manager approved on 8 Oct; still
`PENDING_HR_ELIGIBILITY` on 12 Oct.
- On 12 Oct: status unchanged, effective date still 10 Oct, the request
  screen shows the "effective date passed" note, the HR task is marked
  "Effective date passed". The employee still cannot submit another request
  (one is in progress).
- (a) HR approves on 12 Oct and all required steps complete on 14 Oct. The
  change is scheduled with `effectiveFrom` 10 Oct, and the profile shows
  the new values from 14 Oct. The confirmation says "effective from 10 Oct
  2026" and adds the "date had passed" line. The employee can submit a new
  request at once.
- (b) HR rejects on 12 Oct with a reason: `REJECTED_BY_HR`, nothing
  scheduled.

**XF06 — Same organisational change triggered twice** (reviewer scenario 6)
Request `IN_PROGRESS`; Org and IT completed; Payroll is the last pending
step.
- The tester taps "Complete" on Payroll twice quickly, or OP06 is called
  twice. The first call completes the request. The second returns "This
  step is not pending." (or "This request is already closed.") and changes
  nothing.
- A direct repeat `scheduleOrganisationalChange` call with the same values
  returns the existing change.
- End state: one scheduled change, one `CHANGE_SCHEDULED` entry, one
  `STATUS_CHANGED` → `COMPLETED` entry.

**XF07 — Employee A signs out, employee B signs in** (reviewer scenario 7)
A has two requests and has the second one open. A signs out.
- Before anyone signs in, every operation returns "Please sign in." and no
  request data is on screen.
- B signs in on the same device. B's list shows only B's requests. Back
  navigation does not reach A's screens. A's request IDs give "No request
  found." for OP04 and OP05. The form shows B's current values, and OP02
  reflects B only.
- B signs out and A signs in again: A's two requests are intact.

**XF08 — One downstream step fails after the others completed** (reviewer
scenario 8)
Request: role and location change (Org, Payroll, IT, Facilities all
required). Org, Payroll and Facilities `COMPLETED`; IT `FAILED` last.

| Item | End state |
|---|---|
| Request status | `FAILED` |
| Org, Payroll, Facilities steps | Stay `COMPLETED` in the request and the history; shown as completed (not undone) |
| IT step | `FAILED` |
| Stopped steps | None (nothing was pending); no `STEP_SET` `STOPPED` entry |
| Scheduled organisational change | None; never created, so nothing needs cancelling |
| What remains | The three completed steps (as a record) and the `FAILED` status; the employee's profile is unchanged |
| What is cancelled | Nothing is cancelled, because no change was ever scheduled. Any step still `PENDING` at the failure would be `STOPPED` (see XF01, where Facilities is stopped) |
| Employee profile | Unchanged, before and after the effective date |
| Outside the portal (future real integrations) | The portal does not undo what Payroll or Facilities did. Compensation is out of scope in V1 (BR-16, §12). In V1 these steps are simulated, so nothing outside the app changed |
| New request | Can be submitted straight away |

**XF09 — Future date, downstream failure, then a new request** (review
item 11 example)
Request A effective 15 Oct: Org record `COMPLETED`, then Payroll `FAILED`
on 1 Oct. `FAILED`, nothing scheduled.
- On 1 Oct the employee submits request B for 30 Oct. It is accepted,
  because A is final and nothing is awaiting effect. B's snapshot holds the
  original values (A never took effect).
- B completes on 5 Oct. Exactly one scheduled change exists, B's, effective
  30 Oct. On 15 Oct the profile still shows the original values; on 30 Oct
  it shows B's.

AC21 (no email, push, SLA timer, reminder or escalation) has no runtime
behaviour to test. It is verified at code review (Gate 2) by confirming no
notification or scheduling code exists.

## Explicitly Out of Scope (BRD-001 §12)
- International or cross-legal-entity transfers.
- Receiving-department manager approval.
- Capturing or verifying the conversation with the manager (journey step 1).
- Amending or withdrawing a submitted request.
- SLA timers, reminders and escalation.
- Email and push notifications.
- A minimum transfer lead time.
- Portal-defined HR eligibility rules.
- Real integrations with HR, Payroll, IT and Facilities, and with them
  retry, rollback, compensation and reconciliation. This includes undoing
  what a completed downstream step did outside the portal when the request
  fails (XF08).
- An admin or support console.
- Inactive or terminated employees.
- Sign-in features: password policy, lockout, email verification/OTP,
  identity uniqueness (BR-26). Sign-in is a dependency (D-01), not part of
  this spec.
- Production-grade, server-side authorization (see Security boundary).
- A production-grade interface for each stakeholder role.
- Payroll, IT and Facilities' own internal workflows.
- Retention periods, deletion of requests or history, and subject-access
  handling for employee personal data (BR-25; future production
  requirements).
- Retroactive changes when the effective date passed before completion
  (for example, back-dated payroll). The portal records the original date
  only (SD-05).

## Non-Functional Constraints
- **Demo posture (BR-24 to BR-26, §9):** V1 is a demo. It uses test/demo
  data only and must not be loaded with real employee records. Sign-in is
  demo-level and not production-ready. The simulation cannot prove that a
  real stakeholder took a decision.
- **Security posture (BR-23, BR-26):** V1 access control is
  application-level only and is not production-grade authorization (see
  Security boundary). It must not be described as production security in
  any document, demo or release note.
- **Privacy (BR-25):** no employee personal data in logs at any level,
  including the reason and rejection reasons. The screens show only what
  the journey needs. The tester sees only the Stakeholder contract content.
- **Ownership and role (BR-23, BR-24; SD-18):** the sign-in, role and
  employee-ID checks are enforced in the repository, not only hidden in the
  UI.
- **Session (AC31):** on sign-out, all transfer data held for the previous
  user (screens, controllers, caches) is cleared before another user can
  sign in.
- **Audit (BR-27; SD-19):** history is append-only at the repository level.
  There is no update or delete operation for it. Every entry has an actor.
- **Atomic saves:** each operation's changes, history entries and schedule
  are saved together or not at all.
- **Validation:** every mandatory field has a client-side validator
  (`core/utils/validators.dart`) and is re-checked in the repository before
  saving.
- **Performance:** local reads and writes complete in under 500 ms on a
  mid-range device.
- **Demo-only control (BR-24; SD-13, SD-18):** the simulation screen is part
  of every V1 build, is available only to the `TESTER` role, and is
  visually separate from the employee's screens. It and the `TESTER` role
  must be removed, or replaced by real stakeholder integrations, before any
  production release.

## Spec decisions for Gate 1
Details BRD-001 leaves open that the spec has to settle. Please confirm or
reject each. The last column says whether BRD 5.2 mentions the decision.
Where it does not, the point carries "Not mentioned in BRD 5.2" and is
listed in the reference note. BRD 5.2 is not changed.

| ID | Decision | Why | In BRD 5.2? |
|---|---|---|---|
| SD-01 | Only steps that have been reached are shown. HR appears after the manager approves; the four downstream steps appear when HR approves. There is no "Not started" state. | BR-19 lists six states and no "not started" state. Showing unreached steps would need a seventh. | 💬 **Not mentioned in BRD 5.2.** BR-19 lists six states only |
| SD-02 | A manager or HR approval shows the step as `COMPLETED` (Approved). | BR-19 has no "Approved" state; Completed is the closest. | 💬 **Not mentioned in BRD 5.2.** BR-19 has no "Approved" state |
| SD-03 | Triggers use the current values snapshot taken at submission, not the profile at HR approval time. | The employee confirmed the change against those values (BR-03). The snapshot keeps the decision stable. | 💬 **Not mentioned in BRD 5.2.** §5 compares with current values (BR-03), not when |
| SD-04 | Another employee's request gives the same "No request found." as a missing one. | Avoids telling one employee that another's request exists (BR-23, BR-25). | 💬 **Not mentioned in BRD 5.2.** BR-23 is in BRD 5.2; the wording is not |
| SD-05 | **Revised in v2.3.** The effective date is checked only at submission and never changes. A request still in progress on or after its effective date carries on. The employee sees an "effective date passed" note, and the tester's task is marked. If it completes, the change is scheduled with the original date and shows in the profile from the completion day. The confirmation says so. The portal does not reject or re-date the request; HR may reject it (BR-12). | BRD-001 has no rule for this case. Auto-rejecting or re-dating would add a business rule. The note answers review item 5. | 💬 **Not mentioned in BRD 5.2.** BR-05 covers submission only (reviewer item 5) |
| SD-06 | **Superseded by SD-17 in v2.3.** A new request can no longer be submitted before a completed transfer's effective date, so its snapshot is always taken on or after that date and holds the new values. | v2.1 allowed submission before the effective date with old values, which caused review item 2. | Superseded by SD-17 |
| SD-07 | Idempotency uses a `submissionId` generated once per submit action. | Makes BR-08 testable at the repository, not only in the UI. | 💬 **Not mentioned in BRD 5.2.** BR-08 is in BRD 5.2; `submissionId` is not |
| SD-08 | The employee can list all their requests (OP03), not only the latest. | BR-27 says the employee can view the history; after a new request, the old request's history would otherwise be unreachable. | 💬 **Not mentioned in BRD 5.2.** BR-27 covers viewing history, not a list |
| SD-09 | A downstream failure carries no reason. | §8 needs back only "Completed / Failed". BR-28 requires a reason only for manager and HR rejections. | ✅ §8 ("Completed / Failed"), BR-28 |
| SD-10 | The employee's reason and a rejection reason are each at most 500 characters. | BRD-001 gives no limit; a limit makes the fields testable and keeps the history readable. | 💬 **Not mentioned in BRD 5.2.** No limit in BRD 5.2 |
| SD-11 | There is no maximum effective date. | BR-05 sets only "future date"; adding a maximum would be a new business rule. | 💬 **Not mentioned in BRD 5.2.** BR-05 says only "future date" |
| SD-12 | V1 screens show a "Demo — test data only" indicator (AC28). | Makes BR-25's "test/demo data only" visible and testable. | 💬 **Not mentioned in BRD 5.2.** BR-25 says test/demo data only |
| SD-13 | The simulation screen is in every V1 build and must be removed before production. | V1 has no real integration (ADR-0004), so the journey cannot progress without it; BR-24 requires that it is never taken for a real interface. | 💬 **Not mentioned in BRD 5.2.** BR-24 says demo-only |
| SD-14 | Status labels shown to the employee are as in the Request status table. | BR-06 names "Pending manager approval"; the other labels follow BRD-001 wording (§3, BR-11 to BR-17). | ⚠️ Partly: BR-06, §7 name most labels; "Pending HR eligibility check" and "In progress" are not |
| SD-15 | A stakeholder task's content is fixed when its step becomes `PENDING`. | Keeps the task stable while pending; matches the snapshot rule SD-03. | 💬 **Not mentioned in BRD 5.2.** §8 lists content, not timing |
| SD-16 | **New.** `ORG_RECORD_UPDATE` = `COMPLETED` means "recorded", not "scheduled" or "effective". The organisational change is scheduled only when the whole request becomes `COMPLETED`. A `FAILED` request never schedules a change. **CL-01.** | Review items 1 and 6. Otherwise a failed transfer could still take effect later. BR-15 treats the transfer as a whole. | ⚠️ Partly: recorded/effective are BR-13. 💬 **Scheduling only on `COMPLETED` is not mentioned in BRD 5.2.** (CL-01) |
| SD-17 | **New.** While a `COMPLETED` request is awaiting effect, a new request is blocked (OP01 error 6). **CL-02.** | Review item 2. Prevents two future transfers for one employee and keeps each snapshot correct. The simplest rule that needs no ordering or cancellation logic. | 💬 **Not mentioned in BRD 5.2.** Differs from BR-07/BR-17 (CL-02) |
| SD-18 | **New.** The simulation (OP06, OP07) is available only to a demo account with role `TESTER`. A tester has no profile, cannot submit or view as an employee, and its role is set in demo data. An employee never sees the simulation. | Review item 3. BR-24: only the owning stakeholder records an outcome; an employee must never approve their own request through the app. | 💬 **Not mentioned in BRD 5.2.** `TESTER` role (applies BR-23, BR-24) |
| SD-19 | **New.** The history `actor` includes `SYSTEM`. Status changes, `STEP_SET` (pending, not required, stopped) and `CHANGE_SCHEDULED` entries are recorded by `SYSTEM`; stakeholder outcomes by the owning stakeholder, with `simulatedBy`; the submission by `EMPLOYEE`. | Review item 4. BR-27 requires every status change in the history; these are made by the portal, not by a person. | 💬 **Not mentioned in BRD 5.2.** `SYSTEM` actor (BR-27 is in BRD 5.2) |
| SD-20 | **New.** `scheduleOrganisationalChange` is idempotent by `requestId`, with the results in the Consumed contract table. The schedule is saved in the same save as the last outcome and the status change. | Review item 7. A repeated trigger can never create a duplicate or conflicting change. | 💬 **Not mentioned in BRD 5.2.** Schedule idempotency |

## Points not in BRD 5.2 (CL-01, CL-02)
These two spec decisions read or narrow a BRD 5.2 business rule. They
answer the reviewer's items 1, 2 and 6 and are kept in the spec.
**BRD-001 v5.2 is not changed**: both are recorded for reference in
`reviews/employee-internal-transfer.spec-v2.4.not-in-BRD-5.2.md`, together with every other point BRD 5.2 does not mention.

| ID | BRD-001 v5.2 rule | What the spec does (not in BRD 5.2) | Spec items that depend on it |
|---|---|---|---|
| CL-01 | BR-13, BR-15, BR-16 | "The organisational record update records the new values, which are applied (to take effect from the effective date) only when the request is Completed. If the request Fails, the new values are never applied; the completed step is not rolled back but has no effect on the profile." | SD-16; AC16, AC17, AC20; UT58, UT59, UT69; XF01, XF08, XF09 |
| CL-02 | BR-07, BR-17 | "After a Completed request, a new request can be submitted from its effective date. Before that date, submission is rejected with a message giving the date." | SD-17; OP01 error 6; AC18, AC34; UT24, UT48, UT64; XF02 |

**Why the spec follows the review rather than the literal BRD wording.**
- **CL-01:** review item 1 says a failed request must not leave a transfer
  that "may still happen". Reading BR-13 and BR-16 literally would allow
  exactly that. CL-01 is the smallest reading that meets item 1, and it
  keeps BR-16's "not rolled back" for the step record.
- **CL-02:** review item 2 allows either "block a new request until the
  previous transfer becomes effective" or "define how multiple future
  transfers are handled". The spec takes the first option, which the review
  lists first. The second would need ordering and cancellation rules that
  BRD 5.2 also does not define.

**Reviewer confirmation requested at Gate 1:** accept CL-01 and CL-02 as
the spec's reading of BRD 5.2 for items 1 and 2, with BRD-001 v5.2 left as
approved and both recorded in the reference note.
**Confirmed:** accepted by Shamik Bhattacharya with the Gate 1 approval of
spec v2.4 (2026-09-30).

## Traceability: BRD-001 → spec
| BRD-001 | Spec |
|---|---|
| BR-01, BR-02 | AC01, AC04, OP01 |
| BR-03 | AC02, OP01 snapshot, SD-03 |
| BR-04 | AC06 |
| BR-05 | AC05, AC33, SD-05 |
| BR-06 | AC03 |
| BR-07 | AC07, AC34, OP02, SD-17, CL-02 |
| BR-08 | AC08, AC35, SD-07, SD-20 |
| BR-09 | AC09 |
| BR-10, BR-11 | AC10, AC11 |
| BR-12 | AC12, AC33 |
| BR-13, §5 | AC13, AC16, AC33, AC35, triggers table, three moments, SD-16, SD-20, CL-01 |
| BR-14 | AC14 |
| BR-15 | AC15, AC16, SD-16 |
| BR-16 | AC17, AC20, SD-16, CL-01, XF01, XF08 |
| BR-17 | AC18, AC26, AC34, SD-17, CL-02 |
| BR-18, BR-19, §6 | AC19, Steps table, SD-01, SD-02 |
| BR-20, §7 | AC20 |
| BR-21, BR-22 | AC21 |
| BR-23 | AC22, AC30, AC31, AC32, OP03–OP05, Access rules, SD-04 |
| BR-24 | AC22, AC24, AC26, AC32, OP06, OP07, SD-18 |
| BR-25, BR-26 | AC27, AC28, AC31, Security boundary, Non-Functional Constraints, Out of Scope, Consumed contract |
| BR-27 | AC23, AC30, OP05, SD-08, SD-19 |
| BR-28 | AC11, AC12, AC20, AC25 |
| §8 integration needs | Stakeholder contract, AC29, OP06, OP07, SD-15 |
| §11 D-01 to D-03 | Consumed contract, AC27 |
| §11 D-04 | Context (D-04) |
| §12 | Explicitly Out of Scope |

## BRD-001 coverage check (v2.3)
Every item of the approved BRD-001 v5.2, and where the spec covers it.

| BRD-001 | Covered by | |
|---|---|---|
| §1 objective, success measure | Intent; AC19 (status and pending action visible without contacting anyone) | ✅ |
| §1 failure and security scenarios | AC17, AC31–AC35; XF01–XF09; Security boundary | ✅ |
| §2 primary users | Definitions: Actors | ✅ |
| §3 journey steps 1–8 | Step 1: Context D-04 · Steps 2–7: Steps table, AC10–AC17 · Step 8: AC20 | ✅ |
| BR-01 to BR-28 | Traceability table above; every BR has at least one AC | ✅ |
| §5 downstream triggers | Triggers table (all 7 combinations); UT15–UT18, UT33–UT35 | ✅ |
| §6 pending actions | Steps table; AC19; UT39 | ✅ |
| §7 employee confirmation | AC20; UT32, UT66, UT69 | ✅ |
| §8 integration needs | Stakeholder contract; AC29; OP07; UT44, UT50, UT70 | ✅ |
| §9 business vs technical | Context (ADRs); Security boundary; Non-Functional Constraints; plan decides storage | ✅ |
| §10 assumptions A-01 to A-07 | Context (inherited assumptions) | ✅ |
| §11 dependencies D-01 to D-04 | Context; Consumed contract; AC27 | ✅ |
| §12 out of scope (14 items) | Explicitly Out of Scope (all 14, plus BR-25 retention, production authorization and retroactive changes) | ✅ |
| §13 open questions: none | SD-01 to SD-20 settle spec-level details. SD-16 and SD-17 read or narrow business rules; recorded as CL-01 and CL-02 (not in BRD 5.2) | ✅ Points not in BRD 5.2 recorded in the reference note |

## Changes in v2.4 (from v2.3)
| Area | Change |
|---|---|
| BRD 5.2 | Not changed. The dependency on a BRD clarification is removed; CL-01 and CL-02 are recorded as points not in BRD 5.2 |
| Notes | "In BRD 5.2?" column on the review-response and spec-decision tables; "Not mentioned in BRD 5.2" comments on AC16, AC17, AC18, AC24, AC28, AC30–AC35 and the three moments |
| Reference note | `reviews/employee-internal-transfer.spec-v2.4.not-in-BRD-5.2.md` lists every point not in BRD 5.2 |
| Behaviour | None changed. Every v2.3 answer to review items 1–11 and scenarios S1–S8 is kept |
| Double-check fixes | Item 4 and item 8 "Where" references corrected; XF01 states why "scheduled, then fails" cannot happen (S1); XF08 states what remains and what is cancelled (S8); `getCurrentValues` never shows a late-completed change retroactively (SD-05) |

## Changes in v2.3 (from v2.1; replaces the incomplete v2.2 draft)
| Review item | Change |
|---|---|
| 1, 6 | Three moments of the organisational change; schedule only on `COMPLETED` (SD-16, CL-01); OP06 effects rewritten; AC16, AC17, AC20 revised; UT58, UT59, UT69; XF01, XF08 |
| 2 | OP01 error 6; OP02 returns `awaitingEffect`; AC18 revised, AC34 new; SD-06 superseded, SD-17 new (CL-02); UT24, UT48 revised, UT64 new; XF02, XF09 |
| 3 | `TESTER` role; Access rules; OP06 and OP07 tester-only; AC24 revised, AC32 new; SD-18; UT41 revised, UT51–UT54, UT70; XF03 |
| 4 | `SYSTEM` actor; `STEP_SET` and `CHANGE_SCHEDULED` history entries; actor table; AC23 revised; SD-19; UT30 revised, UT55–UT57; XF04 |
| 5 | "Effective date passed" condition; AC33; SD-05 revised; UT65, UT66; XF05; retroactive changes out of scope |
| 7 | Schedule idempotency and conflict table (SD-20); AC35; UT60–UT63; XF06 |
| 8 | AC22 extended, AC31 new; session constraint; UT67, UT68; XF07 |
| 9 | Security boundary section; security posture constraint; production authorization out of scope |
| 10 | Status and "Acceptance scenarios" say UT/XF are spec-level scenarios that the post-Gate-1 test cases must cover |
| 11 | Cross-flow scenarios XF01–XF09 |

No v2.1 acceptance criterion was removed or renumbered. AC16–AC18, AC20,
AC22–AC24 were revised; AC31–AC35 were added.

## Changes in v2.1 (from v2.0)
| Area | Added |
|---|---|
| BRD-001 §8 | Stakeholder contract (task payload and response per step), AC29, UT44, UT50, SD-15 |
| BRD-001 §2 | Actors table |
| BRD-001 D-04, A-01 to A-07 | Listed in Context |
| BR-18, BR-19 | Status and step display labels (SD-14) |
| BR-25 | AC28 demo indicator (SD-12); retention/deletion/subject-access in Out of Scope |
| BR-26 | AC27 not signed in |
| BR-24 | SD-13 simulation control removed before production |
| BR-23, BR-27 | AC30 own request list |
| BR-02, BR-05 | Reason length limit (SD-10); no maximum effective date (SD-11) |
| BR-16 | AC17: no retry, undo or compensation offered |
| Tests | UT33–UT50: remaining trigger combinations, HR blank reason, widget tests for AC01, AC08, AC09, AC19, AC24, AC27, AC28, AC30 |

## Changes from v1.5
| Area | v1.5 | v2.0 (from BRD-001 v5.2) |
|---|---|---|
| Source | BRD-001 v1–v4, BRD-002, ADR-0005 | BRD-001 v5.2 only |
| Current values and manager | Registration (BRD-002) | Portal profile, read-only on the form (BR-03, D-02) |
| At least one change | Not checked | Required (BR-04) |
| Duplicate submission | UI only | `submissionId` idempotency (BR-08) |
| Downstream steps | Payroll, IT, Facilities always | Org record update always; others by trigger (BR-13, §5) |
| Organisational record update | Absent | Step with effective-from date (BR-13) |
| Rejection reason | None | Mandatory for manager and HR (BR-28) |
| Downstream outcome | `REJECTED` | `FAILED`; pending steps `STOPPED` (BR-16) |
| Step states and pending actions | Stakeholder names | Six states and named actions (BR-19, §6) |
| Confirmation | None | Per final outcome (BR-20, §7) |
| Ownership | Per device install | Per signed-in employee (BR-23) |
| History | Decisions only | Submission, outcomes and status changes, with reasons (BR-27) |

## Next
1. Gate 1 reviewer confirms or rejects SD-16 to SD-20, the revised SD-05
   and SD-06, and CL-01 and CL-02, using the reference note for the points
   not in BRD 5.2.
2. On approval the spec is marked **Gate 1 Approved**. BRD-001 v5.2 stays
   as approved.
3. After approval: write the plan (with Constitution Check), then tasks,
   then the test cases covering UT01–UT70 and XF01–XF09, each for review in
   turn.
