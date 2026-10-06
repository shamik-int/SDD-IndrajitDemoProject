# Project Status Board
_Last updated: 2026-10-06_

## Current Gate
| Item | Status | Owner | Last Updated | Notes |
|---|---|---|---|---|
| **BRD v5.2 (BRD-001)** | **Approved (Gate 1), 2026-09-28** | Indrajit Bhandari (Author); Shamik Bhattacharya (Gate 1) | 2026-09-28 | Approved by Shamik Bhattacharya. BRD-002 kept for version control only. |
| **Spec v2.4 (employee-internal-transfer)** | **Approved (Gate 1), 2026-09-30** | Indrajit Bhandari (Author); Shamik Bhattacharya (Gate 1) | 2026-09-30 | Answers the reviewer's 11 items and 8 scenarios (v2.1 review). 35 ACs, UT01–UT70, XF01–XF09, SD-01–SD-20, OP01–OP07. Every BR-01–BR-28 has an AC. Points not in BRD 5.2 (CL-01, CL-02 and others) listed in `reviews/employee-internal-transfer.spec-v2.4.not-in-BRD-5.2.md`. **BRD 5.2 unchanged.** Approved by Shamik Bhattacharya, including CL-01 and CL-02. Plan v4.0 drafted from it (2026-09-30). |
| **Plan v4.0 (employee-internal-transfer)** | **Gate 1 Approved (as reported 2026-09-30; not reopened)** | Indrajit Bhandari (Author); Shamik Bhattacharya (Gate 1) | 2026-09-30 | The session user (signed in as Subhajit Mukherjee) stated "Gate 1 approval is complete" and directed the build. Constitution Review Authority: only Shamik can close Gate 1, so his sign-off should be attached to the plan. ADR-0006 Proposed. |
| **Build v2.4 (tasks T01–T09, test cases, app)** | **Gate 2: Approved with comments, 2026-10-06** | Indrajit Bhandari (Author); Subhajit Mukherjee (Gate 2) | 2026-10-06 | First review 2026-10-05: Changes Requested, 18 findings. Re-review 2026-10-06: 17 of 18 closed (v1.5 code removed, T09 done; ledger read-error fix; leak tracking; XF mutation evidence 9/9; threat-response and sign-out fixes). **Open: G2-06** (Shamik Bhattacharya's written Gate 1 confirmation for plan v4.0, tasks, test cases and ADR-0006; the Author's statement that Gate 1 stands is not accepted). **Tech Lead to accept:** ADR-0001 amendment (release `ENV` default), ADR-0006 decisions 4 and 5, two ignored leak types. Spec change to raise: storage-failure messages and "encrypt at rest" prerequisite. Merge message must carry no AI trailer (G2-01). **Release blocker:** real freeRASP config. **Verification limit:** Flutter is not available on the reviewer's machine, so `flutter analyze` and `flutter test` were not run by the reviewer; the Author reports analyze clean, 177/177 tests, coverage 93.6/98.9/96.7%. Review: `reviews/employee-internal-transfer.gate2-review.md`; pack: `reviews/employee-internal-transfer.gate2-evidence.md`. |

## Active Specs
| Spec ID | Title | Status | Owner | Last Updated | Notes |
|---|---|---|---|---|---|
| employee-internal-transfer | Employee Internal Transfer Digital Journey | **v2.4 — Approved (Gate 1, 2026-09-30)** | Indrajit Bhandari | 2026-09-30 | Rebuilt from BRD-001 v5.2; v2.4 approved by Shamik Bhattacharya. v1.5 kept as `specs/employee-internal-transfer.spec-v1.5-backup-2026-09-28.md`. The existing code implements v1.5, not v2.x. Plan v4.0, tasks T01–T09 and test cases written from spec v2.4 and implemented (2026-09-30); **in Gate 2 review**. The v1.5 code is no longer wired in; its files await removal (T09). |
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

### 2026-09-29 — Spec v2.1 Gate 1 review; spec v2.3 → v2.4
- Shamik Bhattacharya's Gate 1 review of spec v2.1 committed (`9004c0c`): **Changes Requested**, 11 mandatory items (1–4 critical) and 8 scenarios S1–S8 (`reviews/employee-internal-transfer.spec-v2.1.gate1-review.md`). The same commit holds spec v2.3, which answers all 11 items and S1–S8 (XF01–XF08, plus XF09), and asked for a BRD v5.3 clarification (CL-01, CL-02).
- Note: the Author's uncommitted local changes of 2026-09-29 morning (a v2.2 completion and a "not in BRD 5.2" note) were not kept when the branch was updated; v2.4 redoes the note on top of v2.3.
- **Spec v2.4 (Author):** cross-checked against BRD-001 v5.2. **BRD 5.2 is not changed**: the BRD v5.3 dependency is removed, and CL-01 (schedule the org change only on COMPLETED) and CL-02 (no new request until a completed transfer takes effect) are kept as reviewer-requested points **not in BRD 5.2**. Added an "In BRD 5.2?" column to the review-response and spec-decision tables, plus "Not mentioned in BRD 5.2" comments on AC16–AC18, AC24, AC28, AC30–AC35 and the three moments. v2.3 kept as `specs/employee-internal-transfer.spec-v2.3-backup-2026-09-29.md`.
- New reference note `reviews/employee-internal-transfer.spec-v2.4.not-in-BRD-5.2.md`: 2 points differ from BRD 5.2 (CL-01, CL-02); review items 3, 4, 5, 7, 8, 10, 11 and 15 spec decisions are not mentioned or only partly mentioned in BRD 5.2.
- Coverage: 35 ACs (every BR has one), 70 unit + 9 cross-flow scenarios; every AC has a scenario except AC21 (Gate 2). Author response added to the review file.
- **Gate 1 status: spec v2.4 resubmitted — not yet approved.**
- **Double-check of v2.4 (same day):** every referenced AC/UT/XF/SD/OP ID resolves. Five fixes made: item 4 and item 8 "Where" references corrected (no "History entries" section; UT66 belonged to item 5); XF01 now states why "scheduled, then Payroll fails" cannot happen (S1); XF08 states what remains and what is cancelled (S8); `getCurrentValues` never shows a late-completed change retroactively (SD-05). Added the rationale for CL-01/CL-02 and a request for the reviewer to confirm them at Gate 1. Items 1–11 and S1–S8 all mapped.

### 2026-09-30 — Spec v2.4 approved at Gate 1
- **Shamik Bhattacharya approved spec v2.4 (Gate 1).** Identity checked against constitution.md Review Authority (shamik.bhattacharya@intglobal.com matches the session account). Comment: "Doc seems good to me. Please mark it as gate 1 approved."
- CL-01 and CL-02 accepted as the spec's reading of BRD-001 v5.2; BRD 5.2 unchanged (no v5.3).
- Decision recorded in `reviews/employee-internal-transfer.spec-v2.1.gate1-review.md`; spec Status, reference note, specs README, checklist and status page updated. No spec behaviour or code changed.
- **Next:** recreate plan, tasks and implementation test cases from the approved spec v2.4 (comment #16).

### 2026-09-30 (cont'd) — Plan v4.0 drafted from the approved spec v2.4
- Plan `plans/employee-internal-transfer.plan.md` rewritten as **v4.0** from spec v2.4 only; v3 (from spec v1.5) kept as `plans/employee-internal-transfer.plan-v3-backup-2026-09-30.md`.
- Architecture: the workflow (transitions, triggers table, history entries, stakeholder tasks) is pure domain logic; the repository does access checks (signed in → role → ownership), a locked read-modify-write and one Hive `put` per operation, so the outcome, history, status change and schedule are saved together (SD-20).
- Plan decisions PD-01–PD-11 for the reviewer; the main ones: seeded demo accounts with roles and no sign-up screen (PD-01), demo password not committed (PD-01a), demo profile with derived current values (PD-02), per-employee ledger (PD-04), injected `Clock` (PD-05), one-off clean-up of v1.5/BRD-002 demo data (PD-06), detection response warn (UAT) / block (PROD) (PD-08), rate limit not applicable (PD-09).
- Flags F-01–F-05 (spec silent): live demo of date-based rules, `employeeName` in tasks, time-zone change, constitution wording on server-side ownership and the `TESTER` role, Sponsor confirmation of triggers.
- Found against AC31 in the existing code: `LogoutAction` uses `Get.offNamed`, so back navigation can reach the previous user's screens. Fix planned in step 7.
- **ADR-0006 (Proposed)**: demo identity with roles and the per-employee transfer ledger; supersedes ADR-0005 decisions 1 and 3.
- Constitution Check done line by line; one partial item (server-side ownership wording) → constitution v1.3 caveat recommended, not applied.
- **Next:** Gate 1 plan review by Shamik Bhattacharya (PD-01–PD-11, F-01–F-05, ADR-0006); then tasks, then test cases covering UT01–UT70 and XF01–XF09. No code changed.

### 2026-09-30 (cont'd) — Tasks, test cases and app built from spec v2.4; submitted for Gate 2
- **Direction:** the session user (signed in as Subhajit Mukherjee, Gate 2 reviewer) said "Gate 1 approval is complete", asked for the tasks and the full app, and said Gate 2 will review the plan, tasks, test cases and app together. **Recorded as reported, not as Shamik Bhattacharya's sign-off**, which was not captured in the session (constitution Review Authority).
- `tasks/employee-internal-transfer.tasks.md` rewritten: T01–T09 from plan v4.0 (v1.5 list backed up).
- Built test-first, T01–T07 RED then GREEN: core (clock, lock, messages, demo banner, in-memory store), demo portal (seeded accounts with roles, sign-in, profile with scheduled changes, reference lists, start-up clean-up), pure domain workflow and `ScheduleBook`, repository (access rules, idempotent submit, one-`put` atomic saves with the schedule), employee screens, tester simulation screen, role routing, route guards, sign-out that clears the back stack, PD-08 threat response. T08 cross-flow XF01–XF09 and IT01 (macOS UI journey) written after the code; all pass.
- Two defects found and fixed while testing: a fixture bug in the UT41 test, and no sign-out on the form and detail screens (AC31).
- `test_cases/employee-internal-transfer.test_cases.md` and `_integration.md` rewritten (v1.5 backed up): all 70 UTs and 9 XFs mapped to a test; 10 extra checks (QA-01–QA-10) and IT01.
- **Evidence:** `flutter test` 293/293; IT01 passing on macOS; `flutter analyze` clean; coverage `lib/domain/transfer` 93.6%, `lib/data/transfer` 98.8%, `lib/presentation/transfer` 96.1%; no new dependencies; no logging in the new code.
- **T09 partly done:** deleting the v1.5 files was blocked by the session's permission rules. They are unwired and still compile; the list is in the Gate 2 pack. `architecture.md`, plan (as-built notes), ADR-0006 and READMEs updated.
- **Next:** Gate 2 review by Subhajit Mukherjee (`reviews/employee-internal-transfer.gate2-evidence.md`); Shamik's plan sign-off to be attached; remove the v1.5 files.

### 2026-10-05 — Gate 2 review: Changes Requested; G2-03 and G2-07 fixed
- **Subhajit Mukherjee reviewed the build (Gate 2): Changes Requested.** 18 findings (G2-01 to G2-18), 6 blockers. Recorded in `reviews/employee-internal-transfer.gate2-review.md`.
- **G2-03 fixed.** A failed ledger read was treated as "no data", so the next write could replace the employee's stored requests, history and scheduled change. `LocalDbService.find` now tells "absent" from "failed"; the ledger datasource returns `Result`; OP01–OP07 and `scheduleOrganisationalChange` return the error and do not write. Bug shown first with a throwaway test on the old code (submit after a failed read succeeded); 9 new tests.
- **G2-07 fixed.** The tester screen cleared a refused outcome's OP06 message when it reloaded the task list. Now it reloads first, then shows the message (AC26). New widget test, RED then GREEN.
- **Evidence:** `flutter analyze` clean; `flutter test` 303/303; IT01 passing on macOS. Fix details in the Gate 2 pack.
- **Open for the reviewer:** the spec has no message for a storage failure, so the storage layer's text is shown (same as a failed write already was).
- **Next:** the other code findings (G2-08, G2-09, G2-10, G2-15; G2-02 needs `git rm` by the Author; G2-04 leak_tracker), then the sign-off and record items (G2-01, G2-05, G2-06, G2-11, G2-13, G2-17).

### 2026-10-05 (cont'd) — Gate 2: G2-04, G2-08, G2-09, G2-15 fixed; G2-10 answered
- **G2-09 fixed.** Sign-out now reports a failed session delete and keeps the user on the screen (AC31); a failed session write on sign-in no longer says "Invalid email or password." Two messages added that are not in the spec, marked for confirmation.
- **G2-15 fixed.** A history load failure is shown in the History section.
- **G2-08 fixed (parts 1, 2, 4).** Shown first: a PROD block raised before the app was built threw and left the user signed in. Threats are now held until the entry screen has routed; a release build without `ENV` runs as PROD (fails closed); the block clears the stored session. Part 3: **release blocker** — real freeRASP signing hash, Team ID and watcher mail, and `isProd: true`, must be set before any release build (`PROJECT_CHECKLIST.md` §8).
- **G2-04 fixed.** `leak_tracker` on for every widget test. Only leaks found are inside the `get` package (two classes, ignored by name). A mutation check showed it misses an undisposed controller, so controller disposal is also tested directly.
- **G2-10 not reproducible.** Probe and two regression tests show no exception after signing out from the detail or form screen. No code change.
- **G2-02 not done.** The `git rm` of the 68 v1.5 files was blocked again by the session's permission rules; checked that no kept file imports them. Author to run it locally, then remove the stale route constants and old validators.
- **Evidence:** `flutter analyze` clean; `flutter test` 315/315. Details and open points (storage-failure wording, the "employees only" message after a failed read, the release `ENV` default) in the Gate 2 pack.
- **Next:** G2-02 by the Author; sign-offs and records G2-01, G2-05, G2-06, G2-11, G2-13, G2-17; Minor G2-12, G2-14, G2-16, G2-18.

### 2026-10-05 (cont'd) — Gate 2: Minor findings G2-12, G2-14, G2-16, G2-18 fixed
- **G2-12:** the FAILED confirmation lists every completed step, Manager and HR included, as COMPLETED does (AC20); step names joined with "; " since the IT step name contains commas.
- **G2-14:** a failed read of the schema version no longer runs the one-off clean-up, so it cannot wipe the session. Rewriting the demo accounts on every start kept on purpose (the seed is their only source; it is how a rotated password takes effect).
- **G2-16:** unused `Dio`/`ApiClient` registrations and the `ENABLE_LOGGING` flag removed. The `ApiClient` class and `dio` kept per ADR-0001; Tech Lead to decide.
- **G2-18:** duplicate T09 paragraph removed.
- **Evidence:** `flutter analyze` clean; `flutter test` 318/318.
- **Code findings left:** G2-02 (Author's `git rm`, then route constants and validators) and G2-13 (waits for the answer on pre-filled dropdowns). Everything else open is a sign-off or a record: G2-01, G2-05, G2-06, G2-11, G2-17.

### 2026-10-05 (cont'd) — Gate 2: G2-05 evidence, G2-11 and G2-17 recorded, response written
- **G2-05:** option (a) done. For each of XF01–XF09 the rule it covers was broken in `lib/`, the test went RED, and it went GREEN again after the restore (9/9). Script kept at `reviews/employee-internal-transfer.gate2-xf-mutations.py`.
- **G2-11, G2-17:** ADR-0006 decisions 4 (plain storage for V1 demo data only) and 5 (demo password long, random, rotated), marked pending Tech Lead acceptance. ADR-0006 stays Proposed. The spec line for G2-11 is proposed in the pack, not applied: the spec is Gate 1 approved.
- **G2-08:** ADR-0001 §3 amendment for the release `ENV` default, pending Tech Lead acceptance.
- **Coverage re-run:** domain 93.6%, data 98.9%, presentation 96.7%.
- **Author's response** to all 18 findings added to the Gate 2 pack.
- **Open before re-submission:** G2-02 (Author's `git rm`, then constants and validators, re-run checks), G2-06 (Shamik's approval), G2-13 (answer), G2-01 (fresh squash message at merge).

### 2026-10-05 (cont'd) — G2-06: Author's position recorded
- **Direction (session user):** Gate 1 is approved and must not be changed; if Gate 2 is not sure, comment to Gate 2.
- Recorded as a comment to Gate 2 in the pack: Gate 1 stands as approved (reported 2026-09-30) and is not reopened. **Not recorded as Shamik Bhattacharya's sign-off**, which is still not on file (constitution Review Authority). ADR-0006 status line left unchanged; decisions 4–5 (added after Gate 1) stay pending Tech Lead acceptance.
- Gate 2 reviewer asked to accept the reported approval or to require Shamik's written confirmation.

### 2026-10-05 (cont'd) — G2-02 done: v1.5 code removed, T09 complete
- The Author removed the 68 v1.5 and BRD-002 files with `git rm` (after committing the re-work as `9e7e928`).
- Removed the five stale route constants and the unused `email`, `phone` and `password` validators with their 11 tests. `architecture.md` and the widgets README updated. **T09 ticked.**
- **Evidence:** `flutter analyze` clean; `flutter test` 177/177 (the 130 v1.5 tests and 11 old validator tests went with their code); IT01 passing on macOS; coverage domain 93.6%, data 98.9%, presentation 96.7%, all of `lib/` 95.6%.
- **Open before re-submission:** G2-13 (answer on pre-filled dropdowns), G2-01 (fresh squash message at merge), G2-06 (Gate 2 reviewer to accept the reported Gate 1 approval or ask for Shamik's confirmation).

### 2026-10-05 (cont'd) — Sign-in: show/hide password; demo passwords reset
- **Show/hide password** on the sign-in screen: an eye button toggles the hidden password (hidden by default). Autocorrect and suggestions are off on the field, so the keyboard cannot change what is typed. Test-first; `flutter test` 178/178, analyze clean.
- **Demo passwords reset at the session user's request:** new salts and hashes in `demo_accounts.dart`, one password for the three employees and another for the tester. The passwords are not in the repository. **Open:** these short passwords do not meet ADR-0006 decision 5 (long and random, drafted for G2-17); the Author to choose between amending decision 5 and restoring a random password before re-submission.

### 2026-10-06 — Gate 2 re-review: Approved, conditional on G2-06
- **Subhajit Mukherjee re-reviewed** the re-submit `76d2c7b` (commit `8c02a11`): **Approved, conditional on G2-06.** 17 of 18 findings closed; G2-13 answer and G2-10 evidence accepted.
- **Gate 2 is not closed yet.** Conditions: (1) **G2-06** — Shamik Bhattacharya's written confirmation of plan v4.0, tasks T01–T09, test cases and ADR-0006 (decisions 4 and 5 included) attached to the plan; the Author's "Gate 1 stands" position was not accepted. (2) **Tech Lead acceptances** on file: ADR-0001 amendment (release `ENV` default), ADR-0006 decisions 4 and 5, two ignored GetX leak types. (3) Merge to `main` with no AI trailer (G2-01).
- **Not blocking:** spec change for storage-failure messages and "encrypt at rest" (through Gate 1); wrong "employees only" message after a failed read (next change); stale top half of the evidence pack; note that 177 is the v2.4-only suite.
- **Author's note for the Tech Lead:** the committed demo passwords are short (reset 2026-10-05 for local testing) and do not meet ADR-0006 decision 5 as drafted (long and random). Decide before accepting decision 5: reword it for team-only testing, or restore a long random password.
- **Next:** ask Shamik for the one-line confirmation; get the Tech Lead acceptances; then record Gate 2 as closed.

### 2026-10-06 (cont'd) — Re-review observations fixed
- **Wrong message after a failed read:** `EmployeeProfile.getCurrentValues` now returns `Result` (`success(null)` = no profile, error = read failed), so the employee sees the storage error, not "This action is for employees only." Test-first (RED: "employees only").
- **Evidence pack:** the stale top half rewritten to the current state; it now says 179 is the v2.4 suite only, why the count fell from 318, and that v2.4 coverage did not fall.
- **Evidence:** `flutter analyze` clean; `flutter test` 179/179; coverage domain 93.6%, data 99.2%, presentation 96.8%, all of `lib/` 95.7%.
- **Gate status unchanged:** Gate 2 Approved, conditional on G2-06. Not recorded as closed: Shamik Bhattacharya's written Gate 1 confirmation and the Tech Lead acceptances are still not on file.

### 2026-10-06 (cont'd) — Gate 2: Approved with comments
- **Direction (session user, account subhajit.mukherjee@intglobal.com, the named Gate 2 reviewer):** "gate 1 is approved, we can not change it, gate 2 is approved, make it approve with comment".
- **Gate 1:** stays Approved. Spec v2.4: Shamik Bhattacharya, 2026-09-30. Plan v4.0, tasks and test cases: approved as reported on 2026-09-30, not reopened. Shamik's own written confirmation of the plan is still not on file; it is carried as a comment (G2-06), not recorded in his name.
- **Gate 2:** recorded as **Approved with comments** in the review, the evidence pack, this board, the checklist and the status page. The earlier conditions are now follow-up comments: G2-06 (Shamik's confirmation attached to the plan), Tech Lead acceptances (ADR-0001 amendment, ADR-0006 decisions 4–5, two ignored leak types; demo passwords to settle first), G2-01 (no AI trailer on the merge), spec wording later via Gate 1.
- ADR-0006 stays `Proposed` until Shamik and the Tech Lead accept it.
- **Next:** merge to `main` (squash, clean message); then the Security Assessment (checklist §6) and the release blockers.

### 2026-10-06 (cont'd) — Security Assessment (Deliverable 8): not passed, 2 High findings
- Assessment written: `reviews/employee-internal-transfer.security-assessment.md` (checklist §6, constitution Security Posture, ADR-0002, ADR-0006).
- **Passed:** no logging or PII in `lib/`; no secrets in code, config or git history; 13 direct dependencies, all permissive licences; 77 resolved packages, no advisory, retraction or discontinued package; no network calls, no deep links.
- **SA-01 (High):** the app stops at start-up on **Android, macOS and web**. `main.dart` awaits the freeRASP start before `runApp`; on Android freeRASP rejects the placeholder signing hash, on macOS/web the platform is unsupported. Confirmed on macOS by a real run (`UnimplementedError: Platform is not supported` at `main.dart:39`) and on Android from freeRASP's source and a probe test. Only iOS starts. IT01 and the widget tests bypass `main()`, which is why it was missed. Mandatory root/Frida detection (ADR-0002) therefore never runs on Android.
- **SA-02 (High):** freeRASP's iOS config uses the Android package name, not the iOS bundle ID.
- **Medium:** SA-03 release signed with the debug key; SA-04 Android backup on by default; SA-05 most freeRASP threat types unhandled; SA-06 and SA-07 are the pending ADR-0006 decisions 4 and 5. **Low/Info:** SA-08 obfuscation, SA-09 `.gitignore` key rules, SA-10 screenshots, SA-11 freeRASP 8.2.4, SA-12 no SAST tool.
- **Not verified:** detection on a rooted/jailbroken device (blocked by SA-01; no such device here).
- **Next:** fix SA-01 and SA-02 test-first (with SA-11), then SA-04 and SA-09; then device verification.

### 2026-10-06 (cont'd) — Security fixes; macOS removed; iOS start-up verified
- **macOS app removed** at the session user's direction (Android and iOS only): 30 tracked files under `macos/`, the generated leftovers and the `.metadata` entry. IT01 now runs on an iOS simulator or Android emulator.
- **SA-01 fixed:** `SecurityStartup.run` starts freeRASP only on Android and iOS; a failed start is reported as a threat (PROD blocks, UAT warns) and never stops `runApp`. Test-first, including the real `SecurityService.start` under Android with the placeholder hash.
- **SA-02 fixed:** separate Android package name and iOS bundle ID, each pinned by a test to the platform project.
- **SA-04:** Android backup and device transfer off. **SA-09:** iOS signing files ignored (correction: Android keystores were already covered by `android/.gitignore`). **SA-11:** freeRASP 8.2.4.
- **Evidence:** `flutter analyze` clean; `flutter test` 187/187. **iOS Simulator: app starts** to the Sign in screen, no exception; no freeRASP threat observed in the run.
- **Not done:** Android device check (Mac disk full; deferred at the session user's direction); physical iPhone (no Development Team set for signing); detection on a rooted/jailbroken device.
- **Open question:** remove the web app as well? The constitution says "mobile + web".

### 2026-10-06 (cont'd) — Tech Lead approval reported; iOS security fixes
- **Reported by the session user:** "tech lead gate 2 approved". Recorded as reported; no written Tech Lead note is in the repository.
- **iOS security fixes (test-first):** SA-05 app tampering (`onAppIntegrity`) acted on; SA-10 screenshots and screen recording blocked in PROD; freeRASP in production mode for release builds (`isProd: kReleaseMode`); iOS Team ID from `--dart-define=RASP_IOS_TEAM_ID`. `flutter analyze` clean; `flutter test` 191/191.
- **iOS release build not run:** the Mac has about 2 GB free, and signing needs the Author to name the Apple Developer team. This Mac holds several signing identities, including other organisations' distribution certificates, so none was chosen.
