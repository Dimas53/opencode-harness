---
name: startup
description: >
  Full startup ritual reference with explanations and edge cases.
  Deeper version of the compact Session Start in AGENTS.md.
---

# Startup Ritual — Full Reference

Loaded when AGENTS.md Session Start section says to load this skill.
Use when you need the full ritual with explanations and edge cases.

## Why this exists

The compact version in AGENTS.md (6 steps) is the minimum viable startup.
This skill adds depth: why each step exists, what can go wrong, edge cases.

## Full 12-Step Ritual

Run in order. If any step fails — stop and report before continuing.

**Step 1 — Confirm directory**
```bash
pwd
```
Verifies you're in the right project. If wrong — cd to correct path first.

**Step 2 — Read git log**
```bash
git log --oneline -10
```
Git is the source of truth. MEMORY.md is optimistic. If they disagree — git wins.

**Step 3 — Read MEMORY.md (if exists)**
Check project root for `MEMORY.md`. Read it if present.
Do NOT create it if missing — it's optional.

**Step 4 — Read today's memory log (if exists)**
If `memory/YYYY-MM-DD.md` exists for today or yesterday — read it.

**Step 4b — Read HARNESS.md (if exists)**
Check project root for `HARNESS.md`. Read it if present.
Apply project constraints (Product contract) and risk levels (High/Medium/Low) to session behavior.
Do NOT create it if missing — it's optional.

**Step 5 — Check environment**
Verify dev server, Docker containers, or other services are running if the project needs them.
Typical checks: `docker ps`, `curl localhost:PORT`, `npm run dev` status.

**Step 6 — Load global skill**
Try filesystem first: `Read ~/.config/opencode/skills/using-agent-skills/SKILL.md`.
If not found (built-in skill) — load via `skill("using-agent-skills")`.

**Step 7 — Load stack skills**
Check project `AGENTS.md` for "Stack Skills" section (per-project skills list).
Load all listed skills.

**Step 8 — Read PROGRESS.md**
```
Read PROGRESS.md in project root
```

**Step 9 — Sync check**
Compare git log with `PROGRESS.md`. If they're out of sync (progress mentions undone work or misses completed work) — update `PROGRESS.md` FIRST before anything else.

**Step 10 — Read roadmap.md**
```
Read docs/roadmap.md
```

**Step 11 — Load task-specific context**
Check project AGENTS.md "Task Context" table and load relevant docs.
Check `docs/skills-cheatsheet.md` and load relevant skills per triggers.

**Step 12 — Report session start**
Before writing any code, output:
```
✓ Session initialized.
Current phase: [phase name from roadmap]
Last commit: [hash — message]
Progress status: [one line from PROGRESS.md current status]
Working on: [what user asked for]
Skills loaded: [list]
```
