# Auto-Log Instruction

After every completed task (spec, plan, task, or implementation increment), append an
entry to `.ai-context/prompt_history.md` with:
- Date
- Actor (engineer running the session)
- Task ID, if applicable (e.g. `employee-internal-transfer.T03`)
- Prompt summary
- Files touched
- Outcome (merged / in review / blocked, and why)

This is the audit trail — it exists so no engineer has to remember to write it after
the fact. It is distinct from `status.md`, which is the human-curated daily summary of
what's in flight (Blueprint §21.2).
