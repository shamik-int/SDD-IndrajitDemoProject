# Tasks: Employee Internal Transfer

## Derived From
`.ai-context/plans/employee-internal-transfer.plan.md` (v2 — no backend, per ADR-0004)

## Sequence
- [x] **employee-internal-transfer.T01** — Domain layer: `TransferRequest`
  entity (incl. per-stakeholder status map), `Stakeholder`/`StakeholderDecision`
  enums matching the spec's Status Definitions, abstract repository contract,
  and usecases (`SubmitTransferRequest`, `GetActiveTransferRequestStatus`,
  `GetTransferRequestById`, `RecordStakeholderDecision`). Usecases are
  unit-testable against a `mocktail`-mocked repository before T02 exists.
  — Acceptance: supports AC1, AC3, AC6, AC14 (foundational — no behavior of
  its own beyond correct delegation to the repository contract)

- [x] **employee-internal-transfer.T02** — Data layer: Hive-backed local
  datasource (`transfer_requests` + `app_state` boxes per the plan's Data
  Model) and the repository implementation — field validation, the
  single-in-flight-request check, and the full state-machine transition
  logic (manager → HR → parallel downstream fan-out → Completed, plus both
  rejection branches). This is where most of the spec's actual business
  rules live.
  — Acceptance: AC2, AC3, AC4, AC5, AC7, AC8, AC9, AC10, AC11, AC12, AC13, AC14
  — Test cases: UT01–UT14, QA01–QA14 (`test_cases/employee-internal-transfer.test_cases.md`)

- [x] **employee-internal-transfer.T03** — Presentation: submission screen +
  `GetxController`. Department/location/role selection, effective date
  picker, optional reason field, validators wired to
  `core/utils/validators.dart`, submit action calling
  `SubmitTransferRequest`, and the "already in progress" blocking message.
  — Acceptance: AC1, AC2, AC3, AC4, AC5

- [x] **employee-internal-transfer.T04** — Presentation: status screen +
  `GetxController`. Shows overall status, submitted field values, and the
  current `pendingStakeholders` list, reactive to state changes.
  — Acceptance: AC6, AC7, AC9, AC10, AC11, AC12, AC13

- [x] **employee-internal-transfer.T05** — Presentation: Simulate Decision
  control — a visually distinct section (not styled as a real
  stakeholder-facing feature, per the plan's explicit QA/Gate 2 check item),
  letting a tester pick a stakeholder + decision and call
  `RecordStakeholderDecision`.
  — Acceptance: AC14

- [x] **employee-internal-transfer.T06** — Integration test: full journey
  (submit → simulate manager approve → simulate HR approve → simulate
  Payroll/IT/Facilities complete → Completed) plus both rejection branches
  (manager reject, HR reject), per `test_cases/_integration.md`.
  — Acceptance: AC3, AC8, AC9, AC10, AC11, AC12, AC13, AC14 (end-to-end)

## Notes
- One task, one prompt (Blueprint §16) — implement and get T0N reviewed
  before starting T0N+1. Reference tasks by ID, not description.
- Test-first per constitution.md: for each task, write and confirm RED
  before writing implementation code.
- T01/T02 carry almost all the real logic and test coverage; T03–T05 are
  thin UI wiring over already-tested usecases; T06 is the AC-spanning proof
  that they compose correctly.
