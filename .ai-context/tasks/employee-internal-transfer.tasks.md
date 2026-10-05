# Tasks: Employee Internal Transfer

## Derived From
`.ai-context/plans/employee-internal-transfer.plan.md` **v4.0** (from spec
v2.4, Gate 1 Approved 2026-09-30). One task per Sequencing step of the plan.
The v1.5 task list is kept as `employee-internal-transfer.tasks-v1.5-backup-2026-09-30.md`.

**Review route.** At the session user's direction (2026-09-30), these tasks,
the test cases and the implementation are reviewed together at Gate 2
(Subhajit Mukherjee), rather than the tasks getting a separate Gate 1 pass
first. Recorded in `status.md`.

Every task is test-first: tests written and run RED, then implementation,
then GREEN with `flutter analyze` clean. Test IDs refer to
`test_cases/employee-internal-transfer.test_cases.md`.

## Sequence
- [x] **employee-internal-transfer.T01** — Core support: `Clock` /
  `AdjustableClock` and local-date helpers (`yyyy-MM-dd`, `d MMM yyyy`),
  `AsyncLock`, `TransferMessages` (every spec message verbatim),
  `DemoBanner`, in-memory `LocalDbService` for widget tests, and
  `readAll`/`clearBox` on `LocalDbService`.
  — Plan: PD-04, PD-05, PD-10 — ACs: supports all; AC28 (banner)

- [x] **employee-internal-transfer.T02** — Portal adapters (D-01..D-03) and
  start-up: seeded demo accounts with `EMPLOYEE`/`TESTER` roles (hash + salt
  only), `DemoAuthService` (sign in, sign out, `currentUser()`), `SessionState`,
  `DemoProfileService` (`getCurrentValues`, `pendingScheduledChange`,
  `scheduleOrganisationalChange`), `StaticReferenceLists`, `DemoDataSeeder`
  (PD-06 clean-up of v1.5/BRD-002 boxes, `schemaVersion` 2).
  — Plan: PD-01, PD-01a, PD-02, PD-03, PD-06 — ACs: AC02, AC16, AC27, AC35
  — Tests: UT21, UT60–UT62 (public schedule API), seeding tests

- [x] **employee-internal-transfer.T03** — Domain: entities and enums;
  `TransferWorkflow` (submit validation, outcome transitions, triggers table,
  stakeholder tasks, history entries with actors); `ScheduleBook` (SD-20);
  repository contract; usecases for OP01–OP07.
  — ACs: AC03–AC06, AC10–AC18, AC23, AC25, AC26, AC29, AC35
  — Tests: UT01, UT03–UT08, UT11–UT20, UT22, UT23, UT25–UT27, UT30, UT31,
  UT33–UT36, UT44, UT46, UT47, UT55–UT57, UT60–UT62 (pure)

- [x] **employee-internal-transfer.T04** — Data: `TransferLedgerModel`
  (round trip), `TransferLedgerLocalDataSource`, `TransferRequestRepositoryImpl`
  with the access rules (signed in → role → ownership), idempotent submit,
  lock-serialised read-modify-write and one `put` per operation (outcome,
  history, status and schedule together).
  — ACs: AC02, AC03, AC07, AC08, AC13, AC16, AC18, AC22, AC23, AC27, AC30,
  AC32, AC34, AC35
  — Tests: UT02, UT09, UT10, UT24, UT28, UT29, UT45, UT48, UT50,
  UT52–UT54, UT58, UT59, UT63, UT64, UT70, append-only and timing checks

- [x] **employee-internal-transfer.T05** — Employee screens: Sign in, My
  transfer requests, New transfer request form, Request detail (steps,
  history, confirmation, "effective date passed" note), `ConfirmationBuilder`.
  — ACs: AC01–AC09, AC19–AC21, AC23, AC27, AC28, AC30, AC33, AC34
  — Tests: UT32, UT37–UT40, UT42, UT43, UT45 (widget), UT49, UT64 (form),
  UT65 (note), UT66, UT69

- [x] **employee-internal-transfer.T06** — Tester screen: "Demo only:
  simulate stakeholder outcome" with open tasks (OP07), only valid outcomes
  for pending steps, mandatory rejection reason, busy-state disable,
  "Effective date passed" mark.
  — ACs: AC24–AC26, AC29, AC33
  — Tests: UT41, UT43, UT65 (task mark), reject-reason widget test

- [x] **employee-internal-transfer.T07** — Roles, routing and sign-out:
  role-based start-up routing (PD-07), role middleware on every feature
  route, `Get.offAllNamed` sign-out, no permanent feature controllers,
  PD-08 detection response (warn in UAT, block in PROD).
  — ACs: AC24, AC27, AC31, AC32
  — Tests: UT51, UT67, UT68, entry-routing tests

- [x] **employee-internal-transfer.T08** — Cross-flow tests: XF01–XF09 over
  the real repository, real Hive and an adjustable clock; one UI journey in
  `integration_test/` on macOS desktop.
  — ACs: AC15–AC18, AC22, AC23, AC31, AC33–AC35
  — Tests: XF01–XF09, UT20 and UT24 end to end, IT01

- [ ] **employee-internal-transfer.T09** — Clean-up: remove the v1.5
  transfer code and tests and the BRD-002 Register feature; update
  `architecture.md` and READMEs.
  — Plan: "Existing code: keep, change, remove"
  — **Partly done (2026-09-30):** the v1.5 code is unwired from routes and
  bindings (Register route removed); `architecture.md` and READMEs updated.
  **Deleting the v1.5 files was blocked by the session's permission rules**;
  the file list is in `reviews/employee-internal-transfer.gate2-evidence.md`.
  Blocked again on 2026-10-05 (Gate 2 G2-02); the Author runs the `git rm`.
