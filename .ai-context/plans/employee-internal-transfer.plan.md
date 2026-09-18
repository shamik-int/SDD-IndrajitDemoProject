# Plan: Employee Internal Transfer

_Revised 2026-09-15 (v2) — the original plan assumed a Node.js/NestJS/
PostgreSQL backend (ADR-0003). The Author corrected this: no backend exists
for this project. This revision follows **ADR-0004** (supersedes ADR-0003)
throughout. See `.ai-context/decisions/ADR-0003-*.md` for the superseded
version and why it was wrong, and `ADR-0004-*.md` for the corrected decision._

## Derived From
`.ai-context/specs/employee-internal-transfer.spec.md` (v1.2, Approved)

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
  ```
  Entering `PENDING_DOWNSTREAM_UPDATES` creates three stakeholder-status
  entries (Payroll, IT, Facilities) simultaneously — the fan-out AC10
  describes. Any `OP04` call whose `stakeholder`/`decision` doesn't match the
  current state's valid next step returns `Result.error` (UT14).

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
  scope against.

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
