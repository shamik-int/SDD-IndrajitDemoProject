# Project Completion Checklist — One-Point Employee Portal (Flutter)

_Working checklist for what's left. This is not a replacement for
`.ai-context/status.md` (the SDD source of truth for artefact state) or
`.ai-context/prompt_history.md` (the audit trail) — check things off here as you
go, but keep those two updated same-day per `AGENT.md`._

---

## 0. Already done (kickoff)
- [x] `.agent/` and `.ai-context/` workspace scaffolded
- [x] `constitution.md` v1.0 authored
- [x] `BRD-001` captured in `.ai-context/BRD.md`
- [x] `AGENT.md` gateway file authored
- [x] Client architecture decided — `ADR-0001` (Clean Architecture + GetX + local-first) and `ADR-0002` (root/jailbreak/Frida detection + memory hygiene)
- [x] `architecture.md` updated to reflect both ADRs
- [x] Gate 1 reviewer: **Shamik Bhattacharya** (shamik.bhattacharya@intglobal.com); Gate 2 reviewer: **Subhajit Mukherjee** (subhajit.mukherjee@intglobal.com) — reassigned 2026-09-17, only the named person for each gate may approve it (constitution.md Review Authority)
- [x] External review feedback (AGENT.md size, spec count, "Blueprint" token cost) evaluated against the Blueprint and acted on where warranted: `AGENT.md` trimmed of duplicated content (114 → 92 lines); spec's implicit "one spec, not split" call made explicit (v1.3) after confirming `BRD.md` genuinely describes one feature, not several

---

## 1. Flutter Project Scaffolding (build out ADR-0001 / ADR-0002)
_Core scaffolding done and verified (`flutter analyze` clean, `flutter test`
12/12 passing). Remaining items are release-time/config-specific._

- [x] `flutter create --org com.intglobal --project-name employee_transfer_project .` (android/ios/web)
- [x] Add packages: `get`, `flutter_screenutil`, `hive` + `hive_flutter`, `flutter_dotenv`, `dio`, `equatable`, `path_provider`, `intl`, `freerasp`, `mocktail` (dev)
- [x] Declare `assets/env/`, `assets/images/`, `assets/icons/` under `pubspec.yaml` → `flutter: assets:`
- [x] Download real Lato `.ttf` weights into `assets/fonts/` (Regular, Light, Bold, Italic — from the Google Fonts repo, verified as valid TrueType data) and uncommented the `fonts:` block in `pubspec.yaml`
- [x] Create the `lib/` tree exactly per `ADR-0001`:
  - [x] `lib/app/` — `app.dart`, `routes/`, `bindings/`, `shell/` (temporary boot screen)
  - [x] `lib/core/constants/`, `utils/`, `theme/`, `responsive/`, `security/`, `network/`, `local_db/`, `result/`
  - [x] `lib/data/models/`, `datasources/remote/`, `datasources/local/`, `repositories/` (README placeholders — feature code waits for Tasks stage)
  - [x] `lib/domain/entities/`, `repositories/`, `usecases/` (README placeholders)
  - [x] `lib/presentation/controllers/`, `bindings/`, `pages/`, `widgets/` (README placeholders)
- [x] `main.dart`: `GetMaterialApp` root, env selection via `--dart-define=ENV=uat|prod`, `ScreenUtilInit` wrapper, `LocalDbService.init()`, `SecurityService.start()` all wired
- [x] `core/result/Result<T>` + `Status{success,error,inProgress}` implemented (`lib/core/result/`)
- [x] `core/network/ApiClient` skeleton — `dio`-based, returns `Result<T>`, maps `DioException` to user-safe messages (no raw payloads logged)
- [x] `core/local_db/LocalDbService` skeleton — Hive-based, returns `Result<T>`
- [x] `core/theme/` — light + dark `ThemeData`, color tokens from ADR-0001's palette table, `Lato` text theme (real font files now in place)
- [x] `core/responsive/ResponsiveUtil` — `isTablet()` breakpoint helper (shortestSide ≥ 600)
- [x] `core/utils/common_utils.dart` — toast (`Get.snackbar`), loader (`Get.dialog`)
- [x] `core/utils/validators.dart` — email, phone, mandatory-field validators (unit-tested, 8/8 passing)
- [x] `core/constants/` — `app_strings.dart`, `app_version.dart`
- [x] `core/security/security_service.dart` — `freerasp`/Talsec wired for root (`onPrivilegedAccess`), Frida/hooks (`onHooks`), debugger (`onDebug`), emulator (`onSimulator`); **TODO before any release build:** real Android signing-cert hash, iOS Team ID, and `watcherMail` — currently placeholder values, `isProd: false`
- [ ] Android product flavors / iOS schemes for UAT vs PROD (currently `--dart-define=ENV=` only, no native flavor split yet — fine for now, revisit if the Plan stage wants separate installable UAT/PROD builds side-by-side on one device)
- [x] `flutter pub get`, `flutter analyze` (no issues), `flutter test` (12/12 passing) all clean

---

## 2. Discovery & Specification — Deliverables 1–3 (Milestone 1)
- [x] Deliverable 1 — `.ai-context/discovery/employee-internal-transfer.discovery.md`: business objective, primary users, journey stages, business rules, known decisions, open questions, assumptions, dependencies, out-of-scope, business-vs-technical decisions
- [x] Deliverable 2 — `.ai-context/specs/employee-internal-transfer.spec.md`: Intent, Context, **Scope Decision** (v1.3 — why this is one spec, not split, added per external review), **Local Data Contract** (4 local operations — revised from a REST API Contract at v1.2, ADR-0004: no backend), 14 individually-IDed ACs (added AC14 for the Simulate Decision control), Explicitly Out of Scope, Non-Functional Constraints. Status: **Approved (v1.3)**
- [x] Deliverable 3 — `.ai-context/test_cases/employee-internal-transfer.test_cases.md`: 14 spec-derived rows + 12 QA-added edge/negative cases (revised at v1.2 — 4 HTTP/session-based rows dropped as not applicable to a local, backend-less app)

## 3. Gate 1 — Spec Peer Review (Milestone 2)
- [x] Self-review pass performed against the Gate 1 checklist (`.ai-context/reviews/employee-internal-transfer.gate1-review.md`) — 5 findings: 2 blocking (fixed, spec → v1.1), 1 testability gap (fixed), 1 QA-completeness gap (fixed in test_cases), 1 accepted-as-flagged v1 scope decision
- [x] Outcome recorded as **Approved (v1.1, since revised to v1.4)** — ratified by Author (Indrajit Bhandari) in lieu of an independent Gate 1 sign-off, by explicit instruction 2026-09-15. **Not** an independent peer review — logged as such in the spec's own Status field, not hidden. Subhajit Mukherjee was the assigned Gate 1 reviewer at that time (now reassigned to Gate 2); **recommend Shamik Bhattacharya performs the real Gate 1 review** before production release.
- [x] Deliverable 9 evidence = `.ai-context/reviews/employee-internal-transfer.gate1-review.md` + the Author-ratification note in the spec's Status field
- [ ] **Real Gate 1 review by Shamik Bhattacharya** (the current named reviewer, reassigned 2026-09-17) — review points recorded 2026-09-18 in `.ai-context/reviews/employee-internal-transfer.gate1-review.md`; 30 P0 decisions remain open, so the gate is not approved

## 4. Plan & Tasks — Deliverables 4–7 (Milestone 3)
- [x] Deliverable 4 — `.ai-context/plans/employee-internal-transfer.plan.md`: Architecture Approach, Data Model, Constitution Check, Explicitly Deferred, Sequencing (revised to **4 steps**, all Flutter-only — the original 8-step version had 4 backend steps that no longer exist)
- [x] Backend decision corrected: **no backend** — Hive local DB is the system of record, **ADR-0004** (supersedes ADR-0003's wrong Node.js/NestJS/PostgreSQL assumption, kept on disk marked Superseded)
- [x] Plan checked line-by-line against `constitution.md` (Constitution Check section, all items addressed; 5 constitution.md lines got explicit ADR-0004 caveats rather than being silently contradicted)
- [x] Deliverable 5 — `.ai-context/tasks/employee-internal-transfer.tasks.md`: 6 tasks (T01–T06), ordered, independently verifiable, each mapped to AC ID(s)
- [x] Deliverable 7 (scaffolded) — `.ai-context/prompts/employee-internal-transfer.prompts.md` created with one section per task ID; filled in as each task is actually implemented (not yet — no task implemented)

## 5. Test-First Implementation (Milestone 4)
_Per task, in order — do not batch multiple tasks into one prompt/session._
- [x] T01 (domain layer) — RED confirmed, then GREEN (30/30 tests passing, `flutter analyze` clean)
- [x] T02 (data layer — Hive + repository/state machine) — RED confirmed, then GREEN (55/55 tests passing, `flutter analyze` clean); repository + usecases wired into `InitialBinding`
- [x] T03 (submission screen) — RED confirmed, then GREEN (67/67 tests passing, `flutter analyze` clean); route registered, placeholder `ReferenceData` added for department/location/role selection
- [x] T04 (status screen + real entry logic) — RED confirmed, then GREEN (84/84 tests passing, `flutter analyze` clean); `AppShellPlaceholderPage` retired in favor of `AppEntryPage`'s status-vs-submission decision
- [x] T05 (Simulate Decision control) — RED confirmed, then GREEN (91/91 tests passing, `flutter analyze` clean); full journey now click-through-able in the running app
- [x] T06 (integration test) — real `integration_test` on macOS desktop, not `flutter test`/`testWidgets` (real Hive I/O needed); **caught and fixed a real bug**: both status→submission navigation calls (T04) were missing their controller binding. 3/3 integration tests + 91/91 unit/widget tests passing, `flutter analyze` clean
- [x] `status.md` and `prompt_history.md` updated same day for T01 — keep doing this per task, not just at the end

### Functional coverage (from BRD-001 / scope document)
- [ ] Employee selects proposed department/business unit
- [ ] Employee selects proposed location
- [ ] Employee selects proposed role/job position
- [ ] Employee provides effective date (with validation)
- [ ] Employee provides optional reason
- [ ] Employee submits request
- [x] Employee views current overall status (T04)
- [x] Employee views which stakeholder(s) hold the pending action (T04)
- [x] Manager approval → HR validation → Payroll/IT/Facilities steps → confirmation, all driven by the in-app **Simulate Decision control** (AC14, T05) — there is no real orchestration, per ADR-0004

### Testing coverage
- [ ] Unit tests for every GetX controller (`Get.testMode = true` in setup)
- [ ] Widget tests per screen — happy path + at least one error/empty state
- [ ] `validators.dart` unit tests (email, phone, mandatory fields)
- [ ] `LocalDbService` tests — success/error/inProgress paths (load-bearing for this feature now, per ADR-0004 — not a cache)
- [ ] `ApiClient` tests — **not needed for this feature** (no network call exists, ADR-0004); `ApiClient` stays in `core/` for any future feature that does have a backend
- [x] `integration_test`: full submit → simulate-through-Completed journey (3 tests: happy path, manager rejection, HR rejection — real device/desktop, not `flutter test`)
- [ ] Coverage floor met: 80% on org/payroll/approval-touching modules, 60% elsewhere
- [ ] Memory-hygiene pass: `onClose()`/dispose implemented everywhere; `leak_tracker` run clean in debug/profile

## 6. Security Assessment — Deliverable 8
- [ ] No PII in logs at any log level (grep-checked, not just eyeballed)
- [ ] No secrets hardcoded or logged; `assets/env/*.env.*` confirmed secret-free
- [ ] Root/jailbreak/Frida detection verified on a rooted/jailbroken test device or emulator
- [ ] **N/A — no server to authorize against (ADR-0004).** Ownership is inherent to the local, single-employee-per-device data model; this is a scope limitation, not a control to implement.
- [ ] **N/A — no network endpoint to rate-limit (ADR-0004).**
- [ ] Dependencies vetted (`freerasp`, `hive`, `get`, `flutter_screenutil` — maintenance/license check)
- [ ] SAST/dependency scan run and clean (or exceptions signed off)

## 7. Gate 2 — Code Review & Evidence — Deliverables 9–10
- [ ] Reviewer = **Subhajit Mukherjee** — the named Gate 2 reviewer (constitution.md Review Authority); no one else's sign-off closes this gate
- [ ] Every AC verified individually against the diff, by ID
- [ ] Security checklist (Section 6 above) passed
- [ ] `architecture.md` / ADRs updated if the implementation warranted it
- [ ] Tests confirmed written first (RED before GREEN), not retrofitted
- [ ] Standard review — readability, naming, DRY, consistency with `architecture.md`
- [ ] Deliverable 10 — Gate 2 evidence captured (reviewer, findings, resolution)

## 8. Release
- [ ] Spec status flipped to `Ready for Release` in `status.md`
- [ ] Release notes drafted from the spec's intent, not commit messages
- [ ] Spec status flipped to `Released (vX.Y.Z)`
- [ ] `status.md` Active Specs table archived/updated same day

## 9. Definition of Done — final sweep (Blueprint §27)
- [ ] All acceptance criteria verified individually, not "looks reasonable"
- [ ] No AI-attribution anywhere in comments/commits (task-ID references are fine)
- [ ] No secrets/PII/client-confidential data anywhere in spec/plan/tasks/code
- [ ] `test_cases/employee-internal-transfer.test_cases.md` and spec `Status` both current
- [ ] `AGENT.md` "Current state" section still just points at `status.md`, hasn't regrown duplicated content

## 10. New Feature — employee-registration-login (BRD-002)
_Registration/login gate in front of `employee-internal-transfer`, added
2026-09-17. Follows the same Discovery→BRD→ADR→Spec chain as the first
feature; checklist items below only go as far as this feature has actually
progressed — plan/tasks/implementation sections will be added when reached,
not scaffolded empty ahead of time._

- [x] Discovery — `.ai-context/discovery/employee-registration-login.discovery.md`
- [x] `BRD-002` captured in `BRD.md`, including the cross-feature impact on `employee-internal-transfer`
- [x] **ADR-0005** — local-only authentication (hashed passwords, explicitly flagged as weaker than a real password hash; access gate, not server-verified auth)
- [x] Spec — `.ai-context/specs/employee-registration-login.spec.md`: 9 ACs, 4 local operations, Explicitly Out of Scope, Non-Functional Constraints, self-review notes baked into authoring (caught: unsalted hashing in an earlier draft; AC9's dependency on `employee-internal-transfer`'s own future change)
- [x] Spec-derived test cases — `.ai-context/test_cases/employee-registration-login.test_cases.md` (11 spec-derived + 7 QA-added)
- [x] **Gate 1 review by Shamik Bhattacharya** — performed (`.ai-context/reviews/employee-registration-login.gate1-review.md`): 3 findings, 2 blocking (fixed, spec → v1.1), 1 sequencing note for Plan/Tasks. **Identity caveat logged, not hidden:** reviewing session's account metadata indicated a different person's email; proceeded only after explicit self-confirmation, recorded transparently rather than silently accepted or silently blocked.
- [x] Plan — `.ai-context/plans/employee-registration-login.plan.md`: Architecture Approach, Cross-Feature Amendment, Data Model, Constitution Check, Explicitly Deferred, Sequencing (6 steps, self-checked against constitution.md — not separately re-reviewed by Shamik, consistent with how `employee-internal-transfer`'s plan wasn't either)
- [x] Tasks — `.ai-context/tasks/employee-registration-login.tasks.md`: 5 tasks (T01–T05), each mapped to AC ID(s); AC9/UT11 deliberately excluded from T05 pending `employee-internal-transfer.T07`
- [x] T01 (domain layer) — RED confirmed, then GREEN (9/9 tests passing, `flutter analyze` clean)
- [x] T02 (data layer — Hive datasource/repository, hashing, session) — RED confirmed, then GREEN (32/32 new tests passing, 124/124 total, `flutter analyze` clean)
- [x] T03 (presentation — Login + Register screens) — RED confirmed, then GREEN (19/19 new tests passing, 143/143 total, `flutter analyze` clean)
- [x] T04 (entry-flow integration + Logout on both post-login screens, via a shared `LogoutAction` widget) — RED confirmed, then GREEN (147/147 total, `flutter analyze` clean)
- [ ] T05 (integration test) (next)
- [ ] **Cross-feature follow-up on `employee-internal-transfer`**: add `employeeId` back to its data model, scope single-in-flight-request/ownership per employee — filed as that feature's own **T07** per this plan's Cross-Feature Amendment, tracked here so it isn't forgotten once this feature's own tasks are done
