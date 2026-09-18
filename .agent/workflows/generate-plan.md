# Workflow: /generate-plan

Use after a spec reaches **Approved** status at Gate 1.

**Prompt template:**
"Read `.ai-context/specs/<slug>.spec.md` and `.ai-context/constitution.md`. Draft
`.ai-context/plans/<slug>.plan.md` following the Blueprint §29 plan.md skeleton:
Architecture Approach, Data Model, Constitution Check (line-by-line against
constitution.md), Explicitly Deferred, Sequencing. Flag anything the constitution
requires but the spec is silent on, rather than assuming a default."

**Do not:** generate tasks or code in the same pass — plan first, review at Gate 1
(plan continuation), then generate tasks separately.
