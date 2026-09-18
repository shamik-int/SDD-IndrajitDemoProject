# Discovery Analysis: Employee Internal Transfer

_Deliverable 1 of the assessment brief. Distinct from `BRD.md#BRD-001` — this is
the broader discovery synthesis; BRD-001 is its SDD-formatted restatement._

## Business Objective
Replace the current manual, multi-system employee internal transfer process
(informal manager conversation → separate HR check → uncoordinated downstream
updates) with a single self-service digital journey through the One-Point
Employee Portal — giving the employee visibility into status and pending
stakeholder actions, and reducing coordination overhead and delay.

## Primary Users
| Actor | Role in the journey |
|---|---|
| Employee | Initiates and tracks the request — the only actor using this Flutter app |
| Manager (current) | First approval gate |
| HR | Validates eligibility; second approval gate |
| Payroll | Updates compensation/org-unit records once approved |
| IT | Provisions/de-provisions access for the new role/location |
| Facilities | Arranges the new location/seat |

Manager/HR/Payroll/IT/Facilities are **indirect actors** in this scope — they
act on the request through their own existing systems/processes; this app
only reflects their state back to the employee. No stakeholder-facing UI is
in scope for this Flutter app.

## Journey Stages
1. **Pre-submission** (out of scope, offline) — employee discusses the move
   with their manager informally.
2. **Submission** — employee submits department/location/role/effective
   date/optional reason via the portal.
3. **Manager Approval** — sequential gate.
4. **HR Validation** — sequential gate, after Manager approval.
5. **Downstream Orchestration** — Payroll, IT, Facilities, triggered in
   parallel after HR approval.
6. **Completion** — all downstream steps done; status resolves to Completed.
   (Or: **Rejected** at the Manager or HR gate — terminal, ends the journey.)

## Business Rules
- An employee may have only one non-terminal request in flight at a time.
- Effective date must be a future date.
- Manager and HR approvals are sequential and mandatory; Payroll/IT/Facilities
  run in parallel only after both approvals are in.
- A rejection at either gate is terminal — no downstream steps run, and the
  employee is free to submit a new request.

## Known Decisions (already made, at BRD or Spec stage)
- Captured fields: department, location, role, effective date, optional
  reason (BRD-001).
- Portal orchestrates; it is not the system of record for HR/Payroll/IT/
  Facilities data (BRD-001, constitution.md).
- Single in-flight request per employee (spec v1).
- Current manager only approves — not the receiving department's manager
  (spec v1).
- All three downstream steps always run in v1 — no conditional skipping
  based on what actually changed (spec v1).
- No amend/withdraw, no SLA/escalation, in-portal status only — all deferred
  out of v1 (spec).

## Open Questions (still genuinely open — need business/HR sign-off, not an engineering call)
- Is the placeholder HR eligibility rule (6 months tenure, no active
  disciplinary hold) correct, or does real policy differ? — **HR SME must
  confirm or replace before the spec can be Approved.**
- Do the conservative v1 scope cuts (single in-flight request, current-manager
  -only approval, uniform downstream fan-out, no amend/withdraw, no SLA, no
  notifications) match actual business risk appetite, or are one or more of
  them a fast-follow v1.1 requirement? This is exactly what Gate 1 is for.
- Sponsor identity and priority ranking — both currently assumed, not
  confirmed (see BRD-001).

## Assumptions
- The existing One-Point Employee Portal already has SSO/OAuth2 session
  infrastructure this new module can reuse (constitution.md).
- Manager/HR/Payroll/IT/Facilities each have, or will be given, an
  integration point the orchestrator can call — none are confirmed yet
  (see `architecture.md`'s Integrations table, all rows marked TBD).
- This assessment scaffolds a **new, standalone** Flutter app rather than a
  module inside an existing portal codebase, since no existing portal
  codebase was provided.

## Dependencies
- Manager approval, HR, Payroll, IT, and Facilities systems must each expose
  (or be given) an integration contract — to be identified concretely at
  Plan stage, not assumed here.
- Backend/orchestration service must exist or be built — stack choice
  (Node vs. Java) still open (constitution.md).

## Explicitly Out of Scope
- International or cross-legal-entity transfers.
- Amending or withdrawing a submitted request.
- SLA enforcement, reminders, or escalation.
- Email/push notifications.
- Conditional (non-uniform) downstream orchestration.
- More than one non-terminal request per employee at a time.

## Business Decision vs. Technical Decision
| Business decisions (Product/HR/Sponsor own these) | Technical decisions (Engineering/Architecture own these) |
|---|---|
| What fields are captured on submission | Flutter + Clean Architecture + GetX + local-first persistence (ADR-0001) |
| Who approves (current manager only vs. also receiving manager) | Root/jailbreak/Frida detection approach (ADR-0002) |
| The real HR eligibility rule | API contract shape (endpoints, payloads, status codes) |
| Whether multiple in-flight requests are allowed | Backend/orchestration stack choice (Node vs. Java) — still open |
| Whether amend/withdraw is needed | Async/event-driven vs. synchronous integration pattern for downstream calls |
| SLA/escalation policy | Local DB engine choice (Hive proposed) |
| Notification channels | Client-side vs. server-side validation split (both, per constitution.md) |
