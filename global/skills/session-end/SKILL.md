---
name: session-end
description: >
  Session end protocol with edge cases, troubleshooting, and examples.
  Explains what ~/.opencode-harness/scripts/session-end.sh checks and why;
  the script itself does the docs lag check, PROGRESS.md freshness, memory
  log, audit trail and the .session-ended guard — reading this file does
  not replace running it.
---

# Session End Protocol — Full Reference

Loaded when AGENTS.md Session End section says to load this skill.

## Quick reminder

The protocol in AGENTS.md `## Session End` is mandatory — read it there, it is the single source of truth for which steps exist. Never restate the count here: it drifts the moment a step is added, and AGENTS.md explicitly forbids hardcoding it.
This skill adds: edge cases, troubleshooting, examples.

## Step details

> **Read this first.** The steps below describe **what the script checks and
> why** — they are not a manual alternative to running it. The run itself is
> one command:
>
> ```bash
> bash ~/.opencode-harness/scripts/session-end.sh
> ```
>
> Doing these checks by hand instead is how the mechanical gate ended up
> never running in a real session: the audit trail, the Retro nudge and the
> `.session-ended` guard only exist if the script executes.

### Step 1 — Docs lag check *(the script does this)*
**Why:** Documentation falls behind quickly. Past the threshold in
`AGENTS.md ## Session End`, a gap means someone won't understand the code.

**Edge cases:**
- If there are NO docs commits yet → the script skips the check
- If only auto-generated docs changed → warn but less urgently
- If user says "skip docs" → respect, but note it in PROGRESS.md

### Step 2 — Uncommitted changes: show and ask
```bash
git status
```
Committing is a decision for the user, not a step to execute — `AGENTS.md`
Behavior says never commit without explicit confirmation. Show what is
uncommitted, ask, and only then commit, staging named paths or `git add -p`.

**Never `git add -A` here.** It stages whatever else happens to be in the
tree — scratch files, half-finished work, a stray `.env` — in the one step
where nobody is reviewing the diff.

**Edge cases:**
- Nothing to commit → skip step silently
- User declines → list the uncommitted paths in the Session closed report
- Hooks fail → report error, ask user
- Large diff → ask user what to commit

### Step 3 — Update PROGRESS.md
Write: what was done, what was NOT done, known issues discovered.

**Format:**
```
## Current status
[date]: [summary of what was done]

## Known issues
- [any new issues discovered]

## Next session plan
1. [next concrete step]
2. [next concrete step]
```

### Step 4 — Save workarounds
If you found a workaround or important error this session — write to `memory/YYYY-MM-DD.md` NOW.
Do not wait for session end. This is mandatory.

**Example:**
```
# YYYY-MM-DD

## Workarounds
- Package X v3.2 has bug Y — use v3.1 or apply patch Z

## Errors
- Docker compose fails on M1 Mac if not using platform linux/amd64
```

**Session audit trail (T-H5)** — proof of what actually ran this session,
not just what the diff shows. Add a section to the same
`memory/YYYY-MM-DD.md` file whenever this session ran DoD more than once,
used `DOD_SKIP`, or hit a `--no-verify`/post-commit-guard rollback:
```
## Session audit trail
- DoD ran N times this session; result: [pass / pass with warnings / had to fix a fail]
- DOD_SKIP used: [step name + why] / none
- post-commit guard rollback triggered: [yes, once — cause] / no
```
This is intentionally lightweight — a record for the next session (and for
the human) of what was actually enforced, not a new mechanism. A fuller
active gate (eval-loop measuring this automatically) is Wave F T-F2/T-F4,
not this skill.

**Where the data comes from.** `session-end.sh` builds that section from
`.dod-run.log` — one line per DoD run (timestamp, mode `pre-commit`/`manual`,
pass/fail/warn counts, `DOD_SKIP`). It is local and gitignored. Two
consequences worth knowing:

- **Never delete `.dod-run.log`.** It looks like scratch output and is not.
  Without it the audit trail section is silently skipped — a failure with no
  error message. The post-commit guard also reads it, to tell a real
  `--no-verify` bypass from a gate disagreement (T-I27).
- **`.session-ended`** is the other state file: a single date written at the
  end of a session, read by `start.sh` to notice a session that was never
  closed. Also not clutter, also not to be deleted.

**Retro (mandatory, not optional)** — one line each, even if the answer is
"nothing":
```
## Retro
- What went wrong this session: [...] / nothing
- Workaround found: [...] / none
- Skill behaved unexpectedly: [which skill, what happened, what was expected] / none
```
This is DoD step 7 (Skill feedback) generalized to the whole session, not
just skills — the same place, one broader habit.

### Step 5 — Report
```
Session closed.
Done: [what was accomplished — be specific]
Next: [top 1-2 items from next session plan]
```

### Step 6 — Push
Only after steps 1-5 are complete.

## When protocol doesn't run

- User closes terminal without saying "end" — no protocol
- User says "end" but no changes made — just report

## Orchestration

`git commit` → run Definition of DoD first (see skills/dod/SKILL.md)
`git push` or user says "end/конец/done" → run this protocol

These triggers are already in AGENTS.md Behavior section.
