# Spec: Employee Internal Transfer

## Spec ID
employee-internal-transfer

## Status
**v2.2 — Resubmitted for Gate 1 review. Not yet approved.**
Plan, tasks and the implementation test cases
(`.ai-context/test_cases/employee-internal-transfer.test_cases.md`) must
not be written from this spec until the Gate 1 reviewer (Shamik
Bhattacharya) approves it. The acceptance scenarios in this spec (UT01–UT62,
XF01–XF08) are part of the spec itself, not implementation test cases; see
"Acceptance scenarios".

| | |
|---|---|
| Author | Indrajit Bhandari |
| Gate 1 reviewer | Shamik Bhattacharya |
| Updated | 2026-09-28 |
| Linked BRD | `.ai-context/BRD.md#BRD-001`, **v5.2, Gate 1 Approved 2026-09-28** |
| Previous version | `employee-internal-transfer.spec-v2.1-backup-2026-09-28.md` (v2.1), following v2.0 and v1.5 backups |
| Gate 1 review of v2.1 | `.ai-context/reviews/employee-internal-transfer.spec-v2.1.gate1-review.md` (11 items, 8 scenarios) |

**How v2.2 was written.** v2.2 answers the Gate 1 reviewer's 11 mandatory
items on v2.1 (items 1–4 critical). The main changes: the organisational
change is applied to the profile only when the whole request completes, so a
downstream failure never leaves a transfer scheduled (SD-16); a new request
is blocked until a completed transfer has taken effect (SD-17, **needs a
BRD-001 clarification**, see below); only a demo tester, never an employee,
can use the simulation (SD-18); the history has a `SYSTEM` actor (SD-19). See
"Changes in v2.2" for the full list.

**BRD-001 clarification needed before approval.** SD-17 narrows BR-07 and
BR-17 (a new request is blocked after `COMPLETED` until the effective date).
This is a business rule, so BRD-001 needs a v5.3 clarification approved by
the Gate 1 reviewer; the spec does not change the approved BRD on its own.
Every other v2.2 change stays within BRD-001 v5.2.

**How v2.1 was written.** v2.1 is the Author's revision of v2.0, after a
rule-by-rule check of BRD-001 v5.2 against the spec, so that nothing in
the approved BRD is missed. It adds the stakeholder contract (BRD-001 §8),
status display labels, actors (§2), D-04, acceptance criteria AC27–AC30,
unit tests UT33–UT50, spec decisions SD-10 to SD-15, and the BR-25
retention items under Out of Scope. See "Changes in v2.1" and the BRD-001
coverage check. No v2.0 acceptance criterion was removed or renumbered.

**How v2.0 was written.** v2.0 is rebuilt from **BRD-001 v5.2 only**
(review comment #16). It does not carry anything over from spec v1.5,
BRD-002 or `employee-registration-login`. Every acceptance criterion cites
the BRD-001 rule it implements (see Traceability). Where BRD-001 leaves a
detail open that the spec has to settle, the spec decision is listed under
**Spec decisions for Gate 1**, so the reviewer can confirm or reject each one.

**The existing code implements spec v1.5, not v2.0.** It must not be treated
as meeting this spec. The main differences are listed under
"Changes from v1.5".

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
  - **D-01 sign-in:** the employee is signed in to the portal. Demo-level
    in V1 (BR-26). This spec only consumes the signed-in employee's ID.
  - **D-02 profile:** the portal profile supplies the employee's current
    department, location, role and current manager (BR-03, BR-10).
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
- The Plan decides how D-01 to D-03 are provided in V1 (for example, by the
  existing demo sign-in). This spec defines only what it needs from them
  (Consumed contract, below).

## Scope Decision — one spec
BRD-001 describes one capability with one journey, so there is one spec.
The demo-only simulation (AC24–AC26) is part of this spec because, with no
backend (ADR-0004), it is the only way stakeholder outcomes reach the
journey (BR-24). It is not a separate feature and not a stakeholder
interface.

## Definitions

### Actors (BRD-001 §2)
| Actor | In this spec |
|---|---|
| Employee (primary user) | Signed-in user (D-01). Submits and views only their own requests (OP01–OP05, BR-23) |
| Current manager | Records `MANAGER_APPROVAL` (simulated in V1, OP06) |
| HR | Records `HR_ELIGIBILITY` and `ORG_RECORD_UPDATE` (simulated) |
| Payroll | Records `PAYROLL_UPDATE` (simulated) |
| IT | Records `IT_ACCESS_CHANGE` (simulated) |
| Facilities | Records `FACILITIES_WORKSPACE` (simulated) |
| Demo tester (V1 only) | A demo sign-in account with the `TESTER` role (D-01). The only user who can open the simulation and record stakeholder outcomes on others' requests (OP06, OP07; SD-18). Cannot submit or own a transfer request. Not a BRD-001 actor: it stands in for the stakeholders, because V1 has no real integration (BR-24) |
| System | The portal itself. Records every status change, every step it starts, stops or marks not required, and the scheduling of the organisational change (SD-19). Never records a stakeholder decision |

The history `actor` of each stakeholder outcome is the actor that owns the
step, never the employee or the tester (BR-24). When the outcome was
entered through the simulation, the entry also records `simulatedBy` (the
tester's user ID), so the history shows both who owns the decision and who
actually entered it in the demo.

### Request status (BR-06, BR-11 to BR-17)
| Status | Final? | Label shown to the employee (SD-14) | Meaning |
|---|---|---|---|
| `PENDING_MANAGER_APPROVAL` | No | Pending manager approval | Submitted; waiting for the current manager |
| `PENDING_HR_ELIGIBILITY` | No | Pending HR eligibility check | Manager approved; waiting for HR |
| `IN_PROGRESS` | No | In progress | HR approved; downstream steps running |
| `COMPLETED` | Yes | Completed | Org record update and every required step completed (BR-15) |
| `REJECTED_BY_MANAGER` | Yes | Rejected by Manager | Manager rejected, with reason (BR-11, BR-28) |
| `REJECTED_BY_HR` | Yes | Rejected by HR | HR rejected, with reason (BR-12, BR-28) |
| `FAILED` | Yes | Failed | A required downstream step failed (BR-16) |

A request is **in progress** when its status is not final (BR-07, BR-17).

A `COMPLETED` request is **awaiting effect** while the device local date is
before its effective date: the transfer is approved and scheduled, but the
employee's profile still shows the current values (BR-13). It is shown as
"Completed: takes effect on <effective date>" (SD-17). A request that is not
`COMPLETED` is never awaiting effect.

### The three moments of the organisational change (SD-16)
The reviewer asked what `ORG_RECORD_UPDATE` = `COMPLETED` means. Three
separate moments are defined, and only the third changes what the profile
shows:

| Moment | When | What it means | What changes |
|---|---|---|---|
| **Recorded** | HR records `ORG_RECORD_UPDATE` = `COMPLETED` | HR has confirmed the new department, location and role for the effective date. The step is done | Step state only. The profile and the schedule do **not** change |
| **Scheduled** | The request becomes `COMPLETED` (the last required step completes) | The portal calls `scheduleOrganisationalChange` once, in the same save as the status change | A scheduled change exists, effective from the effective date |
| **Effective** | The device local date reaches the effective date | The scheduled change takes effect | The profile (`getCurrentValues`) shows the new values |

A request that ends `FAILED` never reaches "Scheduled", so no transfer is
scheduled and the profile never changes. This keeps BR-16: the completed
`ORG_RECORD_UPDATE` step is not rolled back (it stays `COMPLETED` in the
request and the history); there is simply nothing to roll back, because the
change is applied only when the whole transfer succeeds.

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

These are the V1 business rule; the Sponsor confirms them before production
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

// D-02 — schedule an organisational change that takes effect later (BR-13).
// Called only when a request becomes COMPLETED (SD-16). Idempotent by requestId (SD-20).
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
after `effectiveFrom`; before that it returns the previous values (BR-13).
`managerName` is demo data, not verified, and grants no authority outside
the request (BR-10).

**`scheduleOrganisationalChange` idempotency and conflicts (SD-20).** The
unique key is `requestId`: at most one scheduled change exists per request.

| Call | Result |
|---|---|
| First call for this `requestId` | `Result.success(ScheduledChange)`; one change is scheduled |
| Repeat call, same `requestId`, same values and date | `Result.success` with the **existing** `ScheduledChange` (same `scheduledAt`). Nothing new is created |
| Repeat call, same `requestId`, different values or date | `Result.error("A different change is already scheduled for this request.")`. The existing change is kept |
| Call for another `requestId` while this employee has a change that has not taken effect | `Result.error("Another transfer is already scheduled for this employee.")`. Nothing is scheduled |

If the call returns an error, the request does not become `COMPLETED`: the
last step's outcome, the status change and the schedule are saved together
or not at all (OP06), and OP06 returns the error. With SD-17 in force, the
last two rows cannot happen through the journey; they guard the contract.

## Local Data Contract
Local operations between the presentation layer and the repository. No
network API (ADR-0004). Every operation returns `Result<T>` (ADR-0001) and
works **only on the signed-in employee's own requests** (BR-23). If nobody
is signed in, every operation returns `Result.error("Please sign in.")`.

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
- has one `SUBMITTED` history entry (BR-27).

**Idempotency (BR-08):** if a request with the same `submissionId` already
exists for this employee, OP01 returns that request unchanged. No second
request and no second history entry are created.

**Errors**, checked in this order; no request and no history entry is
created:
| # | Condition | Message |
|---|---|---|
| 1 | Department, location or role missing, or not in its reference list | Field-level message, e.g. "Select a department." |
| 2 | Effective date missing | "Enter an effective date." |
| 3 | Effective date is today or earlier (device local date) | "Effective date must be in the future." |
| 4 | Department, location and role all equal the current values | "Change at least one of department, location or role." |
| 5 | The employee already has a request in progress | "You already have a transfer request in progress." |
| 6 | Reason longer than 500 characters | "Reason must be 500 characters or fewer." |

A reason that is empty or only spaces is stored as no reason. There is no
maximum effective date (SD-11). The request and its `SUBMITTED` history
entry are saved together or not at all.

### employee-internal-transfer.OP02 — getMyActiveTransferRequest
**Input:** none.
**Success:** `Result.success(TransferRequest?)`: the employee's request in
progress, or `null` if there is none.

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

### employee-internal-transfer.OP06 — recordStakeholderOutcome (demo-only)
_Backs the demo-only simulation (AC24–AC26). Not a stakeholder interface
(BR-24)._

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

**Effects** (each outcome, its history entries and any status change are
saved together or not at all):
| Outcome | Effect |
|---|---|
| Manager `APPROVED` | Step `COMPLETED`; status → `PENDING_HR_ELIGIBILITY`; `HR_ELIGIBILITY` = `PENDING` |
| Manager `REJECTED` | Step `REJECTED` with reason; status → `REJECTED_BY_MANAGER` |
| HR `APPROVED` | Step `COMPLETED`; status → `IN_PROGRESS`; `ORG_RECORD_UPDATE` = `PENDING`; Payroll/IT/Facilities = `PENDING` or `NOT_REQUIRED` per the triggers table |
| HR `REJECTED` | Step `REJECTED` with reason; status → `REJECTED_BY_HR` |
| Downstream `COMPLETED` | Step `COMPLETED`. If this was the last pending step: status → `COMPLETED`. `ORG_RECORD_UPDATE` completed also calls `scheduleOrganisationalChange` with the proposed values and `effectiveFrom = effectiveDate` (BR-13) |
| Downstream `FAILED` | Step `FAILED`; every other `PENDING` step → `STOPPED`; `COMPLETED` steps stay `COMPLETED` (not rolled back); status → `FAILED` (BR-16) |

**Errors** (nothing is changed):
| Condition | Message |
|---|---|
| Request not found, or belongs to another employee | "No request found." |
| Request is in a final outcome | "This request is already closed." |
| The step is not `PENDING` (not reached, already recorded, `STOPPED` or `NOT_REQUIRED`) | "This step is not pending." |
| Outcome not valid for the step | "This outcome is not valid for this step." |
| `REJECTED` with no reason, or a reason of only spaces | "A rejection reason is required." |
| Reason longer than 500 characters | "Reason must be 500 characters or fewer." |

### Stakeholder contract (BRD-001 §8)
What the portal sends to each stakeholder when its step becomes `PENDING`,
and what it needs back. In V1 there is no real integration (ADR-0004): the
task is created locally, **shown in the demo-only simulation control**
(AC29), and answered through OP06. The same shapes are the contract for a
future real integration. The task content is fixed when the step becomes
`PENDING` (SD-15).

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
  actor: EMPLOYEE | MANAGER | HR | PAYROLL | IT | FACILITIES,
  type: SUBMITTED | STEP_OUTCOME | STATUS_CHANGED,
  stepId?, outcome?, reason?, fromStatus?, toStatus?,
  stoppedSteps?,       // on the FAILED status change
}
```

## Acceptance Criteria

### Request capture
1. **employee-internal-transfer.AC01** — Given a signed-in employee with no
   request in progress, when they open the transfer request form, then they
   can select a proposed department/business unit, location and role from
   the reference lists, pick an effective date, and optionally enter a
   reason. *(BR-01, BR-02)*
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
    update completes, then the new department, location and role are
    recorded with effect from the effective date: before that date the
    employee's profile still shows the current values; from that date it
    shows the new values. *(BR-13)*
17. **employee-internal-transfer.AC17** — Given `IN_PROGRESS`, when any
    required step fails, then that step is `FAILED`, every other pending
    step is `STOPPED`, completed steps stay `COMPLETED`, status becomes
    `FAILED`, and stopped steps accept no further outcome. No retry, undo
    or compensation action is offered. *(BR-16)*
18. **employee-internal-transfer.AC18** — Given a request in any final
    outcome, then no step accepts an outcome, and the employee can submit a
    new request. *(BR-17)*

### Visibility and confirmation
19. **employee-internal-transfer.AC19** — Given a request, when the employee
    opens it, then they see the overall status, the proposed values,
    effective date and reason they submitted, and each step that has been
    reached with its state; each pending step shows its pending action as
    named in the Steps table; each rejected step shows its rejection
    reason. *(BR-18, BR-19, §6)*
20. **employee-internal-transfer.AC20** — Given a final outcome, when the
    employee opens the request, then they see the confirmation for that
    outcome, ending with "You may submit a new request": *(BR-20, §7)*
    - `COMPLETED`: transfer confirmed, the new department, location and
      role, "effective from <effective date>", and the completed steps;
    - `REJECTED_BY_MANAGER`: not approved by the manager, the manager's
      reason, and that no further steps were taken;
    - `REJECTED_BY_HR`: not approved by HR, HR's reason, and that no
      further steps were taken;
    - `FAILED`: which step failed, which steps had completed (not undone),
      and which steps were stopped.
21. **employee-internal-transfer.AC21** — Given any status change, then the
    employee is informed only inside the portal; no email or push
    notification is sent, and no SLA timer, reminder or escalation is
    shown or run. *(BR-21, BR-22)*

### Security, ownership and audit
22. **employee-internal-transfer.AC22** — Given two employees, when one
    lists, opens or reads the history of requests, then only their own
    requests are returned; another employee's request ID gives "No request
    found." *(BR-23)*
23. **employee-internal-transfer.AC23** — Given any submission, stakeholder
    outcome or status change, then an entry is appended to the request's
    history (actor, step, outcome or status change, reason for a
    rejection, time); the employee can view it oldest first; no entry is
    ever edited or deleted, and the screen offers no way to do so.
    *(BR-27, BR-28)*

### Demo-only simulation (V1)
24. **employee-internal-transfer.AC24** — Given a request in progress, then
    a control labelled "Demo only: simulate stakeholder outcome" lets a
    tester record an outcome for the **pending** steps only, offering just
    the valid outcomes for each step (Approve / Reject for manager and HR;
    Complete / Fail for downstream steps). It is never presented as a real
    stakeholder interface. *(BR-24, §9)*
25. **employee-internal-transfer.AC25** — Given the tester chooses Reject,
    then a reason is required: the rejection cannot be recorded while the
    reason is empty or only spaces. *(BR-28)*
26. **employee-internal-transfer.AC26** — Given an outcome for a step that is
    not pending, not valid for that step, or on a closed request, then it
    is refused with the matching OP06 error and nothing changes. *(BR-17,
    BR-24)*

### Access, demo posture, stakeholder tasks and request list (added in v2.1)
27. **employee-internal-transfer.AC27** — Given nobody is signed in, when
    the transfer feature is opened, then the employee is asked to sign in,
    no request data is shown, and every operation returns "Please sign in."
    *(BR-26, D-01)*
28. **employee-internal-transfer.AC28** — Given the V1 app, then the
    transfer form, the request screen and the simulation control show a
    visible "Demo — test data only" indicator, so no one mistakes V1 for a
    production system holding real employee records. *(BR-25, §9; SD-12)*
29. **employee-internal-transfer.AC29** — Given a step becomes `PENDING`,
    then a stakeholder task is created with exactly the payload in the
    Stakeholder contract for that step, and the simulation control shows
    it before an outcome is recorded. For `IT_ACCESS_CHANGE` the task lists
    both the access to provision and the access to remove. *(§8, BR-13,
    BR-24)*
30. **employee-internal-transfer.AC30** — Given an employee with one or more
    requests, when they open their request list, then they see only their
    own requests, newest first, each with its submitted date and status
    label, and can open any of them and its history. *(BR-23, BR-27;
    SD-08)*

## Unit Test Cases (spec-derived)
| Test ID | AC | Scenario | Expected |
|---|---|---|---|
| UT01 | AC03 | Submit valid request changing role only | Success; `PENDING_MANAGER_APPROVAL`; 1 `SUBMITTED` entry |
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
| UT20 | AC15 | All required steps complete in a different order each run | `COMPLETED` after the last one |
| UT21 | AC16 | Org record completes; read profile before and on the effective date | Old values before; new values on the date |
| UT22 | AC17 | Payroll completes, then IT fails; Org and Facilities pending | IT `FAILED`; Org and Facilities `STOPPED`; Payroll stays `COMPLETED`; `FAILED` |
| UT23 | AC17 | Outcome recorded on a `STOPPED` step | Error; nothing changes |
| UT24 | AC18 | New submission after each final outcome (4 cases) | Accepted |
| UT25 | AC18, AC26 | Any outcome on a closed request | Error "already closed"; nothing changes |
| UT26 | AC26 | HR outcome while `PENDING_MANAGER_APPROVAL` | Error "not pending" |
| UT27 | AC26 | `COMPLETED` outcome on `MANAGER_APPROVAL` | Error "not valid for this step" |
| UT28 | AC22 | Employee B reads, lists and reads history of employee A's request | "No request found."; B's list excludes A's request |
| UT29 | AC22 | No employee signed in | Every operation returns "Please sign in." |
| UT30 | AC23 | Full journey to `COMPLETED` | History has submission, each outcome and each status change, in order |
| UT31 | AC23 | Outcome that fails validation | No history entry added |
| UT32 | AC20 | Confirmation content for each of the 4 final outcomes | Matches §7 of BRD-001 |
| UT33 | AC13 | HR approves; department and location changed | All four downstream steps `PENDING` |
| UT34 | AC13 | HR approves; department and role changed | Org, Payroll, IT `PENDING`; Facilities `NOT_REQUIRED` |
| UT35 | AC13 | HR approves; location and role changed | All four downstream steps `PENDING` |
| UT36 | AC25 | HR rejects with blank reason | Error "A rejection reason is required."; nothing changes |
| UT37 | AC08 | Widget: tap submit, then tap again while processing | Submit disabled while processing; one request |
| UT38 | AC09 | Widget: open a submitted request | No edit or withdraw action shown |
| UT39 | AC19 | Widget: each of the six steps when `PENDING`; a rejected step | Pending action label matches the Steps table; rejected step shows its reason; states use the defined labels |
| UT40 | AC01 | Widget: open the form; submit without a reason | Lists come from D-03; submission succeeds with no reason |
| UT41 | AC24 | Widget: simulation control on each status | Only pending steps offered, only their valid outcomes; labelled "Demo only" |
| UT42 | AC27 | Widget: open the feature with nobody signed in | Sign-in prompt; no request data shown |
| UT43 | AC28 | Widget: form, request screen, simulation control | "Demo — test data only" indicator visible on each |
| UT44 | AC29 | Each of the six steps becomes `PENDING` | Task payload matches the Stakeholder contract; IT lists provision and remove |
| UT45 | AC30 | Employee with three requests; another employee with one | Own three, newest first; other employee's not listed |
| UT46 | OP01, OP06 | Reason of 501 characters on submit; rejection reason of 501 characters | "Reason must be 500 characters or fewer."; nothing saved |
| UT47 | AC05 | Effective date 5 years ahead | Accepted (no maximum, SD-11) |
| UT48 | AC16 | Org record completed; new request submitted before the effective date | Snapshot uses the old values (SD-06) |
| UT49 | AC17 | Widget: request `FAILED` | No retry, undo or compensation action shown |
| UT50 | AC29 | Second response to a task whose step is no longer pending | "This step is not pending."; request unchanged |

AC21 (no email, push, SLA timer, reminder or escalation) has no runtime
behaviour to test; it is verified at code review (Gate 2) by confirming no
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
  retry, rollback, compensation and reconciliation.
- An admin or support console.
- Inactive or terminated employees.
- Sign-in features: password policy, lockout, email verification/OTP,
  identity uniqueness (BR-26). Sign-in is a dependency (D-01), not part of
  this spec.
- A production-grade interface for each stakeholder role.
- Payroll, IT and Facilities' own internal workflows.
- Retention periods, deletion of requests or history, and subject-access
  handling for employee personal data (BR-25; future production
  requirements).

## Non-Functional Constraints
- **Demo posture (BR-24 to BR-26, §9):** V1 is a demo. It uses test/demo
  data only and must not be loaded with real employee records. Sign-in is
  demo-level and not production-ready. The simulation cannot prove that a
  real stakeholder took a decision.
- **Privacy (BR-25):** no employee personal data in logs at any level,
  including the reason and rejection reasons. The screens show only what
  the journey needs.
- **Ownership (BR-23, BR-24):** the employee-ID check is enforced in the
  repository, not only hidden in the UI.
- **Audit (BR-27):** history is append-only at the repository level; there
  is no update or delete operation for it.
- **Validation:** every mandatory field has a client-side validator
  (`core/utils/validators.dart`) and is re-checked in the repository before
  saving.
- **Performance:** local reads and writes complete in under 500 ms on a
  mid-range device.
- **Demo-only control (BR-24; SD-13):** the simulation control is part of
  every V1 build and is visually separate from the employee's own actions.
  It must be removed, or replaced by real stakeholder integrations, before
  any production release.

## Spec decisions for Gate 1
Details BRD-001 leaves open that the spec has to settle. Please confirm or
reject each.

| ID | Decision | Why |
|---|---|---|
| SD-01 | Only steps that have been reached are shown. HR appears after the manager approves; the four downstream steps appear when HR approves. There is no "Not started" state. | BR-19 lists six states and no "not started" state. Showing unreached steps would need a seventh. |
| SD-02 | A manager or HR approval shows the step as `COMPLETED` (Approved). | BR-19 has no "Approved" state; Completed is the closest. |
| SD-03 | Triggers use the current values snapshot taken at submission, not the profile at HR approval time. | The employee confirmed the change against those values (BR-03). The snapshot keeps the decision stable. |
| SD-04 | Another employee's request gives the same "No request found." as a missing one. | Avoids telling one employee that another's request exists (BR-23, BR-25). |
| SD-05 | The effective date is checked only at submission. A request that is still in progress after its effective date has passed carries on; the date is not re-checked. | BRD-001 has no rule for this case; re-checking would add one. |
| SD-06 | If a new request is submitted after `COMPLETED` but before the effective date, its current values are the old ones (the profile as of today). | Follows BR-13: until the effective date the profile keeps the current values. |
| SD-07 | Idempotency uses a `submissionId` generated once per submit action. | Makes BR-08 testable at the repository, not only in the UI. |
| SD-08 | The employee can list all their requests (OP03), not only the latest. | BR-27 says the employee can view the history; after a new request, the old request's history would otherwise be unreachable. |
| SD-09 | A downstream failure carries no reason. | §8 needs back only "Completed / Failed". BR-28 requires a reason only for manager and HR rejections. |
| SD-10 | The employee's reason and a rejection reason are each at most 500 characters. | BRD-001 gives no limit; a limit makes the fields testable and keeps the history readable. |
| SD-11 | There is no maximum effective date. | BR-05 sets only "future date"; adding a maximum would be a new business rule. |
| SD-12 | V1 screens show a "Demo — test data only" indicator (AC28). | Makes BR-25's "test/demo data only" visible and testable. |
| SD-13 | The simulation control is in every V1 build and must be removed before production. | V1 has no real integration (ADR-0004), so the journey cannot progress without it; BR-24 requires that it is never taken for a real interface. |
| SD-14 | Status labels shown to the employee are as in the Request status table. | BR-06 names "Pending manager approval"; the other labels follow BRD-001 wording (§3, BR-11 to BR-17). |
| SD-15 | A stakeholder task's content is fixed when its step becomes `PENDING`. | Keeps the task stable while pending; matches the snapshot rule SD-03. |

## Traceability: BRD-001 → spec
| BRD-001 | Spec |
|---|---|
| BR-01, BR-02 | AC01, AC04, OP01 |
| BR-03 | AC02, OP01 snapshot, SD-03 |
| BR-04 | AC06 |
| BR-05 | AC05, SD-05 |
| BR-06 | AC03 |
| BR-07 | AC07, OP02 |
| BR-08 | AC08, SD-07 |
| BR-09 | AC09 |
| BR-10, BR-11 | AC10, AC11 |
| BR-12 | AC12 |
| BR-13, §5 | AC13, AC16, triggers table, SD-06 |
| BR-14 | AC14 |
| BR-15 | AC15 |
| BR-16 | AC17 |
| BR-17 | AC18, AC26 |
| BR-18, BR-19, §6 | AC19, Steps table, SD-01, SD-02 |
| BR-20, §7 | AC20 |
| BR-21, BR-22 | AC21 |
| BR-23 | AC22, OP03–OP05, SD-04 |
| BR-24 | AC24, AC26, OP06 |
| BR-25, BR-26 | Non-Functional Constraints, Out of Scope, Consumed contract |
| BR-27 | AC23, OP05, SD-08 |
| BR-28 | AC11, AC12, AC20, AC25 |
| §8 integration needs | Stakeholder contract, AC29, OP06 valid outcomes and effects, SD-15 |
| §11 D-01 to D-03 | Consumed contract, AC27 |
| §11 D-04 | Context (D-04) |
| §12 | Explicitly Out of Scope |

**v2.1 additions to the rows above:** BR-02 → SD-10, UT40, UT46; BR-05 →
SD-11, UT47; BR-08 → UT37; BR-09 → UT38; BR-13 → UT33–UT35, UT48; BR-16 →
UT49; BR-18, BR-19 → status and step labels, SD-14, UT39; BR-23 → AC30,
UT45; BR-24 → AC29, SD-13, UT41, UT44, UT50; BR-25 → AC28, SD-12, UT43,
Out of Scope (retention); BR-26 → AC27, UT42; BR-27 → AC30; BR-28 → UT36.

## BRD-001 coverage check (v2.1)
Every item of the approved BRD-001 v5.2, and where the spec covers it.

| BRD-001 | Covered by | |
|---|---|---|
| §1 objective, success measure | Intent; AC19 (status and pending action visible without contacting anyone) | ✅ |
| §2 primary users | Definitions: Actors | ✅ |
| §3 journey steps 1–8 | Step 1: Context D-04 · Steps 2–7: Steps table, AC10–AC17 · Step 8: AC20 | ✅ |
| BR-01 to BR-28 | Traceability table above; every BR has at least one AC | ✅ |
| §5 downstream triggers | Triggers table (all 7 combinations); UT15–UT18, UT33–UT35 | ✅ |
| §6 pending actions | Steps table; AC19; UT39 | ✅ |
| §7 employee confirmation | AC20; UT32 | ✅ |
| §8 integration needs | Stakeholder contract; AC29; UT44, UT50 | ✅ |
| §9 business vs technical | Context (ADRs); Non-Functional Constraints; plan decides storage | ✅ |
| §10 assumptions A-01 to A-07 | Context (inherited assumptions) | ✅ |
| §11 dependencies D-01 to D-04 | Context; Consumed contract; AC27 | ✅ |
| §12 out of scope (14 items) | Explicitly Out of Scope (all 14, plus BR-25 retention items) | ✅ |
| §13 open questions: none | Spec decisions SD-01 to SD-15 settle spec-level details only; none adds a business rule | ✅ |

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
On Gate 1 approval of this spec: write the plan (with Constitution Check),
then tasks, then spec-derived test cases, each for review in turn.
