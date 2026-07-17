# Progress Log

## Current Status

Phase: v0.3 — Infrastructure stabilization
Last commit: 16ef9d8 — feat: add make start launcher

## Known Issues

- Makefile: duplicate `init` target, empty `setup` target
- `make session-start` target does not exist
- context7 MCP: zero usage in practice (rule exists, no enforcement)
- DoD Step 2 (docs update per mapping) not implemented
- `instructions/reference/` 8 files need consolidation → target 4-5
- `session-end.sh` PROGRESS.md + memory/ warnings expected for meta-project
- `notes/` has 6 stale session artifacts — archive candidate

## Session Log

### 2026-07-16

- Done:
  - Full Harness audit → notes/harness-audit-2026-07-16.md
  - Reality-check annotation → notes/AGENTS.reality-check.md
  - Short & mean version → notes/AGENTS.short-and-mean.md
  - Project-level AGENTS.md in root (100 lines, harness-specific)
  - scripts/dod.sh — DoD checker (uncommitted + cyrillic + docs lag)
  - scripts/install-hooks.sh — installs pre-commit hook into .git/hooks/
  - hooks/pre-commit — blocks commit unless `make dod` passes
  - scripts/session-end.sh — session end checks (docs lag + PROGRESS + memory)
  - Pre-commit hook installed, verified blocking real commits
  - global/AGENTS.md: added `dod` shortcut, replaced Technology Standards with triggers table
  - init scripts: hook installation appended to init-project.sh and init-existing.sh
  - Fixed session-end.sh SIGPIPE 141 bug (head -1 under set -o pipefail)
- Problems:
  - ~70% of Harness rules not enforced (documented in audit)
  - pre-commit hook didn't differentiate staged/unstaged on first run — fixed
- Next:
  - Replace context7 auto-trigger with honest manual rule (done 2026-07-17)
  - Add PROGRESS.md check to `make dod`

### 2026-07-17

- Done:
  - PROGRESS.md: stale no longer blocks, changed to warn only (8998a6d)
  - global/AGENTS.md: session start reduced 9→7 steps, doc check merged into session-end (66bb8c7)
  - scripts/start.sh — `make start` launcher for full session init (16ef9d8)
  - Makefile: added `start` target
  - Replaced automatic context7 triggers with "Honesty Over Guessing" rule in global/AGENTS.md
  - Updated templates/AGENTS.md context7 description to manual-only
  - tests/agents.bats — 14 tests (all scripts exist + bash -n + no TODO)
  - Makefile: added `test-quick` and `test` targets
  - `make test-quick` — 20/20 tests pass (6 templates + 14 agents)
- Problems:
  - context7 auto-trigger was aspirational and never enforced — replaced with honest approach
- Next:
  - Memory save: upgrade from warning to fail in `make session-end`
  - Documentation Session shortcut: remove auto-trigger, add manual `docs` shortcut

### 2026-07-17 (late)

- Done:
  - .session-ended guard: session-end.sh creates it, start.sh warns if missing/stale
  - .gitignore: added .session-ended
  - dod.sh step 5: docs matrix check — warns if code changed but no docs updated
  - dod.sh: renumbered 1-5 → 1-6
  - session-end.sh: creates .session-ended on close
  - start.sh: checks .session-ended on open, warns if missing or >1 day old
  - notes/AGENTS.reality-check.md: full update — all v0.3 fixes marked, compared vs audit/overview/workflow
  - session-end.sh: memory check upgraded from warning to fail if session has git changes
  - global/AGENTS.md: Documentation Session auto-trigger removed, `docs` shortcut added
  - scripts/update.sh: fixed /dev/tty bug — no-TTY auto-applies, interactive prompts use [ -t 0 ]
- Problems: none
- Next:
  - v0.4 planning — decide scope

### 2026-07-17 (v0.3 → v0.4 startup)

- Done:
  - Installed 8 skills from JuliusBrussee/skills (caveman, context-canary, fuck-slop, grill-me, interface-kit, junior-to-senior, last-20-percent, loop-factory)
  - Added junior-to-senior skill to global/skills/ and deployed via make update
  - global/AGENTS.md: updated codebase-health-check triggers (added "assess", removed "DRY, duplication, assess codebase")
  - global/AGENTS.md: added junior-to-senior skill entry with triggers "review, improve quality, make it better"
  - global/AGENTS.md: added "Function max 25 lines. Component max 150 lines." rule to Code Style
  - templates/AGENTS.md: synced all three changes
  - instructions/reference/03-skills-cheatsheet.md: added junior-to-senior and codebase-health-check
  - Moved 5 more skills to OpenCode config (context-canary, fuck-slop, interface-kit, last-20-percent, loop-factory)
  - Added all 5 skills to the Auto-Loading trigger table in global/AGENTS.md + templates/AGENTS.md
- Problems:
  - Russian-language trigger removed from junior-to-senior — rejected by DoD cyrillic check, removed per user confirmation
- Next:
  - v0.4 planning

### 2026-07-17 (v0.3 closing)

- Done:
  - dod.sh step 5: check_warn → check_fail — docs matrix now blocks commit
  - dod.sh step 5: exclude PROGRESS.md + notes/ from code check, add instructions/ as valid docs dir
  - dod.sh: replace head -1 with sed -n '1p' — eliminate SIGPIPE 141
  - global/AGENTS.md: removed Russian trigger words from Session End + DoD
  - global/AGENTS.md: added German session-end triggers (Ende, Schluss, fertig, tschüss, bis dann)
  - templates/AGENTS.md: synced from global
  - global/skills/session-end/SKILL.md, code-reviewer/SKILL.md: removed Russian
  - GUIDE.md, README.md, 02-opencode-commands.md: updated session lifecycle docs
  - ~/.config/opencode/AGENTS.md: auto-synced via make update
- Problems: none
- Next:
  - v0.4 — plan and execute

## Git Log

- `f158e7b` — fix: replace head -1 with sed -n '1p' in dod.sh to avoid SIGPIPE
- `c1b8b3d` — fix: remove Russian trigger words from AGENTS.md, update docs
- `d9f5b12` — fix: dod.sh step 5 check_warn → check_fail, exclude PROGRESS.md + notes/
- `16ef9d8` — feat: add make start launcher
- `66bb8c7` — refactor: session start 9→7 steps, merge doc check into session-end
- `8998a6d` — fix: PROGRESS.md stale → warn not fail
- `80eb51b` — docs: add PROGRESS.md with v0.3 state, dod step 4 validates it
- `174e8c6` — fix: session-end.sh SIGPIPE on docs lag check
- `f152663` — feat: add make session-end script
- `e68336b` — docs: translate "What's Not Here" section to English
- `f3e424c` — feat: add project-level AGENTS.md, clean up architecture diagrams
- `f4d16d4` — fix: exclude dod.sh itself from cyrillic scan
- `d09012f` — feat: add make dod, pre-commit hook, fix Makefile
