# plans/

One file per feature, named by slug: `<feature-slug>.plan.md` (Blueprint §9, §10, §13).
Authored only after the corresponding spec is **Approved** at Gate 1.

## Registered slugs
- `employee-internal-transfer` — authored (see `employee-internal-transfer.plan.md`), derived from spec v1.4 (Approved). No backend — local Hive persistence only, per **ADR-0004** (supersedes ADR-0003's Node/NestJS/PostgreSQL assumption). Pending amendment: `employeeId` scoping (its own future T07), triggered by `employee-registration-login`.
- `employee-registration-login` — authored (see `employee-registration-login.plan.md`), derived from spec v1.1 (Approved). Local-only auth per **ADR-0005**; entry-flow integration prepends a session check to `AppEntryController`'s existing logic. Cross-feature amendment on `employee-internal-transfer` (`employeeId`) is sequenced here but filed under that feature's own tasks, not this one's.
