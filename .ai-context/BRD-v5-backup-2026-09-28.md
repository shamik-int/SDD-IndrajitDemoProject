# Business Requirements Document (BRD)

**Version:** 5.0  
**Status:** **Submitted for Gate 1 Re-Review. Not yet approved;
development remains blocked** until the Gate 1 reviewer (Shamik
Bhattacharya) approves this BRD.  
**Author:** Indrajit Bhandari  
**Gate 1 reviewer:** Shamik Bhattacharya  
**Updated:** 2026-09-28  
**Source document:** `Requirement for SDD (2).pdf` (the business scope document)  
**Previous version:** `BRD-v4-backup-2026-09-28.md`, itself following
`BRD-v3-backup-2026-09-28.md` → `BRD-v2-backup-2026-09-21.md` →
`BRD-v1-backup-2026-09-18.md`

**How to read this document:**
- **BRD-001** is the requirement under Gate 1 review. It depends **only**
  on the source document: every rule traces to a section of the source
  document, and no rule relies on any earlier spec, plan, task, test case
  or ADR. The specs, plan, tasks and test cases will be recreated from this
  BRD after approval.
- **Gate 1 Re-Review Submission** comes straight after BRD-001.
- Everything under **Review history and version control** is kept for
  history only and is **not part of the requirement**. That includes
  BRD-002, which is not being followed.

---

### BRD-001: Enable self-service employee internal transfer requests via the One-Point Employee Portal

**Raised by:** One-Point Employee Portal Product Team (source document §2–§3)  
**Sponsor / Business Owner:** HR Product Owner, One-Point Employee Portal
(assumed, see A-04)  
**Author:** Indrajit Bhandari  
**Priority:** High (assumed, see A-05)

#### 1. Business need and objective (source §2, §3)

Today an employee who wants an internal transfer has to deal with several
teams and systems separately: the manager, HR, Payroll, IT and Facilities.
That causes delay and inconsistent handling, and it leaves the employee
without a single view of where the request stands.

**Objective:** the employee raises an internal transfer request in the
existing One-Point Employee Portal and tracks it in **one digital journey**.
The portal **orchestrates the downstream activities** and gives the
employee **one view of progress** (source §3).

**Success measure:** the employee can see the status of their request, and
the action pending with each stakeholder, without contacting any team.

#### 2. Primary users (source §2, §3)

| User | Role in the journey |
|---|---|
| **Employee** (primary user) | Raises the request, tracks progress, receives the confirmation |
| **Current manager** | Confirms (approves) or rejects the transfer |
| **HR** | Validates eligibility; updates the employee's organisational record |
| **Payroll** | Updates payroll when required |
| **IT** | Provisions new access and removes old access when required |
| **Facilities** | Arranges the workspace at the new location when required |

#### 3. Journey (source §2, steps 1–8)

| Step | Source §2 | Handling in the portal | Rules |
|---|---|---|---|
| 1 | Employee discusses the transfer with the manager | **Precondition, outside the portal.** Not captured or verified. The manager's approval in step 2 is the recorded confirmation. | D-04 |
| 2 | Manager confirms the transfer | The employee's current manager approves or rejects. | BR-10, BR-11 |
| 3 | HR validates eligibility | HR approves or rejects. | BR-12 |
| 4 | Employee's organisational information is updated | **Organisational record update** by HR. **Always required** once HR approves. | BR-13 |
| 5 | Payroll may need to be updated | Payroll: **only when required**. | BR-13 |
| 6 | IT may need to provision or remove access | IT: **only when required**. Covers both provisioning new access and removing old access. | BR-13 |
| 7 | Facilities may need to arrange the new location | Facilities: **only when required**. | BR-13 |
| 8 | Employee receives confirmation | In-portal confirmation for every final outcome. | BR-20 |

Steps 4–7 start together once HR approves.

#### 4. Business rules

Each rule traces to the source document. Rules marked **V1 decision**
settle something the source document leaves open.

**Request capture (source §3)**
- **BR-01:** The employee can initiate an internal transfer request from
  the One-Point Employee Portal.
- **BR-02:** The request captures:
  - the proposed **department/business unit**, **location** and
    **role/job position**, each **selected** from the portal's reference
    lists;
  - an **effective date**;
  - an **optional reason**, as free text.
- **BR-03:** The request form shows the employee's **current** department,
  location, role and manager, read-only, from the employee's portal
  profile. *(V1 decision)*
- **BR-04:** The request must change **at least one** of department,
  location or role compared with the current values. Otherwise it is
  rejected at submission. *(V1 decision)*
- **BR-05:** The effective date must be a **future date**; today and past
  dates are rejected. There is **no minimum lead time**, so any future
  date, including tomorrow, is accepted. *(V1 decision)*
- **BR-06:** The employee submits the request, and it is recorded with the
  status **Pending manager approval**.
- **BR-07:** An employee may have **only one request in progress** (not in
  a final outcome) at a time. A new submission is rejected with an "already
  in progress" message until the current request reaches a final outcome.
  *(V1 decision)*
- **BR-08:** **Duplicate submission.** One submit action creates **at most
  one** request. The submit action is unavailable while a submission is
  being processed. A repeated or double submission never creates a second
  request or a second history entry. *(V1 decision; source §1 failure
  scenarios)*
- **BR-09:** A submitted request **cannot be amended or withdrawn** in V1.
  *(V1 decision)*

**Approval and orchestration (source §2 steps 2–7, §3)**
- **BR-10:** The approver is the employee's **current manager**, as held in
  the employee's portal profile. The receiving department's manager is not
  consulted. In V1 the manager in the profile is test/demo data. It is not
  verified against any organisation structure and grants no authority
  outside this request. *(V1 decision)*
- **BR-11:** If the manager **rejects**, the request ends as **Rejected by
  Manager**. If the manager **approves**, the request moves to HR.
- **BR-12:** HR validates eligibility and approves or rejects:
  - Eligibility rules belong to HR. The portal **must not introduce its own
    eligibility rules** unless HR or Product provides them.
  - In V1 the HR decision is simulated.
  - If HR rejects, the request ends as **Rejected by HR**.
- **BR-13:** When HR approves, these steps start together:
  - the **organisational record update** always starts;
  - Payroll, IT and Facilities start **only when required**, per the
    Downstream triggers table (§5). *(V1 decision; source §2 "may need")*
- **BR-14:** A stakeholder that is not required is shown as **Not
  required** and never becomes pending.
- **BR-15:** The request is **Completed** when the organisational record
  update and every *required* downstream step have completed.
- **BR-16:** **Failure.** If any required downstream step fails, the
  request ends as **Failed**:
  - steps that had already completed are **not rolled back**;
  - steps still pending are **stopped** and receive no further actions;
  - V1 has **no retry, timeout, escalation, compensation or
    reconciliation**. These are future requirements for real integrations.
  *(Source §1 failure scenarios)*
- **BR-17:** **Completed**, **Rejected by Manager**, **Rejected by HR** and
  **Failed** are **final outcomes**. After a final outcome, the employee may
  submit a new request.

**Visibility and confirmation (source §2 step 8, §3)**
- **BR-18:** The employee can view the **current overall status** of their
  request.
- **BR-19:** The employee can view **each stakeholder step**:
  - its state: Pending, Completed, Rejected, Failed, Stopped or Not
    required;
  - for each pending step, the **pending action**, named as in the Pending
    actions table (§6).
- **BR-20:** On a final outcome, the employee sees a **confirmation** in the
  portal, per the Employee confirmation table (§7).
- **BR-21:** **Notifications** are in-portal only. There is no email or
  push notification in V1. *(V1 decision)*
- **BR-22:** **No SLA**, reminder or escalation applies to any stakeholder
  step in V1. *(V1 decision)*

**Security, data and audit (source §1 security; §2)**
- **BR-23:** An employee can **view and submit only their own** transfer
  requests. They cannot see or act on another employee's request.
- **BR-24:** **Ownership of each outcome:**
  - Only the stakeholder responsible for a step can record that step's
    outcome.
  - The employee owns the request fields they submitted. Each stakeholder
    owns the outcome of its own step.
  - In V1, stakeholder outcomes are recorded through a clearly labelled
    **demo-only simulation**. It is not a real stakeholder interface, and
    V1 cannot prove that a real stakeholder took the decision.
- **BR-25:** Request data is **employee personal data**:
  - V1 uses **test/demo data only**. It must not be loaded with, or relied
    on for, real employee records.
  - Personal data is not exposed beyond what the journey needs.
  - Retention periods, deletion and subject-access handling are future
    production requirements.
- **BR-26:** **Sign-in** is provided by the existing portal and is not part
  of this BRD:
  - In V1, sign-in is demo-level. It does not independently verify that
    the user is the actual employee.
  - It is **not production-ready**. A production implementation requires
    proper server-side authentication and authorization.
  - Password policy, account lockout, and email verification/OTP belong to
    the portal sign-in and are **out of scope** for this BRD.
- **BR-27:** **Audit.** Every status change and stakeholder outcome is
  recorded in an **append-only history** (what changed, which stakeholder,
  when) that is never edited or deleted. The employee can view it.

#### 5. Downstream triggers (source §2 steps 4–7)

Decided by comparing the proposed values with the employee's current
values (BR-03):

| Step | Required when | Reason |
|---|---|---|
| Organisational record update (HR) | Always | Every transfer changes at least one organisational field (BR-04) |
| Payroll | Role **or** location changes | Pay grade and location-based pay may change |
| IT | Department **or** role changes | Access must be provisioned for the new department/role and removed for the old one |
| Facilities | Location changes | The employee needs a workspace at the new location |

These trigger rules are the **V1 business rule**. The Sponsor must confirm
them before any production commitment (A-06).

#### 6. Pending actions (source §3 "view actions that are pending")

| Stakeholder | Pending action shown to the employee |
|---|---|
| Current manager | **Manager approval** |
| HR | **HR eligibility check** |
| HR | **Organisational record update** |
| Payroll | **Payroll update** |
| IT | **IT access change**: provision new access, remove old access |
| Facilities | **Facilities: workspace at the new location** |

#### 7. Employee confirmation (source §2 step 8)

| Final outcome | What the employee is shown |
|---|---|
| **Completed** | Transfer confirmed, with the new department, location and role, the effective date, and the list of completed steps |
| **Rejected by Manager** | The request was not approved by the manager, and no further steps were taken |
| **Rejected by HR** | The request was not approved by HR, and no further steps were taken |
| **Failed** | Which step failed, which steps had already completed (these are not undone), and which steps were stopped |

Every confirmation tells the employee that they may submit a new request
(BR-17).

#### 8. Integration needs per stakeholder (source §1 integration and failure scenarios; §3 orchestration)

What the portal needs from each stakeholder. This is a business-level
statement; the specs will define the contracts.

| Stakeholder | Triggered when | Portal sends | Portal needs back | Outcome |
|---|---|---|---|---|
| Current manager | On submission | Employee, current and proposed department/location/role, effective date, reason | Approved / Rejected | Approved → HR. Rejected → **Rejected by Manager** |
| HR: eligibility | Manager approves | Same request details | Approved / Rejected | Approved → steps 4–7. Rejected → **Rejected by HR** |
| HR: organisational record update | HR approves (always) | Employee, new department/location/role, effective date | Completed / Failed | Required for Completed. Failed → **Failed** |
| Payroll | HR approves and role or location changes | Employee, new role/location, effective date | Completed / Failed | Required for Completed. Failed → **Failed** |
| IT | HR approves and department or role changes | Employee, access to **provision** (new) and to **remove** (old), effective date | Completed / Failed | Required for Completed. Failed → **Failed** |
| Facilities | HR approves and location changes | Employee, new location, effective date | Completed / Failed | Required for Completed. Failed → **Failed** |

#### 9. Business decisions vs technical constraints (source §4)

| Business decisions (owned by the Sponsor; in this BRD) | Technical constraints on V1 (decided in the Plan, not here) |
|---|---|
| Journey, approver, outcomes and final states (BR-10 to BR-17) | V1 is a **demo**, not a production system |
| Downstream trigger rules (§5) | **No real integration** with HR, Payroll, IT, Facilities or any org-chart system. Stakeholder outcomes are **simulated** (BR-24) |
| One request in progress, no amend/withdraw, effective date rule (BR-05, BR-07, BR-09) | Sign-in and employee profile are **demo-level** (BR-26) |
| Pending actions and confirmations shown (BR-19, BR-20) | **Test/demo data only** (BR-25) |
| No SLA, in-portal notifications only (BR-21, BR-22) | Architecture, storage, data model and contracts are decided in the Plan and ADRs, after BRD approval |
| Security and ownership rules (BR-23 to BR-27) | |

#### 10. Assumptions

- **A-01:** The One-Point Employee Portal exists, with sign-in and an
  employee profile that holds the current department, location, role and
  manager (source §2). In V1 these are demo-level with test data.
- **A-02:** "Department/business unit" is a single selection in V1.
- **A-03:** Reference lists of departments/business units, locations and
  roles are available from the portal. In V1 these are demo lists.
- **A-04:** The Sponsor is the HR Product Owner of the One-Point Employee
  Portal. The named individual is to be confirmed by Product. This does not
  block V1, but must be confirmed before any production commitment.
- **A-05:** Priority is High, to be confirmed against the portfolio.
- **A-06:** The downstream trigger rules (§5) are proposed by the Author.
  The Sponsor must confirm them before production.
- **A-07:** Steps 4–7 are independent of each other and can run at the
  same time.

#### 11. Preconditions & Dependencies

- **D-01:** The employee is signed in to the existing portal (BR-26).
- **D-02:** The employee's portal profile supplies the current values and
  the current manager (BR-03, BR-10).
- **D-03:** The portal's reference lists supply the selection values
  (BR-02).
- **D-04:** Journey step 1, the conversation with the manager, happens
  before the employee uses the portal.

#### 12. Out of scope for V1

- International or cross-legal-entity transfers. These would be a separate,
  future BRD.
- Receiving-department manager approval.
- Capturing or verifying the conversation with the manager (journey
  step 1).
- Amending or withdrawing a submitted request.
- SLA timers, reminders and escalation.
- Email and push notifications.
- A minimum transfer lead time.
- Portal-defined HR eligibility rules.
- Real integrations with HR, Payroll, IT and Facilities. With them go
  integration retry, rollback, compensation and **reconciliation** of
  downstream data. These are future requirements.
- An **admin or support console** for operational visibility or
  intervention.
- Handling **inactive or terminated employees**. There is no HR feed in V1.
- Sign-in features: password policy, account lockout, email
  verification/OTP, and uniqueness of employee identity. These are owned by
  the portal sign-in (BR-26).
- A production-grade interface for each stakeholder role.
- Payroll, IT and Facilities' own internal workflows. This BRD covers only
  what the portal needs from each.

#### 13. Open questions

**None.** Every decision the source document leaves open is settled above
as a business rule (marked *V1 decision*) or listed as out of scope.

#### 14. Traceability: source document → BRD-001

| Source document | BRD-001 |
|---|---|
| §2: the organisation has a One-Point Employee Portal | A-01, D-01, D-02 |
| §2 step 1: discusses with the manager | Journey step 1, D-04 |
| §2 step 2: manager confirms | BR-10, BR-11 |
| §2 step 3: HR validates eligibility | BR-12 |
| §2 step 4: organisational information updated | BR-13, §5 |
| §2 steps 5–7: Payroll / IT (provision or remove) / Facilities "may need" | BR-13, BR-14, §5, §8 |
| §2 step 8: employee receives confirmation | BR-20, §7 |
| §2: single digital journey | §1, §3 |
| §3: select department/BU, location, role | BR-02, BR-03, A-02, A-03 |
| §3: effective date | BR-05 |
| §3: optional reason | BR-02 |
| §3: submit the request | BR-06, BR-07, BR-08 |
| §3: view current status | BR-18 |
| §3: view actions pending with other stakeholders | BR-19, §6 |
| §3: portal orchestrates downstream; single view of progress | BR-13 to BR-17, §8 |
| §1: handle integration, security and failure scenarios | §8, BR-16, BR-23 to BR-27 |
| §1: maintain traceability | This table; every rule cites the source document |
| §4 Deliverable 1: users, stages, rules, decisions, open questions, assumptions, dependencies, out of scope, business vs technical | §2, §3, §4, §9, §10, §11, §12, §13 |

#### 15. Gate 1 review comments (2026-09-28): coverage in BRD-001

| # | Review comment | Covered by | Status |
|---|---|---|---|
| 1 | Remove stale "Open" items | §13: no open questions | ✅ Done |
| 2 | Authentication local/demo only; user not verified as the actual employee | BR-26 | ✅ Done |
| 3 | Auth not production-ready; server-side required | BR-26 | ✅ Done |
| 4 | Manager name is demo/reference only, not verified | BR-10 | ✅ Done |
| 5 | HR eligibility not implemented; no portal-invented rules | BR-12 | ✅ Done |
| 6 | FAILED: completed actions not rolled back | BR-16 | ✅ Done |
| 7 | Convert open items into V1 decisions or out of scope | §4 *V1 decisions*, §12, §13 | ✅ Done |
| 8 | No minimum lead time | BR-05 | ✅ Done |
| 9 | Account lockout out of scope | BR-26, §12 | ✅ Done |
| 10 | Email verification/OTP not available | BR-26, §12 | ✅ Done |
| 11 | Test/demo data only | BR-25 | ✅ Done |
| 12 | Retry/rollback/compensation/reconciliation are future requirements | BR-16, §12 | ✅ Done |
| 13 | Rule against duplicate submission | BR-08 | ✅ Done |
| 14 | Business owner | BRD-001 Sponsor, A-04. **Author comment:** BRD-002 is not followed and is kept for version control only; the author is Indrajit Bhandari | ✅ Done |
| 15 | Correct the tally | Gate 1 Re-Review Submission: G1-01 to G1-30 map | ✅ Done |
| 16 | Align BRD, spec, plan and tests | **Author comment:** I have stopped writing the specs, plan and tasks; I will write them after the BRD is approved | ⏸️ Deferred until BRD approval |

---

## Gate 1 Re-Review Submission — 2026-09-28

**Submitted by:** Indrajit Bhandari (Author)  
**For:** Shamik Bhattacharya (Gate 1 reviewer)  
**Document:** BRD v5.0, **BRD-001 only**  
**Gate 1 status:** **Submitted for Re-Review. Not yet approved.**

| Review item | Total | Done | Deferred | Open |
|---|---|---|---|---|
| Source document requirements (§1–§4), traced in BRD-001 §14 | 18 rows | 18 | 0 | **0** |
| Requirement-trace gaps (T-01 to T-04, `reviews/BRD-v5.0.requirement-trace.md`) | 4 | 4 | 0 | **0** |
| BRD review blocking comments against the source document (B-01 to B-05) | 5 | 5 | 0 | **0** |
| Gate 1 review comments of 2026-09-28 (#1 to #16) | 16 | 15 | 1 (#16, after approval) | **0** |
| Gate 1 Mandatory Decision Register (G1-01 to G1-30) | 30 | 30 | 0 | **0** |

**Requirement-trace gaps, fixed in this version:**
- **T-01** pending actions: BR-19, §6.
- **T-02** security: BR-23 to BR-26.
- **T-03** traceability: BRD-001 cites only the source document and its
  own rules, with no references to earlier specs, tests or ADRs (§14).
- **T-04** Deliverable 1 items: §2 users, §4 numbered rules, §9 business vs
  technical, §10 assumptions.

**G1-01 to G1-30 → BRD-001:**

| G1 | BRD-001 | G1 | BRD-001 | G1 | BRD-001 |
|---|---|---|---|---|---|
| 01 Identity | BR-26 | 11 Conditional tasks | BR-13, §5 | 21 Contracts / idempotency | BR-08, §8 |
| 02 Registration | BR-26 | 12 Failure handling | BR-16 | 22 Data ownership | BR-24 |
| 03 Email | BR-26, §12 | 13 Amend | BR-09 | 23 Completion | BR-15 |
| 04 Password | BR-26, §12 | 14 Withdrawal | BR-09 | 24 Partial completion | BR-16 |
| 05 Authorization | BR-23, BR-24 | 15 Multiple requests | BR-07 | 25 Reconciliation | §12 |
| 06 Current data | BR-03 | 16 Effective date | BR-05 | 26 Admin/support | §12 |
| 07 Manager | BR-10 | 17 Audit | BR-27 | 27 Privacy | BR-25 |
| 08 Receiving manager | BR-10, §12 | 18 Security | BR-23 to BR-26 | 28 Inactive employees | §12 |
| 09 HR eligibility | BR-12 | 19 Notifications | BR-21 | 29 Duplicate accounts | BR-26, §12 |
| 10 Workflow | §3, BR-10 to BR-17 | 20 SLA | BR-22 | 30 V1 boundaries | §12, §13 |

**For the reviewer to re-check:**
1. The downstream trigger rules (§5). This is the V1 business rule; the
   Sponsor confirms before production.
2. The organisational record update is always required (BR-13).
3. The new security rules (BR-23 to BR-26).

**Known and accepted, not blocking approval:** the Sponsor's name is to be
confirmed (A-04).

**After approval:** write the specs, plan, tasks and test cases from
BRD-001 (comment #16).

**Reviewer decision:** ☐ Approved  ☐ Changes Requested  
**Reviewer / date:** ____________________

---

## Review history and version control (not part of the requirement)

> Kept for history only. Nothing below is a requirement. BRD-001 above is
> the requirement, and it does not depend on anything in this section. The
> earlier "V1 Posture" section is replaced by BRD-001 §9, BR-24, BR-25 and
> BR-26; its v4.0 text is kept in `BRD-v4-backup-2026-09-28.md`.
> References below to specs, test cases or ADRs refer to the earlier,
> paused artefacts.

### BRD-002: Require employee registration and login before accessing the One-Point Employee Portal

> **Not being followed (Author, Indrajit Bhandari, 2026-09-28).** BRD-002 is
> kept in this document for version control only. BRD-001 is the requirement
> under Gate 1 review.

**Raised by:** Author (Indrajit Bhandari), per direct instruction — add a
registration/login gate in front of the existing transfer-request journey.

**Business need:** BRD-001's journey currently has no employee identity at
all — any device with the app installed can submit and view "the" transfer
request, with no concept of *whose* request it is. That was a reasonable v1
simplification when the app was single-purpose and single-device, but it
doesn't hold once the portal is meant to represent a specific employee. The
organisation wants employees to register once and log in thereafter, so a
submitted request, its status, and its stakeholder-decision history belong
to an identified employee, not to a device.

**Product / Business Owner:** HR Product Owner, One-Point Employee Portal,
the same owner as BRD-001. Registration and login gate access to the portal
this owner already sponsors, so ownership belongs there rather than with the
Author. The Author (Indrajit Bhandari) remains the requester ("Raised by")
and engineering owner only, not the long-term business sponsor. The named
individual is still to be confirmed by Product, as for BRD-001.

**Priority:** High — blocks a correctness gap in the existing journey (see
Notes) as soon as more than one employee could plausibly use the same
install.

**Decided:**
- Registration captures: Name, Email, Password, Manager Name, and the
  employee's *current* Department, Location, and Role (reusing the same
  reference-data lists `employee-internal-transfer` already uses for
  *proposed* values).
- Email is the unique account identifier, compared case-insensitively.
  Login is email + password.
- A logged-in employee's transfer request(s) are scoped to their own
  identity — not shared with, or blocked by, a different employee's account
  on the same device.

**V1 decisions (previously "Open at BRD stage", now closed):**
- **Authentication is local/demo only.** V1 checks that the entered email
  is registered and that the password matches the locally stored salted
  hash. It does **not** independently verify that the user is the actual
  employee: nothing prevents someone registering under another person's
  name, department or role. This is a known, accepted limitation of the
  local demo. (ADR-0005; G1-01, G1-02, G1-29)
- **Not production-ready.** This authentication and authorization approach
  must not be treated as production-ready. A production implementation
  requires proper server-side authentication and authorization, including
  identity verification, session management and role-based,
  resource-level access control. (ADR-0005; G1-05, G1-18)
- **Manager Name is demo/reference information only.** `managerName` is
  captured as free text at registration and shown as the pending approver
  on the status screen. It is **not verified** against any employee/HR
  master or organisation structure. It must not be treated as proof of who
  the employee's actual manager is, and it confers no approval authority.
  (G1-07)
- **Current department/location/role are user-entered.** They are not
  authoritative HR data. (G1-06)
- **Password complexity.** At least 8 characters, with at least one letter
  and at least one number. This is accepted as the **V1 demo-level rule**.
  The production password policy will be defined with the server-side
  authentication mechanism. (G1-04)
- **Profile editing.** Registered profile fields cannot be edited after
  registration in V1. This is out of scope, not undecided.

**V1 Out of Scope (explicit):**
- **Email verification / OTP.** Not available in V1: the current
  architecture has no email service (ADR-0004/0005). (G1-03)
- **Password reset / forgot password.** Not available, for the same reason:
  there is no email service.
- **Account lockout / brute-force protection.** Out of scope for the local
  demo. Repeated failed logins are not throttled or locked. It is a
  mandatory requirement for any production implementation. (G1-04)
- Session expiry and auto-logout on inactivity.
- RBAC beyond "logged in or not". There are no admin, manager or HR account
  types.
- Multi-device account sync.
- Account deletion, and PII retention periods and subject-access-request
  handling. These are acceptable to omit only because V1 holds test/demo
  data only (see V1 Posture), and they are future requirements for
  production. (G1-27)
- Handling inactive or terminated employees (no HRIS feed; G1-28).

**Notes:** This BRD exists because implementing it exposes and fixes a real
gap in BRD-001's original scope: `employee-internal-transfer`'s data model
(per ADR-0004) has no `employeeId`, on the reasoning that "one Hive store =
one employee" — true only in the absence of real accounts. Once this BRD
ships, that reasoning is corrected, and `employee-internal-transfer`'s data
model gets an `employeeId` field added back as a cross-feature dependency,
sequenced at that feature's own plan-amendment stage. This BRD does **not**
retroactively invalidate BRD-001 or its spec — it changes an assumption BRD-001
was entitled to make at the time, given here as the same explicit,
un-silent correction ADR-0004 itself models.

**Spec traceability:** `specs/employee-registration-login.spec.md`.

## Gate 1 Mandatory Decision Register

**Recorded by:** Shamik Bhattacharya, Gate 1 reviewer  
**Recorded at:** 2026-09-18 16:02:25 +05:30  
**Classification:** **P0 / Mandatory**  
**Original decision:** **Changes Requested — development remains blocked.**  
**Updated:** 2026-09-28 (BRD v4.0) — the six items that were "Open — comment
only" at v3.0 are now closed as explicit V1 decisions or V1 Out-of-Scope
items, per the Gate 1 review comments of 2026-09-28.

> **v5.0 note: BRD-002 is not followed.** Some resolutions below cite
> BRD-002 registration/login (G1-01, 02, 03, 04, 05, 07, 18, 29). For
> BRD-001 they now read as follows. Employee identity, sign-in, password
> policy, email verification and authorization belong to the **existing
> portal's sign-in**, which is a dependency outside this BRD and demo-level
> in V1. The current manager (G1-07) comes from the **employee's portal
> profile** (BRD-001 Preconditions & Dependencies). The V1 limitations
> recorded in each row still apply.

The following decisions were mandatory before development proceeds. They
were requirements to resolve, not assumptions or approvals. Each resolved
item must be reflected in the applicable BRD, spec, plan, tasks, test cases,
ADRs, and/or security documentation.

**How to read the Resolution column:**
- **Fixed (v1.5/v1.2)** — a design change added in the v3.0 pass to close a
  real gap. Full detail is in the linked spec/plan section.
- **Resolved via ADR** — already settled by ADR-0004 ("no backend") or
  ADR-0005 ("local-only auth"). No new change.
- **Resolved in spec (pre-existing)** — already answered in the spec's
  Assumptions or ACs. No new change.
- **Decided for V1 (BRD v4.0)** — was open at v3.0; the known V1 behaviour
  is now stated as an explicit decision in this BRD.
- **Out of Scope for V1 (BRD v4.0)** — was open at v3.0; now explicitly
  excluded from V1 and recorded as a future/production requirement.
- **Decided in BRD v5.0** — the v4.0 answer was changed in v5.0 to match
  the requirement document; the decision now lives in BRD-001.

| ID | Area | Required decision | Resolution | Comment |
|---|---|---|---|---|
| G1-01 | Employee identity | Define `employeeId` and how it is verified. | **Decided for V1 (BRD v4.0)** | Account is keyed by case-insensitive email (ADR-0005). V1 uses local/demo authentication only: it validates the registered email and password but does not independently verify that the user is the actual employee. Real identity verification requires server-side authentication and is a production precondition (BRD V1 Posture, BRD-002). |
| G1-02 | Registration | Define the employee-verification mechanism that prevents registration using another employee's details. | Resolved via ADR | ADR-0005 names this limitation explicitly: nothing stops registering with someone else's name/dept/role under your own email. No real HRIS to check against (ADR-0004). Documented limitation, now also stated in BRD-002. |
| G1-03 | Email | Define email ownership verification, including email verification or OTP. | Resolved via ADR | No email service exists (ADR-0004/0005), so email verification/OTP is not available in V1. Now an explicit BRD-002 Out-of-Scope item. |
| G1-04 | Password | Define password complexity, hashing, reset, and lockout policy. | **Out of Scope for V1 (BRD v4.0)** — lockout; remainder decided | Hashing (salted SHA-256) is defined. Complexity (≥8 chars, letter + number) is accepted as the V1 demo-level rule. Reset is out of scope (no email service). **Account lockout/brute-force protection is explicitly out of scope for the local demo** and mandatory for production (BRD-002). |
| G1-05 | Authorization | Define RBAC and resource-level authorization. | Resolved via ADR | Only one actor type (employee) exists; Manager/HR/Payroll/IT/Facilities are simulated, not real roles. The BRD V1 Posture now states that production requires proper server-side authorization. |
| G1-06 | Current employee data | Decide whether department, location, and role are authoritative or user-entered. | Resolved in spec (pre-existing) | `employee-registration-login.OP01`: user-entered at registration, not authoritative, no HRIS integration (ADR-0004). |
| G1-07 | Manager identification | Define the source and timing of the manager relationship. | **Fixed (v1.2/v1.5)** | `managerName` (mandatory free text) is captured at registration and displayed as the pending approver. It is **demo/reference information only**: not verified against any employee/HR master or org structure, not proof of the actual manager, and it confers no approval authority (BRD-002). |
| G1-08 | Receiving manager | Decide whether receiving-manager approval is mandatory. | Resolved in spec (pre-existing) | Spec Assumption 1: only the current manager approves; the receiving-department manager is not consulted in V1. |
| G1-09 | HR eligibility | Define explicit HR eligibility rules. | Resolved in spec (pre-existing) | HR eligibility rules are **not implemented in V1**. The HR decision is simulated, and the application must not introduce its own eligibility rules unless HR/Product explicitly provides them (BRD-001). |
| G1-10 | Workflow | Define the canonical workflow state machine, including every state and transition. | Resolved in spec (pre-existing) | `plans/employee-internal-transfer.plan.md` gives the full state machine; the spec's Status Definitions lists terminal and non-terminal states, including `FAILED`. |
| G1-11 | Conditional tasks | Define the Payroll/IT/Facilities decision matrix. | **Decided in BRD v5.0** | BRD-001 "Downstream triggers": the organisational record update is always required; Payroll when role or location changes; IT when department or role changes; Facilities when location changes. This replaces v4.0's "all three always trigger", which contradicted the requirement's "may need". |
| G1-12 | Failure handling | Define retry, timeout, escalation, and compensation behaviour for integration failures. | **Fixed (v1.5)** | Any downstream rejection moves the request to terminal `FAILED`. V1 has no retry, timeout, escalation or compensation. These are future requirements once real integrations exist (BRD V1 Posture). |
| G1-13 | Amend request | Define whether and how amendment is allowed. | Resolved in spec (pre-existing) | Spec Assumption 5: no amendment in V1. |
| G1-14 | Withdrawal | Define withdrawal rules and downstream cancellation behaviour. | Resolved in spec (pre-existing) | Same decision as G1-13: no withdrawal in V1. |
| G1-15 | Multiple requests | Define allowed concurrent-request states and conflict rules. | Resolved in spec (pre-existing) | Spec Assumption 4: exactly one non-terminal request per employee. |
| G1-16 | Effective date | Define past/future validation and minimum lead-time rules. | **Decided for V1 (BRD v4.0)** | The effective date must be in the future (AC5). **There is no minimum transfer lead time in V1.** Any future date, including tomorrow, is acceptable unless Product defines another rule (BRD-001). |
| G1-17 | Audit | Require an immutable audit trail for decision history. | **Fixed (v1.5)** | Append-only Decision History plus `OP05.getDecisionHistory` (spec AC17). |
| G1-18 | Security | Define authentication, authorization, session, API, and PII controls. | **Decided for V1 (BRD v4.0)** | Session handling, no PII in logs and password hashing are defined (ADR-0005). API controls are N/A (no API, ADR-0004). V1 authentication/authorization is **local/demo only and must not be treated as production-ready**. A proper server-side mechanism is required for any production implementation (BRD V1 Posture). |
| G1-19 | Notifications | Define the notification matrix, channels, and triggering events. | Resolved in spec (pre-existing) | Spec Assumption 7: in-portal status only in V1. |
| G1-20 | SLA | Define an SLA per workflow task or explicitly exclude SLA from V1. | Resolved in spec (pre-existing) | Spec Assumption 6: SLA explicitly excluded from V1. |
| G1-21 | Integration contracts | Define request/response schemas, errors, and idempotency for each API/event contract. | **Decided for V1 (BRD v4.0)** | The Local Data Contract (OP01–OP05) specifies shapes and errors. External contracts are N/A (ADR-0004). **Duplicate-submission rule now explicit in BRD-001:** one submit action creates at most one request, and repeated or double submission never creates a second request or a duplicate history entry. Idempotency for real integrations is a future requirement. |
| G1-22 | Data ownership | Define field-level ownership for current and proposed employee data. | **Fixed (v1.5)** | Spec Assumption 11: employee-submitted fields are owned by the employee (OP01); stakeholder-decision fields are owned by the Simulate Decision control (OP04). |
| G1-23 | Effective transfer completion | Define the final success condition for a completed transfer. | **Decided in BRD v5.0** | BRD-001 "Journey": `COMPLETED` when the organisational record update and every *required* downstream step have completed. The employee then sees the Completed confirmation (BRD-001 "Employee confirmation"). |
| G1-24 | Partial completion | Define recovery and/or compensation when HR approves but IT or another downstream step fails. | **Fixed (v1.5)** | If one downstream action has already completed and another stakeholder rejects, the request becomes `FAILED`. **Previously completed actions are not rolled back in V1.** Remaining pending steps are no longer pending, and the employee may submit a new request (BRD-001). |
| G1-25 | Reconciliation | Define reconciliation for downstream data mismatches. | Resolved via ADR | No real downstream system exists (ADR-0004), so V1 has nothing to reconcile. Reconciliation is a documented future requirement once real integrations are introduced (BRD V1 Posture). |
| G1-26 | Admin/support | Define operational visibility and support intervention capabilities. | Resolved via ADR | No admin/support console in V1: there is no server-side state (ADR-0004). The Simulate Decision control is a demo/test stand-in, not an ops tool. |
| G1-27 | Regulatory/privacy | Define PII retention, deletion, access, and audit requirements. | **Out of Scope for V1 (BRD v4.0)** | No PII in logs is defined (constitution.md, both specs). Retention periods, account deletion and subject-access handling are **explicitly out of scope for V1**, acceptable only because V1 uses test/demo employee data only. They are mandatory future requirements for production (BRD V1 Posture, BRD-002). |
| G1-28 | Registration lifecycle | Define behaviour for inactive or terminated employees. | **Fixed (v1.5)** | Spec Assumption 12: explicitly out of scope; no HRIS/termination feed exists (ADR-0004). |
| G1-29 | Duplicate accounts | Define employee-identity uniqueness beyond email uniqueness. | Resolved via ADR | Case-insensitive email uniqueness is defined and tested. Uniqueness beyond email is the same accepted limitation as G1-02 (ADR-0005). |
| G1-30 | V1 boundaries | Explicitly mark all V1 decisions and prevent unresolved items from expanding scope. | Resolved in spec (pre-existing) — closed at BRD v4.0 | Both specs and ADR-0004/0005 carry explicit Out-of-Scope/Deferred sections. At v4.0, no open items remain in the BRD: every former open item is now a V1 decision or V1 Out-of-Scope item. |

**Tally (v5.0; totals 30):**

| Resolution | Count | Items |
|---|---|---|
| Fixed (v1.2/v1.5) | 6 | G1-07, 12, 17, 22, 24, 28 |
| Resolved in spec (pre-existing) | 10 | G1-06, 08, 09, 10, 13, 14, 15, 19, 20, 30 |
| Resolved via ADR | 6 | G1-02, 03, 05, 25, 26, 29 |
| Decided for V1 (BRD v4.0) | 4 | G1-01, 16, 18, 21 |
| Out of Scope for V1 (BRD v4.0) | 2 | G1-04, 27 |
| Decided in BRD v5.0 | 2 | G1-11, 23 |
| **Total** | **30** | Open: **0** |

_Correction note: the v3.0 tally stated "13 already resolved pre-existing or
via ADR" but listed 18 items (G1-02, 03, 05, 06, 08, 09, 10, 11, 13, 14, 15,
19, 20, 23, 25, 26, 29, 30). The correct v3.0 figures were 6 Fixed + 18
Resolved + 6 Open = 30. The v4.0 table above separates "Resolved" into its
two categories (12 + 6 = 18) and moves the 6 former Open items into the two
new v4.0 categories (4 + 2)._

**Traceability:** The complete dated review record is maintained in
`.ai-context/reviews/employee-internal-transfer.gate1-review.md`.

## Gate 1 Review Comments — 2026-09-28

**From:** Shamik Bhattacharya, Gate 1 reviewer  
**Instruction:** Update the BRD only (plan and tasks unchanged in this
pass); release a new BRD version and keep the previous one as a backup.

| # | Review comment | Where addressed in v4.0 | Status |
|---|---|---|---|
| 1 | Reflect Spec/Gate 1 decisions consistently; remove stale "Open" items in BRD-001 | BRD-001 "V1 decisions" (all 7 former open items closed) | ✅ Done |
| 2 | V1 uses local/demo authentication only; does not verify the user is the actual employee | V1 Posture; BRD-002 V1 decisions; G1-01 | ✅ Done |
| 3 | Authentication/authorization not production-ready; server-side mechanism required | V1 Posture; BRD-002 V1 decisions; G1-18 | ✅ Done |
| 4 | `managerName` is demo/reference only, not verified, not proof of manager | BRD-002 V1 decisions; G1-07 | ✅ Done |
| 5 | HR eligibility not implemented in V1; HR decision simulated; no app-invented rules | BRD-001 V1 decisions and Out of Scope; G1-09 | ✅ Done |
| 6 | Clarify FAILED: prior completed actions not rolled back | BRD-001 "FAILED state"; G1-12, G1-24 | ✅ Done |
| 7 | Convert remaining open items into V1 decisions or Out-of-Scope | BRD-001 and BRD-002 now have no "Open" list; register Open count = 0 | ✅ Done |
| 8 | No minimum transfer lead time in V1 | BRD-001 "Effective date"; G1-16 | ✅ Done |
| 9 | Account lockout/brute-force out of scope for local demo | BRD-002 Out of Scope; G1-04 | ✅ Done |
| 10 | Email verification/OTP not available (no email service) | BRD-002 Out of Scope; G1-03 | ✅ Done |
| 11 | Test/demo employee data only; not a production employee data system | V1 Posture; G1-27 | ✅ Done |
| 12 | Real integration retry/rollback/compensation/reconciliation are future requirements | V1 Posture; BRD-001 Out of Scope; G1-12, G1-25 | ✅ Done |
| 13 | Rule to prevent duplicate requests from repeated/double submission | BRD-001 "Duplicate submission"; G1-21 | ✅ Done |
| 14 | Identify appropriate Product/Business Owner for BRD-002 | BRD-002 "Product / Business Owner". **Author comment (Indrajit Bhandari, 2026-09-28):** BRD-002 is not being followed. It is kept in this document for version control only. The author is Indrajit Bhandari. | ✅ Done |
| 15 | Correct the Gate 1 tally to match the individual items | Corrected tally table and correction note | ✅ Done |
| 16 | Review BRD and Spec together so BRD, Spec, plan and test cases reflect the same V1 behaviour | "Downstream Alignment Required" below — the follow-up review. **Author comment (Indrajit Bhandari, 2026-09-28):** I have stopped writing the specs, plan and tasks. I will write them after the BRD is approved. | ⏸️ Deferred until BRD approval |

## BRD Gate 1 Review — 2026-09-28 (against the requirement document)

**Review:** `reviews/BRD-v4.0.gate1-review.md`. BRD v4.0 was reviewed only
against `Requirement for SDD (2).pdf`. Of its 8 blocking comments, the 5
that come directly from the requirement document are addressed in v5.0:

| Comment | Requirement document | Where addressed in v5.0 |
|---|---|---|
| B-01: journey steps 1 and 4 | §2 step 1 "discusses the transfer with the manager"; step 4 "organisational information is updated" | BRD-001 "Journey" (steps 1 and 4); Out of Scope (step 1 not captured) |
| B-02: employee confirmation | §2 step 8 "Employee receives confirmation" | BRD-001 "Employee confirmation" |
| B-03: conditional downstream | §2 steps 5–7 "may need" | BRD-001 "Downstream triggers"; Downstream fan-out; G1-11 |
| B-04: integration needs, IT provision/remove | §1 "Define API contracts", "Handle integration… and failure scenarios"; §2 step 6 "provision or remove access" | BRD-001 "Integration needs per stakeholder" |
| B-05: orchestration vs no integration | §3 "portal to orchestrate the downstream activities" | BRD-001 "Decided": Business intent vs V1 delivery |

B-06, B-07 and B-08 are **not BRD requirements in the requirement
document**. B-06 and B-07 are Deliverable 1 (Discovery) items, already
covered in `discovery/employee-internal-transfer.discovery.md`. B-08 comes
from the decision to recreate the specs, not from the requirement
document. They are not changed in this pass.

## Downstream Alignment Required — superseded

> **Superseded (2026-09-28).** The existing specs, plan, tasks and test cases
> are not being updated. They will be recreated from the approved BRD
> (comment #16, deferred until BRD approval). The list below is kept for
> version control only.

As instructed, this pass changed **only the BRD**. The spec, plan, tasks and
test cases were not edited. The BRD now states some V1 behaviour more
explicitly than those documents do. The joint alignment review (comment 16)
should confirm or carry through each of the items below. None of them
changes existing V1 behaviour: each makes an existing decision explicit.

**`specs/employee-internal-transfer.spec.md`**
- Add an explicit AC for the duplicate-submission rule. Today it exists
  only as test case QA03 plus the OP01 "already in progress" error.
- State "no minimum transfer lead time" explicitly. AC5 currently implies
  it without saying so.
- Reword Assumption 3 (HR eligibility) to include "the application must not
  introduce its own eligibility rules unless HR/Product provides them".
- In Assumption 9 / AC15, state that downstream steps still pending when
  another step fails are no longer actioned. Also state that completed
  steps are not rolled back (already stated in Assumption 9; keep it).
- Add a test/demo-data-only statement.
- Update the "(BRD-001 open question N)" references in the Assumptions
  section to point at the BRD-001 v4.0 "V1 decisions" instead. Those
  questions are no longer open in the BRD.

**`specs/employee-registration-login.spec.md`**
- Add to Out of Scope: account lockout/brute-force protection, and email
  verification/OTP. Today only password reset is listed.
- Move the password-complexity rule from "Open, flagged for Gate 1" to an
  accepted V1 demo-level rule.
- Mark `managerName` explicitly as demo/reference information, not proof of
  the actual manager.
- Add the "not production-ready; server-side authentication and
  authorization required for production" statement to Non-Functional
  Constraints.

**Plan / tasks / test cases** (not changed in this pass, by instruction)
- Confirm the plan already disables the submit action while a submission
  is in progress, and that test case QA03 also covers Decision History (no
  duplicate submission entry).
- Confirm test cases cover the `FAILED` case where a step has already
  completed (for example, Payroll completes and then IT rejects).

**Other:** `project_context.md` still lists the Business Sponsor as
"assumed — confirm". It should be updated when Product names the owner for
BRD-001/BRD-002.

## Revision History

| Version | Date | Summary | Backup |
|---|---|---|---|
| 1.0 | 2026-09-15 → 09-17 | BRD-001 (09-15) and BRD-002 (09-17) authored | `BRD-v1-backup-2026-09-18.md` |
| 2.0 | 2026-09-18 | Gate 1 mandatory decision register (G1-01…G1-30) added — Changes Requested | `BRD-v2-backup-2026-09-21.md` |
| 3.0 | 2026-09-21 | Author remediation: resolutions recorded against G1 items; 6 left "Open — comment only"; submitted for Gate 1 re-review | `BRD-v3-backup-2026-09-28.md` |
| 4.0 | 2026-09-28 | Gate 1 review comments incorporated: all open items closed as V1 decisions or V1 Out of Scope; V1 Posture added; BRD-002 owner reassigned; tally corrected. **Pending Gate 1 final approval — not yet approved** | `BRD-v4-backup-2026-09-28.md` |
| 5.0 | 2026-09-28 | BRD-001 reviewed against the requirement document and rebuilt to depend **only** on it. Blocking comments B-01 to B-05 incorporated: journey steps 1–8, organisational record update, employee confirmation, conditional downstream triggers, integration needs per stakeholder, orchestration intent vs V1 simulation. Requirement-trace gaps T-01 to T-04 fixed: pending actions, security rules, no references to earlier specs/tests/ADRs, Deliverable 1 items. Numbered business rules BR-01 to BR-27, with primary users, assumptions, dependencies, source → BRD traceability, and coverage of all 16 review comments (15 done, #16 deferred) and G1-01 to G1-30. BRD-002 kept for version control only; V1 Posture folded into BRD-001; historical sections moved under "Review history and version control". **Submitted for Gate 1 Re-Review — not yet approved** | — (current) |
