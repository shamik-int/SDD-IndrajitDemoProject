# Business Requirements Document (BRD)

**Version:** 4.0  
**Status:** Gate 1 review comments incorporated — **Pending Gate 1 final
approval. Not yet approved; development remains blocked** until the Gate 1
reviewer (Shamik Bhattacharya) gives final approval after the joint BRD /
Spec / Plan / Test-case alignment review (see "Downstream Alignment
Required" below)  
**Updated:** 2026-09-28  
**Previous version:** `BRD-v3-backup-2026-09-28.md` (itself following
`BRD-v2-backup-2026-09-21.md` → `BRD-v1-backup-2026-09-18.md`)

_Numbered entries, per Blueprint §7 — the source spec authoring pulls from. A spec
should never be the first place a requirement is written down._

**What changed in v4.0:** every item previously listed as "Open at BRD stage"
under BRD-001 and BRD-002 is now either an explicit **V1 decision** or an
explicit **V1 Out-of-Scope** item, consistent with the decisions already made
in the specs and the Gate 1 register. A cross-cutting V1 Posture section was
added, the BRD-002 Business Owner was reassigned from the Author, and the
Gate 1 tally was corrected. The comment-by-comment trace is in "Gate 1 Review
Comments — 2026-09-28" at the end of this document.

## V1 Posture — applies to BRD-001 and BRD-002

These statements hold for every requirement below. Where an individual BRD
item says less, these still apply.

- **V1 is a local demo, not a production system.** There is no backend and
  no real integration with HR, Payroll, IT, Facilities or any org-chart
  system (ADR-0004). All data lives on the device.
- **Test/demo employee data only.** V1 must only be used with test/demo
  employee data. It is not a production employee data system and must not
  be loaded with, or relied on for, real employee records.
- **Local/demo authentication only.** V1 checks the registered email and
  password against a locally stored hash (ADR-0005). It does **not**
  independently verify that the person logging in is the actual employee
  they registered as.
- **Not production-ready authentication or authorization.** The current
  authentication and authorization approach must not be treated as
  production-ready, and must never be described to a business stakeholder
  as equivalent to real authentication. Any production implementation needs
  a proper server-side authentication and authorization mechanism. That is
  a precondition for production, not an enhancement.
- **Stakeholder decisions are simulated.** Manager, HR, Payroll, IT and
  Facilities decisions are recorded through the demo-only Simulate Decision
  control. This is not a real stakeholder interface, and V1 cannot prove
  that a real stakeholder took any decision.
- **Future requirements, not V1 scope:** when real HR, Payroll, IT or
  Facilities integrations are introduced, the following become mandatory
  requirements for that work: integration retry, rollback, compensation and
  reconciliation, plus production-grade identity and authorization, and PII
  retention and subject-access handling. None of them is built in V1.

### BRD-001: Enable self-service employee internal transfer requests via the One-Point Employee Portal

**Raised by:** One-Point Employee Portal Product Team (per the assessment scope document, "Requirement for SDD")

**Business need:** Employees currently initiate an internal transfer through
informal, multi-system coordination — a manager conversation, a separate HR
eligibility check, then uncoordinated downstream updates across org-data, payroll,
IT access, and facilities. This creates delay, inconsistent handling, and leaves the
employee with no single, traceable view of where the request stands or who is
holding it up. The organisation wants employees to raise, and track, an internal
transfer request through the existing One-Point Employee Portal, with the portal
orchestrating — not replacing — the downstream systems and teams that already own
each step (Manager, HR, Payroll, IT, Facilities).

**Sponsor:** HR Product Owner, One-Point Employee Portal (assumed — the named
individual is still to be confirmed by Product; this does not block V1 demo
development but must be confirmed before any production commitment)

**Priority:** High — flagship self-service journey for the One-Point Portal roadmap (assumption; confirm against actual portfolio priority)

**Decided:**
- Employee-initiated request captures: proposed department/business unit, proposed location, proposed role/job position, effective date, and an optional reason.
- The portal is the single system of engagement for status; downstream systems (Manager approval, HR, Payroll, IT, Facilities) remain systems of record for their own domain and are orchestrated, not rebuilt or duplicated.
- The employee can view (a) the current overall status of their request and (b) which stakeholder(s) currently hold the pending action.

**V1 decisions (previously "Open at BRD stage", now closed):**
- **Approver.** Only the employee's *current* manager approves in V1. The
  receiving department's manager is not consulted. (Spec Assumption 1; G1-08)
- **HR eligibility.** HR eligibility rules are **not implemented in V1**. The
  HR decision is simulated (approve or reject via the Simulate Decision
  control) and treated as a black box. The application **must not introduce
  its own eligibility rules** (tenure, performance status, disciplinary
  holds, or anything else) unless HR/Product explicitly provides them.
  (Spec Assumption 3; G1-09)
- **Downstream fan-out.** Once HR approves, Payroll, IT and Facilities are
  **always all three** triggered, whatever actually changed. There is no
  conditional skipping in V1. (Spec Assumption 2; G1-11)
- **Amend / withdraw.** A submitted request cannot be amended or withdrawn
  in V1. (Spec Assumption 5; G1-13, G1-14)
- **SLA.** No SLA, reminder or escalation applies to any stakeholder action
  in V1. (Spec Assumption 6; G1-20)
- **Concurrent requests.** An employee may have **exactly one non-terminal**
  transfer request at a time. A new submission is blocked until the current
  one reaches a terminal status. (Spec Assumption 4; G1-15)
- **Notifications.** V1 shows status in the portal only. There is no email
  and no push notification. (Spec Assumption 7; G1-19)
- **Effective date.** The effective date must be in the future: today or
  any past date is rejected. **There is no minimum transfer lead time in
  V1.** Any future date, including tomorrow, is acceptable unless Product
  defines another rule. (Spec AC5; G1-16)
- **Duplicate submission.** One submit action creates **at most one**
  transfer request. A repeated or double submission (double-tap, re-tapping
  while a submission is still processing, or re-submitting the same form)
  must never create a second request or a second submission entry in
  Decision History. The submit action must be unavailable while a
  submission is in progress. Any submission arriving while the employee
  already has a non-terminal request is rejected with the "already in
  progress" message, not stored. (Test case QA03, OP01 error table; G1-21)
- **FAILED state.** If any downstream stakeholder (Payroll, IT or
  Facilities) rejects while the request is `PENDING_DOWNSTREAM_UPDATES`,
  the request becomes `FAILED`, which is terminal. This holds even if
  another downstream action has already completed: for example, Payroll
  completes and then IT rejects. In V1:
  - **Completed actions are not rolled back.** Payroll's completed step in
    the example stays completed; V1 does no undo, compensation or retry.
  - Any downstream step still pending is no longer pending and receives no
    further actions.
  - The employee may submit a new request, because `FAILED` does not count
    as active.

  Real rollback, compensation, retry and reconciliation are future
  requirements (see V1 Posture). (Spec Assumption 9, AC15, AC16; G1-12,
  G1-24)
- **Audit.** Every state transition is appended to a read-only Decision
  History that is never edited or deleted. (Spec AC17; G1-17)

**V1 Out of Scope (explicit):**
- International or cross-legal-entity transfers (different employer of
  record, cross-border relocation). These would be a separate, future BRD
  item.
- Receiving-department manager approval.
- Conditional Payroll/IT/Facilities orchestration.
- Amend or withdraw after submission.
- SLA timers, reminders and escalation.
- Email and push notifications.
- A minimum transfer lead time.
- Application-defined HR eligibility rules.
- Real integrations with HR, Payroll, IT and Facilities, and with them any
  integration retry, rollback, compensation or reconciliation. These are
  future requirements.
- Handling inactive or terminated employees (no HRIS feed; G1-28).
- A production-grade, authenticated interface for each stakeholder role.

**Notes:** This BRD is scoped strictly to the request-and-orchestrate journey
described in the assessment's scope document. The internal workflows of Payroll,
IT, and Facilities systems themselves are out of scope — this BRD covers only the
integration/contract points the portal needs from each.

**Spec traceability:** This BRD describes one cohesive business capability and
traces to exactly one spec — `specs/employee-internal-transfer.spec.md`. It does
not describe multiple features, so it does not warrant multiple specs; see that
spec's "Scope Decision" section for the reasoning behind keeping it as one
(including the demo-only Simulate Decision control), rather than assuming this
without saying so.

### BRD-002: Require employee registration and login before accessing the One-Point Employee Portal

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
| G1-11 | Conditional tasks | Define the Payroll/IT/Facilities decision matrix. | Resolved in spec (pre-existing) | Spec Assumption 2: no matrix. All three always trigger in V1. |
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
| G1-23 | Effective transfer completion | Define the final success condition for a completed transfer. | Resolved in spec (pre-existing) | AC12: all three downstream stakeholders complete → `COMPLETED`. |
| G1-24 | Partial completion | Define recovery and/or compensation when HR approves but IT or another downstream step fails. | **Fixed (v1.5)** | If one downstream action has already completed and another stakeholder rejects, the request becomes `FAILED`. **Previously completed actions are not rolled back in V1.** Remaining pending steps are no longer pending, and the employee may submit a new request (BRD-001). |
| G1-25 | Reconciliation | Define reconciliation for downstream data mismatches. | Resolved via ADR | No real downstream system exists (ADR-0004), so V1 has nothing to reconcile. Reconciliation is a documented future requirement once real integrations are introduced (BRD V1 Posture). |
| G1-26 | Admin/support | Define operational visibility and support intervention capabilities. | Resolved via ADR | No admin/support console in V1: there is no server-side state (ADR-0004). The Simulate Decision control is a demo/test stand-in, not an ops tool. |
| G1-27 | Regulatory/privacy | Define PII retention, deletion, access, and audit requirements. | **Out of Scope for V1 (BRD v4.0)** | No PII in logs is defined (constitution.md, both specs). Retention periods, account deletion and subject-access handling are **explicitly out of scope for V1**, acceptable only because V1 uses test/demo employee data only. They are mandatory future requirements for production (BRD V1 Posture, BRD-002). |
| G1-28 | Registration lifecycle | Define behaviour for inactive or terminated employees. | **Fixed (v1.5)** | Spec Assumption 12: explicitly out of scope; no HRIS/termination feed exists (ADR-0004). |
| G1-29 | Duplicate accounts | Define employee-identity uniqueness beyond email uniqueness. | Resolved via ADR | Case-insensitive email uniqueness is defined and tested. Uniqueness beyond email is the same accepted limitation as G1-02 (ADR-0005). |
| G1-30 | V1 boundaries | Explicitly mark all V1 decisions and prevent unresolved items from expanding scope. | Resolved in spec (pre-existing) — closed at BRD v4.0 | Both specs and ADR-0004/0005 carry explicit Out-of-Scope/Deferred sections. At v4.0, no open items remain in the BRD: every former open item is now a V1 decision or V1 Out-of-Scope item. |

**Tally (v4.0, corrected; totals 30):**

| Resolution | Count | Items |
|---|---|---|
| Fixed (v1.2/v1.5) | 6 | G1-07, 12, 17, 22, 24, 28 |
| Resolved in spec (pre-existing) | 12 | G1-06, 08, 09, 10, 11, 13, 14, 15, 19, 20, 23, 30 |
| Resolved via ADR | 6 | G1-02, 03, 05, 25, 26, 29 |
| Decided for V1 (BRD v4.0) | 4 | G1-01, 16, 18, 21 |
| Out of Scope for V1 (BRD v4.0) | 2 | G1-04, 27 |
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

| # | Review comment | Where addressed in v4.0 |
|---|---|---|
| 1 | Reflect Spec/Gate 1 decisions consistently; remove stale "Open" items in BRD-001 | BRD-001 "V1 decisions" (all 7 former open items closed) |
| 2 | V1 uses local/demo authentication only; does not verify the user is the actual employee | V1 Posture; BRD-002 V1 decisions; G1-01 |
| 3 | Authentication/authorization not production-ready; server-side mechanism required | V1 Posture; BRD-002 V1 decisions; G1-18 |
| 4 | `managerName` is demo/reference only, not verified, not proof of manager | BRD-002 V1 decisions; G1-07 |
| 5 | HR eligibility not implemented in V1; HR decision simulated; no app-invented rules | BRD-001 V1 decisions and Out of Scope; G1-09 |
| 6 | Clarify FAILED: prior completed actions not rolled back | BRD-001 "FAILED state"; G1-12, G1-24 |
| 7 | Convert remaining open items into V1 decisions or Out-of-Scope | BRD-001 and BRD-002 now have no "Open" list; register Open count = 0 |
| 8 | No minimum transfer lead time in V1 | BRD-001 "Effective date"; G1-16 |
| 9 | Account lockout/brute-force out of scope for local demo | BRD-002 Out of Scope; G1-04 |
| 10 | Email verification/OTP not available (no email service) | BRD-002 Out of Scope; G1-03 |
| 11 | Test/demo employee data only; not a production employee data system | V1 Posture; G1-27 |
| 12 | Real integration retry/rollback/compensation/reconciliation are future requirements | V1 Posture; BRD-001 Out of Scope; G1-12, G1-25 |
| 13 | Rule to prevent duplicate requests from repeated/double submission | BRD-001 "Duplicate submission"; G1-21 |
| 14 | Identify appropriate Product/Business Owner for BRD-002 | BRD-002 "Product / Business Owner" |
| 15 | Correct the Gate 1 tally to match the individual items | Corrected tally table and correction note |
| 16 | Review BRD and Spec together so BRD, Spec, plan and test cases reflect the same V1 behaviour | "Downstream Alignment Required" below — the follow-up review |

## Downstream Alignment Required

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
| 4.0 | 2026-09-28 | Gate 1 review comments incorporated: all open items closed as V1 decisions or V1 Out of Scope; V1 Posture added; BRD-002 owner reassigned; tally corrected. **Pending Gate 1 final approval — not yet approved** | — (current) |
