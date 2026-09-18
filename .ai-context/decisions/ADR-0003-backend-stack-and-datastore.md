# ADR-0003: Backend Orchestration Stack & Datastore for the Transfer Request Service

_Author: Indrajit Bhandari | 2026-09-15 | Status: **SUPERSEDED by ADR-0004**_

> **Superseded 2026-09-15.** This ADR assumed a backend service needed to be
> built for this project. The Author clarified this is a backend-less mobile
> app: no server, no remote datastore — `LocalDbService` (Hive, ADR-0001) is
> the system of record for the whole feature. Kept here, not deleted, so the
> reasoning that led to the wrong assumption stays visible — see ADR-0004 for
> the corrected decision.

## Context
ADR-0001 deliberately scoped the Flutter **client** architecture only, leaving
the backend/orchestration stack open (constitution.md Testing Discipline has
carried this as "still open" since kickoff). The `employee-internal-transfer`
Plan needs a concrete backend + datastore to sequence real tasks against.

No existing One-Point Portal backend codebase was provided for this
engagement — this is a new, standalone service for the purposes of this
assessment, not an extension of a pre-existing system.

## Decision
1. **Stack:** Node.js + NestJS for a new `transfer-request-service`. Chosen
   for fast scaffolding, TypeScript typing for the request state machine, and
   straightforward REST + async event-consumer support. (Flagged as an
   assumption: if a real engagement already mandates a backend stack, this
   ADR would instead just record that mandate — there was none given here.)
2. **Datastore:** PostgreSQL as the system of record. Two tables:
   `transfer_requests` (one row per request) and
   `transfer_request_stakeholder_status` (one row per stakeholder per
   request — Manager/HR/Payroll/IT/Facilities — tracking pending/decided
   state). No Redis/cache layer introduced in v1 — see plan's Explicitly
   Deferred.
3. **Testing:** Jest, test-first — confirms the branch constitution.md's
   conditional Testing Discipline line already anticipated.

## Constitution Check
- [x] No new datastore without an ADR — this ADR is that ADR.
- [x] Testing discipline matches constitution.md.
- [x] Async/event-driven downstream integration (Architectural Constraints) —
      stakeholder decisions arrive via an internal event/endpoint, never a
      synchronous call in the employee's request path.

## Explicitly Deferred
- Real Manager/HR/Payroll/IT/Facilities system adapters — see the plan's
  Explicitly Deferred section; `architecture.md`'s Integrations table stays
  TBD for the real per-system contracts.
- Any additional service or datastore beyond what's listed above requires
  its own ADR.

## Consequences
Unblocks `employee-internal-transfer` Plan and Task generation. Any future
backend feature in this project defaults to Node/NestJS/PostgreSQL unless a
later ADR changes it.
