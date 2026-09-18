# tasks/

One file per feature, named by slug: `<feature-slug>.tasks.md` (Blueprint §9, §10).
Generated from the corresponding plan's Sequencing section, reviewed by the engineer.

## Registered slugs
- `employee-internal-transfer` — authored (see `employee-internal-transfer.tasks.md`), 6 tasks (T01–T06), all merged. A 7th task (`T07`, `employeeId` scoping) is planned but not yet added to this file — triggered by `employee-registration-login`'s plan, to be added when that work starts.
- `employee-registration-login` — authored (see `employee-registration-login.tasks.md`), 5 tasks (T01–T05). AC9 deliberately excluded from T05's integration test — depends on `employee-internal-transfer.T07`, not yet written. Not yet implemented.
