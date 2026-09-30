# Plan: Employee Internal Transfer

## Status
**v4.0 — Gate 1: reported complete; implemented 2026-09-30; submitted for Gate 2.**
Written from the approved spec v2.4. On 2026-09-30 the session user
(signed in as Subhajit Mukherjee, subhajit.mukherjee@intglobal.com) stated
"Gate 1 approval is complete" and directed implementation, with Gate 2 to
review the plan, tasks, test cases and app together. **Shamik Bhattacharya's
own sign-off of this plan was not captured in that session**; the
constitution's Review Authority requires it, so it should be attached to
this file. Tasks: `tasks/employee-internal-transfer.tasks.md`. Test cases:
`test_cases/employee-internal-transfer.test_cases.md`. Gate 2 pack:
`reviews/employee-internal-transfer.gate2-evidence.md`.

| | |
|---|---|
| Author | Indrajit Bhandari |
| Gate 1 reviewer | Shamik Bhattacharya |
| Derived from | `.ai-context/specs/employee-internal-transfer.spec.md` **v2.4, Gate 1 Approved 2026-09-30** |
| Linked BRD | BRD-001 v5.2 (Approved 2026-09-28), unchanged |
| New ADR | `decisions/ADR-0006-v1-demo-identity-and-transfer-ledger.md` (**Proposed**, reviewed with this plan) |
| Previous version | `employee-internal-transfer.plan-v3-backup-2026-09-30.md` (v3, derived from spec v1.5, paused) |

**Why a new plan, not an amendment.** Plan v3 described spec v1.5: five
fixed stakeholders, one `app_state` pointer per device, no roles, no
`SYSTEM` actor, no scheduling. Spec v2.4 changes almost every part of that:
roles, per-employee ownership, conditional downstream steps, the three
moments of the organisational change, atomic saves and a full audit trail.
v4 is written from spec v2.4 alone and reuses v3 only where noted in
"Existing code: keep, change, remove".

## Architecture Approach

### Layers (ADR-0001)
Flutter, Clean Architecture, GetX, every operation returns `Result<T>`. No
backend (ADR-0004). The feature lives in the existing `lib/` tree:

```
lib/
├── core/
│   ├── time/clock.dart                 # Clock: today() as a local date (PD-05)
│   ├── concurrency/async_lock.dart     # serialises read-modify-write (PD-04)
│   └── constants/transfer_messages.dart  # every spec message, verbatim (PD-10)
├── domain/
│   ├── entities/                       # TransferRequest, Step, HistoryEntry, StakeholderTask,
│   │                                   #   ScheduledChange, CurrentUser, EmployeeCurrentValues, ...
│   ├── portal/                         # D-01..D-03 contracts, exactly as the spec's Consumed contract
│   ├── workflow/transfer_workflow.dart # pure state machine + triggers table + history entries
│   ├── workflow/schedule_book.dart     # pure SD-20 schedule rules
│   ├── repositories/transfer_request_repository.dart
│   └── usecases/                       # one per OP01..OP07
├── data/
│   ├── portal/                         # V1 demo adapters for D-01..D-03 (PD-01..PD-03)
│   ├── models/transfer_ledger_model.dart
│   ├── datasources/local/transfer_ledger_local_datasource.dart
│   └── repositories/transfer_request_repository_impl.dart
└── presentation/
    ├── employee/                       # form, my requests, request detail + history
    ├── tester/                         # "Demo only: simulate stakeholder outcome"
    └── widgets/demo_banner.dart        # "Demo — test data only" (AC28)
```

Dependency rule unchanged: `presentation → domain ← data`; `core` depends
on none of them.

_As built: the new code sits in a `transfer/` sub-folder of each layer
(`lib/domain/transfer/…`, `lib/data/transfer/…`, `lib/presentation/transfer/…`),
because the v1.5 files still occupy the plain paths until they are removed
(T09)._

### The workflow is pure domain logic
Plan v3 put the state machine inside the repository. v4 moves it into
`domain/workflow/transfer_workflow.dart` as pure functions with no I/O:

```
submit(currentUser, input, currentValues, activeState, today) → Result<(TransferRequest, [HistoryEntry])>
recordOutcome(request, stepId, outcome, reason, tester, now)  → Result<OutcomeResult>
   OutcomeResult { request', historyEntries[], scheduleIntent? }
triggersFor(currentSnapshot, proposed) → {ORG, PAYROLL, IT, FACILITIES: PENDING | NOT_REQUIRED}
taskFor(step, request, employeeName, now) → StakeholderTask   // payload per Stakeholder contract
```

`recordOutcome` produces exactly the rows of the spec's OP06 Effects table,
in the listed order, with the actors from the "Which actor records which
entry" table (SD-19). Because it is pure, UT11–UT27, UT30, UT44, UT55–UT57
are plain unit tests with no Hive and no GetX. The repository does only
access checks, loading, persistence and the schedule call.

`schedule_book.dart` holds the SD-20 table as a pure function over the
employee's list of scheduled changes: first call, same-values repeat,
different-values repeat, other request while one is awaiting effect. It is
used both by the public D-02 `scheduleOrganisationalChange` (UT60–UT62) and
inside OP06 for the last step (UT59, UT63), so the rule exists once.

### Repository call order (every operation)
1. **Access rules** in the spec's order: signed in → role → ownership
   (`currentUser()` read fresh on every call; nothing cached). A refused call
   returns before any read of request data.
2. Acquire the ledger lock (PD-04).
3. Load the employee's ledger (one Hive read).
4. Run the pure workflow function.
5. For OP06 on the last pending step: apply `ScheduleBook` to the same
   in-memory ledger. An error aborts before anything is written (UT63).
6. Write the whole ledger back with **one** `put` (atomic save, PD-04).
7. Release the lock; return `Result`.

OP02–OP05 and OP07 skip steps 4–6. OP07 is the only operation that reads
every employee's ledger.

### Access rules in code
A single `AccessGuard` in the data layer, called first by every repository
method:

| Method | Requires | Refusal message |
|---|---|---|
| OP01–OP05 | `role == EMPLOYEE`; request `employeeId == currentUser.userId` | "Please sign in." / "This action is for employees only." / "No request found." (SD-04) |
| OP06, OP07 | `role == TESTER` | "Please sign in." / "Only a demo tester can record stakeholder outcomes." |

The UI also hides what a role cannot use (AC24, AC32), but that is
convenience only. The repository check is the enforced one, per the spec's
Non-Functional Constraints. The Security boundary section of the spec
applies unchanged: this is application-level protection, not production
authorization, and no document or demo may describe it otherwise.

### Presentation
| Screen | Who | ACs | Reads / writes |
|---|---|---|---|
| Sign in | nobody signed in | AC27 | D-01 |
| My transfer requests (list) | `EMPLOYEE` | AC30 | OP02, OP03 |
| New transfer request (form) | `EMPLOYEE` | AC01–AC08, AC34 | D-02, D-03, OP02, OP01 |
| Request detail + history + confirmation | `EMPLOYEE` | AC09, AC19, AC20, AC23, AC33 | OP04, OP05, D-02 |
| Demo only: simulate stakeholder outcome | `TESTER` | AC24–AC26, AC29, AC33 | OP07, OP06 |

- Every one of these screens except Sign in shows `DemoBanner` (AC28).
- Tester screens are registered as separate routes behind a `GetMiddleware`
  that redirects a non-`TESTER` to their home. No employee screen contains
  a link, button or menu item to them (UT51).
- The form calls OP02 on open and shows the OP01 error 5 or 6 message
  instead of the form when it applies (AC07, AC34, UT64).
- Submit: the controller generates `submissionId` (UUID v4) once per tap
  and disables the button while the call is in progress (AC08, UT37).
- The detail screen has no edit, withdraw, retry, undo or compensation
  action (AC09, AC17, UT38, UT49), and the history list has no edit or
  delete action (AC23).
- "Effective date passed" (AC33) and "awaiting effect" (AC20, AC34) are
  derived in the controller from `Clock.today()`. They are never stored.
- The confirmation text for each final outcome (AC20, UT32) is built by one
  pure `ConfirmationBuilder`, so its wording is unit-tested without widgets.
- Nothing in the feature sends email or push, or starts a timer, reminder
  or escalation (AC21). There is no code for them. Gate 2 checks this.

### Session and sign-out (AC31)
- Sign-out clears the session, then `Get.offAllNamed(signIn)`. The current
  `LogoutAction` uses `Get.offNamed`, which leaves earlier routes on the
  stack, so back navigation could reach A's screens. That is a defect
  against AC31 and is fixed here.
- No feature controller is `permanent`. Controllers are bound per route,
  so removing all routes disposes them (`onClose`), and their state goes
  with them.
- The repository and the portal adapters hold no per-user state in memory:
  they read `currentUser()` and the ledger on every call. After sign-out,
  every operation returns "Please sign in." (UT68).

## Plan decisions for Gate 1
Details the spec leaves to the Plan ("The Plan decides how D-01 to D-03 are
provided in V1, including how the demo `TESTER` account is seeded"), and
points the constitution requires a decision on. Please confirm or reject
each.

| ID | Decision | Why |
|---|---|---|
| **PD-01** | **D-01 sign-in: seeded demo accounts.** V1 ships a fixed set of demo accounts: three employees and one tester. Each record has `userId`, email, display name, `role` (`EMPLOYEE` or `TESTER`), and password hash + salt. The existing email + password sign-in (SHA-256 + per-account salt, ADR-0005) is reused. **There is no sign-up screen in V1**; the Register screen is removed. | The spec requires that the role "is set in the demo account data and cannot be chosen at sign-in or sign-up". A sign-up form would let anyone create their own profile values and would need a way to stop role choice. BRD-002 is not followed, so there is no requirement for registration. Sign-in features are out of scope (BR-26). |
| **PD-01a** | **Demo password.** The seed stores only the hash and salt. The plaintext demo password is not committed to the repo; the Author gives it to reviewers and testers with the demo instructions. | Constitution v1.2: passwords are never stored or logged in plaintext. A committed seed file with a plaintext password would breach that, even for test accounts. **Alternative for the reviewer:** if a committed demo password is acceptable because the accounts are test data (BR-25), say so and it will be recorded as a constitution caveat. |
| **PD-02** | **D-02 profile: demo baseline + scheduled changes.** Each `EMPLOYEE` demo account carries its baseline current department, location, role and `managerName`. `getCurrentValues(asOf)` starts from the baseline and applies, in `scheduledAt` order, every scheduled change where `asOf` is on or after both `effectiveFrom` and the date of `scheduledAt`. `pendingScheduledChange(asOf)` returns the change with `asOf < effectiveFrom`, if any. A `TESTER` has no profile. | This is the spec's Consumed contract rule, including "never retroactively" (SD-05). Keeping the baseline fixed and deriving the rest means nothing is ever overwritten. |
| **PD-03** | **D-03 reference lists:** the existing static lists in `core/constants/reference_data.dart`, behind a `ReferenceLists` interface (`departments()`, `locations()`, `roles()`). | Demo lists are allowed in V1 (A-03). The interface lets a real source replace them later without touching the feature. |
| **PD-04** | **Storage: one ledger record per employee, one `put` per operation.** A Hive box `transfer_ledgers`, keyed by `employeeId`. Each value holds that employee's requests (with steps, tasks and history) and their scheduled changes. Every state-changing operation reads the ledger, changes it in memory, and writes it back with a single `put`. An in-process `AsyncLock` serialises these read-modify-write cycles. | The spec needs "saved together or not at all" for the outcome, history entries, status change **and** the schedule (Atomic saves, SD-20). Hive has no multi-key transactions, but a single `put` is written as one checksummed frame, and an incomplete frame is discarded when the box is reopened. Putting everything one operation touches under one key makes each operation atomic. The lock stops two quick taps from both reading the old ledger (XF06). Demo data per employee is small (a few KB), so rewriting the whole record is well under the 500 ms budget. |
| **PD-05** | **Dates.** A `Clock` in `core/time/` provides `today()` (device local date, time stripped) and `now()`. Every "today", "before" and "on or after" rule uses `today()`. Date-only values (`effectiveDate`, `effectiveFrom`) are stored as `yyyy-MM-dd` strings; timestamps (`submittedAt`, `recordedAt`, `scheduledAt`, `createdAt`) as local ISO-8601. Tests inject a fixed clock. | The spec defines everything by device local date. Storing dates without a time avoids a date moving by a day when the time zone changes. An injected clock is the only way to test UT05–UT07, UT21, UT48, UT64–UT66 and XF01–XF09 reliably. |
| **PD-06** | **Old demo data is cleared once.** A small `app_meta` box holds `schemaVersion`. At start-up, if it is below 2, the v1.5 boxes (`transfer_requests`, `app_state`) and the BRD-002 boxes (`employees`, `session`) are deleted, the demo accounts are seeded, and `schemaVersion` is set to 2. | All existing data is test data (BR-25) in a shape spec v2.4 cannot read. Migrating it would add code that serves no requirement. |
| **PD-07** | **Start-up routing by role.** Nobody signed in → Sign in. `EMPLOYEE` → My transfer requests. `TESTER` → the simulation screen. | Each role lands on the only screens it can use (AC24, AC27, AC32). |
| **PD-08** | **Root/jailbreak/hook detection response** (constitution: a Plan-stage decision for this feature). **UAT build: warn** (the current toast). **PROD build: block**, with a full-screen message and no access to the app. | Testers need UAT on emulators and debug builds, which the detector flags. V1 has no production release, but the PROD flavour should already behave as production must. Real freeRASP configuration (signing hash, Team ID) is still open before any release build (`PROJECT_CHECKLIST.md` §1). |
| **PD-09** | **Rate limiting: not applicable.** | There is no network endpoint (ADR-0004). The constitution requires the decision to be recorded, even when it is "none". |
| **PD-10** | **Messages.** Every user-facing message in the spec is a constant in `core/constants/transfer_messages.dart`, copied verbatim. Dates in messages use `d MMM yyyy` (e.g. "15 Oct 2026", as in UT64). | Tests assert exact text. One source stops wording drifting between repository, screens and tests. |
| **PD-11** | **Ordering.** OP03: `submittedAt` descending. OP05: `sequence` ascending (sequence is per request, starting at 1). OP07: task `createdAt` ascending, ties broken by the Steps table order. | The spec gives the direction; the tie-break makes tests deterministic. |

## Data Model
All local Hive (ADR-0001, ADR-0004), plain `Map`/`List` values, no
TypeAdapters (same approach as the existing models).

### `demo_accounts` (replaces `employees`), keyed by `userId`
_As built: keyed by `userId` (profile and ownership look-ups are by ID);
sign-in finds the account by normalised email._
```
{ userId, email, displayName, role: EMPLOYEE | TESTER,
  passwordHash, passwordSalt,
  baseline?: { departmentId, locationId, roleId, managerName } }   // EMPLOYEE only
```
Seeded by PD-06. `passwordHash`/`passwordSalt` never leave the data layer.

### `session` (kept), single key `currentUserId`
Set on sign-in, deleted on sign-out. `currentUser()` returns `null` when
missing or when it points at no account.

### `transfer_ledgers`, keyed by `employeeId`
```
TransferLedger {
  employeeId,
  scheduledChanges: [ ScheduledChange { requestId, employeeId, departmentId,
                      locationId, roleId, effectiveFrom, scheduledAt } ],
  requests: [ TransferRequest {
    requestId, employeeId, submissionId,
    current:  { departmentId, locationId, roleId, managerName },   // snapshot, BR-03
    proposed: { departmentId, locationId, roleId },
    effectiveDate, reason?, submittedAt, status,
    steps: [ Step { stepId, stakeholder, state, decision?, reason?, recordedAt?,
                    task?: StakeholderTask { taskId, requestId, stepId, stakeholder,
                                             employeeId, employeeName, effectiveDate,
                                             payload, createdAt } } ],
    history: [ HistoryEntry { sequence, recordedAt, actor, type, stepId?, outcome?,
                              reason?, toState?, fromStatus?, toStatus?,
                              effectiveFrom?, simulatedBy? } ]
  } ]
}
```
- Shapes match the spec's Data shapes one to one. The only addition is
  that history is stored inside its request, so the request and its history
  are always saved together.
- `steps` holds only steps that have been reached (SD-01).
- A task is created and frozen when its step becomes `PENDING` (SD-15,
  AC29). `employeeName` comes from the demo account's `displayName`.
- **Append-only history:** the repository has no method that edits or
  removes a history entry. The only change ever made to `history` is
  adding entries at the end. A unit test checks that every OP06 result
  keeps every earlier entry unchanged, in the same order.
- **Derived, never stored:** "in progress" (status not final), "awaiting
  effect", "effective date passed", and step labels.
- **Idempotency:** OP01 looks up `submissionId` in this employee's requests
  before any validation (BR-08). Schedule idempotency is by `requestId`
  (SD-20).

### `app_meta`, single key `schemaVersion` (PD-06)

### Boxes removed
`transfer_requests`, `app_state` (v1.5), `employees` (BRD-002). Their data
is deleted once by PD-06.

## Existing code: keep, change, remove
The existing code implements spec v1.5 and must not be treated as meeting
spec v2.4.

| Area | Decision |
|---|---|
| `core/` (Result, LocalDbService, validators, theme, responsive, security) | **Keep.** Add `time/`, `concurrency/`, `transfer_messages.dart`. `main.dart` gets the PD-08 response and the PD-06 start-up step |
| Sign-in (`EmployeeAccount*`, `LoginPage`, `LoginController`, hashing) | **Change:** becomes the D-01 demo adapter. Add `userId` and `role`; key the session by `userId`; seed the accounts |
| Register (page, controller, binding, `RegisterEmployee`) | **Remove** (PD-01) |
| Transfer domain (entities, enums, 4 usecases), data (model, datasource, repository), presentation (submission, status, simulate controllers and pages), `integration_test/employee_internal_transfer_test.dart` | **Replace** with the v2.4 design. Their tests are replaced in the same task, not left failing |
| `AppEntryController` | **Change:** routes by role (PD-07) |
| `LogoutAction` | **Change:** `Get.offAllNamed`, see Session and sign-out |

## Constitution Check
Line by line against `.ai-context/constitution.md` v1.2.

**Review Authority**
- [x] This plan is reviewed at Gate 1 by Shamik Bhattacharya only; code by
      Subhajit Mukherjee at Gate 2 only.

**Testing Discipline**
- [x] Test-first for every GetX controller method and every state-changing
      operation: every task in Sequencing starts with failing tests (RED),
      then code (GREEN).
- [x] Coverage floor **80%** for this feature's `domain/`, `data/` and
      controllers, because they hold approval-decision data. 60% elsewhere.
      Measured with `flutter test --coverage` and reported at Gate 2.
- [x] `flutter_test` + `mocktail`; `Get.testMode = true` in controller
      tests; `integration_test` for the end-to-end journeys (XF01–XF09).
      Real Hive is used in repository and integration tests (T02 in v1.5
      showed that mocking it hides real defects).
- [x] Memory hygiene: every controller implements `onClose()`; no feature
      controller is `permanent`; `leak_tracker` runs in the widget tests
      of the sign-out flow (AC31), where a leak would expose A's data.
- [x] No backend testing line applies (ADR-0004).

**Security Posture**
- [x] **No PII in logs, at any level.** The feature writes no log lines
      containing request content. `reason`, rejection reasons, names,
      department/location/role values and email are never passed to
      `debugPrint`, `print` or any logger. Repository errors return the
      spec's fixed messages; caught exceptions are reported without their
      payload. Gate 2 check: search the feature for logging calls.
- [x] **Rate-limit decision recorded:** not applicable (PD-09).
- [x] Secrets: none. `.env.uat` / `.env.prod` stay non-secret. The demo
      password is not committed (PD-01a).
- [x] Downstream least-privilege accounts: moot, no downstream system
      (ADR-0004).
- [~] **Own-request rule "enforced server-side".** There is no server. The
      rule is enforced in the repository by `employeeId` and role
      (AccessGuard), which is application-level only, as the spec's
      Security boundary says. **Flag:** the constitution line still reads
      "server-side" with an ADR-0004/0005 caveat and does not mention the
      `TESTER` role. Recommend a constitution v1.3 caveat (ADR-0006) saying
      V1 enforcement is application-level and the `TESTER` role is the only
      actor that records outcomes. **Not applied in this pass**; the
      amendment needs the same review as a spec change.
- [x] Root/jailbreak/Frida detection at start-up and resume stays mandatory;
      the response is decided in PD-08.
- [x] Passwords hashed only, never plaintext (PD-01, PD-01a). This remains a
      local access gate, not real authentication, and must not be described
      to business stakeholders as equivalent to it.

**Architectural Constraints**
- [x] Flutter is the only client.
- [x] Clean Architecture + GetX only; no second state-management library.
- [x] Local persistence through `LocalDbService` (Hive) as the system of
      record (ADR-0004). **New boxes** (`demo_accounts`, `transfer_ledgers`,
      `app_meta`) are recorded in **ADR-0006 (Proposed)**, so no box is
      added without an ADR.
- [x] Every mandatory field has a validator in `core/utils/validators.dart`
      and is re-checked in the repository (OP01 errors 1–4, 7), which is the
      only and authoritative boundary (ADR-0004 caveat).
- [x] Orchestrator-not-system-of-record: the ADR-0004 exception still
      applies. The demo profile store (PD-02) is a stand-in for D-02, not a
      shadow copy of a real HR system.
- [x] Async downstream integration: moot, no integration (ADR-0004).

**Non-Functional Baselines**
- [x] Local read/write under 500 ms (spec). One read and at most one write
      per operation (PD-04); OP07 reads every ledger, which is fine at demo
      scale (4 accounts). A timing check on a seeded ledger with 20
      requests is part of the repository tests.
- [x] Availability, RPO/RTO: moot for local-only data (ADR-0004 caveat).
      Data lives on one device and is lost with it. V1 is test data only.

**Versioning Rules**
- [x] No API is consumed by other modules or systems. The D-01..D-03
      interfaces are internal to this app.

## Points the spec does not decide (flagged, not assumed)
| # | Point | What the plan does |
|---|---|---|
| F-01 | **Demonstrating date-based behaviour live.** "Awaiting effect", "effective date passed" and "profile shows new values from the date" depend on the device date. The spec has no in-app date control. | Nothing is added. Tests use an injected clock (PD-05). In a live demo, the tester changes the device date. **Reviewer:** if a tester-only "demo date" control is wanted, it is new behaviour and needs a spec change first. |
| F-02 | **`employeeName` in the task payload** is the demo account's display name. | Test data only (BR-25), never logged. Shown only on the tester screen, as the Stakeholder contract requires. |
| F-03 | **Device time-zone change** between two actions. | Dates are stored without time (PD-05), so a stored date never shifts. "Today" is whatever the device says at the time of the call, as the spec defines. |
| F-04 | **Constitution wording** on server-side ownership enforcement and the `TESTER` role. | Flagged in the Constitution Check; amendment recommended, not applied. |
| F-05 | **Sponsor confirmation of the trigger rules** (A-06) before production. | The triggers table is one pure function (`triggersFor`) with UT15–UT18 and UT33–UT35. Changing a rule later is a one-place change. |

## Explicitly Deferred
- Everything in the spec's Explicitly Out of Scope list, unchanged.
- Production readiness: server-side authentication and authorization, real
  stakeholder integrations, removal of the `TESTER` role and the simulation
  screen (spec Security boundary; SD-13). V1 is a demo.
- A sign-up screen, password reset, lockout or password policy (PD-01;
  BR-26).
- A demo date control (F-01).
- Android/iOS native build-flavour split and real freeRASP configuration
  (`PROJECT_CHECKLIST.md` §1).
- Migrating v1.5 or BRD-002 data (PD-06: test data, cleared once).
- The constitution v1.3 caveat (F-04), pending review.

## Sequencing
Each step becomes one or more tasks in `tasks/employee-internal-transfer.tasks.md`
(written after this plan is reviewed). Every task is test-first: tests
written and confirmed RED, then implementation, then GREEN, `flutter
analyze` clean. The implementation test cases file maps every UT and XF ID
to its test.

| # | Step | Delivers | Spec coverage |
|---|---|---|---|
| 1 | **Core support** | `Clock`, `AsyncLock`, `transfer_messages.dart`, date formatting, `DemoBanner` | PD-05, PD-10; used by all |
| 2 | **Portal adapters (D-01..D-03) and start-up** | Demo accounts with roles + seeding + PD-06 clean-up; `currentUser()`; sign-in reuse; `ReferenceLists`; demo profile (`getCurrentValues`, `pendingScheduledChange`, `scheduleOrganisationalChange` via `ScheduleBook`) | Consumed contract, SD-20; UT21 (profile side), UT60–UT62 |
| 3 | **Domain** | Entities; `TransferWorkflow` (submit, recordOutcome, triggers, tasks, history); `ScheduleBook`; `ConfirmationBuilder`; repository contract; OP01–OP07 usecases | UT01, UT03–UT27, UT30–UT36, UT44, UT46–UT48, UT55–UT59 (pure logic) |
| 4 | **Data** | `TransferLedgerModel` round-trip; datasource; `TransferRequestRepositoryImpl` with AccessGuard, lock, one-`put` saves, schedule in the same save | Access rules, atomic saves; UT02, UT09, UT10, UT28, UT29, UT31, UT45, UT50, UT52–UT54, UT59, UT63, UT64 (repository), UT70 |
| 5 | **Employee screens** | Sign in; My requests; form; request detail with steps, history, confirmation, "effective date passed" note | AC01–AC09, AC19–AC21, AC23, AC27, AC28, AC30, AC33, AC34; UT32, UT37–UT40, UT42, UT43, UT49, UT65, UT66, UT69 |
| 6 | **Tester screen** | "Demo only: simulate stakeholder outcome": open tasks (OP07), valid outcomes per pending step, mandatory reject reason, busy-state disable | AC24–AC26, AC29, AC33; UT41, UT43, UT65 (task mark) |
| 7 | **Roles, routing and sign-out** | PD-07 routing, tester-route middleware, `offAllNamed` sign-out, no permanent controllers | AC24, AC27, AC31, AC32; UT51, UT67, UT68 |
| 8 | **Cross-flow integration tests** | `integration_test` on macOS desktop, real Hive, injected clock | XF01–XF09; UT20, UT24 end to end |
| 9 | **Clean-up** | Remove v1.5 transfer code and tests, Register feature, old boxes; update `architecture.md`, `plans/README.md`, ADR statuses | Existing code table |

Steps 1–4 are the critical path and have no UI. Steps 5 and 6 can run in
either order after 4. Step 7 needs 5 and 6. Step 8 needs 7. Step 9 may be
folded into the tasks that replace each piece, so nothing is left dead
between tasks.

### AC coverage by step
| AC | Step | AC | Step | AC | Step |
|---|---|---|---|---|---|
| AC01 | 5 | AC13 | 3, 4 | AC25 | 3, 6 |
| AC02 | 2, 5 | AC14 | 3 | AC26 | 3, 6 |
| AC03 | 3, 4, 5 | AC15 | 3, 8 | AC27 | 4, 5, 7 |
| AC04 | 3, 5 | AC16 | 2, 3, 4 | AC28 | 1, 5, 6 |
| AC05 | 3 | AC17 | 3, 5 | AC29 | 3, 6 |
| AC06 | 3 | AC18 | 3, 4 | AC30 | 4, 5 |
| AC07 | 4, 5 | AC19 | 5 | AC31 | 7, 8 |
| AC08 | 4, 5 | AC20 | 3, 5 | AC32 | 4, 7 |
| AC09 | 5 | AC21 | Gate 2 (no code) | AC33 | 5, 6 |
| AC10 | 3 | AC22 | 4 | AC34 | 3, 4, 5 |
| AC11 | 3 | AC23 | 3, 4, 5 | AC35 | 2, 3, 4 |
| AC12 | 3 | AC24 | 6, 7 | | |

All 35 ACs map to at least one step. AC21 has no runtime behaviour and is
checked at Gate 2, as the spec says.

## Next
1. Gate 1 plan review by Shamik Bhattacharya: PD-01 to PD-11, flags F-01 to
   F-05, and ADR-0006 (Proposed).
2. On approval: ADR-0006 → Accepted; write
   `tasks/employee-internal-transfer.tasks.md` from the Sequencing table.
3. Then write `test_cases/employee-internal-transfer.test_cases.md` covering
   every UT01–UT70 and XF01–XF09.
