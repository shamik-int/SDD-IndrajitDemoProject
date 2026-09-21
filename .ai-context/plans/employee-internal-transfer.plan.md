# Plan: Employee Internal Transfer

_Revised 2026-09-15 (v2) — the original plan assumed a Node.js/NestJS/
PostgreSQL backend (ADR-0003). The Author corrected this: no backend exists
for this project. This revision follows **ADR-0004** (supersedes ADR-0003)
throughout. See `.ai-context/decisions/ADR-0003-*.md` for the superseded
version and why it was wrong, and `ADR-0004-*.md` for the corrected decision._

_Revised 2026-09-21 (v3) — adds the `FAILED` state, `decision_history` box,
and `managerName` display note to close spec v1.5's Gate 1 remediation items
(G1-07, G1-12, G1-17, G1-24). Design-only revision — not yet reflected in
`tasks/employee-internal-transfer.tasks.md` (all tasks there still describe
the pre-v1.5 design) and not yet re-reviewed by Shamik Bhattacharya._

## Derived From
`.ai-context/specs/employee-internal-transfer.spec.md` (v1.5, Changes in progress)

## Architecture Approach
- **No backend (ADR-0004).** There is no `transfer-request-service`, no
  Node.js/NestJS, no PostgreSQL. Everything below is Flutter-only.
- **Client:** Flutter, Clean Architecture, GetX (ADR-0001) — this feature's
  code lands in `lib/data`, `lib/domain`, `lib/presentation` (currently
  README placeholders per the earlier scaffold).
- **`LocalDbService` (Hive) is the system of record**, not a cache — the
  spec's Local Data Contract (OP01–OP04) is implemented entirely as local
  repository methods, no network call anywhere in this feature.
- **Stakeholder actions (spec's "How Stakeholder Actions Are Recorded"):**
  Manager/HR/Payroll/IT/Facilities decisions are recorded through the
  **Simulate Decision control** (AC14) — a clearly-separated, visually
  distinct section of the status screen (or a debug-only route), calling
  `OP04` directly against the local repository. It must never be styled or
  labeled as if it were a real stakeholder-facing feature — a QA/Gate 2 check
  item, not just a suggestion.
- **State machine** (drives both the `status` field and derived
  `pendingStakeholders`, applied entirely in `data/repositories/` — the
  domain layer's usecases call into this, they don't reimplement it):
  ```
  PENDING_MANAGER_APPROVAL --(simulate: manager approves)--> PENDING_HR_VALIDATION
  PENDING_MANAGER_APPROVAL --(simulate: manager rejects)--> REJECTED_BY_MANAGER [terminal]
  PENDING_HR_VALIDATION --(simulate: HR approves)--> PENDING_DOWNSTREAM_UPDATES
  PENDING_HR_VALIDATION --(simulate: HR rejects)--> REJECTED_BY_HR [terminal]
  PENDING_DOWNSTREAM_UPDATES --(simulate: Payroll+IT+Facilities all complete)--> COMPLETED [terminal]
  PENDING_DOWNSTREAM_UPDATES --(simulate: any of Payroll/IT/Facilities rejects)--> FAILED [terminal]
  ```
  Entering `PENDING_DOWNSTREAM_UPDATES` creates three stakeholder-status
  entries (Payroll, IT, Facilities) simultaneously — the fan-out AC10
  describes. Any `OP04` call whose `stakeholder`/`decision` doesn't match the
  current state's valid next step returns `Result.error` (UT14), and this
  includes any `OP04` call once a request is already terminal — including the
  new `FAILED` state (v1.5, spec AC16, UT16).

  **v1.5 addition — `FAILED` (Gate 1 G1-12/G1-24):** unlike the two rejection
  branches above (which happen before downstream fan-out, with a single
  rejecting stakeholder), `FAILED` can occur after Payroll/IT/Facilities are
  already in a mixed state (e.g. Payroll `COMPLETED`, IT `REJECTED`,
  Facilities still `PENDING`). v1 does not roll back Payroll's completed
  work, retry IT, or otherwise reconcile the mixed state — the repository
  simply stops evaluating further stakeholder transitions once `FAILED` is
  set (any subsequent `OP04` call is rejected per AC16, same as any other
  terminal status). This is a deliberate v1 simplification, not a
  correctness gap being silently accepted — a real backend/integration would
  need actual compensation logic here, which is out of scope until this
  project has one (ADR-0004).

## Data Model
Two Hive boxes (ADR-0004) — no relational tables, no server:
- **`transfer_requests`** — keyed by `requestId` (client-generated UUID v4).
  Value per record:
  - `id`, `departmentId`, `locationId`, `roleId`, `effectiveDate`, `reason` (nullable)
  - `status` (enum, matches spec's Status Definitions)
  - `stakeholders`: map of `MANAGER`/`HR`/`PAYROLL`/`IT`/`FACILITIES` →
    `PENDING`/`APPROVED`/`REJECTED`/`COMPLETED`/`NOT_APPLICABLE`
    (`pendingStakeholders` in OP02/OP03's response = keys with value `PENDING`)
  - `submittedAt`, `updatedAt`
- **`app_state`** — single key `activeRequestId`. Set on successful
  `submitTransferRequest` (OP01); cleared when that request's status becomes
  terminal. `OP01` checks this key before creating a new record — this is how
  the single-in-flight-request rule (spec AC2/UT05) is enforced, since Hive
  has no database-level uniqueness constraints the way a relational store
  would.
- No `employeeId` field — dropped per ADR-0004: one Hive store per app
  install already belongs to exactly one employee, so there's nothing to
  scope against. **(Superseded by ADR-0005 — tracked as this feature's own
  upcoming plan amendment once `employee-registration-login` ships; not
  applied in this revision.)**
- **`decision_history`** (v1.5, Gate 1 G1-17) — append-only. Keyed by a
  client-generated UUID v4 per entry (not by `requestId`, so multiple entries
  per request coexist). Value per entry:
  - `requestId` (foreign key into `transfer_requests`, no relational
    enforcement — Hive has none, same caveat as `app_state`)
  - `stakeholder` (`MANAGER`/`HR`/`PAYROLL`/`IT`/`FACILITIES`, or `null` for
    the initial submission entry)
  - `decision` (`SUBMITTED`/`APPROVED`/`REJECTED`/`COMPLETED`)
  - `resultingStatus` (the `transfer_requests.status` value immediately after
    this entry was applied)
  - `recordedAt` (timestamp)

  Entries are written by the same repository method that applies each state
  transition (OP01 for the initial `SUBMITTED` entry, OP04 for every
  subsequent one) — there is no separate "write history" call for the
  presentation layer to remember to make, so history can't be forgotten by a
  caller. Read via `OP05.getDecisionHistory`, filtered by `requestId`,
  ordered by `recordedAt` ascending. Never updated or deleted after being
  written — if this were ever wrong, the fix is a new entry, not an edit.

## Constitution Check
- [x] No new datastore introduced without ADR — local persistence approved
      in ADR-0001, confirmed as the system of record (not cache) by ADR-0004.
- [x] Testing discipline matches constitution.md — `flutter_test`,
      `Get.testMode = true`, test-first for the repository's state-machine
      logic and every GetX controller method.
- [x] Security posture — `reason` free-text is never logged at any level; no
      employee-identifying field beyond what's needed is logged. Ownership
      enforcement is inherent to the local, single-employee data model
      (constitution.md, ADR-0004 caveat) — no separate access-control code
      needed, and none should be added (it would be unused complexity).
- [x] Architectural constraints — no synchronous or asynchronous integration
      call exists at all; the "async/event-driven downstream" constitution
      rule is moot here (ADR-0004 caveat), not violated.
- [x] Rate-limit decision: **not applicable** — there is no network endpoint
      to rate-limit.
- [x] Root/jailbreak/Frida detection (ADR-0002) still applies — this feature
      touches organisational data locally, so the mandatory detection from
      `main.dart`/`SecurityService` is unaffected by the no-backend change.

## Explicitly Deferred
- A real backend and real Manager/HR/Payroll/IT/Facilities integrations —
  ADR-0004 does not solve this; would require revisiting this entire plan.
- Multi-device sync / cloud backup of the transfer request — not raised as a
  requirement anywhere in BRD-001 or the spec.
- Android/iOS native build-flavor split (already deferred from Flutter
  scaffolding — `PROJECT_CHECKLIST.md` §1).
- Any SLA/escalation logic, amend/withdraw, or notification channel beyond
  in-portal status (all explicitly out of scope per the spec).
- Automatic retry/compensation on a `FAILED` request, and the `employeeId`
  re-scoping this feature owes `employee-registration-login` (ADR-0005) —
  both v1.5 items, sequenced as follow-up plan amendments, not implemented in
  this revision (design-only per this Gate 1 remediation pass).
- Manager-identity verification against an authoritative source —
  `managerName` (v1.5, captured by `employee-registration-login.OP01`) is
  displayed as-entered on the status screen (AC7); this plan does not add any
  lookup, validation, or org-chart integration for it (ADR-0004: no HRIS).

## Sequencing
1. Flutter: `domain/` — `TransferRequest` entity (incl. per-stakeholder
   status map), repository contract, usecases
   (`SubmitTransferRequest`, `GetActiveTransferRequestStatus`,
   `GetTransferRequestById`, `RecordStakeholderDecision`).
2. Flutter: `data/` — Hive-backed local datasource (`transfer_requests` +
   `app_state` boxes), repository implementation applying the state machine,
   the single-in-flight check, and field validation (re-validated at this
   boundary per the spec's Non-Functional Constraints, since there is no
   separate API layer to also validate at).
3. Flutter: `presentation/` — submission screen (AC1, AC3–AC5, validators
   wired to `core/utils/validators.dart`), status screen (AC6, AC7, AC9–AC13),
   and the Simulate Decision control (AC14) as a visually distinct section.
4. Integration test: full journey + both rejection branches, per
   `.ai-context/test_cases/_integration.md`.

Task generation (`tasks/employee-internal-transfer.tasks.md`) follows this
sequencing directly, one task per numbered step above (further split where a
step isn't independently verifiable in one sitting — step 3 in particular
will likely split into submission-screen / status-screen / simulate-control
tasks).
