# Tasks: Employee Registration & Login

## Derived From
`.ai-context/plans/employee-registration-login.plan.md`

## Sequence
- [x] **employee-registration-login.T01** — Domain layer: `EmployeeAccount`
  entity (no password fields — those stay data-layer-only per the spec's
  contract note), `RegisterEmployeeInput`/`LoginInput` value objects,
  abstract repository contract, and 4 usecases (`RegisterEmployee`,
  `LoginEmployee`, `GetCurrentSession`, `LogoutEmployee`). Unit-testable
  against a `mocktail`-mocked repository before T02 exists.
  — Acceptance: supports AC1, AC3, AC6, AC8 (foundational — delegation only)

- [x] **employee-registration-login.T02** — Data layer: Hive-backed
  datasource (`employees` box keyed by normalized/lowercased email,
  `session` box) and the repository implementation — field validation
  (name/email/password via `core/utils/validators.dart`'s new `password`
  validator), email normalization, uniqueness check, SHA-256+salt password
  hashing and verification (`crypto` package, ADR-0005), session
  read/write/clear.
  — Acceptance: AC2, AC3, AC4, AC5, AC6, AC7, AC8
  — Test cases: UT01–UT10, QA01–QA07 (`test_cases/employee-registration-login.test_cases.md`) — **UT11 (AC9) explicitly excluded**, see T05 below

- [x] **employee-registration-login.T03** — Presentation: Login screen +
  controller (email/password fields, generic invalid-credentials error per
  AC7, link to Register), and Register screen + controller (name/email/
  password + current department/location/role dropdowns reusing
  `ReferenceData`, field-level validation errors per AC4/AC5).
  — Acceptance: AC1, AC2, AC3, AC4, AC5, AC6, AC7

- [x] **employee-registration-login.T04** — Entry-flow integration: prepend
  a session check to `AppEntryController.resolveInitialRoute()` (no
  session → Login route; session exists → existing status-vs-submission
  logic, unchanged). Add a Logout action to **both** screens a logged-in
  employee can land on — the status screen's `AppBar` and the submission
  screen's `AppBar` — routing back through `AppEntryPage` after clearing
  the session.
  — Acceptance: AC1, AC8

- [ ] **employee-registration-login.T05** — Integration test (real device/
  desktop target, per T06's precedent on `employee-internal-transfer` —
  real Hive I/O doesn't reliably resolve under `flutter_tester`): register
  → auto-login → submit a transfer request → logout → log back in → status
  still visible and correct.
  — Acceptance: AC1, AC3, AC6, AC8 (single-account journey only)
  — **AC9 is explicitly out of scope for this task.** Per Gate 1 Finding 1 /
  the plan's Cross-Feature Amendment section: AC9 requires
  `employee-internal-transfer.T07` (`employeeId` scoping), which doesn't
  exist yet. Writing an AC9 test now that can never go GREEN within this
  feature's own tasks would violate test-first discipline (RED must be
  followed by a GREEN this feature can actually deliver). AC9/UT11 move to
  `employee-internal-transfer.T07`'s own test-first work once that task
  starts.

## Cross-Feature Task (filed under the other feature, not duplicated here)
- `employee-internal-transfer.T07` — add `employeeId` to `transfer_requests`,
  change `app_state`'s key to `activeRequestId:<employeeEmail>`, thread
  `employeeId` through `submit()`/`getActive()`/`recordStakeholderDecision()`.
  Only once this lands does AC9/UT11 become verifiable. Tracked in
  `PROJECT_CHECKLIST.md` and `employee-internal-transfer.tasks.md` (to be
  added there when that task starts), not as a task under this slug.

## Notes
- One task, one prompt (Blueprint §16). T01/T02 carry the real logic and
  most test coverage, same shape as `employee-internal-transfer`'s T01/T02.
- Test-first per constitution.md: RED confirmed before implementation, for
  every task including T04 (entry-flow wiring) — a routing change is still
  a state-changing operation, not exempt from the rule.
