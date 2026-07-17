# Session End Protocol — Full Reference

Loaded when AGENTS.md Session End section says to load this skill.

## Quick reminder

The compact 6-step protocol in AGENTS.md is mandatory and fail-proof.
This skill adds: edge cases, troubleshooting, examples.

## Step details

### Step 1 — Docs lag check
```bash
git log --oneline -- docs/ | head -1
git log --oneline | head -1
```
**Why:** Documentation falls behind quickly. 3+ commits gap means someone won't understand the code.

**Edge cases:**
- If there are NO docs commits yet → skip check
- If only auto-generated docs changed → warn but less urgently
- If user says "skip docs" → respect, but note it in PROGRESS.md

### Step 2 — Commit uncommitted changes
```bash
git add -A && git commit -m "type: description"
```
**Edge cases:**
- Nothing to commit → skip step silently
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
`git push` or user says "end / done / bye / Ende / fertig" → run this protocol

These triggers are already in AGENTS.md Behavior section.
