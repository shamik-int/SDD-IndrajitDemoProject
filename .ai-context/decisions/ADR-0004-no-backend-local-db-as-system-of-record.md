# ADR-0004: No Backend — Local DB as System of Record; In-App Simulated Stakeholder Decisions

_Author: Indrajit Bhandari | 2026-09-15 | Status: Accepted — supersedes ADR-0003_

## Context
ADR-0003 assumed a backend service (Node.js + NestJS + PostgreSQL) needed to
be built to hold the transfer-request lifecycle. The Author corrected this:
this project has **no backend and no backend database** — it is a
backend-less mobile app. `LocalDbService` (Hive, ADR-0001 §4) — originally
scoped in ADR-0001 as an offline cache layer alongside a remote API — becomes
the system of record for this feature instead.

This also removes the actor that was supposed to call the internal
stakeholder-decision endpoint ADR-0003/the plan proposed. With no backend,
nothing external can push a Manager/HR/Payroll/IT/Facilities decision into
the app. A decision was needed on how the approved state machine (spec AC7–
AC13) still progresses without one — resolved with the Author's input: an
**in-app Simulate Decision control**.

## Decision
1. **No backend, no remote datastore.** `transfer-request-service`
   (Node/NestJS/PostgreSQL, ADR-0003) is not built.
2. **`LocalDbService` (Hive) is the system of record** for
   `employee-internal-transfer` — not a cache in front of something else.
   Two Hive boxes:
   - `transfer_requests` — keyed by `requestId`, one record per request
     (fields in the Plan's Data Model).
   - `app_state` — a single `activeRequestId` key, set on submission,
     cleared when that request reaches a terminal status. This is how the
     single-in-flight-request rule (spec AC2) is enforced, since Hive has no
     database-level uniqueness constraints the way the superseded Postgres
     design had.
3. **Employee scoping is now implicit, not a field.** The original spec's
   data model carried an `employee_id` to scope requests to their owner in a
   shared, multi-tenant database. With no backend and one Hive store per app
   install, there is exactly one employee's data per device — `employee_id`
   is dropped from the local record; ownership is inherent to the install,
   not enforced in code.
4. **Stakeholder decisions (Manager/HR/Payroll/IT/Facilities) are recorded
   via an in-app Simulate Decision control** — a clearly-labeled,
   non-production affordance (spec AC14, backed by
   `employee-internal-transfer.OP04`) that writes a state transition
   directly to the local store. This is a deliberate stand-in for a real
   integration that does not exist in this assessment's scope — it is not
   presented as, or mistaken for, a real stakeholder-facing feature.

## Constitution Check
- [x] No new datastore introduced without an ADR — this ADR *removes* a
      datastore (PostgreSQL) rather than adding one; local persistence was
      already approved in ADR-0001.
- [~] constitution.md's "the portal is an orchestrator, not a system of
      record" (Architectural Constraints) — **does not hold for this
      project** as originally written, since there is no backend and no
      real downstream system to orchestrate against. This is a deliberate,
      flagged exception for this assessment's scope, not a silent
      contradiction — constitution.md is being amended alongside this ADR to
      note the exception rather than leave the two documents disagreeing.
- [x] Testing discipline — `flutter_test`, unit tests on the repository's
      state-machine logic (no backend test framework needed now).

## Explicitly Deferred
- A real backend and real Manager/HR/Payroll/IT/Facilities integrations —
  this ADR does not solve that; if this ever needs to be production software
  acting on real external decisions, this ADR must be revisited.
- Multi-device sync — since the store is local-only and per-install, a
  transfer request does not follow the employee across devices. Not raised
  as a requirement anywhere in BRD-001 or the spec, so not addressed here.

## Consequences
Removes the entire backend workstream (all four backend steps) from the
Plan's Sequencing — everything is now Flutter-only. Every stakeholder-decision
AC (AC7–AC13) is driven by the Simulate Decision control rather than a real
external actor, which means **this app cannot, on its own, guarantee a
decision reflects a real Manager/HR/Payroll/IT/Facilities action** — that
limitation is inherent to a backend-less scope, not something engineering can
resolve without a backend and real integrations. `architecture.md`,
`constitution.md`, the spec, and the plan are all being updated in the same
pass as this ADR to keep them from disagreeing with each other.
