# Business Requirements Document (BRD)

**Version:** 3.0  
**Status:** Remediated — Submitted for Gate 1 Re-Review  
**Updated:** 2026-09-21  
**Previous version:** `BRD-v2-backup-2026-09-21.md` (itself following
`BRD-v1-backup-2026-09-18.md`)

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
**Original decision:** **Changes Requested — development remains blocked.**

The following decisions were mandatory before development proceeds. They
were requirements to resolve, not assumptions or approvals. Each resolved
item must be reflected in the applicable BRD, spec, plan, tasks, test cases,
ADRs, and/or security documentation and returned for Gate 1 re-review — this
section is that return.

**How to read the Resolution column:**
- **Fixed (v1.5/v1.2)** — genuinely unaddressed before this pass; a real
  design decision was added to close the gap. Full detail in the linked
  spec/plan section.
- **Resolved via ADR** — already had a deliberate, documented v1 answer
  (mostly ADR-0004 "no backend" or ADR-0005 "local-only auth") that this
  register's original wording didn't credit as an answer. No new change in
  this pass; a comment explains why the existing artifact already settles
  it.
- **Resolved in spec (pre-existing)** — already answered in the spec's
  Assumptions/ACs, unrelated to the no-backend architecture. No new change.
- **Open — comment only** — still genuinely open; a comment explains the
  residual gap and why it's judged acceptable (or not) to leave open for a
  local demo build. No design change made.

| ID | Area | Required decision | Resolution | Comment |
|---|---|---|---|---|
| G1-01 | Employee identity | Define `employeeId` and how it is verified. | Open — comment only | Account is keyed by email (ADR-0005), not a separate `employeeId`. Verification = password match against a locally stored hash only — ADR-0005 states outright this is "not identity verification in the sense a real backend would provide." Acceptable for a local-only demo; would need a real backend to actually resolve. |
| G1-02 | Registration | Define the employee-verification mechanism that prevents registration using another employee's details. | Resolved via ADR | ADR-0005 names this limitation explicitly: nothing stops registering with someone else's name/dept/role under your own email. No real HRIS to check against (ADR-0004). Documented limitation, not a silent gap. |
| G1-03 | Email | Define email ownership verification, including email verification or OTP. | Resolved via ADR | No email service exists (ADR-0004/0005) — OTP/verification is architecturally impossible without one. `employee-registration-login.spec.md` Out of Scope confirms this is deferred indefinitely, not just for v1. |
| G1-04 | Password | Define password complexity, hashing, reset, and lockout policy. | Open — comment only | Hashing (salted SHA-256) and complexity (≥8 chars, letter+number) are defined; reset is out of scope (no email service). **Lockout policy is not defined anywhere** — no brute-force/lockout logic exists. Genuine residual gap; low risk for a local demo with no network attack surface, but should be an explicit "no lockout in v1" statement rather than silence. |
| G1-05 | Authorization | Define RBAC and resource-level authorization. | Resolved via ADR | `employee-registration-login.spec.md` Out of Scope: no admin/manager account type; only one actor type (employee) exists. Manager/HR/Payroll/IT/Facilities are simulated via the Simulate Decision control, not real roles. RBAC has nothing to arbitrate in this architecture. |
| G1-06 | Current employee data | Decide whether department, location, and role are authoritative or user-entered. | Resolved in spec (pre-existing) | `employee-registration-login.OP01`: user-entered at registration, no HRIS integration to source them from (ADR-0004). Decided, if implicitly. |
| G1-07 | Manager identification | Define the source and timing of the manager relationship. | **Fixed (v1.2/v1.5)** | `employee-registration-login.OP01` now captures `managerName` (mandatory, free text) at registration; `employee-internal-transfer` v1.5 displays it as the pending approver on the status screen. Display-only, not verified against any org-chart source — see each spec's "Manager Identification"/Cross-Feature Impact sections. |
| G1-08 | Receiving manager | Decide whether receiving-manager approval is mandatory. | Resolved in spec (pre-existing) | `employee-internal-transfer.spec.md` Assumption 1 / Out of Scope: only the current manager approves; receiving-department manager is not consulted in v1. |
| G1-09 | HR eligibility | Define explicit HR eligibility rules. | Resolved in spec (pre-existing) | Spec Assumption 3 (Gate 1 self-review Finding 2): HR's eligibility rule is intentionally opaque to this app — no AC depends on it, HR's decision is treated as a black box. Business-side sign-off on the actual rule is still open per BRD-001, but that's a business question, not an engineering gap this register is scoped to. |
| G1-10 | Workflow | Define the canonical workflow state machine, including every state and transition. | Resolved in spec (pre-existing) | `plans/employee-internal-transfer.plan.md` gives the full state machine with every transition and guard condition; spec's Status Definitions lists terminal/non-terminal explicitly. Now also includes the v1.5 `FAILED` transition (see G1-12/G1-24). |
| G1-11 | Conditional tasks | Define the Payroll/IT/Facilities decision matrix. | Resolved in spec (pre-existing) | Spec Assumption 2: deliberately no matrix — all three always trigger uniformly in v1. A real, blunt decision, flagged in the original Gate 1 self-review (Finding 5) as a known operational cost, not a gap. |
| G1-12 | Failure handling | Define retry, timeout, escalation, and compensation behaviour for integration failures. | **Fixed (v1.5)** | New terminal `FAILED` status: any downstream stakeholder (Payroll/IT/Facilities) simulated as `REJECTED` moves the request to `FAILED` instead of leaving it stuck (spec AC15, plan v3). No retry/compensation is built — explicitly out of scope until this project has a real backend/integration (ADR-0004) — but the request no longer gets stuck with an undefined next state. |
| G1-13 | Amend request | Define whether and how amendment is allowed. | Resolved in spec (pre-existing) | Spec Assumption 5: no amend/withdraw in v1, explicit Out of Scope entry. |
| G1-14 | Withdrawal | Define withdrawal rules and downstream cancellation behaviour. | Resolved in spec (pre-existing) | Same decision as G1-13 — bundled, both explicitly out of scope. |
| G1-15 | Multiple requests | Define allowed concurrent-request states and conflict rules. | Resolved in spec (pre-existing) | Spec Assumption 4: exactly one non-terminal request per employee; enforced via the `app_state.activeRequestId` key (plan). |
| G1-16 | Effective date | Define past/future validation and minimum lead-time rules. | Open — comment only | "Must be in the future" is fully defined and tested (AC5). **No minimum lead-time rule** (e.g. "≥14 days notice") exists — tomorrow currently qualifies. Genuine residual gap; a business/Product decision more than an engineering one — flagging for Shamik/Product rather than inventing a number unilaterally. |
| G1-17 | Audit | Require an immutable audit trail for decision history. | **Fixed (v1.5)** | New append-only `decision_history` Hive box + `OP05.getDecisionHistory` (spec AC17, plan v3) — one entry per state transition, never edited or deleted. |
| G1-18 | Security | Define authentication, authorization, session, API, and PII controls. | Open — comment only | Session handling, PII-in-logs, and password hashing are all defined (ADR-0005). API controls are N/A (no API exists, ADR-0004). **Authorization remains a soft, local-only guarantee** — ADR-0005 itself says this "must never be described to a business stakeholder as equivalent to real user authentication." That caveat is the honest answer for a local demo, not a fixable gap without a real backend. |
| G1-19 | Notifications | Define the notification matrix, channels, and triggering events. | Resolved in spec (pre-existing) | Spec Assumption 7: in-portal status only, no email/push in v1, explicit Out of Scope entry. |
| G1-20 | SLA | Define an SLA per workflow task or explicitly exclude SLA from V1. | Resolved in spec (pre-existing) | Spec Assumption 6: no SLA enforcement in v1, explicit Out of Scope entry — matches this item's own "or explicitly exclude" phrasing exactly. |
| G1-21 | Integration contracts | Define request/response schemas, errors, and idempotency for each API/event contract. | Open — comment only | The Local Data Contract (OP01–OP05) fully specifies request/response shapes and error tables for every local operation — that part is resolved. Real external integration contracts are N/A (no backend, ADR-0004). **Idempotency for the local operations themselves (e.g. a double-submit replay) is not explicitly discussed** beyond the double-tap UI case (QA03) — residual gap, low risk given there's no network to cause genuine retries. |
| G1-22 | Data ownership | Define field-level ownership for current and proposed employee data. | **Fixed (v1.5)** | Explicit statement added to spec Assumptions: employee-submitted fields are owned by the submitting employee via OP01; stakeholder-decision fields are owned by the Simulate Decision control standing in for that stakeholder via OP04. No real Payroll/IT/Facilities/HR system exists to dispute this in v1. |
| G1-23 | Effective transfer completion | Define the final success condition for a completed transfer. | Resolved in spec (pre-existing) | AC12: all three downstream stakeholders reporting complete → `COMPLETED`, no stakeholder pending. Precise and tested. |
| G1-24 | Partial completion | Define recovery and/or compensation when HR approves but IT or another downstream step fails. | **Fixed (v1.5)** | Same `FAILED` status as G1-12 covers this directly — e.g. Payroll completes, IT rejects, Facilities still pending → request moves to `FAILED`. No rollback of Payroll's already-completed work; the plan states this explicitly as a v1 simplification requiring real compensation logic once a real backend exists. |
| G1-25 | Reconciliation | Define reconciliation for downstream data mismatches. | Resolved via ADR | ADR-0004: no real downstream system exists at all (only the Simulate Decision stand-in) — there is nothing to reconcile against. Moot by architecture, not silently skipped. |
| G1-26 | Admin/support | Define operational visibility and support intervention capabilities. | Resolved via ADR | No admin/support console exists or is needed — there is no server-side state to have operational visibility into (ADR-0004). The Simulate Decision control is explicitly framed in-spec as a demo/test stand-in, not an ops tool. Weaker precedent than G1-02/03/05/25 (no single line says "admin tooling out of scope" in so many words) but consistent with the architecture throughout. |
| G1-27 | Regulatory/privacy | Define PII retention, deletion, access, and audit requirements. | Open — comment only | No-PII-in-logs is strongly and repeatedly defined (constitution.md, both specs). Account deletion is at least named as deferred (`employee-registration-login.discovery.md`). **Retention period and subject-access-request handling are not addressed anywhere** — genuine residual gap; reasonable to leave open for a local demo with no real data-processing agreement in force, but should be named explicitly rather than left silent if this ever became a real product. |
| G1-28 | Registration lifecycle | Define behaviour for inactive or terminated employees. | **Fixed (v1.5)** | Explicit Out of Scope statement added to spec Assumptions: no HRIS/termination feed exists (ADR-0004), so this app cannot know an employee has left; an inactive account and its requests simply remain as last written. Previously this was silently absent — now it's a named v1 limitation, deferred alongside ADR-0004's other Explicitly Deferred items. |
| G1-29 | Duplicate accounts | Define employee-identity uniqueness beyond email uniqueness. | Resolved via ADR | Email uniqueness (case-insensitive) is fully defined and tested. "Uniqueness beyond email" is the same architectural limitation as G1-02 — ADR-0005 states there is no way to verify true identity beyond the password/email match. Same resolved-as-limitation treatment as G1-02, not a separate open item. |
| G1-30 | V1 boundaries | Explicitly mark all V1 decisions and prevent unresolved items from expanding scope. | Resolved in spec (pre-existing), with residual noted | Both specs have explicit "Explicitly Out of Scope" sections and both relevant ADRs have "Explicitly Deferred" sections — the habit and mechanism are well-established. The five items still marked "Open — comment only" above (G1-01, 04, 16, 18, 21, 27) are the boundary not yet fully closed; they are now named here rather than silently missing from any Out-of-Scope list, which is itself the G1-30 fix for this pass — full closure (a business/Product decision on each) is still pending. |

**Tally after this pass:** 6 fixed this pass (G1-07, 12, 17, 22, 24, 28) · 13
already resolved pre-existing or via ADR-0004/0005, credited but unchanged
(G1-02, 03, 05, 06, 08, 09, 10, 11, 13, 14, 15, 19, 20, 23, 25, 26, 29, 30 —
30 counts G1-30 as "resolved with residual noted") · 6 remain genuinely open
with a comment rather than a fix (G1-01, 04, 16, 18, 21, 27) — each is judged
low-risk for a local, backend-less demo, but is a real gap if this project
is ever taken toward production.

**Traceability:** The complete dated review record, including this pass's
detailed audit evidence per item, is maintained in
`.ai-context/reviews/employee-internal-transfer.gate1-review.md`.

## Submitted for Gate 1 Re-Review — Author, 2026-09-21

**To:** Shamik Bhattacharya, Gate 1 reviewer  
**From:** Indrajit Bhandari (Author)

This BRD, `employee-internal-transfer.spec.md` (→ v1.5),
`employee-registration-login.spec.md` (→ v1.2), and
`plans/employee-internal-transfer.plan.md` (→ v3) are submitted together for
Gate 1 re-review. Per constitution.md's Review Authority section, the Author
addressing his own findings does **not** satisfy "reviewer ≠ author" — this
submission is a remediation package for Shamik's independent review, not a
self-approval. The original Gate decision ("Not approved — development
remains blocked") stands until he reviews it.

**What changed:** the 6 items above marked "Fixed" (G1-07, 12, 17, 22, 24,
28) have real design changes in the linked spec/plan sections. The 6 items
marked "Open — comment only" (G1-01, 04, 16, 18, 21, 27) were deliberately
**not** force-closed with a placeholder decision — each comment states why
it's judged acceptable to leave open for this project's local-demo scope,
for Shamik to confirm, reject, or push to a business/Product owner as
appropriate.

**Not done in this pass:** no code changes, no `tasks/*.tasks.md` updates —
those files still describe the pre-remediation design and will need
amendment once Shamik's review lands (design-decision-only pass, by explicit
scope request).
