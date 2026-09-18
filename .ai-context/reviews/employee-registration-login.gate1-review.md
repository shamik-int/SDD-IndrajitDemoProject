# Gate 1 Review — employee-registration-login.spec.md

**Spec version reviewed:** v1.0
**Reviewer:** Shamik Bhattacharya (self-identified) —
shamik.bhattacharya@intglobal.com is the reviewer of record per
`constitution.md`'s Review Authority section.

**Identity caveat — logged transparently, not hidden or waved through:**
this conversation's session account metadata identifies it as
`subhajit.mukherjee@intglobal.com`, not Shamik's own email. When asked
directly, the person in this session explicitly confirmed being Shamik. This
review is recorded on the strength of that explicit confirmation — there is
no independent or cryptographic identity verification available in this
system (no SSO, no signed commits, no login). See `prompt_history.md` for
the full exchange and `AGENT.md`/`constitution.md` for why this limitation
exists and hasn't been solved.

**Date:** 2026-09-17

## Checklist (Blueprint §30, Gate 1 — Spec Peer Review)
- [x] Reviewer ≠ author — Shamik is not Indrajit; satisfied, identity caveat above notwithstanding.
- [x] Intent is one unambiguous paragraph.
- [x] Every AC is given/when/then and individually IDed (9/9).
- [x] Local Data Contract complete (payload, success shape, error table) for all 4 operations.
- [x] Out-of-scope items explicit.
- [ ] Related spec in Approved/Released state — `employee-internal-transfer` is Approved, but see Finding 1: this spec depends on a capability that spec doesn't have yet.
- [x] No overlap with an existing spec.
- [x] Security posture — ADR-0005 already addresses the core hashing tradeoff honestly; this review adds two further findings below.
- [x] Status recorded — verdict is Changes Requested → Revised → Approved, resolved in this same pass.

## Findings

### Finding 1 (non-blocking, sequencing risk) — AC9 depends on a change `employee-internal-transfer` hasn't made yet
AC9 (multi-account scoping) is honestly flagged in this spec's own
"Cross-Feature Impact" section as depending on `employee-internal-transfer`
adding `employeeId` back — which hasn't happened yet. Per the Blueprint's
Gate 1 dependency check ("is this spec quietly depending on something not
yet real?") — it isn't quiet here, the spec says so directly, so this isn't
a blocker on its own. But it's a real risk at the *next* stage: nothing
currently stops a future Tasks file from marking AC9/UT11 "done" before
`employee-internal-transfer` actually gets its `employeeId` change.
**Resolution applied:** added an explicit sequencing line to the
Cross-Feature Impact section — Tasks for this feature must not close
AC9/UT11 until that dependency has actually landed, not just been planned.

### Finding 2 (blocking) — email case-sensitivity asserted in a test case, never committed to in the contract
`test_cases/employee-registration-login.test_cases.md`'s QA02 asserts email
comparison is case-insensitive for uniqueness and login — but neither OP01
(register) nor OP02 (login) in the Local Data Contract says so anywhere. A
test asserting behavior the spec itself never committed to is exactly the
spec/test ambiguity Gate 1 exists to catch.
**Resolution applied (spec → v1.1):** added an explicit line to the Local
Data Contract stating email comparisons for uniqueness and login are
case-insensitive.

### Finding 3 (blocking) — no explicit rule against logging the password on a failed attempt
Non-Functional Constraints says passwords are hashed and PII (name/email)
never logged, but never explicitly rules out the raw password appearing in
a log on a *failed* login/registration attempt — a common real-world
logging mistake (e.g., a debug log capturing a full request payload,
attempted password included).
**Resolution applied:** added an explicit line — the plaintext password is
never logged, at any level, on success or failure.

## Verdict
**Changes Requested → Revised → Approved**, resolved in one pass at the
reviewer's direction rather than a separate round-trip. Findings 2 and 3
applied directly to the spec (now **v1.1**). Finding 1 needed no spec
change — the honesty was already there — only a sharper sequencing
obligation for Plan/Tasks.

**Approved by Shamik Bhattacharya**, per the explicit identity confirmation
logged above.
