# Gate 2 Review — employee-internal-transfer (spec v2.4, plan v4.0, tasks T01–T09)

**Reviewer:** Subhajit Mukherjee (subhajit.mukherjee@intglobal.com), the named Gate 2 reviewer
**Author:** Indrajit Bhandari
**Code reviewed:** commit `e902795` (`lib/`, `test/`, `integration_test/`, `.ai-context/`)
**Checked against:** spec v2.4 (AC01–AC35, OP01–OP07), plan v4.0 (PD-01–PD-11), `constitution.md` v1.2, Blueprint §27 (Definition of Done), §30 (Gate 2 and Security checklists)
**Method:** read the code and artefacts against the spec, the constitution and the Blueprint checklists. I did not re-run `flutter analyze`, `flutter test` or the integration test: the Flutter SDK is not installed on this machine. The results in `employee-internal-transfer.gate2-evidence.md` are the Author's and are not re-verified here.

## Decision: Changes Requested

The domain and data layers match the spec closely. The workflow rules, the access order, the triggers table, the atomic single write and the schedule idempotency are all correct. The findings below are what stops sign-off. Findings **G2-01 to G2-06** block the merge. The rest should be fixed in this PR or recorded as accepted by the people named.

Severity: **Blocker** (blocks Gate 2), **Major** (fix in this PR), **Minor** (fix or record), **Question** (needs an answer).

---

## Summary table

| ID | Severity | File | One line |
|---|---|---|---|
| G2-01 | Blocker | git history | Commit messages carry AI co-author trailers |
| G2-02 | Blocker | `lib/`, `test/`, `integration_test/` (v1.5 files) | T09 not done: two parallel implementations in the tree |
| G2-03 | Blocker | `lib/data/transfer/datasources/transfer_ledger_local_datasource.dart` | A read error is treated as "no data", so a write can wipe the audit history |
| G2-04 | Blocker | `test/` (no `flutter_test_config.dart`) | Constitution requires `leak_tracker` checks; none exist |
| G2-05 | Blocker | `test/domain/...`, `test/integration/cross_flow_test.dart` | XF01–XF09 and two other tests written after the code |
| G2-06 | Blocker | `plans/employee-internal-transfer.plan.md`, `tasks/`, `test_cases/` | Gate 1 sign-off by Shamik Bhattacharya not captured |
| G2-07 | Major | `lib/presentation/transfer/tester/simulation_controller.dart` | A refused outcome's error message is wiped straight away |
| G2-08 | Major | `lib/main.dart`, `lib/core/security/security_service.dart` | PROD "block" may never fire, and the default build is warn-only |
| G2-09 | Major | `lib/data/transfer/portal/demo_auth_service.dart` | Sign-out ignores a failed delete; sign-in write failure gives the wrong message |
| G2-10 | Major | `lib/presentation/transfer/employee/my_requests_page.dart` | Controller lookup after sign-out can throw |
| G2-11 | Major | `lib/core/local_db/local_db_service.dart` | Local data is unencrypted and no decision is recorded |
| G2-12 | Minor | `lib/presentation/transfer/employee/confirmation_builder.dart` | FAILED confirmation omits Manager and HR steps; step names join ambiguously |
| G2-13 | Question | `lib/presentation/transfer/employee/transfer_form_controller.dart` | Proposed dropdowns are pre-filled with the current values |
| G2-14 | Minor | `lib/data/transfer/portal/demo_data_seeder.dart` | A read failure is treated as "first run" |
| G2-15 | Minor | `lib/presentation/transfer/employee/request_detail_controller.dart` | A history load failure is silent |
| G2-16 | Minor | `lib/app/bindings/initial_binding.dart`, `assets/env/.env.uat` | Unused `Dio`/`ApiClient` and an unused `ENABLE_LOGGING` flag |
| G2-17 | Minor | `lib/data/transfer/portal/demo_accounts.dart` | Committed single-round SHA-256 hashes; no sign-in throttle |
| G2-18 | Minor | `tasks/employee-internal-transfer.tasks.md` | T09 paragraph duplicated |

---

## Blockers

### G2-01 — AI attribution in commit messages
**Where:** commits `e3db463`, `03a3182` and `379ef53`. Each ends with a `Co-Authored-By: Claude Opus 5.5 …` trailer. The code in `lib/` and `test/` is clean: a grep for AI names found nothing.
**Rule:** Blueprint principle #4, §14 and the Definition of Done: no AI attribution in comments or commit messages, ever. This is also listed as a Gate 2 checklist item and an anti-pattern (§28, "client-trust and IP-hygiene violation").
**Request:** rewrite the three commit messages before the branch goes anywhere else, or make sure the squash-merge message to `main` is written fresh without any trailer (§14 requires squash-merge). Confirm the IDE or tool setting that adds the trailer is turned off. Task-ID references such as `Implements employee-internal-transfer.T03` are fine and encouraged.

### G2-02 — T09 is not done; two implementations are in the tree
**Where:** `tasks/employee-internal-transfer.tasks.md` (T09 unchecked); the list in `gate2-evidence.md` ("v1.5 files to remove"); `lib/app/routes/app_routes.dart:16-20` (stale constants `placeholder`, `transferRequestSubmit`, `transferRequestStatus`, `login`, `register`).
**Problem:** about 40 v1.5 and BRD-002 source files and their tests are still compiled and tested. Several share class names with the v2.4 code, for example `TransferRequestRepositoryImpl`, `AppEntryController` and `AppEntryPage` each exist twice under different folders. Code that is not wired in still counts toward coverage and the "293/293 passing" figure, and it still contains the BRD-002 register and password-hashing code. A future import with the wrong path would silently pick the wrong one. The plan and spec both say the v1.5 code "must not be treated as meeting" v2.4.
**Request:** the Author deletes the files listed in the evidence file, deletes the stale route constants, and re-runs analyze and the tests. The note says deletion was blocked by the session's permission rules; that needs to be done locally by the Author, since it is a plain `git rm`. T09 is then ticked. The old validators `phone`, `email` and `password` in `lib/core/utils/validators.dart` can go with them if nothing else uses them.

### G2-03 — A read error is treated as "no data"; a later write can overwrite the whole ledger
**Where:** `lib/data/transfer/datasources/transfer_ledger_local_datasource.dart:17` and `:25`.
**Problem:** `LocalDbService.read` returns `Result.error` both for "no record" and for a real failure (box cannot be opened, corrupt data). `get()` maps every error to `null`, and the repository (`transfer_request_repository_impl.dart`, `_ledger()`) turns `null` into `TransferLedger.empty`.
**Failure scenario:** the employee has three requests and a scheduled change. A transient Hive open or read error happens. They submit a new request: `_ledger()` returns an empty ledger, the new request is added to it, and `put` replaces the stored record. Every earlier request, every history entry and the scheduled change are gone. That breaks AC23 ("no entry is ever edited or deleted") and the "append-only" claim in the evidence file, and it is silent. `all()` has the same shape: a failed `readAll` returns `[]`, so OP06 answers "No request found." and OP07 shows no tasks.
**Request:** make the datasource distinguish "absent" from "failed" (for example a `Result` that carries absence separately, or check `box.containsKey`). On a failure, OP01 and OP06 must return an error and not write. Add a test with a `LocalDbService` that fails on read and assert that nothing is written.

### G2-04 — No `leak_tracker` checks
**Where:** `constitution.md`, Testing Discipline: "every controller/stream/animation-controller implements `onClose()`/dispose, and leak checks run via Flutter's `leak_tracker` in debug/profile test runs (see ADR-0002)". There is no `test/flutter_test_config.dart`, no `LeakTesting` call and no leak configuration anywhere in `test/` or `integration_test/`.
**Problem:** the `onClose()`/`dispose()` implementations look right when read (`SignInController`, `TransferFormController`), but the constitution makes the automated check mandatory, and Gate 2 checks code against the constitution (Blueprint §20). The evidence pack does not mention it.
**Request:** enable leak tracking for widget tests (a `flutter_test_config.dart` calling `LeakTesting.enable()`, with the widget tests that create controllers covered), fix whatever it finds, and add the result to the evidence pack. If the Author believes it should be waived, that needs an amendment to the constitution, reviewed like a spec, not a silent skip.

### G2-05 — Tests written after the code
**Where:** `gate2-evidence.md`, process note 3: XF01–XF09 (T08), the usecase delegation test and the ledger round-trip test "were written after the code and passed first time". The files are `test/integration/cross_flow_test.dart`, `test/domain/transfer/transfer_usecases_test.dart` and `test/data/transfer/transfer_ledger_model_test.dart`.
**Rule:** principle #3, the Definition of Done and the Gate 2 checklist: tests written first and confirmed Red, then Green. §28 lists "retrofitting tests after implementation" as prohibited because it removes the Red check. The Author disclosed this honestly, which is appreciated, but the rule has no "disclosed" exception.
**Also:** all history is in one squashed commit (`e902795`), so Red-before-Green for T01–T07 cannot be verified from the repository. The evidence is the Author's statement only.
**Request:** either (a) show that these tests can fail: for each of XF01–XF09, break the rule it covers (for example move the schedule call earlier, drop the lock, skip the ownership check) and show the test goes Red, then restore; or (b) record a deviation note signed by the Author and the Tech Lead. I would accept (a) as evidence. The Author should also commit Red and Green separately in future so this can be checked.

### G2-06 — Gate 1 sign-off not captured for the plan, tasks and test cases
**Where:** `status.md` (Plan v4.0 row), `gate2-evidence.md` process notes 1 and 2, `constitution.md` Review Authority.
**Problem:** the constitution says only Shamik Bhattacharya can close Gate 1, and that any other sign-off, including one from the session user, "does not close that gate". The status board records that plan v4.0 was reported complete by someone else, with Shamik's sign-off "not captured". The tasks and test cases never had a Gate 1 pass at all; they were handed straight to Gate 2. PD-01 to PD-11 and ADR-0006 (still `Proposed`) are design decisions that Gate 1 exists to approve before code, and several are security decisions (PD-01a, PD-08, ADR-0006).
**Request:** attach Shamik's written approval of plan v4.0, tasks, test cases and ADR-0006 (status `Accepted`). Gate 2 cannot be recorded as Approved until then. I have no objection to the code review running in parallel, as it has here, but the approval cannot be skipped.

---

## Major

### G2-07 — A refused outcome's error message disappears
**File:** `lib/presentation/transfer/tester/simulation_controller.dart:51` and `:56`.
**Problem:** `record()` sets `error.value` from the OP06 result, then always calls `load()`. `load()` sets `error.value = result.isError ? result.message : null` (line 36), which clears the OP06 error whenever the task list loads fine. So when OP06 refuses an outcome ("This request is already closed.", "This step is not pending.", a schedule error), the tester sees nothing, the list just refreshes. AC26 says the outcome "is refused with the matching OP06 error". The repository does return it; the screen drops it.
**Why tests missed it:** `test/presentation/transfer/tester_screen_test.dart` has no test that asserts an error is visible after a refused outcome.
**Request:** keep the OP06 message after the reload (for example, reload without touching `error`, or reload first and then set it). Add a widget test: a stale task whose step is no longer pending, tap Approve, expect the "This step is not pending." message on screen.

### G2-08 — The PROD "block" response may not run, and a default build is warn-only
**Files:** `lib/main.dart:18`, `:29-34`; `lib/core/security/security_service.dart:39-46`.
**Problems:**
1. `SecurityService.start` runs before `runApp`. If a threat is reported right away, `block` calls `Get.offAllNamed(AppRoutes.blocked)` with no `GetMaterialApp` and no navigator yet, so nothing happens and the user is not blocked. The warn path (`CommonUtils.showToast`) has the same problem. *Plausible; I could not run it on a rooted device. Please verify with a simulated callback before the app has built.*
2. `env` defaults to `'uat'` (`defaultValue: 'uat'`). A release build made without `--dart-define=ENV=prod` gets the warn-only response. The protection fails open. A release-mode check, or a default of `prod`, fails closed.
3. `isProd: false` is hard-coded and the signing hash, Team ID and watcher mail are still `TODO-…` placeholders. The Author lists this as known and the file says do not ship with them. I agree it is not a defect in this PR, but it must be a tracked release blocker, not only a comment. Please add it to the Release Checklist and `status.md`.
4. After a block, the stored session is not cleared, so the next launch on the same device goes straight back to the signed-in screens until the next detection fires.
**Request:** queue the threat until the app is up (or start detection after `runApp`), choose the fail-closed default, and add a test that drives `ThreatResponse` and the routing together.

### G2-09 — Sign-out and sign-in ignore storage failures
**File:** `lib/data/transfer/portal/demo_auth_service.dart:30` and `:36`.
**Problems:**
- `signOut()` ignores the result of `localDb.delete(...)`. `SignOutAction` then clears `SessionState` and goes to the sign-in screen. If the delete failed, the stored `currentUserId` is still there, so the next cold start signs the previous user back in. That breaks AC31 on the failure path, and it fails silently.
- When the session write fails during `signIn`, the user gets "Invalid email or password." (line 30), which is wrong and hides the real problem.
**Request:** make `signOut` return a result and keep the user on a "could not sign out" message if the delete fails; return a distinct message for a failed session write.

### G2-10 — Possible exception after sign-out from a pushed screen
**File:** `lib/presentation/transfer/employee/my_requests_page.dart:14-17`.
**Problem:** `_open` awaits `Get.toNamed(...)` and then calls `controller.load()`. If the employee signs out while on the form or the detail screen, `Get.offAllNamed` removes every route, including the list screen. The pushed route's future then completes, and `controller` (a `Get.find`) is looked up for a controller that was just disposed. That is an unhandled async error after sign-out. *Plausible from reading the GetX route and binding lifecycle; not reproduced.*
**Request:** guard against it (check the controller is still registered, or have the controller refresh itself when the route is resumed). Add a widget test: open a request, sign out, expect no exception.

### G2-11 — Local data is stored unencrypted with no recorded decision
**File:** `lib/core/local_db/local_db_service.dart:18` (`Hive.openBox(boxName)` with no cipher).
**Problem:** the employee's name, current and proposed organisational values, the free-text reason and the full history are stored in plain Hive files. So is the session key `currentUserId`. Anyone with the device storage can read them, or change `currentUserId` to `tst-001` to become the tester. The spec accepts that "anyone with access to the device, its storage or a modified app can bypass" the checks, and the data is test data (BR-25). My concern is the Security checklist item "data-at-rest handling matches constitution.md": the constitution is silent, ADR-0002 is about runtime hardening, and ADR-0006 does not record a data-at-rest decision. In UAT, root detection only warns.
**Request:** record the decision. Either add Hive's `HiveAesCipher` with a key held in the platform keystore, or add a line to ADR-0006 saying plain storage is accepted for V1 demo data only, with the reason, and add "encrypt at rest" to the production prerequisites in the spec's Security boundary section.

---

## Minor and questions

### G2-12 — FAILED confirmation and step list formatting
**File:** `lib/presentation/transfer/employee/confirmation_builder.dart:36`, `:52-56`.
- AC20 for `FAILED` says the screen shows "which steps had completed". `where()` is limited to the four downstream steps, so Manager approval and HR eligibility, which are always completed, are never listed. The `COMPLETED` confirmation (line 36) does include them. The two are inconsistent. Include them in both, or state in the spec that FAILED lists downstream steps only.
- `_names` joins step names with `', '`, and the IT step name itself contains commas ("IT access change: provision new access, remove old access"), so a list like "Organisational record update, IT access change: provision new access, remove old access, Payroll update" is hard to read. Use a different separator or one item per line.

### G2-13 — Question: pre-filled proposed values
**File:** `lib/presentation/transfer/employee/transfer_form_controller.dart:75-77`.
The three "proposed" dropdowns start with the employee's **current** department, location and role. AC01 says the employee selects the proposed values, and AC04 describes blocking on a missing department, location or role. With the pre-fill that path can't happen through the UI, and an employee can submit with one field "chosen" only because it was pre-filled. Is the pre-fill intended? If yes, say so in AC01 and add a test for the "change at least one" message; if no, start them empty.

### G2-14 — Seeder treats a read failure as first run
**File:** `lib/data/transfer/portal/demo_data_seeder.dart:20`.
`version.isError` is true both for "never set" and for a failed read. A failed read re-runs the clean-up, which clears the `session` box and signs the user out. It also rewrites all four demo accounts on every start (lines 26-28), so any local change to them is lost. Both are harmless for demo data but easy to tighten, and it is the same read/absent confusion as G2-03.

### G2-15 — History load failure is silent
**File:** `lib/presentation/transfer/employee/request_detail_controller.dart:45`.
If the request loads but the history does not, the screen shows the request and an empty History section with no message (the error is only displayed when the request itself is null). AC23 says the employee can view the history. Show the error in the History section.

### G2-16 — Unused code and flags
- `lib/app/bindings/initial_binding.dart:32-33` registers `Dio` and `ApiClient` as permanent singletons. ADR-0004 says there is no backend and nothing in `lib/` uses them. Remove them, and `dio` from `pubspec.yaml` if it is otherwise unused, or record why they stay.
- `assets/env/.env.uat:8` has `ENABLE_LOGGING=true` but there is no logger anywhere. When one is added, it must follow the constitution (no PII at any level). Remove the flag until then.

### G2-17 — Demo password hashes
**File:** `lib/data/transfer/portal/demo_accounts.dart:53-54`, `:397-434`.
The four accounts' salts and hashes are committed. The hash is a single round of SHA-256, which is fast to guess offline, and there is no attempt throttle on sign-in (PD-09 records "rate limiting: not applicable" because there is no endpoint, which is true for the network but not for the local sign-in). The constitution accepts SHA-256 + salt for this feature and the Author notes it is a demo gate only. Please add two things to ADR-0006: that the demo password must be long and random (since the hashes are public), and that the password is rotated before any build leaves the team.

### G2-18 — Task file duplicate
**File:** `.ai-context/tasks/employee-internal-transfer.tasks.md`, T09 ("Partly done (2026-09-30)" appears twice). Remove one copy.

---

## Things checked and found correct

- **Access rules (spec "Access rules"):** `_employee()` and `_tester()` check signed in, then role, on every OP; OP04/OP05 read only the caller's ledger, so another employee's ID gives "No request found." (`transfer_request_repository_impl.dart`).
- **OP01:** idempotency on `submissionId` before any error; errors 1–7 in the spec's order (`transfer_workflow.dart`, `submit`); a blank reason is stored as none.
- **OP06:** error order, effects table, history entry order and actors match the spec, including `simulatedBy`, `STOPPED` on failure, completed steps not rolled back, and nothing scheduled until the last required step completes.
- **Triggers table** (`triggersFor`) matches all seven rows.
- **Atomicity:** one `put` per operation, serialised by `AsyncLock`; the schedule is saved with the final outcome (SD-20). If scheduling fails, nothing is saved.
- **Schedule rules** (`ScheduleBook`): idempotent per request, one pending change per employee, no retroactive profile values.
- **AC31 / session hygiene:** the repository reads the signed-in user on every call and caches nothing; sign-out removes all routes; feature controllers are bound per route.
- **PII and secrets:** no `print`, `debugPrint` or logger in `lib/`; only hashes and salts are committed; `.env` files hold non-sensitive configuration only (ADR-0001 clarification).
- **Dependencies:** `pubspec.yaml` has no new package for this change.
- **Demo posture:** the "Demo — test data only" banner is on the form, request screens and simulation screen (AC28); the simulation is behind the TESTER guard and the repository check.

## Needed to close

1. G2-01 to G2-06 resolved, with evidence in the evidence pack.
2. G2-07 to G2-11 fixed or explicitly accepted by the named owner (Tech Lead for G2-08 and G2-11).
3. Re-run `flutter analyze`, `flutter test --coverage` and the integration test after T09 and the fixes, and update the evidence pack.
4. Re-submit for Gate 2. I will re-review only the changed files and the findings above.

## Gate 2 decision

| | |
|---|---|
| Decision | First review: ☒ Changes requested. Re-review 2026-10-06: Approved, conditional on G2-06. **Final 2026-10-06: ☒ Approved with comments** |
| Date | 2026-10-05 (first review); 2026-10-06 (re-review and final) |
| Recorded by | Final decision recorded at the direction of the session user (account subhajit.mukherjee@intglobal.com, the named Gate 2 reviewer): "gate 2 is approved, make it approve with comment" |
| Findings | G2-01 to G2-18 above; 17 closed. G2-06 and the items below are carried as comments to follow up, not as conditions |
| Comments | See "Approval comments" below |
| Verification limit | Flutter is not available on the reviewer's machine, so `flutter analyze` and `flutter test` could not be run by the reviewer. Results quoted are the Author's |

---

# Re-review — 2026-10-06

**Code reviewed:** branch `employee-transfer-request` at `76d2c7b` (the Author's re-work `9e7e928` and re-submit `76d2c7b`), against the Author's responses in `gate2-evidence.md`.
**Method:** each finding re-read in the current code, and the test added for it read. As before, the Flutter SDK is not installed on this machine, so I did not re-run `flutter analyze`, `flutter test`, the mutation script or IT01. The figures in the evidence pack (177/177, analyze clean, coverage) are the Author's.

## Result per finding

| ID | Result | What I checked |
|---|---|---|
| G2-01 | **Closed, on one condition** | The three trailers are still in the branch history, but `main` is at `103cf18` and none of them is on it, so a squash-merge with a clean message keeps them out. The merge message must carry no trailer. Re-work commits have none. |
| G2-02 | **Closed** | All v1.5 directories are gone from `lib/`, `test/` and `integration_test/`; `app_routes.dart` has only the seven v2.4 constants; T09 is ticked and its duplicate paragraph removed. |
| G2-03 | **Closed** | `LocalDbService.find` returns success(null) only for an absent record. `TransferLedgerLocalDataSource.get/all` return `Result`; `_ledger()` returns the error, so no write follows a failed read. Tests added for each operation. |
| G2-04 | **Closed, with one note** | `test/flutter_test_config.dart` enables `LeakTesting`. Two `get`-package types are ignored by name; the stated reason is sound and `lib/` creates neither. The Author also found that leak tracking would not catch a missing `dispose()`, and added `controller_dispose_test.dart` to check `onClose()` directly. Tech Lead to accept the two ignores. |
| G2-05 | **Closed** | Option (a) done: the re-runnable `gate2-xf-mutations.py` breaks one rule per XF test; the Author reports 9/9 RED then GREEN. I have not re-run it. The usecase-delegation and ledger round-trip tests are not covered, which is acceptable: each is one call. |
| G2-06 | **Open** | See below. |
| G2-07 | **Closed** | `record()` reloads first, then sets the OP06 message; widget test added. |
| G2-08 | **Closed, with acceptances** | `ThreatResponse` holds threats until `markReady()`, called from `AppEntryPage`; `resolveEnv` makes a release build without `ENV` run as `prod`; `blockDevice()` clears the session and blocks even if that fails; the freeRASP placeholders are a release blocker in `PROJECT_CHECKLIST.md` §8. The `ENV` default change needs the Tech Lead to accept an ADR-0001 amendment. |
| G2-09 | **Closed** | `signOut` returns `Result`; `SignOutAction` keeps the user in place with a message on failure; sign-in has its own message for a failed session write. |
| G2-10 | **Closed on the Author's evidence** | The Author reports the pushed route's future completes while the list controller is still registered, and `load()` returns once closed. Regression tests for the detail and form screens are in `session_failure_test.dart`. I could not reproduce it by reading either, and can't run it here, so I accept this on the tests. |
| G2-11 | **Closed, pending acceptance** | ADR-0006 decision 4 records plain storage as accepted for V1 demo data only. The spec wording is a spec change and goes through Gate 1. |
| G2-12 | **Closed** | FAILED lists all completed steps, Manager and HR included; names joined with "; ". |
| G2-13 | **Closed (answered)** | Pre-fill is intended; the unreachable-in-UI "missing selection" case is still enforced and tested at the repository. Accepted. |
| G2-14 | **Closed** | Only an absent version counts as first run. Rewriting the demo accounts on every start is kept for a stated reason (a rotated password takes effect); accepted. |
| G2-15 | **Closed** | `historyError` shown in the History section; test added. |
| G2-16 | **Closed** | `Dio`/`ApiClient` no longer registered; `ENABLE_LOGGING` removed. The `ApiClient` class and `dio` package stay per ADR-0001; accepted, Tech Lead may remove. |
| G2-17 | **Closed, pending acceptance** | ADR-0006 decision 5. |
| G2-18 | **Closed** | Duplicate removed. |

## Still open

1. **G2-06 (blocker): Gate 1 sign-off for plan v4.0, tasks, test cases and ADR-0006.** The Author's position is that Gate 1 stands because "the session user stated Gate 1 approval is complete". The constitution says the opposite: only Shamik Bhattacharya can close Gate 1, and no other sign-off counts, including from the Gate 2 reviewer. I do not accept that statement as the approval. The Author has offered to ask Shamik for a one-line confirmation, and that is all that is needed: ask for it, attach it to the plan, and this closes. ADR-0006 decisions 4 and 5 were added after Gate 1, so Shamik's confirmation should cover them too, and the ADR status should change from `Proposed` once he and the Tech Lead accept.
2. **Tech Lead acceptances** (named in the Author's response): the ADR-0001 amendment for the release `ENV` default (G2-08), ADR-0006 decisions 4 and 5 (G2-11, G2-17), and the two ignored leak types (G2-04).
3. **Spec wording** for the storage-failure messages and the "encrypt at rest" production prerequisite: a spec change through Gate 1 (PD-10 says messages come from the spec verbatim).

## New observations from the re-work (minor)

- **Wrong message after a failed ledger read.** The Author discloses this: `getMyCurrentValues`, and OP01 internally, turn "unknown values" into "This action is for employees only." Nothing is written, so no data is at risk, but an employee sees a wrong reason. Make `getCurrentValues` return `Result` so the real error shows. Not a blocker; fix in the next change.
- **Stale text in the evidence pack.** The top of `gate2-evidence.md` (the "What to review" state, process notes 1 and 4, the "Evidence" table, "Known limitations", "Files changed", and the "v1.5 files to remove" list) still describes the pre-fix state, while the fix sections below it say the opposite. Update the top half so a reader who stops there is not misled.
- **Test count.** The suite fell from 318 to 177 because the v1.5 tests went with their code. That is expected, but the evidence pack should say that the 177 is the v2.4 suite only, so nobody reads it as lost coverage.

## Recommendation

The code findings are resolved and the fixes are test-first with tests that I read. I would move the decision from Changes Requested to **Approved, conditional on G2-06**: Gate 2 should not be recorded as closed until Shamik's written confirmation is attached and the Tech Lead acceptances above are on file. The decision is recorded as conditional in the decision block above, in `gate2-evidence.md` and in `status.md`. Static analysis and the test run were not possible on the reviewer's machine because Flutter is not available there; these results rest on the Author's run.

## Approval comments (2026-10-06)
Gate 2 is **Approved with comments**. The comments below are follow-ups; they
do not hold the approval.

1. **G2-06:** attach Shamik Bhattacharya's written confirmation of plan v4.0, tasks T01–T09, test cases and ADR-0006 (decisions 4 and 5 included) to the plan, then change ADR-0006 from `Proposed`.
2. **Tech Lead acceptances:** ADR-0001 amendment (release `ENV` default), ADR-0006 decisions 4 and 5, the two ignored GetX leak types. Decide on the demo passwords before accepting decision 5 (they are short; decision 5 says long and random).
3. **G2-01:** squash-merge to `main` with a fresh message and no AI trailer.
4. **Later, through Gate 1:** spec wording for storage-failure messages and "encrypt at rest" as a production prerequisite.
5. **Verification limit:** `flutter analyze`, the tests, the XF mutation script and IT01 were run by the Author, not the reviewer (no Flutter on the reviewer's machine).
