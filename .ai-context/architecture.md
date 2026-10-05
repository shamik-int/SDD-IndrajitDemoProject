# Architecture — One-Point Employee Portal (Employee Transfer Project)

_Last updated: 2026-09-30 (spec v2.4 / plan v4.0 implemented). Keep current or don't trust it (Blueprint §17) — a stale
version of this file actively misleads the next agent session._

## Features in this project
| Slug | Spec | Status |
|---|---|---|
| `employee-internal-transfer` | BRD-001 v5.2 | Spec v2.4 Approved; plan v4.0 implemented; in Gate 2 review |
| `employee-registration-login` | BRD-002 | Not followed (version control only); Register screen removed from the V1 app |

## System Overview
- **Client:** Flutter app (mobile + web), Clean Architecture (domain/data/presentation
  + core), GetX for state management. Full detail in **ADR-0001**.
- **No backend.** ADR-0003 (a Node.js/NestJS/PostgreSQL backend) is
  **superseded by ADR-0004** — this project has no server and no remote
  datastore. `LocalDbService` (Hive) is the system of record for the whole
  `employee-internal-transfer` feature.
- **Downstream systems** (Manager, HR, Payroll, IT, Facilities) are not
  integrated with at all — there is no backend to integrate through. Their
  outcomes are recorded on the **"Demo only: simulate stakeholder outcome"**
  screen (spec v2.4 AC24), available only to a seeded `TESTER` demo account
  (SD-18, ADR-0006). It is not a stakeholder interface and must be removed
  before production (SD-13).
- **Portal dependencies (D-01..D-03)** are demo adapters in
  `lib/data/transfer/portal/`: seeded demo accounts with roles and sign-in
  (D-01), a demo profile with scheduled organisational changes (D-02), and
  static reference lists (D-03). Plan v4.0 PD-01–PD-03.

## Client Architecture (Flutter) — see ADR-0001 for full rationale
```
lib/
├── app/            # GetMaterialApp root, routes, root bindings
├── core/           # constants, utils (toast/loader/validators), theme, responsive,
│                    security (ADR-0002), network (ApiClient), local_db (LocalDbService),
│                    result (Result<T> / Status)
├── data/           # models, datasources/{remote,local}, repositories
├── domain/         # entities, repository contracts, usecases
└── presentation/   # controllers (GetX), bindings, pages, widgets
```
Dependency rule: `presentation` → `domain` ← `data`; `domain` has no dependency on
either. `core/` is importable by all three, depends on none of them.

`employee-internal-transfer` (v2.4) lives in `lib/domain/transfer/`,
`lib/data/transfer/` and `lib/presentation/transfer/`. The journey's rules
are pure functions in `lib/domain/transfer/workflow/` (`TransferWorkflow`,
`ScheduleBook`); the repository applies the access rules (signed in → role →
ownership), serialises writes with an `AsyncLock`, and saves each operation
with one Hive `put`. Dates come from an injected `Clock` (`lib/core/time/`).
The v1.5 transfer code and the BRD-002 Register/Login feature were removed
on 2026-10-05 (tasks T09, Gate 2 G2-02).

- **State management:** GetX (`GetxController`, `Get.put`/`Get.find`, `GetPage`).
- **Persistence:** local-only. `LocalDbService` (Hive) is the system of record
  for `employee-internal-transfer` (ADR-0004) — not a cache in front of a
  backend, since there is no backend. It still returns `Result<T>` carrying
  `Status { success, error, inProgress }` (ADR-0001 §4), so the presentation
  layer's handling is unchanged even though there's no remote counterpart to
  fall back to for this feature.
- **Environments:** UAT and PROD via `assets/env/.env.uat` / `.env.prod`
  (non-secret configuration only — see Security Posture in `constitution.md`).
- **Responsiveness:** `flutter_screenutil` for scaling + a breakpoint helper
  (`shortestSide >= 600` ⇒ tablet layout).
- **Theming:** light/dark `ThemeData`, primary Green / accent Yellow, secondary
  tint shades, layered text-color shades; font is Lato, self-hosted under
  `assets/fonts/` (not the `google_fonts` runtime-fetch package — offline-safe).
- **Security:** root/jailbreak/Frida detection at startup and resume (mandatory,
  not optional) — see **ADR-0002**. Memory hygiene (controller/stream disposal,
  `leak_tracker` in test) is a related but separate, dev-time discipline, not a
  runtime guard.
- **Validation:** every mandatory field has an explicit validator in
  `core/utils/validators.dart`; client validation is UX, never the sole security
  boundary.

## Integrations
| System | Direction | Purpose | Contract | ADR |
|---|---|---|---|---|
| Manager Approval | None — simulated in-app | Confirm manager sign-off on transfer | No real integration; Simulate Decision control | ADR-0004 |
| HR System | None — simulated in-app | Eligibility validation | No real integration; Simulate Decision control | ADR-0004 |
| Payroll System | None — simulated in-app | Compensation/org-unit update | No real integration; Simulate Decision control | ADR-0004 |
| IT Provisioning | None — simulated in-app | Access provision/de-provision | No real integration; Simulate Decision control | ADR-0004 |
| Facilities | None — simulated in-app | New location/seat arrangement | No real integration; Simulate Decision control | ADR-0004 |

## Data Model
- **`employee-internal-transfer`** (ADR-0006, plan v4.0): Hive boxes
  `demo_accounts` (keyed by `userId`; role, password hash + salt, baseline
  profile for employees), `session` (`currentUserId`), `transfer_ledgers`
  (one record per employee: requests with steps, stakeholder tasks and
  append-only history, plus scheduled organisational changes) and
  `app_meta` (`schemaVersion` 2). The v1.5 boxes (`transfer_requests`,
  `app_state`) and BRD-002's `employees` box are cleared once at start-up.
- **`employee-registration-login`**: not followed; its boxes are cleared by
  the start-up step above.

The shared `Result<T>` contract (ADR-0001 §4) wraps every read/write for
both features.

## Decisions in Force
| ADR | Title | Summary |
|---|---|---|
| ADR-0001 | Flutter Client Architecture, State Management & Local Persistence | Clean Architecture + GetX + local-first (Hive) persistence + theming/responsiveness/env conventions |
| ADR-0002 | Mobile Runtime Security Hardening & Memory Hygiene | Mandatory root/jailbreak/Frida detection; memory hygiene as a separate dev-time discipline |
| ~~ADR-0003~~ | ~~Backend Orchestration Stack & Datastore~~ | **Superseded by ADR-0004** — no backend is built |
| ADR-0004 | No Backend — Local DB as System of Record | Hive is the system of record (not a cache); Manager/HR/Payroll/IT/Facilities decisions are simulated via an in-app control, not a real integration |
| ADR-0005 | Local-Only Employee Authentication | Hashed (not real-security-grade) local credential store; access gate only, not server-verified auth. Decisions 1 and 3 superseded by ADR-0006 |
| ADR-0006 | V1 Demo Identity (Roles) and the Per-Employee Transfer Ledger | **Proposed.** Seeded demo accounts with `EMPLOYEE`/`TESTER` roles, no sign-up; one ledger record per employee saved with a single `put` |
