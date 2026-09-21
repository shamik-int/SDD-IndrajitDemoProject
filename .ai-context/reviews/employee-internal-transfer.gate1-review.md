# Gate 1 Review — employee-internal-transfer.spec.md

**Spec version reviewed:** v1.0
**Reviewer:** Indrajit Bhandari — **self-review pass, standing in for the named
Gate 1 reviewer (Subhajit Mukherjee)**. This is not a substitute for his actual
sign-off; see Verdict below.
**Date:** 2026-09-15

> **Addendum, 2026-09-17:** Gate 1 reviewer for this project has since been
> reassigned from Subhajit Mukherjee to **Shamik Bhattacharya**
> (shamik.bhattacharya@intglobal.com) — see constitution.md's Review
> Authority section. The "standing in for Subhajit Mukherjee" line below is
> historically accurate (he was the assignment at the time this self-review
> was performed) and is left unchanged. No independent Gate 1 review — by
> Subhajit then, or by Shamik now — has actually happened yet; this remains
> a self-review stand-in until Shamik reviews it.

## Checklist (Blueprint §30, Gate 1 — Spec Peer Review)
- [x] Reviewer ≠ author — caveat: this specific pass is the author standing in
      for the real reviewer, flagged rather than presented as independent review.
- [x] Intent is one unambiguous paragraph.
- [x] Every AC is given/when/then and individually IDed (13/13).
- [x] API Contract complete (payload, success shape, exception table) for all 3 endpoints.
- [ ] Out-of-scope items explicit — **gap found, see Finding 1.**
- [x] Related/Builds-on specs in Approved/Released state — N/A (first spec; architecture.md/ADR-0001/ADR-0002 already Accepted).
- [x] No overlap with an existing spec — N/A, first spec.
- [x] Security/Architecture sign-off — constitution.md rules addressed inline; ADR-0001/0002 already accepted.
- [ ] Status recorded — verdict below is **Changes Requested**, not Approved.

## Findings

### Finding 1 (blocking) — No defined mechanism for Manager/HR/Payroll/IT/Facilities actions
AC7–AC13 describe *outcomes* ("given the manager approves...") but the spec's
API Contract (API01–03) is entirely employee-facing — submit and read status.
Nothing says how a manager actually approves, how HR validates, or how
Payroll/IT/Facilities report completion. Left unresolved, an implementer
can't tell whether this Flutter app needs stakeholder-facing screens or
whether those decisions arrive from elsewhere. This is exactly the class of
ambiguity Gate 1 exists to catch (Blueprint §12.4).
**Resolution applied (spec → v1.1):** added a "How Stakeholder Actions Are
Recorded" note under Context — those decisions happen in each stakeholder's
own existing system; the orchestrator (a Plan-stage concern) detects them via
that system's own integration contract. This app never exposes an action UI
for Manager/HR/Payroll/IT/Facilities. Added the same to Explicitly Out of
Scope.

### Finding 2 (blocking as worded) — HR eligibility "placeholder rule" doesn't gate anything this spec builds
Assumption §3 asked Gate 1 to confirm a placeholder eligibility rule (6
months tenure, no disciplinary hold) — but no AC actually depends on knowing
that rule; every AC treats HR's decision as a black box. Requiring business
sign-off on a rule this app never implements would block Approval on
something irrelevant to the spec as scoped.
**Resolution applied:** reworded Assumption §3 — the eligibility rule is
intentionally opaque to this app (HR's own internal process), removed as a
blocking confirmation item.

### Finding 3 (non-blocking, testability) — "Non-terminal" used but never defined
AC2, AC9, AC11 depend on a terminal/non-terminal distinction the spec never
states explicitly.
**Resolution applied:** added an explicit status-definitions list under Context.

### Finding 4 (non-blocking, QA completeness) — AC4's "or" only tested once
AC4 covers four possible missing fields; `UT02` only exercises
`departmentId`.
**Resolution applied:** added `QA11`–`QA13` to
`test_cases/employee-internal-transfer.test_cases.md` for
location/role/effectiveDate missing. Test-coverage addition, not a spec change.

### Finding 5 (accepted as-is, flagged not blocking) — Downstream fan-out always triggers all three systems
Confirmed deliberate v1 simplification (Assumption §2). Has a real
operational cost — unnecessary tickets to Payroll/IT/Facilities on transfers
that don't need them. Recommend Product/HR is made aware this is a v1
simplification, not a permanent design, but it does not block Approval.

## Verdict
**Changes Requested → Revised.** Findings 1–3 applied directly to the spec
(now v1.1). Finding 4 addressed in `test_cases/`. Finding 5 stands as an
accepted, explicitly-flagged v1 scope decision.

**This report is a self-review stand-in, not Subhajit Mukherjee's actual
sign-off.** Recommended next step: hand spec v1.1 + this report to Subhajit
for real Gate 1 review, or have the Author explicitly ratify it as Approved
if proceeding without his direct involvement this cycle.

## Gate 1 Review Points — Shamik Bhattacharya

**Recorded by:** Shamik Bhattacharya, Gate 1 reviewer  
**Recorded at:** 2026-09-18 16:02:25 +05:30  
**Classification:** **P0 / Mandatory — Changes Requested**  
**Review status:** Open; these points are not an approval or sign-off.

The following review points must be resolved and reflected in the relevant
BRD, spec, plan, tasks, test cases, ADRs, and/or security documentation before
development proceeds:

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

**Gate decision:** **Not approved.** Development remains blocked until the
mandatory decisions above are resolved, reviewed, and traceable to updated
project artefacts.

## Remediation Pass — Indrajit Bhandari, 2026-09-21

**Not a Gate 1 re-review** — the Author addressing his own findings does not
satisfy constitution.md's "reviewer ≠ author" rule any more than the earlier
self-review stand-ins did. Logged here for the same reason those were: so
the gap is visible, not silently closed.

An audit found the 30 G1 items above conflate two different situations:
items with a genuine, documented v1 answer already in ADR-0004/ADR-0005 or
the spec's own Assumptions/Out-of-Scope sections (G1-02, 03, 05, 08, 09, 10,
13, 14, 15, 19, 20, 23, 25), versus items nothing in the project actually
addressed (G1-07, 12, 17, 22, 24, 28), plus several partially answered ones
(G1-01, 04, 06, 11, 16, 18, 21, 27, 29, 30).

**Design changes made against the fully-open items:**
- **G1-07 (manager identification)** — `employee-registration-login.OP01`
  gains a mandatory `managerName` field (spec v1.2); displayed, not
  verified.
- **G1-17 (audit trail)** — new append-only `decision_history` Hive box
  (plan v3) and `OP05.getDecisionHistory` (spec v1.5, AC17).
- **G1-12 / G1-24 (failure handling / partial completion)** — new `FAILED`
  terminal status when any downstream stakeholder is simulated as `REJECTED`
  (spec v1.5, AC15/AC16); no retry/compensation, explicitly out of scope.
- **G1-22 (data ownership)** — explicit field-ownership statement added to
  spec v1.5 Assumptions.
- **G1-28 (inactive employees)** — explicit out-of-scope statement added to
  spec v1.5 Assumptions, matching the pattern ADR-0004 already uses for
  comparable no-HRIS limitations.

**Remaining genuinely-open items, left as comments rather than force-closed**
(full per-item comment in `BRD.md`'s Gate 1 Mandatory Decision Register):
- **G1-01** — no true `employeeId`/identity verification, only email +
  password-hash match (ADR-0005's own stated limit).
- **G1-04** — password lockout policy is undefined (complexity and hashing
  are; reset is out of scope).
- **G1-16** — no minimum lead-time rule for effective date (only "must be in
  the future" is enforced) — judged a Product decision, not invented here.
- **G1-18** — authorization remains a soft, local-only guarantee per
  ADR-0005, not a real security boundary.
- **G1-21** — idempotency of local operations beyond the double-tap UI case
  (QA03) isn't explicitly discussed.
- **G1-27** — PII retention period and subject-access-request handling are
  undefined (logging restrictions and account-deletion status are).

Each was deliberately left open with a comment explaining why it's
acceptable for a local, backend-less demo, rather than force-closed with an
unjustified placeholder — for Shamik to confirm, reject, or route to a
business/Product owner.

**Not done in this pass:** no code changes, no test_cases/ additions beyond
what the spec's own Unit Test Cases table already lists, no tasks.md
updates — this was a design-decision-only remediation, by explicit scope
request. `tasks/employee-internal-transfer.tasks.md` still describes the
pre-v1.5 design and will need new/amended tasks before v1.5 is actually
built.

**Next step, unchanged from the original verdict:** Shamik Bhattacharya
reviews spec v1.5 / v1.2, the plan v3 changes, and `BRD.md` v3.0 (submitted
for re-review, see that file's "Submitted for Gate 1 Re-Review" section) and
either confirms them or requests further changes. This remediation pass does
not move the Gate decision from "Not approved."
