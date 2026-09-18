# AGENT.md — Read This First

This is the single entry point for **any** AI agent session (Claude Code, Copilot,
Cursor, Gemini, Codex, or otherwise) working in this repository, and for any human
prompt directed at one. Per INT SDD Blueprint §1–§6: no prompt gets actioned against
this codebase without orienting via this file first. If you are an agent reading
this because you were just handed a prompt, stop and go through the steps below
before writing a single line of spec, plan, task, or code.

## The rule that overrides everything else
**No implementation without an approved spec → approved plan → approved tasks.**
This is not the ideal path, it is the only path (Blueprint Principles #1, #2).

If a prompt says "just build X" / "quickly add Y" without pointing at a feature
slug and a task ID: **don't**. Ask which spec/task this maps to, or propose that a
spec be drafted first. Generating code against an unapproved or non-existent spec
is the "vibe coding" anti-pattern this whole workspace exists to prevent
(Blueprint §28) — refuse it even if asked directly, and say why.

## Before you do anything
1. Read `.ai-context/project_context.md` — one-page orientation.
2. Read `.ai-context/constitution.md` — non-negotiables, checked at every Gate 1/Gate 2.
3. Read `.ai-context/status.md` — what's currently in flight, and its exact state.
4. Identify the **feature slug** the prompt relates to. If none exists yet, or the
   request has no corresponding spec, see "If there's no approved spec" below.

## Where everything lives
| What | Where |
|---|---|
| Non-negotiables | `.ai-context/constitution.md` |
| Business requirements | `.ai-context/BRD.md` |
| Discovery analysis (one per slug) | `.ai-context/discovery/<slug>.discovery.md` |
| Specs (one per slug) | `.ai-context/specs/<slug>.spec.md` |
| Plans (one per slug) | `.ai-context/plans/<slug>.plan.md` |
| Tasks (one per slug) | `.ai-context/tasks/<slug>.tasks.md` |
| Spec-derived test cases | `.ai-context/test_cases/<slug>.test_cases.md`, `_integration.md` |
| Living architecture doc | `.ai-context/architecture.md` |
| Architecture decisions | `.ai-context/decisions/ADR-NNNN-*.md` |
| State & progress board | `.ai-context/status.md` |
| Session audit trail | `.ai-context/prompt_history.md` |
| Stack-specific coding rules | `.agent/rules/int-standards.flutter.md` |
| Reusable prompt templates | `.agent/workflows/*.md` |
| Context-scoping ignore rules | `.agent/rules/.agentignore` |

## How to handle a prompt, step by step
1. **Identify slug + current artefact state** from `.ai-context/status.md` (Draft /
   In Peer Review / Approved / Plan Drafted / Plan Reviewed / Tasks Generated /
   In Development / In QA / Ready for Release / Released — Blueprint §21.1).
2. **Match the ask to the correct stage** — don't skip ahead:
   - "Understand/scope this" → Discovery, feeds `.ai-context/BRD.md`.
   - "Write the spec" → author/update `.ai-context/specs/<slug>.spec.md` only. No code.
   - "Review the spec" → Gate 1 checklist (Blueprint §30); reviewer ≠ author.
   - "Plan the approach" → only once spec is **Approved**; `.ai-context/plans/<slug>.plan.md`, Constitution Check section is mandatory.
   - "Break into tasks" → only once plan is reviewed; `.ai-context/tasks/<slug>.tasks.md`, one independently verifiable unit per task.
   - "Implement T0N" → one task, one prompt, referenced by ID. Tests first, confirmed RED, then implementation, then GREEN. Do not touch other tasks.
   - "Review the code" → Gate 2 checklist + Security checklist (Blueprint §30).
3. **Prompt by identity, not description** (Blueprint §16): reference
   `<slug>.T0N`, `<slug>.ACN`, `<slug>.API0N` — never "the transfer-status screen"
   or "the OTP thing". IDs survive edits; descriptions drift.
4. **Scope context to the task** — the spec, the plan, and the specific files the
   task touches. Don't dump the whole repo into context (Blueprint §17,
   `.agentignore`).
5. **Log the work.** After finishing, append an entry to
   `.ai-context/prompt_history.md` (per `.agent/rules/auto-log.md`) and update
   `.ai-context/status.md` the same day. An agent session that doesn't do this
   recreates the exact "ask around to find out what's in flight" problem SDD
   exists to remove.

## Non-negotiables
Full, authoritative list: **`.ai-context/constitution.md`**. Not restated here —
a second copy is how these two documents quietly drift apart. Read it before
touching a spec, plan, or task.

## Ownership for this project
| Role | Name | Email |
|---|---|---|
| Author / Engineer | Indrajit Bhandari | indrajit.bhandari@intglobal.com |
| Gate 1 Reviewer | Shamik Bhattacharya | shamik.bhattacharya@intglobal.com |
| Gate 2 Reviewer | Subhajit Mukherjee | subhajit.mukherjee@intglobal.com |

**Only the named person for each gate may approve it** — verify identity
(name + email) before treating a sign-off as valid; see constitution.md's
Review Authority section (this table must stay in sync with it and with
`project_context.md`'s Stakeholders table).

## If there's no approved spec for what's being asked
Do not guess and generate. Either:
- point the requester at drafting/updating `.ai-context/BRD.md` and the relevant
  spec, or
- if this is genuinely exploratory/spike work, keep it local and unmerged — it
  must graduate to a spec before it touches a reviewed or demoed branch.

## Current state
Not tracked here — **`.ai-context/status.md`** is the one source of truth for
what's active, its status, and what's next. This file previously kept a
duplicate "snapshot" and it went stale within days (still said "Plan Drafted,
next: T01" after all six tasks had shipped) — proof of exactly the drift this
section now refuses to repeat. Read status.md, not this file, for state.
