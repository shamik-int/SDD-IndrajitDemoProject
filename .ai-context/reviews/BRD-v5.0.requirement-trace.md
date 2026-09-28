# Requirement Trace — BRD v5.0 (BRD-001) against the Requirement Document

**Document checked:** `.ai-context/BRD.md` v5.0, section BRD-001
**Checked against:** `Requirement for SDD (2).pdf` **only**. Not compared with earlier BRD versions, specs, plans, tasks or test cases.
**Date:** 2026-09-28
**Purpose:** Gate 1 evidence. Confirms that every requirement in the requirement document appears in the BRD, and that each of the 16 Gate 1 review comments (2026-09-28) traces to the requirement document.

## Summary

| Check | Result |
|---|---|
| Requirement items (R01–R23) covered by BRD-001 | **20 of 23 fully covered · 3 partially covered (R19, R22, R23) · 0 missing** |
| Deliverable 1 items (§4) in BRD-001 | **6 of 10 present · 4 partial** (primary users, business rules, assumptions, business vs technical) |
| 16 review comments traceable to the requirement document | **10 trace to it** (4 directly, 6 as a V1 decision on something the document leaves open) · **3 do not apply to BRD-001** (they concern BRD-002) · **3 are document housekeeping** |
| Blocking gaps for Gate 1 | **4** (T-01 to T-04 below) |

## Part A: requirement document → BRD-001

### §2 Business context and journey

| # | Requirement document | BRD-001 | Result |
|---|---|---|---|
| R01 | The organisation has a One-Point Employee Portal (HR, payroll, IT, learning, facilities services) | Preconditions & Dependencies: employee is signed in to the existing portal | ✅ |
| R02 | Step 1: employee discusses the transfer with the manager | Journey step 1: precondition outside the portal | ✅ |
| R03 | Step 2: manager confirms the transfer | Journey step 2; Integration needs: Current manager | ✅ |
| R04 | Step 3: HR validates eligibility | Journey step 3; V1 decision "HR eligibility" | ✅ |
| R05 | Step 4: organisational information is updated | Journey step 4: organisational record update, always required | ✅ |
| R06 | Step 5: Payroll may need to be updated | Journey step 5; Downstream triggers | ✅ |
| R07 | Step 6: IT may need to provision or remove access | Journey step 6; Integration needs (provision and remove) | ✅ |
| R08 | Step 7: Facilities may need to arrange the new location | Journey step 7; Downstream triggers | ✅ |
| R09 | Step 8: employee receives confirmation | Employee confirmation table, for every final outcome | ✅ |
| R10 | A single digital journey through the portal | Business intent | ✅ |

### §3 Business requirement

| # | Requirement document | BRD-001 | Result |
|---|---|---|---|
| R11 | Initiate an Internal Transfer Request from the portal | Title; Decided | ✅ |
| R12 | Select the proposed new department/business unit | Decided (captures); Preconditions (selection lists) | ✅ |
| R13 | Select the proposed new location | Same | ✅ |
| R14 | Select the proposed role/job position | Same | ✅ |
| R15 | Provide an effective date | Decided; V1 decision "Effective date" | ✅ |
| R16 | Provide an optional reason | Decided | ✅ |
| R17 | Submit the request | Decided; V1 decision "Duplicate submission" | ✅ |
| R18 | View the current status of the request | Decided (a) | ✅ |
| R19 | **View actions that are pending with other stakeholders** | Decided (b): "which stakeholder(s) currently hold the pending action". This names the stakeholder, not the **action** | ⚠️ **Partial → T-01** |
| R20 | The portal orchestrates the downstream activities | Business intent; V1 delivery (simulated) | ✅ |
| R21 | A single view of progress for the employee | Business intent; "Not required" shown for stakeholders that are not needed | ✅ |

### §1 Objective (only the items that apply to a BRD)

| # | Requirement document | BRD-001 | Result |
|---|---|---|---|
| R22 | Handle integration, security and failure scenarios | Integration: Integration needs table ✅. Failure: rejections, FAILED, no rollback ✅. **Security: only a demo-level sign-in statement in V1 Posture. No business rule on who may see or act on a request** | ⚠️ **Partial → T-02** |
| R23 | Maintain traceability from requirement to implementation | Journey steps cite §2. **BRD-001 still cites earlier artefacts as its sources**: "Spec Assumption 1–9", "Spec AC5/AC15/AC16/AC17", "Test case QA03", "OP01 error table", ADR-0004, the state code `PENDING_DOWNSTREAM_UPDATES`, and a "Spec traceability" line naming the old spec file | ⚠️ **Partial → T-03** |

Not BRD items: *Define API contracts*, *testable acceptance criteria*, *technical approach*, *task decomposition* and *test-first* belong to the Spec, Plan, Tasks and Tests. The BRD gives them their input through the Integration needs table and the V1 decisions.

### §4 Deliverable 1: Requirement / Discovery Analysis

The requirement document asks for these items in the Discovery analysis.
Because the BRD must now stand on the requirement document alone, it is
checked for them too.

| Item | BRD-001 | Result |
|---|---|---|
| Business objective | Business need | ✅ |
| Primary users | Not stated. Employee and stakeholders are implied only | ⚠️ **→ T-04** |
| Journey stages | Journey table, steps 1–8 | ✅ |
| Business rules | Present but unnumbered and spread across sections | ⚠️ **→ T-04** |
| Known decisions | Decided; V1 decisions | ✅ |
| Open questions | None remain (all closed as V1 decisions or out of scope) | ✅ |
| Assumptions | Only "Sponsor assumed" and "Priority assumed". No assumptions section | ⚠️ **→ T-04** |
| Dependencies | Preconditions & Dependencies | ✅ |
| Out-of-scope items | V1 Out of Scope | ✅ |
| Business decision vs technical decision | Not separated. Business rules sit next to technical terms (simulate control, state code, ADR) | ⚠️ **→ T-04** |

## Blocking gaps (fix in BRD-001 before approval)

- **T-01: pending actions (R19).** For each stakeholder, name the action
  the employee sees as pending. For example: "Manager approval", "HR
  eligibility check", "Organisational record update", "Payroll update",
  "IT access provision/removal", "Facilities: workspace at new location".
- **T-02: security (R22).** Add business rules:
  - an employee can see, and submit, only their own transfer requests;
  - only the named stakeholder can record their own decision (simulated in
    V1);
  - the request data is employee personal data, and V1 uses test/demo data
    only.
- **T-03: traceability (R23).** Remove every source reference to earlier
  artefacts from BRD-001 (Spec Assumption N, AC numbers, QA03, OP01,
  ADR-0004, `PENDING_DOWNSTREAM_UPDATES`, the "Spec traceability" line).
  Replace them with requirement document § references and the BRD's own
  numbered rules.
- **T-04: Deliverable 1 items.** Add short sections for:
  - **Primary users:** Employee (primary); current manager, HR, Payroll,
    IT and Facilities (stakeholders).
  - **Numbered business rules:** `BR-01…`
  - **Assumptions**
  - **Business decisions vs technical constraints**

## Part B: the 16 Gate 1 review comments → requirement document

| # | Comment | Traces to the requirement document? | Covered in BRD-001? |
|---|---|---|---|
| 1 | Remove stale "Open" items | **Housekeeping**: not a requirement | ✅ No open items |
| 2 | Authentication local/demo only | **Derived**: §1 "security" (the document says nothing about authentication) | ✅ V1 Posture |
| 3 | Auth not production-ready | **Derived**: §1 "security" | ✅ V1 Posture |
| 4 | Manager name demo/reference only | **Partial**: §2 steps 1–2 name the manager. The source of the manager is not in the document | ✅ Manager from portal profile (test/demo data) |
| 5 | HR eligibility not implemented, no invented rules | **Direct**: §2 step 3 | ✅ |
| 6 | FAILED: completed actions not rolled back | **Direct**: §1 "failure scenarios" | ✅ |
| 7 | Turn open items into decisions or out of scope | **Housekeeping**: supports §1 "identify missing decisions" | ✅ |
| 8 | No minimum lead time | **Derived**: §3 "Provide an effective date" (the document sets no rule) | ✅ |
| 9 | Lockout out of scope | **Not in the document**. About BRD-002 sign-in | ➖ Not applicable to BRD-001 (sign-in is outside this BRD) |
| 10 | No email verification/OTP | **Not in the document**. About BRD-002 | ➖ Not applicable to BRD-001 |
| 11 | Test/demo data only | **Derived**: §1 "security" | ✅ V1 Posture |
| 12 | Retry/rollback/compensation/reconciliation are future requirements | **Direct**: §1 "integration… and failure scenarios" | ✅ |
| 13 | Duplicate-submission rule | **Derived**: §3 "Submit the request" plus §1 "failure scenarios" | ✅ |
| 14 | Business owner for BRD-002 | **Not in the document**. BRD-002 is not followed | ➖ Not applicable (author comment recorded) |
| 15 | Correct the tally | **Housekeeping** | ✅ |
| 16 | Align BRD, spec, plan and tests | **Direct**: §1 "Maintain traceability" | ⏸️ Deferred until BRD approval |

**Result:**
- **Trace to the requirement document (10):** 4 directly (#5, 6, 12, 16),
  1 partially (#4), and 5 as a V1 decision on something the document
  leaves open (#2, 3, 8, 11, 13). All are covered in BRD-001, except #16,
  which is deferred by design.
- **Do not apply to BRD-001 (3):** #9, 10 and 14 are about BRD-002
  sign-in and ownership, which the requirement document does not ask for.
- **Housekeeping (3):** #1, 7 and 15 keep the document consistent. They
  are not requirements.

## Recommendation

BRD-001 covers the whole journey and every §3 capability. It is **not yet
ready for Gate 1 approval** until T-01 to T-04 are fixed. T-03 matters most:
the BRD must depend on the requirement document, not on the earlier specs.

## Update 2026-09-28: gaps fixed in BRD v5.0 (final draft)

| Gap | Fixed in BRD-001 |
|---|---|
| T-01 pending actions (R19) | BR-19, §6 Pending actions |
| T-02 security (R22) | BR-23 (own requests only), BR-24 (outcome ownership), BR-25 (personal data, test/demo only), BR-26 (sign-in) |
| T-03 traceability (R23) | BRD-001 cites only the source document and its own rules; §14 maps source → BRD |
| T-04 Deliverable 1 items | §2 Primary users, §4 BR-01 to BR-27, §9 Business vs technical, §10 Assumptions, §11 Dependencies, §13 Open questions |

**Result now:** R01–R23 all fully covered. The 16 review comments are all
covered in BRD-001 §15; #16 is deferred until approval by design. The BRD
is ready for the Gate 1 reviewer's decision.
