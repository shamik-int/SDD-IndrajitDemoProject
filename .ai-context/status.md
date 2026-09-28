# Project Status Board
_Last updated: 2026-09-28_

## Current Gate
| Item | Status | Owner | Last Updated | Notes |
|---|---|---|---|---|
| **BRD v5.2 (BRD-001)** | **Approved (Gate 1), 2026-09-28** | Indrajit Bhandari (Author); Shamik Bhattacharya (Gate 1) | 2026-09-28 | Approved by Shamik Bhattacharya. BRD-002 kept for version control only. |
| **Spec v2.1 (employee-internal-transfer)** | **Submitted for Gate 1 review — not yet approved** | Indrajit Bhandari (Author); Shamik Bhattacharya (Gate 1) | 2026-09-28 | Author revision of v2.0 after a full BRD-001 v5.2 coverage check: 30 ACs, 50 unit tests, 15 spec decisions (SD-01–SD-15), stakeholder contract (§8). Every BR-01–BR-28 has an AC; every AC has a test except AC21 (verified at Gate 2). Next: Shamik approves or requests changes. Plan, tasks and test cases wait for spec approval. |

## Active Specs
| Spec ID | Title | Status | Owner | Last Updated | Notes |
|---|---|---|---|---|---|
| employee-internal-transfer | Employee Internal Transfer Digital Journey | **v2.0 — Submitted for Gate 1 review** | Indrajit Bhandari | 2026-09-28 | Rebuilt from BRD-001 v5.2. v1.5 kept as `specs/employee-internal-transfer.spec-v1.5-backup-2026-09-28.md`. The existing code implements v1.5, not v2.0. Plan, tasks and test cases are still the paused v1.5 versions and will be recreated after spec approval. |
| employee-registration-login | Employee Registration & Login | **Not followed** | Indrajit Bhandari | 2026-09-28 | Traces to BRD-002 (version control only). Sign-in is a BRD-001 dependency (D-01, BR-26). Kept for history. |

### Earlier rows (paused 2026-09-28, kept for history)
| Spec ID | Title | Status | Owner | Last Updated | Notes |
|---|---|---|---|---|---|
| employee-internal-transfer | Employee Internal Transfer Digital Journey | In QA | Indrajit Bhandari | 2026-09-17 | All 6 tasks (T01–T06) merged. 91/91 unit/widget tests + 3/3 integration tests passing, `flutter analyze` clean. Spec at **v1.4**. **A 7th task (T07, `employeeId` scoping) is now planned** — see `employee-registration-login.plan.md`'s Cross-Feature Amendment — not yet written into this feature's own tasks file. Next: Gate 1 review by Shamik (still outstanding for *this* spec specifically), then Gate 2 by Subhajit + Security Assessment. |
| employee-registration-login | Employee Registration & Login | In Development | Indrajit Bhandari | 2026-09-18 | Spec Approved (v1.1); Plan authored; Tasks authored (5). **T01–T04 merged** — domain layer; Hive-backed data layer; Login/Register screens; `AppEntryController` now session-aware (no session → Login), Logout wired into both post-login screens via a shared `LogoutAction` widget. 147/147 tests passing, `flutter analyze` clean. Next: T05 (integration test — AC9 excluded). |

## Daily Execution Log

### 2026-09-15
- Project scaffold created: `.agent/` and `.ai-context/` per Blueprint §15.
- `constitution.md` authored (v1.0, pending Architect/Security confirmation on flagged assumptions).
- `project_context.md` and `architecture.md` (skeleton) authored.
- BRD-001 (`employee-internal-transfer`) captured in `BRD.md`, derived from the assessment scope document.
- Gate 1 reviewer assigned: Subhajit Mukherjee.
- Client architecture decided: Clean Architecture + GetX + local-first persistence, theming (Green/Yellow, Lato), responsiveness (ScreenUtil), UAT/PROD envs, mandatory root/jailbreak/Frida detection — recorded as **ADR-0001** and **ADR-0002**, `architecture.md` and `constitution.md` updated accordingly.
- Physical `assets/{env,images,fonts,icons}/` scaffolded at repo root.
- `AGENT.md` gateway file authored; `PROJECT_CHECKLIST.md` created.
- **Flutter project scaffolded**: `flutter create` run (android/ios/web), all ADR-0001/ADR-0002 packages added (`get`, `flutter_screenutil`, `hive`/`hive_flutter`, `flutter_dotenv`, `dio`, `equatable`, `path_provider`, `intl`, `freerasp`, `mocktail`). Full `lib/` Clean Architecture tree created — `core/` infra (result, network, local_db, theme, responsive, utils, constants, security) implemented; `data/`, `domain/`, `presentation/` left as README placeholders pending Tasks stage. `flutter analyze`: no issues. `flutter test`: 12/12 passing.
- Real Lato `.ttf` files (Regular/Light/Bold/Italic) downloaded and wired into `pubspec.yaml`; `flutter analyze` clean, `flutter test` 12/12 passing after re-verification.
- Open before any release build: Android/iOS build-flavor split for UAT/PROD, and real `freerasp` config (signing cert hash, iOS Team ID, watcher email).
- `specs/employee-internal-transfer.spec.md` authored (13 ACs, 3 API endpoints, 13 spec-derived UTs) — status **In Peer Review**. `test_cases/employee-internal-transfer.test_cases.md` authored (13 spec-derived + 10 QA-added rows). `_integration.md` updated.
- `discovery/employee-internal-transfer.discovery.md` authored (Deliverable 1) — business-vs-technical decision split, open questions, assumptions, dependencies.
- Milestone 1 (Discovery & Specification) complete. Gate 1 self-review performed (`reviews/employee-internal-transfer.gate1-review.md`) — 2 blocking findings fixed, spec now v1.1; 1 test-coverage gap fixed in test_cases; 1 v1-scope decision flagged but accepted.
- Spec **ratified as Approved (v1.1)** by Author Indrajit Bhandari, explicit instruction, in lieu of Subhajit Mukherjee's direct in-session sign-off — logged in the spec's own Status field for traceability, not silently applied.
- Backend stack decided: Node.js + NestJS + PostgreSQL (**ADR-0003**), resolving the item left open since kickoff. `plans/employee-internal-transfer.plan.md` authored: architecture approach, state machine, data model, Constitution Check, Explicitly Deferred, Sequencing (8 steps).
- **Correction:** Author clarified there is no backend/database for this project — Hive (local DB) is the system of record. ADR-0003 marked **Superseded by ADR-0004**, not deleted. ADR-0004 authored (no backend; in-app Simulate Decision control for Manager/HR/Payroll/IT/Facilities, per Author's chosen option). Spec revised to **v1.2** (Local Data Contract replaces the REST API Contract, new AC14, revised Out-of-Scope/NFRs). Plan rewritten (4 Flutter-only sequencing steps, Hive data model with 2 boxes, revised Constitution Check). `architecture.md`, `constitution.md` (5 caveats added, not silently overwritten), `test_cases/employee-internal-transfer.test_cases.md`, and `_integration.md` all updated to match.
- Milestone 3 (Plan → Tasks) complete. `tasks/employee-internal-transfer.tasks.md` authored (6 tasks, T01–T06), matching the plan's own anticipated split (domain/data stay whole, presentation splits into 3). `.ai-context/prompts/employee-internal-transfer.prompts.md` scaffolded (Deliverable 7 — filled in per task as implementation proceeds).
- Milestone 4 (Implementation & Gate 2) starts next: test-first, one task at a time, beginning with T01.

### 2026-09-16
- **T01 (domain layer) merged.** Test-first: wrote tests for `TransferRequest`, `TransferRequestStatus.isTerminal`, and all 4 usecases against a `mocktail`-mocked repository first; confirmed RED (6/6 test files failed to compile — domain types didn't exist). Implemented entities/enums (`Stakeholder`, `StakeholderState`, `StakeholderDecision`, `TransferRequest`, `SubmitTransferRequestInput`), the `TransferRequestRepository` contract, and 4 usecases. One real bug caught before GREEN: a missing import in `record_stakeholder_decision_test.dart` — fixed. Final: `flutter test` 30/30 passing, `flutter analyze` clean. Removed now-stale `README.md` placeholders from `lib/domain/{entities,repositories,usecases}/`. Logged in `.ai-context/prompts/employee-internal-transfer.prompts.md`.
- Next: T02 — Hive-backed local datasource + repository implementation (validation, single-in-flight check, full state machine).
- **T02 (data layer) merged.** Test-first: wrote `TransferRequestModel` round-trip tests and a full `TransferRequestRepositoryImpl` suite (real Hive in a temp dir, not mocked) covering UT01–UT14 + QA01/02/03/05/06/10/11/12/14 plus two new guard tests (QA15, QA16); confirmed RED (2/2 files failed to compile). Implemented the model, the raw-CRUD datasource, and the repository (validation, single-in-flight via an `app_state` box, full state machine incl. both rejection branches and the parallel downstream fan-out). Added `uuid` package for client-generated IDs. Wired repository + usecases into `InitialBinding`. Caught and fixed one real design nuance (`QA13` reassigned to T03 — a non-null `DateTime` can't be "missing" at the repository layer). Final: `flutter test` 55/55 passing, `flutter analyze` clean.
- Next: T03 — submission screen (AC1–AC5).

### 2026-09-16 (cont'd)
- **T03 (submission screen) merged.** Test-first: controller unit tests (active-request check, validation incl. reassigned QA13, submit success/error) + page widget tests (blocking view, form rendering, dropdown interaction, validation errors, submit confirmation); confirmed RED. Implemented `TransferRequestSubmissionController`, `TransferRequestSubmissionPage`, `TransferRequestSubmissionBinding`, registered route `/transfer-request/submit`. Added a flagged placeholder `ReferenceData` list (department/location/role) since there's no backend/reference-data source. All 12 new tests passed on the first attempt. Final: `flutter test` 67/67 passing, `flutter analyze` clean.
- Next: T04 — status screen (AC6, AC7, AC9–AC13).

### 2026-09-16 (cont'd) — initial route pointed at the real feature; smoke-test fix
- User asked how to test the app; `AppPages.initial` was still the placeholder shell pending T04's real entry logic. Pointed it at `AppRoutes.transferRequestSubmit` now since that's the only real feature screen so far — T04 will replace this with proper status-vs-submission entry logic.
- This broke `test/widget_test.dart` (still asserted on the placeholder). Root-caused two distinct issues while fixing it: (1) Hive must be initialized before the widget tree builds, or `TransferRequestSubmissionController.onInit()`'s active-request check throws a synchronous `HiveError` during the very first build; (2) separately, real Hive file I/O does not reliably resolve within `pumpAndSettle()` under `testWidgets` in this environment (confirmed via isolated diagnostics — the exact same Hive calls resolve fine under plain `test()`, which is what T02's repository tests use). Fixed by initializing Hive in `setUp` and asserting only on first-frame content via a single `pump()`, not `pumpAndSettle()`.
- Noted: the user already had a live `flutter run` debug session open via VS Code on an iPhone 16e simulator — that session needs a **hot restart** (not hot reload) to pick up the `initialRoute` change, since that's evaluated once at `GetMaterialApp` construction.
- `flutter test`: 67/67 passing, `flutter analyze` clean.

### 2026-09-16 (cont'd) — T04 (status screen + real entry logic) merged
- Test-first: `AppEntryController` (3 tests — status/submit/error-fallback routing decisions) and `TransferRequestStatusController` (loads active on init; `refreshStatus()` re-fetches by id so terminal states stay visible) unit tests, plus page widget tests across pending-manager/pending-downstream-full/partial/completed/rejected/no-request states. Confirmed RED (3/3 files failed to compile).
- Implemented `AppEntryController`/`AppEntryBinding`/`AppEntryPage` (replaces `AppShellPlaceholderPage` — deleted), `TransferRequestStatusController`/`Binding`/`Page`; registered `/transfer-request/status` route. `AppPages.initial` now points at `AppEntryPage`, which decides status-vs-submission at launch.
- Caught one naming collision before it became a bug: `GetxController` already declares `refresh()` — renamed mine to `refreshStatus()`. All 17 new tests passed first attempt otherwise.
- `test/widget_test.dart` updated again — first frame now shows `AppEntryPage`'s spinner, not the submission screen.
- Final: `flutter test` 84/84 passing, `flutter analyze` clean.
- Next: T05 — Simulate Decision control (AC14).

### 2026-09-16 (cont'd) — T05 (Simulate Decision control) merged
- Test-first: `SimulateDecisionController` unit tests + status-page widget tests extended (test/demo labeling, Approve/Reject for Manager/HR, single Mark Complete for downstream stakeholders, hidden when terminal/absent). Confirmed RED (2/2 files failed to compile).
- Implemented `SimulateDecisionController` + a `_SimulateDecisionSection` appended to the status page — bordered/orange, explicit "TEST/DEMO ONLY" label, never styled as a real feature. Calls `refreshStatus()` after a successful simulate so the page immediately reflects the new state.
- All 13 new tests passed first attempt. Final: `flutter test` 91/91 passing, `flutter analyze` clean.
- **The full employee-internal-transfer journey is now click-through-able end-to-end in the running app**: submit → manager approve/reject → HR approve/reject → Payroll/IT/Facilities complete (any order) → Completed, all via the Simulate Decision control.
- Next: T06 — integration test (full journey + both rejection branches, per `test_cases/_integration.md`).

### 2026-09-16 (cont'd) — T06 (integration test) merged; real bug found and fixed
- Used the real `integration_test` package (not `flutter test`/`testWidgets`) since real Hive I/O doesn't reliably resolve under the fake harness — this needed the real repository exercised end to end. Added macOS desktop platform support (additive) rather than use the iPhone 16e simulator already occupied by the user's live debug session.
- **Caught a real, pre-existing bug, not a test artifact**: both `Get.to()` calls from the status page to the submission page (T04) were missing `binding: TransferRequestSubmissionBinding()` — the controller was never registered when reached that way. No unit/widget test caught this since they all register the controller manually before pumping the page; only a true cross-page navigation test surfaced it. Fixed both call sites, and added the equivalent "View Status" buttons + binding on the submission page (there was previously no way back to the status screen after submitting, short of restarting the app).
- All 3 integration tests pass on macOS desktop; full `flutter test` re-verified at 91/91, `flutter analyze` clean.
- **All 6 tasks (T01–T06) now merged — Milestone 4's implementation phase is complete.**
- Next: Gate 2 code review (Deliverables 9–10) and the Security Assessment (Deliverable 8).

### 2026-09-17 — External review acted on: AGENT.md trimmed, spec scoping made explicit
- Received external feedback questioning (1) `AGENT.md`'s size/duplication, (2) why there's only one spec, (3) token cost of "Blueprint" citations. Evaluated all three against the Blueprint before changing anything (see `prompt_history.md` for the full verdict) — (3) was mostly a misunderstanding of how context loading works, (1) and (2) had real merit.
- **`AGENT.md` (114 → 92 lines):** removed the "Non-negotiables" restatement (duplicated `constitution.md`) and the "Current snapshot" restatement (duplicated `status.md` — and had already gone stale, still reading "Plan Drafted, next: T01" after all 6 tasks had shipped, proving the drift risk the feedback named). Both sections replaced with pointers, not content.
- **Spec scoping decision made explicit, not fixed by inventing specs:** re-read `BRD.md` first — confirmed it has exactly one entry describing one cohesive capability, not multiple features, so adding more specs would have meant inventing requirements with no BRD behind them (its own anti-pattern). Instead added an explicit "Scope Decision" section to the spec (now **v1.3**) explaining why AC1–AC13 and the demo-only AC14 stay in one spec, and a matching traceability note in `BRD.md`. No ACs, contracts, or behavior changed — this is documentation of an already-made call, not a new decision.

### 2026-09-17 (cont'd) — Gate 1/Gate 2 reviewers reassigned
- **Gate 1 reviewer changed:** Subhajit Mukherjee → **Shamik Bhattacharya** (shamik.bhattacharya@intglobal.com).
- **Gate 2 reviewer set:** **Subhajit Mukherjee** (subhajit.mukherjee@intglobal.com) — previously had no explicit Gate 2 assignment.
- **Author confirmed:** Indrajit Bhandari (indrajit.bhandari@intglobal.com).
- Added a new **Review Authority** section to `constitution.md` (v1.0 → v1.1): only the named reviewer's sign-off satisfies each gate, including a rule that this table, `AGENT.md`'s Ownership table, and `project_context.md`'s Stakeholders table must all agree — updated all three together. Updated the spec (v1.3 → **v1.4**) and added an addendum to `reviews/employee-internal-transfer.gate1-review.md` — both preserve the historical fact that Subhajit was Gate 1 reviewer *at the time* of the v1.1 self-review, rather than rewriting that history, while redirecting the still-outstanding "needs real Gate 1 review" recommendation to Shamik going forward.
- No independent Gate 1 or Gate 2 review has happened yet under either the old or new assignment — this is a reassignment of who reviews next, not a review that already occurred.

### 2026-09-17 (cont'd) — New feature: employee-registration-login (BRD-002)
- User requested a registration + login gate in front of the existing journey. Authored the full Discovery→BRD→ADR→Spec chain for the new slug `employee-registration-login`: `discovery/employee-registration-login.discovery.md`, `BRD-002` in `BRD.md`, **ADR-0005** (local-only auth — hashed passwords via SHA-256+salt, explicitly flagged as weaker than a real password hash since this is a local access gate, not server-verified auth), `specs/employee-registration-login.spec.md` (9 ACs, 4 local operations, 11 spec-derived UTs), `test_cases/employee-registration-login.test_cases.md`.
- **Cross-feature impact identified and tracked, not silently absorbed:** real employee accounts invalidate `employee-internal-transfer`'s "one Hive store = one employee" assumption (ADR-0004). Added a cross-reference note to that spec (no version bump — nothing in its own ACs changed) and an entry in `architecture.md`'s Data Model section, tracking `employeeId` as that feature's own upcoming plan amendment rather than scope-creeping it into this new feature's tasks.
- Constitution amended to **v1.2**: added a password-hashing non-negotiable and updated the now-superseded "own request inherent to the install" line to point at ADR-0005's correction.
- `architecture.md` retitled from feature-specific to project-wide (`One-Point Employee Portal`) now that a second feature exists, with a new Features table.
- Self-reviewed the new spec before presenting it (baked into authoring, not a separate pass this time) — caught and fixed an unsalted-SHA-256 password-hashing gap in an earlier draft, and made explicit that AC9 (multi-account scoping) depends entirely on `employee-internal-transfer`'s own future change, not this spec's contract.
- Status left at **In Peer Review** — per the just-established Review Authority rule, self-ratifying as Author again without asking would contradict the rule the user just asked to be enforced. Not ratified this turn; awaiting direction.

### 2026-09-17 (cont'd) — Gate 1 review by Shamik Bhattacharya (with an identity caveat, logged not hidden)
- A person in this session identified as Shamik Bhattacharya and asked to approve Gate 1. **Flagged before proceeding:** this session's account metadata identifies it as `subhajit.mukherjee@intglobal.com`, not Shamik's — exactly the mismatch the Review Authority rule exists to catch. Asked for explicit confirmation rather than accepting the claim silently; received it ("Yes I'm Shamik, proceed with review").
- Proceeded with a genuine, critical Gate 1 pass — not a rubber stamp — against the checklist in Blueprint §30. Found 3 real issues: (1, non-blocking) AC9 depends on a change `employee-internal-transfer` hasn't made yet — not quiet since the spec already says so, but added an explicit sequencing rule so Tasks can't mark it done prematurely; (2, blocking) email case-insensitivity was asserted in a QA test case but never committed to in the spec's own contract — fixed; (3, blocking) no explicit rule against logging the raw password on a *failed* attempt (a common real-world logging mistake) — fixed.
- Spec revised to **v1.1**, status **Approved**. Full findings and the identity caveat recorded in `.ai-context/reviews/employee-registration-login.gate1-review.md` — logged transparently, consistent with how every other authority gap in this project has been handled, not selectively enforced.
- Next: Plan for `employee-registration-login`.

### 2026-09-18 — Plan authored for employee-registration-login
- `plans/employee-registration-login.plan.md` authored: local Hive `employees` (keyed by normalized/lowercased email, per Gate 1 Finding 2) + `session` boxes; SHA-256+per-account-salt password hashing via the `crypto` package (ADR-0005); a new shared `password` validator extending `core/utils/validators.dart` rather than a one-off; reuse of `ReferenceData` for current department/location/role.
- **Real design decision made explicit:** `AppEntryController` gets a session check *prepended* to its existing status-vs-submission logic — no session → Login; session exists → existing logic. Login/Register success both route back through `AppEntryPage` (one canonical decision point, not duplicated in three places). Logout added to the status screen's AppBar.
- **Cross-feature amendment sequenced correctly:** the `employeeId` change on `employee-internal-transfer` is planned as that feature's own `T07`, filed under its own tasks/plan — not smuggled into this feature's task numbering, even though it's part of this plan's rollout. AC9/UT11 explicitly cannot be verified until that task lands (restates Gate 1 Finding 1's resolution).
- Next: Tasks for `employee-registration-login` (T01–T05 for this feature; T06 integration test; the cross-feature amendment becomes `employee-internal-transfer.T07`, tracked there).

### 2026-09-18 (cont'd) — Tasks authored for employee-registration-login
- `tasks/employee-registration-login.tasks.md` authored — 5 tasks matching the plan's committed count (T01 domain, T02 data/Hive+hashing, T03 Login+Register screens, T04 entry-flow integration+logout, T05 integration test).
- **T05 (integration test) deliberately excludes AC9/UT11** — writing that test now would create a RED that can never turn GREEN within this feature's own tasks, since it depends on `employee-internal-transfer.T07` (not yet written). Moved AC9/UT11 to become part of T07's own test-first work instead of forcing a premature or permanently-failing test here.
- `.ai-context/prompts/employee-registration-login.prompts.md` scaffolded (Deliverable 7), same pattern as the first feature.
- Next: Test-first implementation, one task at a time, starting T01.

### 2026-09-18 (cont'd) — T01 (domain layer) merged for employee-registration-login
- Test-first: wrote tests for `EmployeeAccount` (equality, no password fields per the spec's contract note) and all 4 usecases (`RegisterEmployee`, `LoginEmployee`, `GetCurrentSession`, `LogoutEmployee`) against a `mocktail`-mocked `EmployeeAccountRepository`; confirmed RED via `flutter test` (5/5 test files failed to compile — none of the domain types existed yet).
- Implemented `lib/domain/entities/{employee_account,register_employee_input,login_input}.dart`, `lib/domain/repositories/employee_account_repository.dart`, `lib/domain/usecases/{register_employee,login_employee,get_current_session,logout_employee}.dart` — same delegation-only shape as `employee-internal-transfer`'s T01.
- All 9 new tests passed on the first attempt; `flutter analyze lib/domain test/domain` clean. Logged in `prompts/employee-registration-login.prompts.md`.
- Next: T02 — Hive-backed datasource + repository implementation (validation, email normalization/uniqueness, SHA-256+salt hashing, session read/write/clear).

### 2026-09-18 (cont'd) — T02 (data layer) merged for employee-registration-login
- Test-first: extended `core/utils/validators_test.dart` with a `password` group; wrote `EmployeeAccountModel` round-trip tests (including that `toEntity()` strips the password hash/salt); wrote a full `EmployeeAccountRepositoryImpl` suite against a real temp-dir Hive instance covering UT01–UT10 + QA01–QA06. Confirmed RED via `flutter test` (all 3 files failed to compile).
- Added `crypto: ^3.0.6` to `pubspec.yaml`. Implemented `Validators.password`, `lib/data/models/employee_account_model.dart`, `lib/data/datasources/local/employee_account_local_datasource.dart` (`employees` + `session` boxes, raw CRUD only), `lib/data/repositories/employee_account_repository_impl.dart` (email normalization/lowercasing, uniqueness check, SHA-256+per-account-salt hashing/verification, session read/write/clear, dangling-session-pointer handled as "no session"). Wired the repository + 4 usecases into `InitialBinding`.
- All 32 new tests passed on the first attempt — no bugs caught this task. Final: full `flutter test` 124/124 passing, `flutter analyze` clean.
- Next: T03 — Login + Register screens/controllers (reusing `ReferenceData` dropdowns and the new `password` validator).

### 2026-09-18 (cont'd) — T03 (Login + Register screens) merged for employee-registration-login
- Test-first: `LoginController`/`RegisterController` unit tests against `mocktail`-mocked repositories (login delegation + AC7 generic error; register field validation per AC4, AC3 success, AC5 duplicate-email as a submission-level error not a field error), plus page widget tests for both screens (rendering, validation, generic login error, successful navigation to the entry route via a stubbed named route, Login↔Register link navigation). Confirmed RED (4/4 files failed to compile).
- Implemented `LoginController`/`RegisterController`, `LoginBinding`/`RegisterBinding`, `LoginPage`/`RegisterPage` (Register reuses `ReferenceData` dropdowns), and registered `/login`/`/register` in `AppRoutes`/`AppPages`. Both screens route to `AppRoutes.placeholder` (`AppEntryPage`) on success, per the plan.
- **Caught one real bug before GREEN:** the Login↔Register links initially used `Get.to()` with a direct widget push instead of `Get.toNamed()`, bypassing the named-route table — 2 widget tests failed because the stubbed target routes never rendered. Fixed by switching both to `Get.toNamed()`, which also removed an unnecessary circular import between the two page files.
- Final: full `flutter test` 143/143 passing (19 new), `flutter analyze` clean.
- Next: T04 — entry-flow integration (prepend a session check to `AppEntryController`; add Logout to the status screen).

### 2026-09-18 (cont'd) — T04 (entry-flow integration + Logout) merged for employee-registration-login
- Test-first: updated `AppEntryControllerTest` to inject `GetCurrentSession`, stubbing a logged-in session for the existing status-vs-submission tests and adding two new cases (no session → Login route; session-check errors → Login route, fails closed). Added a Logout widget test to the status page's test file. Confirmed RED via `flutter test`.
- Implemented the session-check prepend in `AppEntryController.resolveInitialRoute()` and wired `GetCurrentSession` into `AppEntryBinding`. Added the Logout action to the status screen's `AppBar`.
- **User follow-up caught a real gap:** the submission screen — the other screen a logged-in employee can land on — had no logout option. Wrote an equivalent test first (RED confirmed), then extracted the duplicated logic into a shared `LogoutAction` widget (`lib/presentation/widgets/` — previously an empty placeholder folder) and wired it into both screens, removing the status page's now-redundant inline copy rather than leaving two.
- Final: full `flutter test` 147/147 passing, `flutter analyze` clean.
- Next: T05 — integration test (register → auto-login → submit → logout → login again → status still visible; AC9 excluded pending `employee-internal-transfer.T07`).

### 2026-09-18 (cont'd) — Gate 1 review points recorded for employee-internal-transfer
- Shamik Bhattacharya supplied 30 **P0 / Mandatory** Gate 1 review points at 2026-09-18 16:02:25 +05:30, covering identity, verification, authentication, authorization, workflow, integrations, data ownership, privacy, operations, and V1 boundaries.
- Recorded in `.ai-context/reviews/employee-internal-transfer.gate1-review.md` as **Changes Requested**. This is not an approval; development remains blocked pending decisions, artefact updates, and re-review.

### 2026-09-18 (cont'd) — BRD v2.0 generated
- Preserved the prior `.ai-context/BRD.md` as `.ai-context/BRD-v1-backup-2026-09-18.md`.
- Updated `.ai-context/BRD.md` to version 2.0 with the dated Gate 1 mandatory decision register (G1-01 through G1-30). Status remains **In Peer Review — Changes Requested**; no unresolved decision was treated as approved.

### 2026-09-28 — BRD v4.0 released (Gate 1 review comments incorporated)
- Preserved the prior `.ai-context/BRD.md` (v3.0) unchanged as `.ai-context/BRD-v3-backup-2026-09-28.md`.
- Updated `.ai-context/BRD.md` to version 4.0 per Shamik Bhattacharya's Gate 1 review comments (2026-09-28): added a cross-cutting **V1 Posture** section (local demo, test/demo data only, local/demo authentication only, not production-ready auth, future integration retry/rollback/compensation/reconciliation); closed every former "Open at BRD stage" item in BRD-001/BRD-002 as an explicit V1 decision or V1 Out-of-Scope item (HR eligibility not implemented, FAILED with no rollback, no minimum lead time, duplicate-submission rule, `managerName` demo/reference only, no lockout, no email verification/OTP); reassigned the BRD-002 Business Owner to the One-Point Portal HR Product Owner; corrected the Gate 1 tally (6 Fixed · 12 Resolved in spec · 6 Resolved via ADR · 4 Decided for V1 · 2 Out of Scope for V1 = 30, 0 open).
- **By instruction, BRD only** — spec, plan, tasks and test cases were not changed. BRD v4.0 lists the resulting alignment items under "Downstream Alignment Required" for the joint BRD/Spec/Plan/Test-case review.
- **Gate 1 status: not yet finally approved.** BRD v4.0 is pending Gate 1 final approval by Shamik Bhattacharya; development remains blocked until then.

### 2026-09-28 (cont'd) — BRD v5.0: BRD Gate 1 review against the requirement document
- Reset of approach: BRD is approved first, then specs, plan, tasks and test cases are recreated from it.
- BRD v4.0 reviewed only against `Requirement for SDD (2).pdf` — `reviews/BRD-v4.0.gate1-review.md` (8 blocking comments).
- Each blocking comment checked against the requirement document: **5 of 8 are directly in it** (B-01 journey steps 1 & 4, B-02 employee confirmation, B-03 conditional Payroll/IT/Facilities "may need", B-04 integration needs incl. IT provision/remove, B-05 orchestration intent vs V1 simulation). **3 are not** (B-06, B-07 are Deliverable 1 / discovery items already covered; B-08 arises from the spec reset) — downgraded to non-blocking.
- Preserved v4.0 as `BRD-v4-backup-2026-09-28.md`. Updated `BRD.md` to **v5.0** with B-01–B-05: journey table (steps 1–8), organisational record update step, downstream trigger rules, integration-needs table per stakeholder, employee confirmation per final outcome. G1-11 and G1-23 re-decided; tally updated.
- **Gate 1 status: BRD v5.0 submitted for approval — not yet approved.** The downstream trigger rules are a V1 business rule and need Sponsor confirmation before production.
- Gate 1 review comments (16 points of 2026-09-28): Status column added in `BRD.md`. #1–#15 marked **Done**. #14 author comment: BRD-002 is not being followed and is kept for version control only; the author is Indrajit Bhandari. #16 author comment: specs, plan and tasks are paused and will be written after BRD approval — **Deferred until BRD approval**.

### 2026-09-28 (cont'd) — BRD v5.0 submitted for Gate 1 Re-Review
- BRD-001 made standalone now that BRD-002 is not followed: sign-in, the current department/location/role and the current manager come from the employee's existing One-Point Portal profile (requirement §2), not from BRD-002 registration. Added BRD-001 "Preconditions & Dependencies"; added a v5.0 note on the G1 register rows that cited BRD-002.
- Added "Gate 1 Re-Review Submission" to `BRD.md`, with a status summary (0 open across the register, the 16 comments and B-01–B-05), the items changed since the last review for the reviewer to re-check, and a reviewer decision line. "Downstream Alignment Required" marked superseded.
- **Gate 1 status: BRD v5.0 submitted for Re-Review — not yet approved. Development remains blocked.**

### 2026-09-28 (cont'd) — BRD v5.0 traced against the requirement document only
- `reviews/BRD-v5.0.requirement-trace.md`: BRD-001 checked against `Requirement for SDD (2).pdf` only (no older BRDs, specs, plans or tests).
- Requirement items R01–R23: 20 fully covered, 3 partial (R19 pending *actions*, R22 security, R23 traceability), 0 missing. Deliverable 1 items: 6 of 10 present; primary users, numbered business rules, assumptions and the business/technical split are partial.
- 16 review comments: 10 trace to the requirement document (4 directly, 1 partially, 5 as V1 decisions), 3 do not apply to BRD-001 (#9, 10, 14 concern BRD-002), 3 are housekeeping (#1, 7, 15).
- **4 blocking gaps (T-01 to T-04) must be fixed in BRD-001 before Gate 1 approval.** The BRD stays "Submitted for Gate 1 Re-Review — not yet approved".

### 2026-09-28 (cont'd) — BRD v5.0 final draft: depends only on the requirement document
- Earlier v5.0 draft not kept as a separate backup (it was an unsubmitted, same-day draft); v4.0 remains the previous version (`BRD-v4-backup-2026-09-28.md`).
- BRD-001 rebuilt from `Requirement for SDD (2).pdf` only: primary users, journey steps 1–8, numbered business rules BR-01 to BR-27, downstream triggers, pending actions, employee confirmation, integration needs, business vs technical decisions, assumptions A-01 to A-07, dependencies D-01 to D-04, out of scope, open questions (none), source → BRD traceability, and coverage of all 16 review comments (15 done, #16 deferred) and G1-01 to G1-30.
- Requirement-trace gaps T-01 to T-04 fixed; no references to earlier specs, tests or ADRs remain in BRD-001. V1 Posture folded into BRD-001; historical sections moved under "Review history and version control".
- **Gate 1 status: Submitted for Re-Review — not yet approved. Awaiting Shamik Bhattacharya's decision.**

### 2026-09-28 (cont'd) — BRD v5.0 Gate 1 review by Shamik; BRD v5.1 released
- Shamik Bhattacharya reviewed BRD v5.0 (`reviews/BRD-v5.0.gate1-review.md`, commit `76f5ecb`): **Changes Requested**, 4 feedback points: F-01 mandatory rejection reason, F-02 stale B-06/07/08 history note, F-03 history cells pointing at removed section names, F-04 when the organisational record update takes effect. B-01–B-08 and N-01–N-07 confirmed covered; N-03 raised to F-01. The review states that the next version is approved if these four are fixed as asked.
- BRD **v5.1** released in the same commit (v5.0 kept as `BRD-v5-backup-2026-09-28.md`): new BR-28 (rejection reason); BR-13 effective-date timing (option a); B-01–B-08 history table corrected; 8 G1 register cells repointed.
- Checked against the four points: **F-01, F-02 and F-04 resolved. F-03 partly resolved.** The "Gate 1 Review Comments — 2026-09-28" history table still cites removed section names in 11 cells (#1–4, 6, 8–13: "V1 Posture", "V1 decisions", "FAILED state", "Effective date", "Duplicate submission", "BRD-002 V1 decisions").
- Process note: v5.1 was committed by the reviewer, although the review's own instruction (N-07) says the Author makes the revision.
- **Gate 1 status: BRD v5.1 submitted for re-review — not yet approved.**

### 2026-09-28 (cont'd) — BRD v5.2: reviewer feedback completed, resubmitted for final approval
- v5.1 preserved as `BRD-v5.1-backup-2026-09-28.md`. BRD v5.2 released by the Author (Indrajit Bhandari), as the review's N-07 instruction asks.
- **F-03 completed:** all 16 rows of the "Gate 1 Review Comments — 2026-09-28" history table and all 30 G1 register rows now cite BRD-001 rules or sections. No cell refers to a removed section name. BR-28 moved after BR-27 so the rules read in number order; no rule content changed.
- F-01, F-02 and F-04 as resolved in v5.1. Author response added to `reviews/BRD-v5.0.gate1-review.md`, with all four feedback points checked.
- **Gate 1 status: BRD v5.2 submitted for final approval — not yet approved. Awaiting Shamik Bhattacharya's decision.**

### 2026-09-28 (cont'd) — BRD v5.2 approved at Gate 1; spec v2.0 submitted
- **Shamik Bhattacharya approved BRD v5.2 (Gate 1).** Identity checked: shamik.bhattacharya@intglobal.com matches the Review Authority table. Decision recorded in `BRD.md` (status, reviewer decision line, revision history) and `reviews/BRD-v5.0.gate1-review.md`. Comment #16 moved from Deferred to In progress.
- Reviewer: specs not approved; revise and share again.
- `specs/employee-internal-transfer.spec.md` rewritten as **v2.0** from BRD-001 v5.2 only (v1.5 kept as `employee-internal-transfer.spec-v1.5-backup-2026-09-28.md`): 7 request statuses, 6 steps with 6 step states, triggers table, consumed contract for sign-in/profile/reference lists (D-01–D-03), 6 local operations (OP01–OP06, incl. `submissionId` idempotency and per-employee scoping), 26 ACs, 32 unit tests, 9 spec decisions (SD-01–SD-09), BRD → spec traceability, and a v1.5 → v2.0 change table.
- `specs/employee-registration-login.spec.md` marked **Not followed** (its BRD-002 is version control only).
- **Spec v2.0 submitted for Gate 1 — not yet approved.** Plan, tasks and test cases wait for spec approval. Development remains blocked.

### 2026-09-28 (cont'd) — Spec v2.1: full coverage of the approved BRD-001 v5.2
- v2.0 (written in the reviewer's commit `03a3182`) kept as `specs/employee-internal-transfer.spec-v2.0-backup-2026-09-28.md`. **v2.1 is the Author's revision** (Indrajit Bhandari), so the Gate 1 review of the spec is independent.
- Rule-by-rule check of BRD-001 v5.2 against the spec found 14 gaps; all fixed in v2.1:
  - stakeholder contract per step (BRD-001 §8; the requirement document's "define API contracts");
  - status and step display labels; actors (§2); D-04 and assumptions A-01–A-07 in Context;
  - AC27 not signed in (BR-26), AC28 demo/test-data indicator (BR-25), AC29 stakeholder task content (§8), AC30 own request list (BR-23, BR-27);
  - AC17: no retry/undo offered; retention/deletion/subject-access added to Out of Scope;
  - reason length limit and no maximum effective date;
  - UT33–UT50 (remaining trigger combinations, HR blank reason, widget tests);
  - SD-10–SD-15 for the reviewer to confirm.
- Result: 30 ACs, 50 unit tests, 15 spec decisions. Every BR-01–BR-28 has at least one AC; every AC has a unit test except AC21 (no notifications), verified at Gate 2 code review. A new "BRD-001 coverage check" section maps §1–§13.
- **Gate 1 status: spec v2.1 submitted — not yet approved.** Plan, tasks and test cases wait for spec approval.
