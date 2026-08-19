---
name: startup
description: >
  Session Start reference — why each step exists, what breaks without it,
  and the edge cases. The step list itself lives in AGENTS.md
  "## Session Start"; this file follows it one-for-one and never renumbers.
---

# Startup Ritual — Full Reference

Loaded when AGENTS.md Session Start section says to load this skill.
Use when you need the reasoning behind a step, or hit an edge case.

## Why this exists

`~/.config/opencode/AGENTS.md ## Session Start` is the single source of truth for which
steps exist and in what order. This skill adds depth: why each step exists,
what can go wrong, what to do when it does.

**It does not add steps.** Until T-I7 this file announced a "full ritual" of
its own, with more steps than the canon and a different protocol underneath —
not a longer version of the same one — an agent that dutifully loaded "the full version" got a *different*
startup than the canon. Both lists are now checked against each other
by a linter that runs in the harness repo (`make check-docs-sync`) and in
CI, so they cannot drift apart again silently.

## The ritual, step by step

Run in order. If any step fails — stop and report before continuing.

### Step 1 — Orient

```bash
pwd
git log --oneline -10
```

Verifies you are in the right project. If wrong — `cd` to the correct path
before anything else.

Git is the source of truth. `MEMORY.md` and `PROGRESS.md` are optimistic:
they record what someone *meant* to finish. When they disagree with git,
git wins.

**Environment check.** Also confirm that whatever the project needs to run
is actually running — `docker ps`, dev server, `curl localhost:PORT`. Doing
it here costs seconds; discovering it after a failed command costs a
debugging detour into a problem that was never in the code.

### Step 2 — Load skills

Filesystem path first: `Read ~/.config/opencode/skills/using-agent-skills/SKILL.md`.
If not found (built-in skill) — load via `skill("using-agent-skills")`.

Then the project's own:

- **Stack skills** — project `AGENTS.md`, "Stack Skills" section. These are
  the per-project skills someone deliberately picked for this codebase.
- **Task-specific context** — the "Task Context" table in project `AGENTS.md`,
  and `docs/skills-cheatsheet.md`, matched against what the user just asked
  for. Loading an extra skill costs a `Read`; missing a required one costs a
  real defect.

### Step 3 — Progress

Read `PROGRESS.md` in the project root, then compare it against the git log
from step 1. Out of sync — progress claims undone work, or misses work that
landed — update `PROGRESS.md` FIRST, before touching anything else.
No `PROGRESS.md` — skip; do not create one here.

**Chat language.** Look for a line starting with `Chat language:`.
Present — use that language for chat, always English for generated files.
Absent — ask, then write `Chat language: <chosen>` into `PROGRESS.md` so
the question is asked once in the project's lifetime, not once per session.

### Step 4 — Roadmap

Read `docs/roadmap.md`. This is where the current phase comes from for the
report in step 8. Missing — say so in the report rather than inventing a
phase.

### Step 5 — Memory

Read `MEMORY.md` if present, and `memory/YYYY-MM-DD.md` for today or
yesterday. Yesterday matters: a session that ended late leaves its notes
under a date that is no longer today, and those notes are usually the ones
explaining why the code looks the way it does.

Do NOT create these files here — they are optional, and an empty one created
at startup is worse than none (it looks like "nothing happened" rather than
"nobody wrote it down").

### Step 6 — Harness constraints

Read `HARNESS.md` if present. Apply its Product contract and risk levels
(High/Medium/Low) to how you behave for the rest of the session — it is the
project's own statement of what must not break.

Do NOT create it if missing.

### Step 7 — Directus MCP

Only if the project uses Directus (`.env` has `DIRECTUS_URL`, or `HARNESS.md`
declares an instance):

- A project-level `opencode.jsonc` exists — it is already in use, OpenCode
  picked it up at start and it fully overrides the global config. **Read
  only, never modify it here.**
- No local `opencode.jsonc` — warn the user that Directus MCP is not
  configured for this project, and point at `.env` plus
  `bash ~/.opencode-harness/scripts/gen-opencode.sh "$(pwd)"`.

There is no global Directus config to compare against and nothing to switch
between: do not "fix" this by editing configs during startup.

### Step 8 — Report

Before writing any code:

```
Session initialized. Phase: [from roadmap]. Last commit: [hash — msg].
Progress: [from PROGRESS.md current status]. Skills loaded: [list].
```

Keep it under 10 lines. If the next step is genuinely unclear from
`PROGRESS.md` and the roadmap, ask **one** clarifying question before
proceeding — do not guess, and do not open the session with an interrogation.
