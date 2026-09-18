# Workflow: /code-review

Use at Gate 2, against a specific task's diff.

**Prompt template:**
"Review the diff for `<slug>.T0N` against `<slug>.spec.md` AC `<slug>.ACN` and the
Security Checklist (Blueprint §30). Check: AC satisfied, no AI-attribution in
comments/commits, no PII in logs, dependencies vetted, error/failure paths covered,
consistency with `.ai-context/architecture.md`. Report gaps only — do not silently
fix and report clean."

**Do not:** approve without checking the Constitution Check section of the linked
plan for anything the plan explicitly deferred — scope-creep into deferred items is
a Gate 2 finding, not a bonus.
