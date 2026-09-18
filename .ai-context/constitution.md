# Project Constitution — Employee Internal Transfer Digital Journey (One-Point Employee Portal)

_Author: Indrajit Bhandari (indrajit.bhandari@intglobal.com) | v1.2 | 2026-09-17_
_Written once at project kickoff per Blueprint §8. Amendments follow the same review rigor as a spec — see Amendment Log below for what changed and why._

## Review Authority
- **Gate 1** (spec/plan peer review) may only be approved by the named Gate 1
  reviewer: **Shamik Bhattacharya** (shamik.bhattacharya@intglobal.com).
- **Gate 2** (code review) may only be approved by the named Gate 2 reviewer:
  **Subhajit Mukherjee** (subhajit.mukherjee@intglobal.com).
- No one else's sign-off satisfies either gate for this project — **including
  the Author.** Before treating a Gate 1/Gate 2 approval as valid, confirm the
  reviewer's identity (name *and* email) matches the assignment above. A
  sign-off from anyone else, however qualified, does not close that gate;
  escalate to get the actual named reviewer rather than substitute one.
- Reassigning either role requires updating this file, `AGENT.md`'s Ownership
  table, and `project_context.md`'s Stakeholders table together — an
  assignment that exists in only one of those three isn't a real assignment.

## Amendment Log
- **v1.1** (2026-09-17): added Review Authority (reviewer reassignment).
- **v1.2** (2026-09-17): added a password-hashing non-negotiable under
  Security Posture, for `employee-registration-login` (BRD-002, ADR-0005).

## Testing Discipline
- Test-first is mandatory for every API endpoint, every GetX controller method, and every state-changing operation on the transfer-request lifecycle; no exceptions for "simple" screens.
- Minimum 80% line coverage for any module touching employee organisational, payroll-adjacent, or approval-decision data; 60% elsewhere. Coverage is a floor, not a target to write to.
- Flutter app: `flutter_test` + `mocktail` for unit/widget tests. `GetxController`s are plain Dart classes — test them directly with `flutter_test`, setting `Get.testMode = true` in test setup to suppress navigation/snackbar side effects. `integration_test` for the end-to-end submit → track journey.
- Memory hygiene is a testing-discipline concern, not a runtime security one: every controller/stream/animation-controller implements `onClose()`/dispose, and leak checks run via Flutter's `leak_tracker` in debug/profile test runs (see ADR-0002).
- **Revised (ADR-0004):** this project has no backend service at all — `employee-internal-transfer` (and, by default, any future feature unless a new ADR says otherwise) is local-only. The Jest/JUnit line above is retired, not just deferred; if a real backend is ever introduced later, that decision gets its own ADR and re-adds a backend testing line here.

## Security Posture
- No employee PII (full legal name, government ID, payroll amount, bank/payment instrument, health/disciplinary record) appears in logs at ANY log level, including debug.
- All employee-facing and stakeholder-facing endpoints sit behind the existing One-Point Portal SSO/OAuth2 session; no endpoint ships without an explicit rate-limit decision recorded in its plan (even if the decision is "none, and here's why").
- Secrets (API keys/credentials to HR, Payroll, IT, and Facilities systems) only via the organisation's secrets manager; never in `.env` files committed to any repo, sanitized or not.
- **Clarification (ADR-0001):** `assets/env/.env.uat` and `assets/env/.env.prod` are the app's build-flavor configuration files and hold **non-sensitive configuration only** — environment name, API base URL, feature flags. They may be committed. This does not relax the rule above: actual credentials never go in these files, committed or not.
- Every orchestration call to a downstream system (HR, Payroll, IT, Facilities) is authenticated and scoped to least privilege for that specific integration — no shared "God" service account across integrations. **(Moot for `employee-internal-transfer`, ADR-0004: there is no orchestration call, no downstream system, and no backend to make one from. This rule stays the default for any future feature that does integrate with a real downstream system.)**
- An employee may only view or act on their own transfer request; a manager/HR/IT/Facilities actor may only view or act on requests where they are the current pending stakeholder — enforced server-side, not just hidden in the UI. **(Revised for `employee-internal-transfer`, ADR-0004: with no backend and one Hive store per device install, "own request" was inherent to the install, not a rule enforced in code. Superseded again by `employee-registration-login` (BRD-002, ADR-0005) — once real employee accounts exist, "own request" is enforced by `employeeId` scoping, not by the device-install assumption. The Simulate Decision control, AC14, remains a flagged non-production stand-in either way, not a real per-stakeholder access boundary.)**
- The app detects rooted/jailbroken devices and Frida/hook instrumentation at startup and on resume — mandatory, not optional (ADR-0002). The response to a positive detection (block vs. warn) is a Plan-stage decision for `employee-internal-transfer`; the detection capability itself is a standing rule.
- **(v1.2, ADR-0005)** Employee passwords are never stored or logged in plaintext, at any level — hashed only (SHA-256 + per-account salt, proposed). This is a local access gate, not real authentication (no backend exists to verify identity against) — do not describe it to a business stakeholder as equivalent to server-verified auth.

## Architectural Constraints
- Frontend: Flutter (mobile + web) is the only client for this journey; no parallel native client without an ADR.
- Client architecture is Clean Architecture (domain / data / presentation, plus a `core/` cross-cutting layer), with **GetX** as the single state-management approach for the whole app — decided in **ADR-0001**. No introducing a second state-management library "for this one feature."
- Local persistence is an approved client-side datastore (ADR-0001): a `LocalDbService` abstraction, shaped the same way as the remote `ApiClient`, both returning a shared `Result<T>` carrying `Status { success, error, inProgress }`. Originally scoped as the client's local cache/queue layer in front of a backend — **for `employee-internal-transfer`, ADR-0004 makes it the system of record instead**, since this project has no backend. Any future feature that does have a backend defaults back to cache-only.
- Every mandatory input field has an explicit validator (`core/utils/validators.dart`); client-side validation is a UX aid, never the sole security boundary — the same field is re-validated at the repository/API boundary. **(For `employee-internal-transfer`, ADR-0004: there is no separate API boundary to re-validate at — the local repository layer is the only boundary, and is treated as authoritative.)**
- The portal is an orchestrator, not a system of record: employee org data, payroll data, IT access, and facilities allocation remain owned by their existing systems. The transfer-request service persists only the request itself, its workflow state, and stakeholder-action status — never a shadow copy of a downstream system's master data. **(Does not hold for `employee-internal-transfer`, ADR-0004: there is no backend and no real downstream system to orchestrate against, so the local app *is* the system of record for this feature. Flagged as a deliberate, scoped exception, not a silent contradiction — this remains the default rule for any future feature with a real backend.)**
- Downstream integration (Manager approval, HR, Payroll, IT, Facilities) is asynchronous/event-driven wherever a downstream system's response time cannot be guaranteed inside a user-facing request — no synchronous call in the request path blocks portal responsiveness (same reasoning as the Blueprint's Twilio-dispatch example, §10). **(Moot for `employee-internal-transfer`, ADR-0004: there is no downstream integration — Manager/HR/Payroll/IT/Facilities decisions are simulated in-app via AC14.)**
- No new datastore without an ADR approved by the Architect (local persistence above is the one exception already covered by ADR-0001; any additional datastore still needs its own ADR).

## Non-Functional Baselines
- p95 API latency < 500ms for employee-facing status/read endpoints, measured at the gateway. **(Revised for `employee-internal-transfer`, ADR-0004: no gateway or network call exists — the equivalent local baseline is in the spec's Non-Functional Constraints, e.g. local read/write completing well under 500ms with no network variability to budget for.)**
- 99.5% availability target for the request-submission and status-view path (initial target; revisit once a 90-day baseline exists, per Blueprint §26). **(For `employee-internal-transfer`: "availability" is now a function of the device/app being open, not a hosted service's uptime.)**
- RPO 15 minutes / RTO 1 hour for the transfer-request datastore. **(Moot for `employee-internal-transfer`, ADR-0004: no server-side datastore to back up/restore — data lives only on the employee's device, with the data-loss profile that implies. Not raised as a requirement in BRD-001, so not solved here.)**

## Versioning Rules
- APIs consumed by other One-Point Portal modules or downstream systems are semver. Breaking changes require a major version bump, an ADR documenting the break, and a minimum 30-day deprecation window communicated to consuming teams.

---
**Note on assumptions:** Items above marked implicitly as defaults (backend stack, exact NFR figures, sponsor identity) are the author's kickoff assumptions where the scope document was silent. They are checkable and challengeable at Gate 1 — see `.ai-context/BRD.md` Open Questions for the corresponding business-side gaps.
