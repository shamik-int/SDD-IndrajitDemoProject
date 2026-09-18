# decisions/

ADRs — the "why" behind significant technical choices. Project-global sequential
IDs (`ADR-NNNN-<slug>.md`), not scoped to a single feature slug (Blueprint §9, §22).

## Authored
- **ADR-0001** — Flutter Client Architecture, State Management & Local Persistence (Clean Architecture + GetX + local-first persistence + theming/responsiveness/env conventions). Referenced from `architecture.md`.
- **ADR-0002** — Mobile Runtime Security Hardening (Root/Jailbreak/Frida) & Memory Hygiene. Referenced from `architecture.md`.
- ~~**ADR-0003**~~ — ~~Backend Orchestration Stack & Datastore (Node.js + NestJS + PostgreSQL)~~ — **Superseded by ADR-0004** same day. Kept, not deleted, so the wrong assumption and its correction both stay traceable.
- **ADR-0004** — No Backend — Local DB as System of Record; In-App Simulated Stakeholder Decisions. Corrects ADR-0003: this project has no backend/database at all — Hive is the system of record, and Manager/HR/Payroll/IT/Facilities decisions are recorded via an in-app Simulate Decision control. Referenced from `architecture.md`, `constitution.md`, the spec (v1.2), and `plans/employee-internal-transfer.plan.md`.
- **ADR-0005** — Local-Only Employee Authentication (Access Gate, Not a Security Boundary). For `employee-registration-login` (BRD-002): passwords hashed (SHA-256 + per-account salt, explicitly flagged as weaker than a real password hash) since there's no backend to verify against; `employeeId` added back to `employee-internal-transfer`'s data model as a cross-feature consequence. Referenced from `architecture.md`, `constitution.md`, and the spec.

## Still open (not yet an ADR)
- Final local DB engine confirmation (Hive proposed in ADR-0001, now load-bearing per ADR-0004) — confirm once real usage patterns are observed.
- Real Manager/HR/Payroll/IT/Facilities integration contracts — explicitly out of scope per ADR-0004, not applicable unless this project later gains a real backend.
- Real password-reset flow for `employee-registration-login` — explicitly deferred indefinitely per ADR-0005 (no email service/backend to build one on).
