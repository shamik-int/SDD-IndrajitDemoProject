# Integration & Cross-Feature Test Cases

Reserved for cross-feature and system-level scenarios that don't map cleanly to a
single spec (Blueprint §19.1). Per-feature spec-derived cases live in
`<feature-slug>.test_cases.md` alongside each spec.

## Employee Internal Transfer — End-to-End Journey
_Per-feature spec-derived cases now live in
`test_cases/employee-internal-transfer.test_cases.md`. This section holds only
the full-journey and cross-feature scenarios._

- Full journey (revised at spec v1.2, ADR-0004 — no backend, all via the
  Simulate Decision control): submit request (AC3) → simulate manager approve
  (AC8/AC14) → simulate HR approve (AC10/AC14) → simulate Payroll/IT/
  Facilities complete in any order (AC12/AC14) → employee sees status resolve
  to `COMPLETED` with no pending stakeholder. Also exercise both rejection
  branches (manager reject → AC9; HR reject → AC11) end-to-end in the same
  integration test file.
- Regression: submitting a second request while one is already in flight is
  now **resolved** (not open) — single in-flight request per employee, per
  `employee-internal-transfer.spec.md`'s "Assumptions Requiring Gate 1
  Confirmation" §4 and AC2/UT05. Re-test this scenario if Gate 1 changes that
  decision.
