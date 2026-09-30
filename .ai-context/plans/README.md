# plans/

One file per feature, named by slug: `<feature-slug>.plan.md` (Blueprint §9, §10, §13).
Authored only after the corresponding spec is **Approved** at Gate 1.

## Registered slugs
- `employee-internal-transfer` — **v4.0 drafted 2026-09-30 from spec v2.4 (Gate 1 Approved); awaiting Gate 1 plan review.** Plan decisions PD-01–PD-11, flags F-01–F-05, new ADR-0006 (Proposed). v3 (from spec v1.5) kept as `employee-internal-transfer.plan-v3-backup-2026-09-30.md`.
- `employee-registration-login` — **Not followed** (BRD-002 is version control only). Authored (see `employee-registration-login.plan.md`), derived from spec v1.1 (Approved). Local-only auth per **ADR-0005**; entry-flow integration prepends a session check to `AppEntryController`'s existing logic. Cross-feature amendment on `employee-internal-transfer` (`employeeId`) is sequenced here but filed under that feature's own tasks, not this one's.
