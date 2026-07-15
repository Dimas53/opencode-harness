# Definition of Done — Full Reference

Loaded when AGENTS.md Definition of Done section says to load this skill.

## Why this exists

The compact version in AGENTS.md (6 steps) is the mandatory checklist.
This skill adds: per-step checklists, examples, edge cases.

## When to run

Triggered by:
- Saying "done", "ready", or "finished"
- Running `git commit` (Session End Protocol calls DoD first)
- User asks "is it done?" or "check before commit"

## The full rule

BEFORE saying "done", "ready", or "finished" — execute every step below.
Skipping any step is a violation.
"I only did X in this prompt" is NOT an excuse.
Look at the ENTIRE conversation window, not just the last action.

---

### STEP 0 — Session scan (do first)

```bash
git log --oneline origin/main..HEAD
```

Also list EVERYTHING created, modified, or deployed this session:
- New Directus Flows (created/deployed to production)
- Directus collections / fields
- Composables / server routes / utilities
- Pages / components
- Config / Docker / nginx / deploy scripts
- Any other file touched

Write this list explicitly. Use it as input for every step below.
If git log shows nothing but you did work — still list what you did.

---

### STEP 1 — PROGRESS.md update

Checklist:
- [ ] Completed items moved to "Current status"
- [ ] New known issues added if any discovered
- [ ] Next session plan updated
- [ ] Git log section or commit hash noted
- [ ] Reflects EVERYTHING from session scan, not just last action

---

### STEP 2 — Architecture docs

Checklist:
- [ ] For each item in session scan — ask: "Is there a doc that describes this?"
  - YES → update it now
  - NO and item is significant → create docs/architecture/feature-name.md

Significant = new page, Flow, collection, composable with business logic, external service
NOT significant = CSS tweak, typo fix, minor UI change

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
- [ ] If test suite exists — run: all tests must pass
- [ ] If new feature — add at least one test
- [ ] If no test suite exists — skip this step

---

### STEP 5 — Safety check

Checklist:
- [ ] No Russian text introduced in project files
- [ ] No .env, docker-compose, lock files modified without confirmation

---

### STEP 5b — Skill feedback

Checklist:
- [ ] Did any skill behave unexpectedly or miss an important step?
- [ ] If yes — noted in memory/YYYY-MM-DD.md what happened and expected behavior

---

### STEP 6 — Cleanup

Checklist:
- [ ] Uncommitted changes are intentional (not leftover debug code)
- [ ] No console.log or debug code committed unless intentional
- [ ] No TODO/FIXME left without note

---

### Respond to user

Only after ALL steps are confirmed — respond.

## Checklist format

Use this format for each step in your response:
```
### STEP 1 — PROGRESS.md
[•] Updating...

### STEP 2 — Architecture docs
[ ] No significant changes this session
```

- `[ ]` = not done yet
- `[•]` = in progress
- `[✓]` = confirmed done (only mark after execution)
