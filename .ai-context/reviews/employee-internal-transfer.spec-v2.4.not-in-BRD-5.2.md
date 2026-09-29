# Reference Note — Spec v2.4 points not in BRD 5.2

**Spec:** `specs/employee-internal-transfer.spec.md` v2.4
**BRD:** `BRD.md` BRD-001 **v5.2, Gate 1 Approved 2026-09-28. Not changed by this note.**
**Review answered:** `reviews/employee-internal-transfer.spec-v2.1.gate1-review.md` (11 items, 8 scenarios)
**Author:** Indrajit Bhandari
**Date:** 2026-09-29

**Purpose:** reference only. This note lists every point in spec v2.4 that
BRD 5.2 does not mention or states differently. That way the Gate 1
reviewer, and later the plan, can see what the spec adds beyond the
approved BRD. Each point comes from the reviewer's feedback or is a
spec-level detail. All of them are kept in the spec.

**Kind:**
- **Differs from BRD**: the spec narrows or reads a BRD 5.2 rule
  differently, because the reviewer's feedback asks it to.
- **Mechanism**: a technical or demo mechanism used to meet a BRD rule.
- **Detail**: a spec-level detail that BRD 5.2 leaves open.

## 1. Points that differ from BRD 5.2

| ID | Reviewer item | What the spec does | What BRD 5.2 says | Spec items |
|---|---|---|---|---|
| **CL-01** | 1, 6 (S1, S8) | The organisational change is scheduled only when the whole request becomes `COMPLETED`. A `FAILED` request never changes the employee's record. The completed `ORG_RECORD_UPDATE` step stays `COMPLETED` but has no effect on the profile | BR-13: the organisational record update records the new values, effective from the effective date. BR-16 and §7: steps already completed are "not rolled back" / "not undone" | SD-16; three moments; OP06; AC16, AC17, AC20; UT58, UT59, UT69; XF01, XF08, XF09 |
| **CL-02** | 2 (S2) | After a `COMPLETED` request, a new request cannot be submitted until its effective date | BR-07 and BR-17: after any final outcome, the employee may submit a new request | SD-17; OP01 error 6; OP02; AC18, AC34; UT24, UT48, UT64; XF02 |

**Reviewer confirmation requested:** CL-01 is the smallest reading of BR-13
and BR-16 that meets review item 1. CL-02 is the first of the two options
review item 2 offers. The reviewer is asked to accept both at Gate 1 as the
spec's reading of BRD 5.2, with the BRD left as approved.

## 2. Points not mentioned in BRD 5.2

| ID | Reviewer item | Point in spec v2.4 | Kind | Related BRD 5.2 rule |
|---|---|---|---|---|
| SD-18, AC24, AC32, OP06, OP07 | 3 (S3) | Demo sign-in has `EMPLOYEE` and `TESTER` roles. Only the tester uses the simulation; an employee cannot approve their own request | Mechanism | BR-23, BR-24 |
| SD-19, AC23 | 4 (S4) | History has a `SYSTEM` actor for automatic changes, and `simulatedBy` on simulated outcomes | Mechanism | BR-27 |
| SD-05 (revised), AC33 | 5 (S5) | If the effective date passes while the request is pending: the request carries on, the date never changes, and a note is shown. On completion the profile shows the new values from the completion day | Detail | BR-05, BR-13 |
| SD-20, AC35 | 7 (S6) | `scheduleOrganisationalChange` is keyed by `requestId`: a repeat returns the existing change; a conflicting call is refused | Mechanism | BR-13 (BR-08 covers submission only) |
| AC31 | 8 (S7) | On sign-out all data held for the previous user is cleared; employee B never sees employee A's data | Detail | BR-23 |
| Acceptance scenarios | 10 | UT01–UT70 and XF01–XF09 are spec-level acceptance scenarios, separate from the implementation test cases | Detail (document structure) | — |
| XF01–XF09 | 11 | Cross-flow scenarios | Detail (document structure) | — |
| SD-01 | — | Only steps that have been reached are shown | Detail | BR-19 |
| SD-02 | — | An approved manager or HR step is shown as "Completed (Approved)" | Detail | BR-19 |
| SD-03 | — | Triggers use the current values snapshot taken at submission | Detail | BR-03, §5 |
| SD-04 | — | Another employee's request gives "No request found." | Detail | BR-23 |
| SD-07 | — | Duplicate submission blocked with a `submissionId` | Mechanism | BR-08 |
| SD-08, AC30 | — | The employee can list all their own requests | Detail | BR-23, BR-27 |
| SD-10 | — | Reason and rejection reason at most 500 characters | Detail | BR-02, BR-28 |
| SD-11 | — | No maximum effective date | Detail | BR-05 |
| SD-12, AC28 | — | "Demo — test data only" indicator | Detail | BR-25 |
| SD-13 | — | The simulation and the `TESTER` role are removed before production | Detail | BR-24 |
| SD-14 (part) | — | Labels "Pending HR eligibility check" and "In progress"; the other labels are in BRD 5.2 | Detail | BR-06, BR-18 |
| SD-15 | — | A stakeholder task's content is fixed when its step becomes `PENDING` | Detail | §8 |

## 3. Review items that are in BRD 5.2

| Reviewer item | BRD 5.2 rule |
|---|---|
| 6: meaning of `ORG_RECORD_UPDATE` = `COMPLETED` (recorded, effective from the date) | BR-13. Scheduling only on `COMPLETED` is CL-01 |
| 9: demo security is not production authorization | BR-26 |
| SD-09: a downstream failure carries no reason | §8, BR-28 |

## Summary

| Group | Total | In BRD 5.2 | Partly | Not mentioned | Differs from BRD 5.2 |
|---|---|---|---|---|---|
| Review items 1–11 | 11 | 1 (9) | 4 (3, 4, 6, 8) | 4 (5, 7, 10, 11) | 2 (1, 2) |
| Spec decisions SD-01–SD-20 | 20 | 1 (SD-09) | 2 (SD-14, SD-16) | 15 | SD-17 (CL-02); SD-06 superseded |

BRD-001 v5.2 remains the approved business requirement. This note does not
change it.
