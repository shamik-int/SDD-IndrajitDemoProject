# ADR-0006: V1 Demo Identity (Roles) and the Per-Employee Transfer Ledger

_Author: Indrajit Bhandari | 2026-09-30 | Status: **Proposed** (reviewed at Gate 1 with plan v4.0)_

## Context
Spec v2.4 of `employee-internal-transfer` (Gate 1 Approved 2026-09-30)
needs three things the current local design cannot give:

1. **Roles.** Only a `TESTER` may record stakeholder outcomes; an
   `EMPLOYEE` may only submit and view their own requests (SD-18). The role
   must be set in demo account data, not chosen at sign-in or sign-up. The
   BRD-002 registration flow (ADR-0005) lets anyone create an account and
   has no role.
2. **Atomic saves across the request, its history and the scheduled
   organisational change** (spec Atomic saves, SD-20). Plan v3 kept these in
   separate Hive boxes (`transfer_requests`, `decision_history`, `app_state`).
   Hive has no multi-key transaction, so a crash between two writes could
   leave a status change without its history entry, or a `COMPLETED`
   request without its schedule.
3. **Per-employee ownership** instead of one active request per device.

## Decision
1. **Seeded demo accounts replace self-registration.** Box `demo_accounts`
   (replaces `employees`), keyed by `userId`: email (sign-in looks it up normalised),
   display name, `role` (`EMPLOYEE` | `TESTER`), password hash + salt, and a
   baseline profile for employees only. Seeded at start-up. No sign-up
   screen in V1. Password handling stays as in ADR-0005 (SHA-256 + salt,
   never plaintext); the demo password is not committed. The `session` box
   now holds `currentUserId`.
2. **One ledger record per employee.** Box `transfer_ledgers`, keyed by
   `employeeId`, holding that employee's requests (steps, tasks, history)
   and scheduled organisational changes. Every state-changing operation is
   read → change in memory → **one `put`**. A single `put` is one
   checksummed Hive frame; an incomplete frame is dropped when the box is
   reopened, so each operation is saved completely or not at all. An
   in-process lock serialises read-modify-write cycles.
3. **`app_meta.schemaVersion`.** Below 2, the v1.5 boxes (`transfer_requests`,
   `app_state`) and the BRD-002 `employees` box are deleted once and the demo
   accounts are seeded. All of it is test data (BR-25).
4. **Data at rest: plain Hive storage, V1 demo data only** _(added
   2026-10-05 for Gate 2 G2-11; pending Tech Lead acceptance)._ The boxes
   are not encrypted. Anyone with access to the device storage can read
   them, and can change `session.currentUserId` to act as another demo
   user, including the tester. This is accepted for V1 only because every
   value is demo test data (BR-25) and the spec already places device and
   storage access outside the V1 protection (Security boundary, BR-26).
   Before any build holds real employee data, the boxes must be encrypted
   (for example `HiveAesCipher` with a key held in the platform keystore).
5. **Demo password** _(added 2026-10-05 for Gate 2 G2-17; pending Tech
   Lead acceptance)._ The salts and hashes of the seeded accounts are
   committed, and the hash is a single round of SHA-256, which is fast to
   guess offline; local sign-in has no attempt limit. So the demo password
   must be long and random (at least 20 characters, generated, not a
   word), it is never written to the repository, and it is rotated —
   new salts and hashes in `demo_accounts.dart` — before any build leaves
   the team. The start-up seeder rewrites the accounts on every start, so a
   rotated password takes effect on the next launch.

## Relation to earlier ADRs
- **ADR-0004** — still in force (no backend, Hive is the system of record,
  simulated stakeholders). Its two-box data model is replaced by decision 2.
- **ADR-0005** — its decisions 1 (`employees` box and self-registration) and
  3 (`currentEmployeeEmail`) are **superseded** by decision 1 above. Its
  decision 2 (password hashing) and its Consequences remain in force.
  Decision 4 (`employeeId` scoping) is carried out by decision 2 above.

## Constitution Check
- [x] No new datastore without an ADR: this ADR covers `demo_accounts`,
      `transfer_ledgers` and `app_meta`. All three are boxes in the same
      local Hive store (ADR-0001).
- [x] Passwords never plaintext, in storage, seed or logs.
- [~] Ownership is enforced in the repository, not "server-side" as the
      constitution line reads. Application-level only (spec Security
      boundary). A constitution v1.3 caveat is recommended, not applied here.

## Consequences
- The whole ledger is rewritten on every change. Fine at demo scale; a
  real backend would use proper transactions instead.
- OP07 (tester task list) reads every ledger. Fine for a handful of demo
  accounts; not a design for real volumes.
- The `TESTER` role stops an employee approving their own request **through
  the app**. It is not a control against anyone with device, storage or
  code access, and is not production authorization (spec Security
  boundary). It must be removed with the simulation before any production
  release (SD-13).
- If this app ever gets a backend, this ADR is superseded, not patched.
