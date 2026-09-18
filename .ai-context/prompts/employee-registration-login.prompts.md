# AI Prompts: Employee Registration & Login

_Deliverable 7 pattern, mirroring `prompts/employee-internal-transfer.prompts.md`.
The actual prompt used per task, by task ID. Filled in as each task is
implemented, one task at a time._

## employee-registration-login.T01 — Domain layer
**Status:** Merged (2026-09-18)

**Prompt used:**
> Implement employee-registration-login.T01 — must satisfy AC1, AC3, AC6, AC8
> (foundational — delegation only). Test-first: write tests for
> `EmployeeAccount` (entity equality — no password fields, those stay
> data-layer-only per the spec's contract note), and the four usecases
> (`RegisterEmployee`, `LoginEmployee`, `GetCurrentSession`,
> `LogoutEmployee`) against a `mocktail`-mocked `EmployeeAccountRepository`,
> confirm RED, then implement the entities (`EmployeeAccount`,
> `RegisterEmployeeInput`, `LoginInput`), the repository contract, and the
> usecases. Do not implement T02 (Hive datasource/repository/hashing) in
> this pass.

**Outcome:** RED confirmed via `flutter test` (5/5 test files failed to
compile — `EmployeeAccount`, `RegisterEmployeeInput`, `LoginInput`,
`EmployeeAccountRepository`, and all four usecases didn't exist). Implemented
`lib/domain/entities/{employee_account,register_employee_input,
login_input}.dart`, `lib/domain/repositories/employee_account_repository.dart`,
`lib/domain/usecases/{register_employee,login_employee,get_current_session,
logout_employee}.dart`. Final: `flutter test` on the 5 domain test files —
9/9 passing, `flutter analyze lib/domain test/domain` clean on first attempt.

## employee-registration-login.T02 — Data layer (Hive + repository, hashing)
**Status:** Merged (2026-09-18)

**Prompt used:**
> Implement employee-registration-login.T02 — must satisfy AC2–AC8, spec-
> derived UT01–UT10 and QA01–QA07 (`test_cases/employee-registration-
> login.test_cases.md`) — UT11/AC9 stays out of scope until
> `employee-internal-transfer.T07`. Test-first: extend
> `core/utils/validators.dart`'s test with a `password` validator group
> (≥8 chars, ≥1 letter, ≥1 number per the spec's placeholder complexity
> rule); write `EmployeeAccountModel` round-trip tests (including that
> `toEntity()` never carries the password hash/salt); write a full
> `EmployeeAccountRepositoryImpl` suite against a real, temp-directory-backed
> Hive instance (not mocked) covering register/login/getCurrentSession/
> logout. Confirm RED, then implement the `password` validator, the model,
> the `EmployeeAccountLocalDataSource` (raw CRUD only, `employees` + `session`
> boxes), and the repository (email normalization/lowercasing, uniqueness,
> SHA-256+per-account-salt hashing via `crypto`, session read/write/clear).
> Wire the repository and its 4 usecases into `InitialBinding`.

**Outcome:** RED confirmed via `flutter test` (all 3 files failed to compile
— `Validators.password`, `EmployeeAccountModel`,
`EmployeeAccountLocalDataSource`, `EmployeeAccountRepositoryImpl` didn't
exist). Added `crypto: ^3.0.6` to `pubspec.yaml`. Implemented
`lib/data/models/employee_account_model.dart`,
`lib/data/datasources/local/employee_account_local_datasource.dart`,
`lib/data/repositories/employee_account_repository_impl.dart`, and the new
`Validators.password` method. Wired `EmployeeAccountRepository` + 4 usecases
into `InitialBinding`, same pattern as `employee-internal-transfer`. All 32
new tests passed on the first attempt (no bugs caught this task). Final:
full `flutter test` — 124/124 passing, `flutter analyze` clean.

## employee-registration-login.T03 — Presentation: Login + Register screens
**Status:** Merged (2026-09-18)

**Prompt used:**
> Implement employee-registration-login.T03 — must satisfy AC1–AC7 (Login
> and Register screens/controllers). Test-first: write controller unit tests
> for `LoginController` (delegates to `LoginEmployee`, AC6 success, AC7
> generic invalid-credentials error covers both failure cases) and
> `RegisterController` (AC4 field-level validation per empty/malformed
> field, AC3 successful registration, AC5 duplicate email surfaced as a
> submission-level error rather than a field error since uniqueness is the
> repository's concern) against `mocktail`-mocked repositories; then page
> widget tests for both screens (field rendering, validation errors,
> generic login error, successful login/register navigating to the entry
> route via a stubbed named route, and the Login↔Register link
> navigation). Confirm RED, then implement `LoginController`/
> `RegisterController`, `LoginBinding`/`RegisterBinding`, `LoginPage`/
> `RegisterPage` (reusing `ReferenceData` dropdowns for current department/
> location/role), and register `/login`/`/register` routes in
> `AppRoutes`/`AppPages`. On success, both pages route to
> `AppRoutes.placeholder` (`AppEntryPage`) per the plan's Architecture
> Approach — not yet session-aware, that's T04.

**Outcome:** RED confirmed via `flutter test` (all 4 new test files failed
to compile). Implemented the two controllers, two bindings, two pages, and
wired the new routes. One real bug caught before GREEN: the pages'
Login↔Register links initially used `Get.to()` with a directly-constructed
widget instead of `Get.toNamed()` — this bypassed the named-route table
entirely, so the widget tests' stubbed target routes never rendered (2
failures: "tapping the Register link" / "tapping the Log In link"). Fixed
by switching both links to `Get.toNamed(AppRoutes.register)` /
`Get.toNamed(AppRoutes.login)`, which also removed an unnecessary circular
import between `login_page.dart` and `register_page.dart`. Final: `flutter
test` — 143/143 passing (19 new), `flutter analyze` clean.

## employee-registration-login.T04 — Entry-flow integration + Logout
**Status:** Merged (2026-09-18)

**Prompt used:**
> Implement employee-registration-login.T04 — must satisfy AC1 (no session →
> Login on launch) and AC8 (logout returns to Login, account/request data
> untouched). Test-first: update `AppEntryControllerTest` to add a
> `GetCurrentSession` dependency and mock `EmployeeAccountRepository` —
> existing status-vs-submission tests now stub a logged-in session first;
> add two new tests (no session → Login route; session-check itself errors
> → Login route, fail closed). Add a widget test to the status page's test
> asserting that tapping a `logout-button` calls `LogoutEmployee` and
> navigates to the stubbed entry route. Confirm RED, then prepend the
> session check to `AppEntryController.resolveInitialRoute()` and add the
> Logout AppBar action.

**Outcome:** RED confirmed via `flutter test` (`AppEntryControllerTest`
failed to compile on the new constructor parameter; the new Logout widget
test failed to find `logout-button`). Implemented the session-check
prepend in `AppEntryController`, updated `AppEntryBinding` to supply
`GetCurrentSession`, and added the Logout action to
`TransferRequestStatusPage`'s `AppBar`.

**Follow-up (same day):** the user pointed out the submission screen — the
*other* screen a logged-in employee can land on (no active request yet) —
had no logout option, only the status screen did. Wrote an equivalent
Logout test in `transfer_request_submission_page_test.dart` first,
confirmed RED, then extracted the duplicated logout logic into a shared
`LogoutAction` widget (`lib/presentation/widgets/logout_action.dart` — this
folder existed as an empty placeholder since scaffolding) and wired it into
both pages' `AppBar`s, removing the status page's now-redundant inline
`_logout()` helper rather than leaving two copies of the same logic.
Final: full `flutter test` — 147/147 passing, `flutter analyze` clean.

## employee-registration-login.T05 — Integration test
_Not yet implemented._
