# Project Context — One-Point Employee Portal (Employee Transfer Project)

_One-page orientation — what you'd hand a new hire on day one._

## Objective
Give employees a single, self-service way to request — and track — an internal
transfer (department, location, role change), gated behind their own registered
account, replacing today's manual, multi-team coordination (Manager → HR →
Payroll → IT → Facilities) with one consolidated, identified status view.

## Scope Source
The transfer journey is scoped by the assessment brief `Requirement for SDD (2).pdf`,
treated as the **business scope document** — not itself a BRD. `BRD-001` in
`.ai-context/BRD.md` is the SDD-compliant restatement of it. The registration/login
gate (`BRD-002`) was added afterward, directly by the Author, per Blueprint §7 ("a
spec should never be the first place a requirement is written down").

## Architecture Summary (see `architecture.md` for the authoritative, current version)
- **Client:** Flutter app (mobile + web). Clean Architecture + GetX (ADR-0001).
- **No backend, by design.** ADR-0004 supersedes an earlier
  Node.js/NestJS/PostgreSQL assumption (ADR-0003, kept on disk marked
  Superseded, not deleted) — `LocalDbService` (Hive) is the system of record
  for both features in this project.
- **Manager/HR/Payroll/IT/Facilities** are not integrated with at all — their
  decisions are simulated via an in-app, clearly-labeled Simulate Decision
  control (`employee-internal-transfer` AC14), not a real integration.
- **Employee identity** (`employee-registration-login`, ADR-0005) is a local
  access gate only — hashed credentials checked against local storage, not
  server-verified authentication.

## Stakeholders
| Role | Name | Email |
|---|---|---|
| Author / Engineer | Indrajit Bhandari | indrajit.bhandari@intglobal.com |
| Gate 1 Reviewer | Shamik Bhattacharya | shamik.bhattacharya@intglobal.com |
| Gate 2 Reviewer | Subhajit Mukherjee | subhajit.mukherjee@intglobal.com |
| Business Sponsor | HR Product Owner, One-Point Employee Portal (assumed — confirm) | — |
| Domain stakeholders touched by orchestration | Manager, HR, Payroll, IT, Facilities | — |

Only the named person for each gate may approve it (constitution.md Review
Authority) — this table, `AGENT.md`'s Ownership table, and constitution.md
must agree; if they ever don't, constitution.md wins.

## Status
Not tracked here in detail — see `.ai-context/status.md` (the one source of
truth for what's active). As of 2026-09-17: `employee-internal-transfer` is
Approved and fully implemented (T01–T06 merged, In QA, awaiting Gate 1/Gate 2
review). `employee-registration-login` is a new feature, spec authored and
self-reviewed, awaiting Gate 1.
