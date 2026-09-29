# Gate 1 Review — employee-internal-transfer.spec.md v2.1

**Document reviewed:** `.ai-context/specs/employee-internal-transfer.spec.md` v2.1 (2026-09-28), submitted for Gate 1
**Linked BRD:** BRD-001 v5.2 (Gate 1 Approved 2026-09-28)
**Previous review:** `reviews/BRD-v5.0.gate1-review.md` (BRD approved; specs not approved)
**Reviewer:** Shamik Bhattacharya, Gate 1 reviewer of record
**Date recorded:** 2026-09-29
**Verdict:** **Changes Requested.** The 11 items below are mandatory before spec approval. Reviewer: "Once these points are agreed we can mark the spec as approved."

> **Update, 2026-09-29: feedback incorporated in spec v2.3.** v2.1 is kept
> as `specs/employee-internal-transfer.spec-v2.1-backup-2026-09-28.md`.
> An earlier v2.2 draft applied the feedback only in part (Definitions and
> Consumed contract). It was never complete, and it is kept for reference
> only as `specs/employee-internal-transfer.spec-v2.2-draft-backup-2026-09-29.md`.
> See "Author response — spec v2.3" below.

## Developer feedback — mandatory before spec approval

| # | Priority | Feedback / required change |
|---|---|---|
| 1 | 🔴 Critical | Please clarify what happens if a downstream step fails after the organisation change is scheduled. Currently, the Org Record Update can be marked completed and the transfer can be scheduled for a future date. If Payroll/IT/Facilities fails later, the request becomes FAILED, but the scheduled transfer may still happen. Please define what should happen to the scheduled transfer in this case. |
| 2 | 🔴 Critical | Please prevent conflicting future transfers. The current spec allows a new request after a previous request is completed, even if its effective date is still in the future. This can result in two different transfers being scheduled for the same employee. Please either block a new request until the previous transfer becomes effective or define exactly how multiple future transfers should be handled. |
| 3 | 🔴 Critical | Please restrict the Demo/Simulation controls. The spec currently allows a tester to simulate Manager/HR/Payroll/IT/Facilities actions. It is not clear who is allowed to use this functionality. A normal employee should not be able to approve their own transfer by using the simulation controls. Please define the test/demo access clearly. |
| 4 | 🔴 Critical | Please define the audit actor for system-generated status changes. The history currently supports Employee, Manager, HR, Payroll, IT and Facilities, but some status changes will happen automatically by the system. Please add a SYSTEM actor or define clearly how these changes should be recorded. |
| 5 | 🟠 High | Please define what happens when the effective date has already passed but the workflow is still pending. The current spec says the workflow continues, but it does not clearly explain what the user should see or whether the original effective date remains unchanged. |
| 6 | 🟠 High | Please clarify the meaning of "ORG_RECORD_UPDATE = COMPLETED". The current flow appears to schedule the organisation change for a future date. So does COMPLETED mean the employee's profile was actually changed, or only that the change was successfully scheduled? Please define this clearly. |
| 7 | 🟠 High | Please define duplicate/conflicting organisation change handling. What happens if scheduleOrganisationalChange() is called more than once for the same request? Please define the unique key/idempotency rule and expected response. |
| 8 | 🟠 High | Please add negative test cases for employee access. Test that Employee A cannot see or operate Employee B's request. Also test logout/login with another employee and confirm that previous employee data is not accessible. |
| 9 | 🟠 High | Please clearly separate demo security from production security. The current ownership validation is inside the app/repository. Since V1 has no backend, please document that this is only application-level protection and cannot be considered production-grade authorization. |
| 10 | 🟡 Medium | Please clarify the test-case statement. The document says test cases should not be created before Gate 1 approval, but the spec already contains UT01–UT50. Please clarify whether these are acceptance/reference scenarios or actual implementation test cases. |
| 11 | 🟡 Medium | Please add cross-flow scenarios, not only individual requirement coverage. Each BR may have an acceptance criterion, but the important failures are happening when multiple requirements work together—for example: future effective date + downstream failure + new transfer request. These scenarios should be explicitly covered. |

### Most important scenarios to add
The development/testing team must cover these:

| S | Scenario |
|---|---|
| S1 | Transfer scheduled → Payroll fails → What happens to the scheduled transfer? |
| S2 | Transfer scheduled for Oct 15 → User submits another transfer for Oct 30 → What happens? |
| S3 | Employee tries to use Manager/HR approval simulation → Should be blocked unless authorised as a tester. |
| S4 | Manager approves → System automatically changes request status → Audit history should show SYSTEM as actor. |
| S5 | Effective date passes while HR approval is still pending → Confirm expected behaviour. |
| S6 | Same organisation change is triggered twice → System should not create duplicate changes. |
| S7 | Employee A logs out → Employee B logs in → Employee B must not see Employee A's request/history. |
| S8 | One downstream step fails after other steps have completed → Confirm exactly which changes remain and which are cancelled. |

## Approval checklist for the next spec version

- [ ] 1: scheduled transfer on downstream failure defined
- [ ] 2: conflicting future transfers prevented or defined
- [ ] 3: simulation access restricted; employee cannot self-approve
- [ ] 4: SYSTEM audit actor defined
- [ ] 5: effective date passed while pending defined
- [ ] 6: meaning of ORG_RECORD_UPDATE = COMPLETED defined
- [ ] 7: scheduleOrganisationalChange idempotency defined
- [ ] 8: employee A/B and logout/login negative scenarios
- [ ] 9: demo vs production security separated
- [ ] 10: test-case statement clarified
- [ ] 11: cross-flow scenarios added (S1–S8)

## Author response — spec v2.3 (2026-09-29)

Spec v2.3 answers every item and scenario. Section names below are those
in spec v2.3.

| # | Status | Answer in spec v2.3 | Where |
|---|---|---|---|
| 1 | ✅ (needs CL-01) | The org change is scheduled only when the whole request becomes `COMPLETED`. A `FAILED` request never has a scheduled change, and the profile never changes | Three moments; OP06 effects; AC16, AC17, AC20; SD-16; XF01, XF08 |
| 2 | ✅ (needs CL-02) | A new request is blocked while a `COMPLETED` transfer is awaiting effect (OP01 error 6, with the date). The contract also refuses a second schedule for the same employee | OP01, OP02; AC18, AC34; SD-17, SD-20; XF02, XF09 |
| 3 | ✅ | `TESTER` role only for the simulation (OP06, OP07). An employee never sees it and is refused. A tester cannot submit or own a request | Actors; Access rules; AC24, AC32; SD-18; XF03 |
| 4 | ✅ | `SYSTEM` actor for status changes, `STEP_SET` and `CHANGE_SCHEDULED` entries. Stakeholder outcomes keep the owning stakeholder, plus `simulatedBy` | History entries; actor table; AC23; SD-19; XF04 |
| 5 | ✅ | The request continues and the effective date never changes. The employee sees an "effective date passed" note. On completion the profile shows the new values from that day | Request status; AC33; SD-05 (revised); XF05 |
| 6 | ✅ | `COMPLETED` = "recorded" only. Recorded / Scheduled / Effective are defined as three separate moments | Three moments; AC16 |
| 7 | ✅ | The unique key is `requestId`. A same-values repeat returns the existing change. Different values, or another request while a change is pending, are refused | Consumed contract; AC35; SD-20; UT60–UT63; XF06 |
| 8 | ✅ | A vs B: list, open, history, operate. Sign-out clears all data held for the previous user | AC22, AC31; UT28, UT52, UT67, UT68; XF07 |
| 9 | ✅ | Security boundary section: V1 protection is application-level only, not production-grade authorization | Security boundary; Non-Functional Constraints; Out of Scope |
| 10 | ✅ | UT and XF are acceptance scenarios, part of the spec. The post-Gate-1 test cases must cover every ID | Status; Acceptance scenarios |
| 11 | ✅ | Cross-flow scenarios XF01–XF09 | Cross-flow scenarios |

| Scenario | Covered by |
|---|---|
| S1 | XF01 |
| S2 | XF02 |
| S3 | XF03 |
| S4 | XF04 |
| S5 | XF05 |
| S6 | XF06 |
| S7 | XF07 |
| S8 | XF08 |
| Item 11 example (future date + failure + new request) | XF09 |

**Items for the reviewer to decide.** Two answers read or narrow an
approved BRD-001 rule, so they need a BRD-001 v5.3 clarification:
- **CL-01** (items 1, 6): the org change is applied only when the request
  is Completed (BR-13, BR-15, BR-16).
- **CL-02** (item 2): a new request is blocked until a completed transfer's
  effective date (BR-07, BR-17).

New spec decisions SD-16 to SD-20, revised SD-05 and superseded SD-06 are
also listed for confirmation in the spec.

**Author's checklist for the reviewer:**
- [x] 1 · [x] 2 · [x] 3 · [x] 4 · [x] 5 · [x] 6 · [x] 7 · [x] 8 · [x] 9 · [x] 10 · [x] 11
- [x] S1–S8 covered by XF01–XF08
- [ ] CL-01 decided by the reviewer
- [ ] CL-02 decided by the reviewer

**Awaiting the Gate 1 reviewer's decision** (Approved / Changes Requested).
Once CL-01 and CL-02 are agreed and recorded in BRD-001 v5.3, the spec is
marked **Gate 1 Approved**.

## Author response — spec v2.4 (Indrajit Bhandari, 2026-09-29)

v2.3 is kept as `specs/employee-internal-transfer.spec-v2.3-backup-2026-09-29.md`.
v2.4 keeps every v2.3 answer above, for items 1–11 and S1–S8, without
changing any behaviour.

**BRD-001 v5.2 is not changed.** The Author has decided not to raise a BRD
v5.3. CL-01 (items 1, 6) and CL-02 (item 2) stay in the spec, because this
review asks for them. They are recorded as **points not in BRD 5.2**, not
as BRD clarifications. Every review item, spec decision and acceptance
criterion that BRD 5.2 does not mention is marked "Not mentioned in BRD
5.2" in the spec. All of them are listed in
`reviews/employee-internal-transfer.spec-v2.4.not-in-BRD-5.2.md`.

| Item | In BRD 5.2? |
|---|---|
| 1 | Differs (CL-01: BR-13, BR-16) |
| 2 | Differs (CL-02: BR-07, BR-17) |
| 3 | Partly (BR-23, BR-24; `TESTER` role not mentioned) |
| 4 | Partly (BR-27; `SYSTEM` actor not mentioned) |
| 5 | Not mentioned |
| 6 | Yes (BR-13), with scheduling timing as CL-01 |
| 7 | Not mentioned |
| 8 | Partly (BR-23; sign-out clearing not mentioned) |
| 9 | Yes (BR-26) |
| 10, 11 | Not mentioned (document and scenario structure) |

**Author's checklist for the reviewer (v2.4):**
- [x] 1 · [x] 2 · [x] 3 · [x] 4 · [x] 5 · [x] 6 · [x] 7 · [x] 8 · [x] 9 · [x] 10 · [x] 11
- [x] S1–S8 covered by XF01–XF08; item 11 example by XF09
- [x] Points not in BRD 5.2 recorded; BRD 5.2 unchanged

**Awaiting the Gate 1 reviewer's decision** (Approved / Changes Requested).
