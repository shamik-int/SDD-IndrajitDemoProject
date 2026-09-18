# AI Prompts: Employee Internal Transfer

_Deliverable 7 of the assessment brief. The actual prompt used per task, by
task ID (Blueprint §16 — "prompt by identity, not by description"). Distinct
from `.ai-context/prompt_history.md`, which is the narrative session-level
audit trail; this file is the literal prompt catalog, filled in as each task
is implemented, one task at a time._

## employee-internal-transfer.T01 — Domain layer
**Status:** Merged (2026-09-16)

**Prompt used:**
> Implement employee-internal-transfer.T01 — must satisfy AC1, AC3, AC6, AC14
> (foundational: entity shape, contract, usecase delegation). Test-first:
> write tests for `TransferRequest` (entity, `pendingStakeholders` derivation,
> equality), `TransferRequestStatus.isTerminal`, and all four usecases
> (`SubmitTransferRequest`, `GetActiveTransferRequestStatus`,
> `GetTransferRequestById`, `RecordStakeholderDecision`) against a
> `mocktail`-mocked `TransferRequestRepository`, confirm they fail to compile
> (RED — the domain types don't exist yet), then implement the entities,
> enums (`Stakeholder`, `StakeholderState`, `StakeholderDecision`), the
> repository contract, and the usecases themselves. Do not implement T02
> (Hive datasource/repository) in this pass — T01 only needs a mocked
> repository to prove the usecases delegate correctly.

**Outcome:** RED confirmed first (`flutter test test/domain` → 6/6 files
failed to compile, target files didn't exist). Implemented
`lib/domain/entities/{transfer_request_status,stakeholder,stakeholder_state,
stakeholder_decision,transfer_request,submit_transfer_request_input}.dart`,
`lib/domain/repositories/transfer_request_repository.dart`,
`lib/domain/usecases/{submit_transfer_request,get_active_transfer_request_status,
get_transfer_request_by_id,record_stakeholder_decision}.dart`. One real bug
caught on the first GREEN attempt: `record_stakeholder_decision_test.dart`
used `StakeholderState` without importing it — fixed, re-ran. Final:
`flutter test` 30/30 passing (12 pre-existing infra + 18 new), `flutter
analyze` clean. Removed the now-stale `README.md` placeholders from
`lib/domain/{entities,repositories,usecases}/`.

## employee-internal-transfer.T02 — Data layer (Hive + repository/state machine)
**Status:** Merged (2026-09-16)

**Prompt used:**
> Implement employee-internal-transfer.T02 — must satisfy AC2, AC3, AC4, AC5,
> AC7–AC14. Test-first: write tests for `TransferRequestModel.toMap/fromMap`
> (round-trip) and for `TransferRequestRepositoryImpl` covering UT01–UT14 and
> the QA cases in `test_cases/employee-internal-transfer.test_cases.md`
> (QA01, QA02, QA03, QA05, QA06, QA10, QA11, QA12, QA14, plus two new guard
> tests, QA15/QA16, for state-machine dimensions the original UT list didn't
> isolate). Test against real Hive in a temp directory, not a mock — the
> datasource is thin enough that mocking it would test less than the real
> thing. Confirm RED, then implement the model, the raw-CRUD datasource, and
> the repository (validation, single-in-flight check via an `app_state` box,
> and the full state machine: Manager → HR → parallel Payroll/IT/Facilities
> fan-out → Completed, plus both rejection branches). Add `uuid` for
> client-generated request IDs. Wire the repository and usecases into
> `InitialBinding` so the presentation layer can `Get.find` them directly.

**Outcome:** RED confirmed first (2/2 new test files failed to compile).
Implemented `lib/data/models/transfer_request_model.dart`,
`lib/data/datasources/local/transfer_request_local_datasource.dart`,
`lib/data/repositories/transfer_request_repository_impl.dart`. One design
nuance caught while writing tests, not after: `QA13` ("effectiveDate
missing") can't actually happen at this layer — `SubmitTransferRequestInput
.effectiveDate` is a non-null `DateTime`, so Dart's type system already rules
it out. Reassigned QA13 to T03 (form-level "must select a date" validation)
and noted it in `test_cases/employee-internal-transfer.test_cases.md` rather
than silently dropping it. Two failures on first test run were case-sensitivity
mismatches in test assertions (not implementation bugs) — fixed the
assertions. Final: `flutter test` 55/55 passing (30 pre-existing + 25 new),
`flutter analyze` clean. Removed stale `README.md` placeholders from
`lib/data/{models,datasources/local,repositories}/`.

## employee-internal-transfer.T03 — Presentation: submission screen
**Status:** Merged (2026-09-16)

**Prompt used:**
> Implement employee-internal-transfer.T03 — must satisfy AC1–AC5. Test-first:
> write unit tests for a `TransferRequestSubmissionController`
> (`GetxController`) against a `mocktail`-mocked repository — active-request
> check on init (AC2), field validation (AC4/AC5, including the QA13
> date-required case reassigned from T02), and successful/error submission
> (AC3) — plus widget tests for the page (blocking view, form rendering,
> dropdown interaction, validation-error rendering, successful-submit
> confirmation). Confirm RED, then implement. Department/location/role need
> to be selectable per BRD-001's wording, but there's no backend/reference
> -data source (ADR-0004) — add a small local placeholder reference-data
> list, clearly flagged as a stand-in, not real org data.

**Outcome:** RED confirmed first (controller + page test files both failed
to compile). Implemented `lib/core/constants/reference_data.dart` (flagged
placeholder department/location/role lists),
`lib/presentation/controllers/transfer_request_submission_controller.dart`,
`lib/presentation/pages/transfer_request_submission_page.dart`,
`lib/presentation/bindings/transfer_request_submission_binding.dart`, and
registered a new route (`/transfer-request/submit`) in
`app_routes.dart`/`app_pages.dart` — the app's `initialRoute` stays the
placeholder shell until T04 adds the real entry logic (status vs.
submission). Verified `DropdownButtonFormField`'s `initialValue` vs. `value`
parameter against the actual installed Flutter SDK source (3.47.4 deprecated
`value` after 3.33) rather than guessing. All 12 new tests passed on the
first implementation attempt — no bugs caught this round. Final: `flutter
test` 67/67 passing, `flutter analyze` clean. Removed stale `README.md`
placeholders from `lib/presentation/{controllers,pages,bindings}/`.

## employee-internal-transfer.T04 — Presentation: status screen
**Status:** Merged (2026-09-16)

**Prompt used:**
> Implement employee-internal-transfer.T04 — must satisfy AC6, AC7, AC9–AC13.
> Test-first: write unit tests for a `TransferRequestStatusController`
> (loads the active request on init; `refreshStatus()` re-fetches by id so a
> request that turns terminal — Completed/Rejected — between views is still
> shown, since `getActive()` alone stops returning non-terminal requests) and
> widget tests for the page across representative states (pending-manager,
> pending-downstream full/partial fan-out, completed, rejected-by-manager,
> no-request-at-all). Also implement the "real entry logic" the plan flagged:
> an `AppEntryController`/`AppEntryPage` that decides, once at launch,
> whether to land on the status screen or the submission screen, replacing
> the placeholder shell. Confirm RED, then implement.

**Outcome:** RED confirmed first (3/3 new test files failed to compile).
Implemented `AppEntryController` (+ `AppEntryBinding`, `AppEntryPage`,
replacing `AppShellPlaceholderPage`), `TransferRequestStatusController` (+
`TransferRequestStatusBinding`), `TransferRequestStatusPage`; registered the
new `/transfer-request/status` route. One naming collision caught during
implementation, not after: `GetxController` already declares a `refresh()`
member — renamed mine to `refreshStatus()` to avoid an ambiguous override
rather than silently relying on Dart accepting it. All 17 new tests passed
on the first attempt otherwise. Updated `test/widget_test.dart` again since
the initial route now shows `AppEntryPage`'s loading spinner (not the
submission screen directly) on first frame. Final: `flutter test` 84/84
passing, `flutter analyze` clean.

## employee-internal-transfer.T05 — Presentation: Simulate Decision control
**Status:** Merged (2026-09-16)

**Prompt used:**
> Implement employee-internal-transfer.T05 — must satisfy AC14. Test-first:
> write unit tests for a `SimulateDecisionController` (delegates to
> `RecordStakeholderDecision`, returns the updated request or surfaces an
> error) and extend the status-page widget tests with the Simulate Decision
> control: labeled as test/demo only (never a real feature), Approve/Reject
> buttons for Manager/HR, a single Mark Complete button for downstream
> stakeholders, and hidden entirely when the request is terminal or absent.
> Confirm RED, then implement as a visually distinct section on the status
> screen (not a separate page) — it acts on the same request already being
> viewed there.

**Outcome:** RED confirmed first (2/2 files failed to compile). Implemented
`SimulateDecisionController` and a `_SimulateDecisionSection` widget appended
to `TransferRequestStatusPage`'s body — bordered, orange-flagged, explicit
"TEST/DEMO ONLY" label — wired into `TransferRequestStatusBinding`. After a
successful simulate call, the section calls the status controller's
`refreshStatus()` so the page immediately reflects the new state (next
pending stakeholder, or terminal outcome). All 13 new tests passed on the
first attempt. Final: `flutter test` 91/91 passing, `flutter analyze` clean.

## employee-internal-transfer.T06 — Integration test
**Status:** Merged (2026-09-16)

**Prompt used:**
> Implement employee-internal-transfer.T06 — the full journey (submit →
> simulate manager → simulate HR → simulate downstream, any order →
> Completed) plus both rejection branches, per test_cases/_integration.md.
> Use the real `integration_test` package on a real device/desktop target,
> not `flutter test`/`testWidgets` — real Hive file I/O does not reliably
> resolve within `pumpAndSettle()` under the `flutter_tester` harness in
> this environment (established while fixing `test/widget_test.dart`
> earlier), and this test specifically needs the real Hive-backed repository
> exercised end to end, nothing mocked. Target macOS desktop or another
> device that isn't the user's currently-active debug session, not the
> iPhone 16e simulator already in use.

**Outcome:** Added `integration_test` as a dev dependency and macOS desktop
platform support (`flutter create --platforms=macos .` — additive, doesn't
touch iOS/Android/web). Web was tried first but `integration_test` doesn't
support web targets; macOS desktop worked. **Found and fixed a real,
pre-existing bug this way, not a test-isolation artifact**: both
navigation calls from the status page to the submission page
(`Get.to(() => const TransferRequestSubmissionPage())`, in the "no request"
view and the terminal "submit a new request" button, both from T04) were
missing `binding: TransferRequestSubmissionBinding()` — so
`TransferRequestSubmissionController` was never registered when reached via
either path, only when reached via the named route or a test's manual
`Get.put()`. No unit or widget test had caught this, because every one of
them registers the controller explicitly before pumping the page — none of
them exercised the actual cross-page navigation wiring. Fixed both call
sites via a shared `_goToSubmissionPage()` helper; added the equivalent
`_goToStatusPage()` helper with its binding on the submission page's two
"View Status" buttons (also new — added when writing this test exposed
that there was previously no way to reach the status screen after
submitting, short of restarting the app).
- **Files touched:** `integration_test/employee_internal_transfer_test.dart` (new), `lib/presentation/pages/transfer_request_status_page.dart` (bug fix), `lib/presentation/pages/transfer_request_submission_page.dart` (View Status buttons), `pubspec.yaml` (+integration_test), `macos/` (new platform folder), `.ai-context/tasks/employee-internal-transfer.tasks.md`, `.ai-context/prompts/employee-internal-transfer.prompts.md`, `.ai-context/status.md`, `PROJECT_CHECKLIST.md`
- **Outcome:** All 3 integration tests pass on macOS desktop (`flutter test integration_test/employee_internal_transfer_test.dart -d macos`). Full `flutter test` suite re-verified at 91/91 passing, `flutter analyze` clean, after the fix. Milestone 4's implementation phase (T01–T06) is complete; Gate 2 code review and the Security Assessment are still outstanding.
