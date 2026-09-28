# Gate 1 Review — BRD v5.0 (follow-up to the BRD v4.0 review)

**Document reviewed:** `.ai-context/BRD.md` v5.0 (2026-09-28), submitted for Gate 1 Re-Review
**Previous review:** `reviews/BRD-v4.0.gate1-review.md`
**Reviewer:** Shamik Bhattacharya, Gate 1 reviewer of record
**Date:** 2026-09-28
**Verdict:** **Changes Requested.** BRD v5.0 will be marked **Approved (Gate 1)** once the 4 feedback points below are resolved. No further blocking review round is planned: if these are fixed as asked, the next version is approved.

> **Update, 2026-09-28: feedback incorporated in BRD v5.1.** v5.0 is kept
> as `BRD-v5-backup-2026-09-28.md`.
>
> | Feedback | Addressed in BRD v5.1 |
> |---|---|
> | F-01 rejection reason | New BR-28; BR-11, BR-12, BR-19, BR-27, §3, §7, §8, §9, §14 |
> | F-02 B-06/B-07/B-08 note | "BRD Gate 1 Review" history table now lists B-01 to B-08 |
> | F-03 stale section names | History tables and G1-01, 05, 11, 12, 18, 23, 25, 27 cite v5.1 rules |
> | F-04 effective timing | Option (a): new values take effect from the effective date (BR-13, §3 step 4, §7) |
>
> **Awaiting the reviewer's check of v5.1 and the Gate 1 decision.** The
> v5.1 changes were made at the reviewer's direct instruction rather than
> by the Author (see N-07).

## Outcome of the v4.0 review comments

| Comment | Status in BRD v5.0 |
|---|---|
| B-01 to B-08 | ✅ All covered in BRD-001 |
| N-01, N-02, N-04, N-05, N-06, N-07 | ✅ Covered |
| **N-03: rejection reason** | ❌ **Not covered.** Raised to blocking as **F-01** below |

## Feedback points (must be resolved before approval)

### F-01: A rejection must carry a reason that the employee sees (was N-03, now blocking)
BRD-001 does not say whether a manager or HR rejection carries a reason.
§7 tells the employee only that the request "was not approved", and §8
records only "Approved / Rejected". So the employee is told the transfer
was refused but not why, which weakens the single view of progress
(source §3) and the confirmation (source §2 step 8).

**Required:**
- Add a business rule: when the current manager or HR **rejects**, a
  **rejection reason is mandatory**. A rejection without a reason cannot
  be recorded.
- The employee sees the reason:
  - in the **Rejected by Manager** and **Rejected by HR** confirmations
    (§7);
  - in the stakeholder step view (BR-19).
- The reason is recorded in the append-only history (BR-27), together with
  which stakeholder rejected and when.
- §8: for the Current manager and HR eligibility rows, "Portal needs back"
  becomes "Approved / Rejected **with reason**".
- Reflect the new rule in BR-11, BR-12, §7, §8, §14 (traceability) and the
  Gate 1 Re-Review Submission.
- In V1 the reason is entered through the demo-only simulation (BR-24),
  like the decision itself.

### F-02: Out-of-date note on B-06, B-07 and B-08
`BRD.md` lines 650–654 ("BRD Gate 1 Review", under Review history) say
B-06, B-07 and B-08 "are not changed in this pass". v5.0 does address them:
§9 (business vs technical), §2, §3 and §4 (users, journey, BR-01 to BR-27),
and §14 (traceability to the source document only).

**Required:** Replace the note with the rows showing where v5.0 addresses
B-06, B-07 and B-08, so the history matches BRD-001.

### F-03: History tables point at section names that no longer exist
- The B-01 to B-05 table (`BRD.md` lines 642–648) cites "BRD-001
  'Decided': Business intent vs V1 delivery", "Downstream fan-out" and
  "Journey" (as the place completion is defined). v5.0 has no such
  sections.
- The G1-23 row (line 580) cites BRD-001 "Journey" for the completion rule,
  but completion is defined in BR-15.

**Required:** Point every cell at the v5.0 section or rule number, for
example B-03 → §5, BR-13, BR-14; B-05 → §1, §9, BR-24; G1-23 → BR-15, §7.
Check the rest of the G1 register for the same issue.

### F-04: When the organisational record update takes effect is not stated
BR-13 says the organisational record update **starts** when HR approves.
It does not say whether the employee's department, location and role
**change** at that point or on the **effective date**. The v4.0 review asked
this under B-01, and it matters for the Completed confirmation (§7), which
shows the new values and the effective date.

**Required:** Record one of these as a business decision:
- (a) The record update is completed after HR approves, and the new values
  **take effect from the effective date**. Until then the employee's
  profile still shows the current values. *(Suggested)*
- (b) The new values take effect as soon as the record update completes,
  and the effective date is for information only.

Add the decision to BR-13 (or a new rule) and to §7's Completed row.

## Approval checklist for the next BRD version

- [ ] F-01: mandatory rejection reason for manager and HR, shown to the employee and recorded in history
- [ ] F-02: B-06 / B-07 / B-08 history note corrected
- [ ] F-03: history and register cells point at v5.0 sections and rule numbers
- [ ] F-04: effective timing of the organisational record update decided

When all four items are checked, the reviewer marks the BRD **Approved
(Gate 1)**. The specs, plan, tasks and test cases are then recreated from
BRD-001 (comment #16).

**Instruction to the Author:** as for v5.0, the Author makes the revision
(N-07). Keep v5.0 as a backup (`BRD-v5-backup-2026-09-28.md`), release the
next version, and resubmit it for Gate 1.

## Author response — BRD v5.2 (Indrajit Bhandari, 2026-09-28)

v5.1 is kept as `BRD-v5.1-backup-2026-09-28.md`. BRD v5.2 completes the
feedback and is resubmitted for Gate 1 final approval.

| Feedback | Status in v5.2 |
|---|---|
| F-01 rejection reason | ✅ BR-28 (unchanged from v5.1); reflected in BR-11, BR-12, BR-19, BR-27, §3, §7, §8, §9, §14 |
| F-02 B-06/B-07/B-08 note | ✅ "BRD Gate 1 Review" history table lists B-01 to B-08 with BRD-001 references (unchanged from v5.1) |
| F-03 stale section names | ✅ **Completed in v5.2.** The 16-comment history table now cites BRD-001 rules for every row, and **all 30** G1 register rows cite a BRD-001 rule or section (v5.1 covered 8; v5.2 adds the other 22). No cell refers to a removed section name |
| F-04 effective timing | ✅ Option (a): new values take effect from the effective date (BR-13, §3 step 4, §7) (unchanged from v5.1) |

Also: BR-28 was moved after BR-27 so the business rules read in number
order. No rule content changed.

**Author's checklist for the reviewer:**
- [x] F-01: mandatory rejection reason for manager and HR, shown to the employee and recorded in history
- [x] F-02: B-06 / B-07 / B-08 history note corrected
- [x] F-03: history and register cells point at BRD-001 sections and rule numbers
- [x] F-04: effective timing of the organisational record update decided

**Awaiting the Gate 1 reviewer's decision** (Approved / Changes Requested).
