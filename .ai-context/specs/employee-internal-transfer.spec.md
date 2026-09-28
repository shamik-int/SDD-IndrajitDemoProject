# Spec: Employee Internal Transfer

## Spec ID
employee-internal-transfer

## Status
**v2.0 — Submitted for Gate 1 review. Not yet approved.**
Plan, tasks and test cases must not be written from this spec until the
Gate 1 reviewer (Shamik Bhattacharya) approves it.

| | |
|---|---|
| Author | Indrajit Bhandari |
| Gate 1 reviewer | Shamik Bhattacharya |
| Updated | 2026-09-28 |
| Linked BRD | `.ai-context/BRD.md#BRD-001`, **v5.2, Gate 1 Approved 2026-09-28** |
| Previous version | `employee-internal-transfer.spec-v1.5-backup-2026-09-28.md` |

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

### Request status (BR-06, BR-11 to BR-17)
| Status | Final? | Meaning |
|---|---|---|
| `PENDING_MANAGER_APPROVAL` | No | Submitted; waiting for the current manager |
| `PENDING_HR_ELIGIBILITY` | No | Manager approved; waiting for HR |
| `IN_PROGRESS` | No | HR approved; downstream steps running |
| `COMPLETED` | Yes | Org record update and every required step completed (BR-15) |
| `REJECTED_BY_MANAGER` | Yes | Manager rejected, with reason (BR-11, BR-28) |
| `REJECTED_BY_HR` | Yes | HR rejected, with reason (BR-12, BR-28) |
| `FAILED` | Yes | A required downstream step failed (BR-16) |

A request is **in progress** when its status is not final (BR-07, BR-17).

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
`PENDING`, `COMPLETED`, `REJECTED`, `FAILED`, `STOPPED`, `NOT_REQUIRED`.
No other state is used (spec decision SD-01).

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
// D-01 — the signed-in employee. null when nobody is signed in.
String? currentEmployeeId();

// D-02 — the employee's current values, as of a given date.
EmployeeCurrentValues getCurrentValues(String employeeId, {required DateTime asOf});
// { departmentId, locationId, roleId, managerName }

// D-02 — record an organisational change that takes effect later (BR-13).
void scheduleOrganisationalChange(String employeeId, {
  required String departmentId, required String locationId,
  required String roleId, required DateTime effectiveFrom,
});

// D-03 — reference lists.
List<ReferenceItem> departments();  // { id, name }
List<ReferenceItem> locations();
List<ReferenceItem> roles();
```

`getCurrentValues` returns the scheduled values only when `asOf` is on or
after `effectiveFrom`; before that it returns the previous values (BR-13).
`managerName` is demo data, not verified, and grants no authority outside
the request (BR-10).

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
  reason: String?,          // optional free text
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

A reason that is empty or only spaces is stored as no reason.

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
  reason: String?,   // mandatory when outcome == REJECTED (BR-28)
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
Step { stepId, stakeholder, state: StepState, decision?, reason?, recordedAt? }
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
    `FAILED`, and stopped steps accept no further outcome. *(BR-16)*
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
| §8 integration needs | OP06 valid outcomes and effects; Consumed contract |
| §11 D-01 to D-03 | Consumed contract |
| §12 | Explicitly Out of Scope |

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
