---
name: dod
description: >
  Full Definition of Done reference with per-step checklists, examples, and
  edge cases. Mirrors global/AGENTS.md ## Definition of Done exactly — same
  steps, same numbers, same order. This file never defines its own step.
---

# Definition of Done — Full Reference

Loaded when AGENTS.md Definition of Done section says to load this skill.

## Why this exists

`global/AGENTS.md` ## Definition of Done is the single source of truth for
WHICH steps exist and in what order. This skill adds: per-step checklists,
examples, edge cases. If this file and AGENTS.md ever disagree on step
content or count — AGENTS.md wins; this file is stale and must be fixed to
match, not the other way around.

## When to run

Triggered by:
- Saying "done", "ready", or "finished"
- Running `git commit` (Session End Protocol calls DoD first)
- User asks "is it done?" or "check before commit"

## The full rule

BEFORE saying "done", "ready", or "finished" — execute every step below.
Skipping any step is a violation. "I only did X in this prompt" is NOT an
excuse. Look at the ENTIRE conversation window, not just the last action.

---

### STEP 1 — Session scan (do first)

```bash
git log --oneline origin/main..HEAD
```

List EVERYTHING created, modified, or deployed this session:
- New Directus Flows (created/deployed to production)
- Directus collections / fields
- Composables / server routes / utilities
- Pages / components
- Config / Docker / nginx / deploy scripts
- Any other file touched

Write this list explicitly. Use it as input for every step below.
If git log shows nothing but you did work — still list what you did.

---

### STEP 2 — Update docs (per Docs Update Matrix in AGENTS.md)

Checklist:
- [ ] For each item in session scan — find its row in the Docs Update Matrix table
- [ ] Update the matching doc NOW — do not defer to next session
- [ ] `PROGRESS.md`: completed items, known issues, reflects EVERYTHING from
      session scan, not just the last action

DO NOT WAIT. DO NOT SKIP. DO NOT DEFER TO NEXT SESSION.

---

### STEP 3 — JSDoc

Checklist:
- [ ] New composable/module created → JSDoc added
- [ ] Existing composable/module significantly modified → JSDoc updated
- [ ] New component with non-trivial logic → JSDoc added
- [ ] New server route or API endpoint → JSDoc added
- [ ] New utility function → JSDoc added

---

### STEP 4 — Tests

Checklist:
- [ ] If test suite exists — run it: all tests must pass
- [ ] If new feature — add at least one test
- [ ] If no test suite exists — skip this step

---

### STEP 5 — Commit Gate

This is a DIFFERENT kind of check from steps 1-4: it is a mechanical,
exit-code-enforced script (`~/.opencode-harness/scripts/dod.sh`), not a judgment call.

**This runs automatically** via the pre-commit hook on every `git commit`
— no manual command needed, and it must exit 0 for the commit to succeed.
To run it manually as a pre-check before committing:

```bash
make dod                              # only if this project has a Makefile
bash ~/.opencode-harness/scripts/dod.sh   # works everywhere else (client projects)
```

Must exit 0. If it fails:
- Read the failing step's output — it tells you exactly what to fix
- Fix the actual problem — do NOT run `git commit --no-verify` to skip it.
  If you believe the failure is a false positive, STOP and ask the user
  before bypassing anything — see Hard Limits in AGENTS.md.

---

### STEP 6 — Safety check

Checklist:
- [ ] No Russian text introduced in project files
- [ ] No .env, docker-compose, lock files modified without confirmation

---

### STEP 7 — Skill feedback

Checklist:
- [ ] Did any skill behave unexpectedly or miss an important step?
- [ ] If yes — noted in memory/YYYY-MM-DD.md what happened and expected behavior

---

### STEP 8 — Cleanup

Checklist:
- [ ] Uncommitted changes are intentional (not leftover debug code)
- [ ] No console.log or debug code committed unless intentional
- [ ] No TODO/FIXME left without a note explaining why it's deferred

---

### STEP 9 — Respond to user

Only after ALL steps 1-8 are confirmed — respond.

If this project defines a `make self-check` target — run it as part of
Step 5. Most projects do not have this target (it is specific to the
opencode-harness meta-repo); skip if absent.

## Checklist format

Use this format for each step in your response:
```
### STEP 1 — Session scan
[•] Scanning...

### STEP 2 — Docs update
[ ] No significant changes this session
```

- `[ ]` = not done yet
- `[•]` = in progress
- `[✓]` = confirmed done (only mark after execution)
