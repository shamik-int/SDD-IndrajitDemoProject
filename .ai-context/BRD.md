# Business Requirements Document (BRD)

**Version:** 2.0  
**Status:** In Peer Review — Changes Requested  
**Updated:** 2026-09-18  
**Previous version:** `BRD-v1-backup-2026-09-18.md`

_Numbered entries, per Blueprint §7 — the source spec authoring pulls from. A spec
should never be the first place a requirement is written down._

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

**Sponsor:** HR Product Owner, One-Point Employee Portal (assumed — confirm actual sponsor before Spec approval)

**Priority:** High — flagship self-service journey for the One-Point Portal roadmap (assumption; confirm against actual portfolio priority)

**Decided:**
- Employee-initiated request captures: proposed department/business unit, proposed location, proposed role/job position, effective date, and an optional reason.
- The portal is the single system of engagement for status; downstream systems (Manager approval, HR, Payroll, IT, Facilities) remain systems of record for their own domain and are orchestrated, not rebuilt or duplicated.
- The employee can view (a) the current overall status of their request and (b) which stakeholder(s) currently hold the pending action.

**Open at BRD stage:**
- Is manager approval a single approver (the employee's current manager), or does the *receiving* department's manager also need to approve before HR validates? — deferred to Spec-stage discovery with HR/Org Design.
- What HR eligibility rules gate a transfer (minimum tenure in current role, active performance-review status, disciplinary holds)? — deferred to HR SME sign-off before Spec approval.
- Does every transfer require Payroll, IT, and Facilities action, or only when department/location/role changes cross specific boundaries (e.g., a same-location role change may not need Facilities)? — deferred to Spec, to be modelled as conditional orchestration steps.
- Can an employee amend or withdraw a request after submission, and what happens to already-actioned or in-flight downstream tasks if they do? — open, needs a Product decision.
- What is the expected turnaround (SLA) per stakeholder action (Manager, HR, Payroll, IT, Facilities), and what happens on breach — reminder, escalation, or neither? — open, needs a Product/Ops decision.
- Can an employee have more than one transfer request in flight at a time, or is a second submission blocked until the first resolves? — open, needs a Product decision.
- Notification channels beyond the in-portal status view — email, push, or none for v1? — open.

**Notes:** This BRD is scoped strictly to the request-and-orchestrate journey
described in the assessment's scope document. The internal workflows of Payroll,
IT, and Facilities systems themselves are out of scope — this BRD covers only the
integration/contract points the portal needs from each. International or
cross-legal-entity transfers (different employer of record, cross-border
relocation) are explicitly out of scope for v1 and would be a separate, future BRD
item if raised later.

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

**Sponsor:** Author (Indrajit Bhandari) — no external business sponsor
identified for this addition; treat as an internal engineering-quality
requirement, not a customer-facing ask, unless told otherwise.

**Priority:** High — blocks a correctness gap in the existing journey (see
Notes) as soon as more than one employee could plausibly use the same
install.

**Decided:**
- Registration captures: Name, Email, Password, and the employee's *current*
  Department, Location, and Role (reusing the same reference-data lists
  `employee-internal-transfer` already uses for *proposed* values).
- Email is the unique account identifier; login is email + password.
- A logged-in employee's transfer request(s) are scoped to their own
  identity — not shared with, or blocked by, a different employee's account
  on the same device.

**Open at BRD stage:**
- Real password complexity policy — deferred to Spec as a placeholder,
  same treatment as BRD-001's HR eligibility rule (an engineering stand-in,
  not a business decision made here).
- Whether registered profile fields (current department/location/role) can
  ever be edited post-registration — deferred, no v1 requirement either way.

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

## Gate 1 Mandatory Decision Register

**Recorded by:** Shamik Bhattacharya, Gate 1 reviewer  
**Recorded at:** 2026-09-18 16:02:25 +05:30  
**Classification:** **P0 / Mandatory**  
**Decision:** **Changes Requested — development remains blocked.**

The following decisions are mandatory before development proceeds. They are
requirements to resolve, not assumptions or approvals. Each resolved item must
be reflected in the applicable BRD, spec, plan, tasks, test cases, ADRs, and/or
security documentation and returned for Gate 1 re-review.

| ID | Area | Required decision |
|---|---|---|
| G1-01 | Employee identity | Define `employeeId` and how it is verified. |
| G1-02 | Registration | Define the employee-verification mechanism that prevents registration using another employee's details. |
| G1-03 | Email | Define email ownership verification, including email verification or OTP. |
| G1-04 | Password | Define password complexity, hashing, reset, and lockout policy. |
| G1-05 | Authorization | Define RBAC and resource-level authorization. |
| G1-06 | Current employee data | Decide whether department, location, and role are authoritative or user-entered. |
| G1-07 | Manager identification | Define the source and timing of the manager relationship. |
| G1-08 | Receiving manager | Decide whether receiving-manager approval is mandatory. |
| G1-09 | HR eligibility | Define explicit HR eligibility rules. |
| G1-10 | Workflow | Define the canonical workflow state machine, including every state and transition. |
| G1-11 | Conditional tasks | Define the Payroll/IT/Facilities decision matrix. |
| G1-12 | Failure handling | Define retry, timeout, escalation, and compensation behaviour for integration failures. |
| G1-13 | Amend request | Define whether and how amendment is allowed. |
| G1-14 | Withdrawal | Define withdrawal rules and downstream cancellation behaviour. |
| G1-15 | Multiple requests | Define allowed concurrent-request states and conflict rules. |
| G1-16 | Effective date | Define past/future validation and minimum lead-time rules. |
| G1-17 | Audit | Require an immutable audit trail for decision history. |
| G1-18 | Security | Define authentication, authorization, session, API, and PII controls. |
| G1-19 | Notifications | Define the notification matrix, channels, and triggering events. |
| G1-20 | SLA | Define an SLA per workflow task or explicitly exclude SLA from V1. |
| G1-21 | Integration contracts | Define request/response schemas, errors, and idempotency for each API/event contract. |
| G1-22 | Data ownership | Define field-level ownership for current and proposed employee data. |
| G1-23 | Effective transfer completion | Define the final success condition for a completed transfer. |
| G1-24 | Partial completion | Define recovery and/or compensation when HR approves but IT or another downstream step fails. |
| G1-25 | Reconciliation | Define reconciliation for downstream data mismatches. |
| G1-26 | Admin/support | Define operational visibility and support intervention capabilities. |
| G1-27 | Regulatory/privacy | Define PII retention, deletion, access, and audit requirements. |
| G1-28 | Registration lifecycle | Define behaviour for inactive or terminated employees. |
| G1-29 | Duplicate accounts | Define employee-identity uniqueness beyond email uniqueness. |
| G1-30 | V1 boundaries | Explicitly mark all V1 decisions and prevent unresolved items from expanding scope. |

**Traceability:** The complete dated review record is maintained in
`.ai-context/reviews/employee-internal-transfer.gate1-review.md`. This BRD
version does not approve, close, or silently resolve any of the mandatory
decisions above.
