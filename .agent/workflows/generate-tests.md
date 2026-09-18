# Workflow: /generate-tests

Use after `tasks.md` is approved, one task at a time — never for the whole feature in
one pass.

**Prompt template:**
"Implement the test(s) for `<slug>.T0N` only. Reference `<slug>.spec.md`'s Unit Test
Cases table for `<slug>.UT0N` and Acceptance Criteria `<slug>.ACN`. Write tests first;
do not write implementation code. Confirm the tests fail (RED) before returning."

**Do not:** write implementation in the same prompt — Red phase is a separate,
verified step (constitution.md Testing Discipline; Blueprint Principle #3).
