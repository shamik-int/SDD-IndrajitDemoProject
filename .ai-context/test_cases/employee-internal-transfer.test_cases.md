# Test Cases: Employee Internal Transfer

## Derived from
- Spec **v2.4** (Gate 1 Approved 2026-09-30): acceptance scenarios UT01–UT70 and XF01–XF09.
- Plan **v4.0** and tasks T01–T09.
- The v1.5 test cases are kept as `employee-internal-transfer.test_cases-v1.5-backup-2026-09-30.md`.

Every UT and XF ID maps to at least one automated test below. IDs appear in
the test names, so `flutter test --plain-name UT37` runs that scenario.
The scenario and expected columns are copied verbatim from the spec.

## Test levels
| Level | Where | Runs on | Notes |
|---|---|---|---|
| Unit | `test/domain/transfer/` | `flutter test` | Pure `TransferWorkflow` and `ScheduleBook`; no storage, no GetX |
| Repository | `test/data/transfer/` | `flutter test` | Real Hive in a temp directory, plain `test()` |
| Widget | `test/presentation/transfer/` | `flutter test` | The real app (routes, bindings, role guards) over the in-memory store, because real Hive I/O does not settle under `testWidgets` |
| Cross-flow | `test/integration/cross_flow_test.dart` | `flutter test` | XF01–XF09 over the real repository, demo portal and real Hive, with an adjustable clock |
| UI journey | `integration_test/transfer_journey_test.dart` (IT01) | `flutter test integration_test -d macos` | Full journey through the real UI and real Hive |

## Single-requirement scenarios (UT)
| ID | AC | Scenario | Expected | Automated test |
|---|---|---|---|---|
| UT01 | AC03 | Submit valid request changing role only | Success; `PENDING_MANAGER_APPROVAL`; 1 `SUBMITTED` entry, actor `EMPLOYEE` | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT02 | AC02, AC03 | Submit | Request snapshot equals profile current values as of today | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive)<br>`test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT03 | AC04 | Submit with `departmentId` missing | Error "Select a department."; no request | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT04 | AC04 | Submit with a location not in the reference list | Field error; no request | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT05 | AC05 | Effective date = today | Error "must be in the future" | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT06 | AC05 | Effective date = yesterday | Same error | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT07 | AC05 | Effective date = tomorrow | Success | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT08 | AC06 | Proposed values equal current values | Error "Change at least one…"; no request | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT09 | AC07 | Submit while a request is in progress | Error "already in progress"; still one request | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive)<br>`test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT10 | AC08 | Submit twice with the same `submissionId` | Same request returned; 1 request, 1 history entry | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive) |
| UT11 | AC10 | Manager approves | `PENDING_HR_ELIGIBILITY`; HR step `PENDING` | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT12 | AC11 | Manager rejects with reason | `REJECTED_BY_MANAGER`; reason stored on step and in history | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT13 | AC25 | Manager rejects with blank reason | Error "A rejection reason is required."; nothing changes | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT14 | AC12 | HR rejects with reason | `REJECTED_BY_HR`; reason stored | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT15 | AC13 | HR approves; department only changed | Org `PENDING`, IT `PENDING`, Payroll and Facilities `NOT_REQUIRED` | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT16 | AC13 | HR approves; location only changed | Org, Payroll, Facilities `PENDING`; IT `NOT_REQUIRED` | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT17 | AC13 | HR approves; role only changed | Org, Payroll, IT `PENDING`; Facilities `NOT_REQUIRED` | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT18 | AC13 | HR approves; all three changed | All four downstream steps `PENDING` | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT19 | AC14 | Outcome recorded on a `NOT_REQUIRED` step | Error "This step is not pending." | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT20 | AC15 | All required steps complete in a different order each run | `COMPLETED` after the last one, whichever step it is | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT21 | AC16 | Request completes; read profile before and on the effective date | Old values before; new values on the date | `test/data/transfer/demo_portal_test.dart` (repository, real Hive)<br>`test/domain/transfer/schedule_book_test.dart` (unit) |
| UT22 | AC17 | Payroll completes, then IT fails; Org and Facilities pending | IT `FAILED`; Org and Facilities `STOPPED`; Payroll stays `COMPLETED`; `FAILED`; nothing scheduled | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT23 | AC17 | Outcome recorded on a `STOPPED` step | Error; nothing changes | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT24 | AC18 | New submission after `REJECTED_BY_MANAGER`, `REJECTED_BY_HR`, `FAILED` (same day), and after `COMPLETED` on its effective date | Accepted in all 4 cases | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive)<br>`test/integration/cross_flow_test.dart` (cross-flow, real Hive) |
| UT25 | AC18, AC26 | Any outcome on a closed request | Error "already closed"; nothing changes | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT26 | AC26 | HR outcome while `PENDING_MANAGER_APPROVAL` | Error "not pending" | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT27 | AC26 | `COMPLETED` outcome on `MANAGER_APPROVAL` | Error "not valid for this step" | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT28 | AC22 | Employee B lists, opens and reads the history of employee A's request | "No request found."; B's list excludes A's request | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive) |
| UT29 | AC27 | No user signed in | Every operation OP01–OP07 returns "Please sign in." | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive) |
| UT30 | AC23 | Full journey to `COMPLETED` (role only changed) | History in order: `SUBMITTED` (EMPLOYEE); manager `STEP_OUTCOME` (MANAGER); `STATUS_CHANGED` (SYSTEM); `STEP_SET` HR (SYSTEM); HR `STEP_OUTCOME` (HR); `STATUS_CHANGED` (SYSTEM); 4× `STEP_SET` (SYSTEM); 3× `STEP_OUTCOME` (owners); `STATUS_CHANGED` (SYSTEM); `CHANGE_SCHEDULED` (SYSTEM) | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT31 | AC23 | Outcome that fails validation | No history entry added | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive)<br>`test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT32 | AC20 | Confirmation content for each of the 4 final outcomes | Matches §7 of BRD-001 and AC20, including the `FAILED` "have not changed" line | `test/presentation/transfer/confirmation_builder_test.dart` (widget) |
| UT33 | AC13 | HR approves; department and location changed | All four downstream steps `PENDING` | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT34 | AC13 | HR approves; department and role changed | Org, Payroll, IT `PENDING`; Facilities `NOT_REQUIRED` | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT35 | AC13 | HR approves; location and role changed | All four downstream steps `PENDING` | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT36 | AC25 | HR rejects with blank reason | Error "A rejection reason is required."; nothing changes | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT37 | AC08 | Widget: tap submit, then tap again while processing | Submit disabled while processing; one request | `test/presentation/transfer/employee_screens_test.dart` (widget) |
| UT38 | AC09 | Widget: open a submitted request | No edit or withdraw action shown | `test/presentation/transfer/employee_screens_test.dart` (widget) |
| UT39 | AC19 | Widget: each of the six steps when `PENDING`; a rejected step | Pending action label matches the Steps table; rejected step shows its reason; states use the defined labels | `test/presentation/transfer/employee_screens_test.dart` (widget) |
| UT40 | AC01 | Widget: open the form; submit without a reason | Lists come from D-03; submission succeeds with no reason | `test/domain/transfer/transfer_workflow_test.dart` (unit)<br>`test/presentation/transfer/employee_screens_test.dart` (widget) |
| UT41 | AC24 | Widget, as `TESTER`: simulation screen for requests in each status | Only pending steps offered, only their valid outcomes; labelled "Demo only" | `test/presentation/transfer/tester_screen_test.dart` (widget) |
| UT42 | AC27 | Widget: open the feature with nobody signed in | Sign-in prompt; no request data shown | `test/presentation/transfer/employee_screens_test.dart` (widget) |
| UT43 | AC28 | Widget: form, request screen, simulation screen | "Demo — test data only" indicator visible on each | `test/presentation/transfer/employee_screens_test.dart` (widget)<br>`test/presentation/transfer/tester_screen_test.dart` (widget) |
| UT44 | AC29 | Each of the six steps becomes `PENDING` | Task payload matches the Stakeholder contract; IT lists provision and remove | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT45 | AC30 | Employee with three requests; another employee with one | Own three, newest first; other employee's not listed | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive)<br>`test/presentation/transfer/employee_screens_test.dart` (widget) |
| UT46 | OP01, OP06 | Reason of 501 characters on submit; rejection reason of 501 characters | "Reason must be 500 characters or fewer."; nothing saved | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT47 | AC05 | Effective date 5 years ahead | Accepted (no maximum, SD-11) | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT48 | AC34 | Request `COMPLETED`, effective date in the future; submit on its effective date | Accepted; snapshot holds the new values (replaces the v2.1 "submit before effective date" scenario) | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive) |
| UT49 | AC17 | Widget: request `FAILED` | No retry, undo or compensation action shown | `test/presentation/transfer/employee_screens_test.dart` (widget) |
| UT50 | AC29 | Second response to a task whose step is no longer pending | "This step is not pending."; request unchanged | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive)<br>`test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT51 | AC24, AC32 | Widget, as `EMPLOYEE`: every transfer screen | No simulation screen, entry point or outcome button shown | `test/presentation/transfer/roles_and_session_test.dart` (widget) |
| UT52 | AC32 | `EMPLOYEE` calls OP06 on their own pending request (manager step) | "Only a demo tester can record stakeholder outcomes."; request and history unchanged | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive) |
| UT53 | AC32 | `EMPLOYEE` calls OP07 | Same error; no task returned | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive) |
| UT54 | AC32 | `TESTER` calls OP01 to OP05 | "This action is for employees only." for each; no request created | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive) |
| UT55 | AC23 | Manager approves | `STEP_OUTCOME` actor `MANAGER` with `simulatedBy` = tester ID; `STATUS_CHANGED` actor `SYSTEM`; `STEP_SET` HR `PENDING` actor `SYSTEM` | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT56 | AC23 | HR approves, department only changed | Four `STEP_SET` entries, actor `SYSTEM`: Org and IT `PENDING`, Payroll and Facilities `NOT_REQUIRED` | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT57 | AC23, AC17 | Facilities fails with Org and Payroll pending | `STEP_SET` → `STOPPED` for Org and Payroll, actor `SYSTEM`; `STATUS_CHANGED` → `FAILED`, actor `SYSTEM` | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT58 | AC16 | Org record completed first; Payroll and IT still pending | `pendingScheduledChange` is `null`; profile unchanged; no `CHANGE_SCHEDULED` entry | `test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT59 | AC16, AC35 | Last pending step completes | Exactly one scheduled change with the proposed values and `effectiveFrom` = effective date; one `CHANGE_SCHEDULED` entry (SYSTEM) | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive)<br>`test/domain/transfer/transfer_workflow_test.dart` (unit) |
| UT60 | AC35 | `scheduleOrganisationalChange` called twice, same `requestId` and values | Second call returns the existing change (same `scheduledAt`); one change exists | `test/data/transfer/demo_portal_test.dart` (repository, real Hive)<br>`test/domain/transfer/schedule_book_test.dart` (unit) |
| UT61 | AC35 | Same `requestId`, different values | Error "A different change is already scheduled for this request."; original kept | `test/data/transfer/demo_portal_test.dart` (repository, real Hive)<br>`test/domain/transfer/schedule_book_test.dart` (unit) |
| UT62 | AC35 | Another `requestId` while the employee has a change not yet in effect | Error "Another transfer is already scheduled for this employee."; nothing scheduled | `test/data/transfer/demo_portal_test.dart` (repository, real Hive)<br>`test/domain/transfer/schedule_book_test.dart` (unit) |
| UT63 | AC35 | Schedule call returns an error when the last step completes | OP06 returns the error; step stays `PENDING`; status stays `IN_PROGRESS`; no history entry added | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive) |
| UT64 | AC34 | Request `COMPLETED`, effective date 15 Oct; on 1 Oct open form and submit | Form shows, and OP01 returns, "Your previous transfer takes effect on 15 Oct 2026…"; no request | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive)<br>`test/presentation/transfer/employee_screens_test.dart` (widget) |
| UT65 | AC33 | Effective date reached while `PENDING_HR_ELIGIBILITY` | Status and effective date unchanged; "effective date passed" note shown; task marked; HR can approve or reject | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive)<br>`test/presentation/transfer/employee_screens_test.dart` (widget)<br>`test/presentation/transfer/tester_screen_test.dart` (widget) |
| UT66 | AC33 | Request completes after its effective date | Scheduled with the original `effectiveFrom`; profile shows new values today; confirmation shows the "date had passed" line | `test/presentation/transfer/employee_screens_test.dart` (widget) |
| UT67 | AC31 | A signs in and opens a request; signs out; B signs in | B sees only B's data on every screen and after back navigation; OP04/OP05 with A's ID → "No request found." | `test/presentation/transfer/roles_and_session_test.dart` (widget) |
| UT68 | AC31 | A signs out; operations called before anyone signs in | Every operation returns "Please sign in."; no A data shown | `test/presentation/transfer/roles_and_session_test.dart` (widget) |
| UT69 | AC20, AC17 | Widget: `FAILED` after Org record completed | Confirmation lists Org as completed (not undone) and says "Your department, location and role have not changed." | `test/presentation/transfer/employee_screens_test.dart` (widget) |
| UT70 | OP07 | `TESTER` lists open tasks with requests from two employees | Only `PENDING` steps' tasks, oldest first, each with contract content only | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive) |

## Cross-flow scenarios (XF)
| ID | Scenario | Automated test |
|---|---|---|
| XF01 | Org record recorded, then Payroll fails | `test/integration/cross_flow_test.dart` (cross-flow, real Hive) |
| XF02 | Scheduled transfer, then a second request | `test/integration/cross_flow_test.dart` (cross-flow, real Hive) |
| XF03 | Employee tries to use the simulation | `test/integration/cross_flow_test.dart` (cross-flow, real Hive) |
| XF04 | Manager approves; audit actors | `test/domain/transfer/transfer_workflow_test.dart` (unit)<br>`test/integration/cross_flow_test.dart` (cross-flow, real Hive) |
| XF05 | Effective date passes while HR is pending | `test/integration/cross_flow_test.dart` (cross-flow, real Hive) |
| XF06 | Same organisational change triggered twice | `test/data/transfer/transfer_request_repository_impl_test.dart` (repository, real Hive)<br>`test/integration/cross_flow_test.dart` (cross-flow, real Hive) |
| XF07 | Employee A signs out, employee B signs in | `test/integration/cross_flow_test.dart` (cross-flow, real Hive) |
| XF08 | One downstream step fails after the others completed | `test/integration/cross_flow_test.dart` (cross-flow, real Hive) |
| XF09 | Future date, downstream failure, then a new request | `test/integration/cross_flow_test.dart` (cross-flow, real Hive) |

## Added by the implementation (not spec IDs)
| ID | Covers | Test |
|---|---|---|
| IT01 | Full journey through the UI: submit → tester records all outcomes → COMPLETED confirmation | `integration_test/transfer_journey_test.dart` |
| QA-01 | History is append-only: earlier entries never change (AC23) | `data/transfer/transfer_request_repository_impl_test` |
| QA-02 | OP01 idempotency is checked before every error (AC08) | `data/transfer/transfer_request_repository_impl_test` |
| QA-03 | Performance: operations on a 20-request ledger finish under 500 ms (NFR) | `data/transfer/transfer_request_repository_impl_test` |
| QA-04 | Seeded accounts hold only hash and salt (PD-01a) | `data/transfer/demo_portal_test` |
| QA-05 | Start-up clean-up of v1.5 and BRD-002 data (PD-06) | `data/transfer/demo_portal_test` |
| QA-06 | Start-up routing by role (PD-07) | `presentation/transfer/roles_and_session_test` |
| QA-07 | Threat response: warn in UAT, block in PROD (PD-08) | `presentation/transfer/roles_and_session_test` |
| QA-08 | A tester is refused on employee routes; an employee on the tester route (AC24, AC32) | `presentation/transfer/roles_and_session_test` |
| QA-09 | `SD-05`: a late-completed change never shows retroactively | `domain/transfer/schedule_book_test` |
| QA-10 | Ledger model round trip | `data/transfer/transfer_ledger_model_test` |

## Not automated
- **AC21** (no email, push, SLA timer, reminder or escalation): no runtime
  behaviour, per the spec. Checked at Gate 2 by confirming that the feature
  contains no notification, timer or scheduling code.

## Test-first note
T01–T07: tests were written first and run RED (they failed to compile), then
the code was written and the tests turned GREEN. The cross-flow XF tests (T08),
the usecase delegation test and the ledger round-trip test were written after
the code they exercise and passed on first run. They verify the behaviour; they
did not drive it.

## Last run (2026-09-30)
- `flutter test`: **all passing** (includes the v1.5 tests still on disk until
  their files are removed; see T09).
- `flutter test integration_test/transfer_journey_test.dart -d macos`: IT01 passing.
- `flutter analyze`: no issues.
- Line coverage: `lib/domain/transfer` 93.6%, `lib/data/transfer` 98.8%,
  `lib/presentation/transfer` 96.1% (constitution floor 80%).
