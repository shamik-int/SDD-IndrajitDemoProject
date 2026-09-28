# Gate 1 Review — BRD v4.0 (against the Requirement Document)

**Document reviewed:** `.ai-context/BRD.md` v4.0 (2026-09-28)
**Reviewed against:** `Requirement for SDD (2).pdf` (the business scope document) only
**Reviewer:** Shamik Bhattacharya, Gate 1 reviewer of record
**Date:** 2026-09-28
**Verdict:** **Changes Requested.** BRD v4.0 can be approved once the 8 blocking comments below are resolved.

> **Update, 2026-09-28: blocking comments checked against the requirement document.**
> Only 5 of the 8 blocking comments come directly from `Requirement for SDD (2).pdf`:
>
> | Comment | In the requirement document? | Status |
> |---|---|---|
> | B-01 | ✅ Yes: §2 steps 1 and 4 | **Addressed in BRD v5.0** |
> | B-02 | ✅ Yes: §2 step 8 | **Addressed in BRD v5.0** |
> | B-03 | ✅ Yes: §2 steps 5–7 "may need" | **Addressed in BRD v5.0** |
> | B-04 | ✅ Yes: §1 API contracts / integration and failure; §2 step 6 | **Addressed in BRD v5.0** |
> | B-05 | ✅ Yes: §3 "orchestrate the downstream activities" | **Addressed in BRD v5.0** |
> | B-06 | ❌ Not a BRD requirement: §4 asks for business vs technical decisions in *Deliverable 1 (Discovery)*, already in `discovery/employee-internal-transfer.discovery.md` | Downgraded to non-blocking |
> | B-07 | ❌ Not a BRD requirement: users, journey stages and business rules are *Deliverable 1* items, already in the discovery doc | Downgraded to non-blocking |
> | B-08 | ❌ Not in the requirement document: arises from the decision to recreate the specs | Downgraded to non-blocking; handle when the specs are recreated |
>
> **Revised verdict:** all blocking comments that come from the requirement
> document are addressed in BRD v5.0. BRD v5.0 is **ready for Gate 1
> approval by the reviewer**. It is not approved yet.
>
> **N-01 resolved (2026-09-28):** the Author decided BRD-002 is not
> followed and is kept for version control only. BRD-001 is standalone:
> sign-in and the employee profile come from the existing portal. BRD v5.0
> was **submitted for Gate 1 Re-Review** on 2026-09-28. See "Gate 1
> Re-Review Submission" in `BRD.md`.

## Review basis

The project is resetting: the specs, plan, tasks and test cases will be
**recreated from the approved BRD**. So the BRD is reviewed here as the
**single source of truth**. It must be complete against the requirement
document, and it must stand on its own without relying on any spec, plan,
test case or ADR.

Earlier review material (the G1-01 to G1-30 register and the 16 comments of
2026-09-28) is kept for history. Where it relies on artefacts that are being
discarded, it is superseded by this review.

## What BRD v4.0 gets right (accepted, no change needed)

- A V1 Posture section: local demo, test/demo data only, stakeholder
  decisions simulated, demo-only authentication.
- Captured fields match requirement §3: department/business unit, location,
  role/position, effective date, optional reason.
- Status view, plus which stakeholder currently holds the pending action.
- One active request per employee, and rules to prevent duplicate
  submission.
- Effective date must be in the future, with no minimum lead time.
- Only the current manager approves. HR eligibility is simulated, and the
  app must not invent its own eligibility rules.
- `FAILED` outcome with no rollback, and pending steps stop when it happens.
- Append-only decision history (audit trail).
- An explicit V1 out-of-scope list (amend/withdraw, SLA, notifications,
  international transfers).
- The Gate 1 tally has been corrected.

## Coverage against the requirement document

| Requirement document item | BRD v4.0 | Comment |
|---|---|---|
| §2 step 1: employee discusses the transfer with the manager | ❌ Missing | B-01 |
| §2 step 2: manager confirms | ✅ | Current manager approves or rejects |
| §2 step 3: HR validates eligibility | ✅ | Simulated, rules not invented |
| §2 step 4: employee's organisational information is updated | ❌ Missing | B-01 |
| §2 steps 5–7: Payroll / IT / Facilities **may** need updating | ⚠️ Contradicted | B-03 ("always all three") |
| §2 step 6: IT **provision or remove** access | ⚠️ Partial | B-04 |
| §2 step 8: employee receives confirmation | ❌ Missing | B-02 |
| §3: select department/BU, location, role | ⚠️ Partial | N-04 (source of the selection lists) |
| §3: effective date, optional reason, submit | ✅ | |
| §3: view current status | ✅ | |
| §3: view actions pending with other stakeholders | ⚠️ Partial | N-02 (shows *who* is pending, not *what action*) |
| §3: portal orchestrates downstream activities | ⚠️ Contradicted | B-05 |
| §1: define API contracts / handle integration and failure | ❌ No integration needs stated | B-04 |
| §4 D1: primary users, journey stages, business rules | ❌ Missing | B-07 |
| §4 D1: business decision vs technical decision | ❌ Mixed together | B-06 |
| §1 / §5: traceability from requirement to implementation | ⚠️ Points at discarded artefacts | B-08 |

## Blocking comments (must be resolved before approval)

### B-01: Journey steps 1 and 4 are missing
Requirement §2 lists "Employee discusses the transfer with the manager"
(step 1) and "Employee's organisational information is updated" (step 4).
The BRD has neither.
**Required:**
- State that step 1 is an offline precondition, outside the system, and
  record whether the portal asks the employee to confirm it happened.
- Define step 4 as a named journey step: who updates the employee's
  department/location/role record, when (on HR approval? on the effective
  date?), and whether V1 simulates it like the other stakeholders. The
  "Completed" definition must include it.

### B-02: "Employee receives confirmation" (step 8) is not defined
The BRD says V1 shows status only in the portal, with no email or push. It
never says what the confirmation *is*.
**Required:** Define the confirmation the employee receives for each final
outcome: completed, rejected by the manager, rejected by HR, and failed.
For example: an in-portal final status plus a summary of the approved
change and its effective date. Include what the employee is told they can
do next.

### B-03: Payroll / IT / Facilities "may" is replaced by "always all three"
The requirement says Payroll, IT and Facilities **may** need to act, which
is conditional. The BRD's "always all three" contradicts the source and
comes with no business rationale.
**Required:** Choose one and record it as a **business decision** with an
owner:
- (a) A simple conditional rule. For example: Payroll only if role or
  location changes; IT always, since access changes with role or
  department; Facilities only if location changes. Proposed rule, needs
  sponsor confirmation.
- (b) Keep "always all three" as an explicit, sponsor-approved V1 deviation
  from the source, with the reason stated. For example: simplicity for the
  demo, at the cost of unnecessary downstream tasks.

### B-04: Integration needs are not stated
The requirement asks for API contracts and for handling integration and
failure scenarios. The BRD's own Notes say it "covers only the
integration/contract points the portal needs from each", but it never
lists them.
**Required:** Add one table with a row per stakeholder (Manager, HR,
Org-data update, Payroll, IT, Facilities), covering:
- what the portal must send;
- what it must receive back (approve / reject / complete / fail);
- the business outcome of each response.

IT must cover both **provision** and **remove** access. This is a business
need, independent of whether V1 delivers it for real or simulates it.

### B-05: "Orchestrates downstream systems" vs "no integration" contradiction
The BRD-001 "Decided" section says downstream systems "remain systems of
record… orchestrated, not rebuilt". The V1 Posture says "no backend, no real
integration… all data lives on the device". These two statements contradict
each other.
**Required:** Restate as:
- **Business intent:** the portal orchestrates the downstream stakeholders
  (from the requirement).
- **V1 delivery:** those stakeholders' actions are simulated in the demo,
  and nothing is integrated for real.

### B-06: Business decisions and technical decisions are mixed
Requirement §4 asks you to "clearly distinguish business decision vs
technical decision". The BRD contains technical choices: salted SHA-256,
hashes stored on the device, backend-less architecture, session handling,
ADR-0004/0005.
**Required:**
- The BRD keeps only business rules and business constraints. For example:
  "V1 is a demo using test data only; stakeholder actions are simulated;
  sign-in is demo-level and not production security".
- Move the technical choices to the new Plan and ADRs.
- Add a short "Business decisions" vs "Technical constraints imposed on the
  solution" split so the distinction is visible.

### B-07: Primary users, journey stages and business rules are not stated
Requirement §4 Deliverable 1 asks for the primary users, journey stages
and business rules. The BRD has none of these as sections.
**Required:**
- **Users:** Employee (primary). Current Manager, HR, Payroll, IT and
  Facilities as participants.
- **Journey stages:** requirement §2 steps 1–8, each with its BRD handling.
- **Business rules:** numbered `BR-01…BR-nn`, so that the new specs can
  trace to them.

### B-08: The BRD depends on artefacts that are being discarded
The BRD makes 45 references to "Spec Assumption N", AC numbers, OP01–OP05,
QA03 and ADRs. The Gate 1 register's resolutions cite spec sections, and
"Downstream Alignment Required" lists edits to the old specs. Once the
specs are recreated, all of these references stop pointing at anything.
**Required:**
- Replace each reference with the BRD's own `BR-xx` rule IDs.
- Restate the G1-01 to G1-30 resolutions in terms of the BRD rules.
- Remove the "Downstream Alignment Required" section; it no longer
  applies.
- Rename the "Spec traceability" lines to "Traceability to requirement
  document §x".

## Non-blocking comments (fix in the same pass if possible)

- **N-01: BRD-002 (registration/login) is not in the requirement
  document.** Requirement §2 says the organisation already *has* a
  One-Point Employee Portal, which implies sign-in already exists. Decide
  one of the following:
  - (a) Keep BRD-002, clearly labelled "Supporting requirement, raised by
    the Author, not in the scope document: demo substitute for the existing
    portal sign-in". Reduce it to business need only.
  - (b) Drop BRD-002 and record "employee is already signed in to the
    portal" as an assumption and dependency.

  **Recommendation: (a)**, because the demo has no real portal to depend
  on.
- **N-02: "View actions that are pending".** Requirement §3 asks for the
  *actions*, not just the stakeholders. Name the action shown for each
  stakeholder, for example "Manager approval", "HR eligibility check",
  "IT access change".
- **N-03: Rejection outcome.** State whether a manager's or HR's rejection
  carries a reason that the employee sees.
- **N-04: Selection lists.** State where the department/BU, location and
  role lists come from (a demo reference list in V1), and whether
  "business unit" is the same as "department".
- **N-05: Success measures.** The business need has no measurable outcome.
  Add one or two, for example "employee can see status and the pending
  stakeholder without contacting any team".
- **N-06: Sponsor.** The HR Product Owner is still "assumed". This is
  acceptable for the V1 demo, but it must stay flagged.
- **N-07: Authorship.** BRD v4.0 was edited directly by the reviewer. For
  independence, the Author should make the next revision against these
  comments, and the reviewer then approves it.

## Approval checklist for the next BRD version

- [x] B-01: journey steps 1 and 4 defined
- [x] B-02: confirmation defined for every final outcome
- [x] B-03: downstream condition recorded as a business decision
- [x] B-04: integration-needs table per stakeholder
- [x] B-05: orchestration intent vs V1 simulation stated consistently
- [x] B-06: business decisions separated from technical constraints
- [x] B-07: users, journey stages and numbered business rules
- [x] B-08: no references to specs, plan, tasks, test cases or ADR IDs as sources
- [x] N-01: decision on BRD-002 recorded

> **Checked by the reviewer against BRD v5.0 (2026-09-28):** all items above
> are covered. N-03 (rejection reason) is **not** covered and is raised to
> blocking as F-01 in `reviews/BRD-v5.0.gate1-review.md`, together with
> F-02 to F-04. Approval follows once those are resolved.

When all blocking items are checked, the BRD can be marked **Approved
(Gate 1)**. The specs, plan, tasks and test cases are then recreated from
it, tracing to the `BR-xx` rules.
