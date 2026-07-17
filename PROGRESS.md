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
  - Enforce context7 usage (zero calls in practice)
  - Add PROGRESS.md check to `make dod`

### 2026-07-17

- Done:
  - PROGRESS.md: stale no longer blocks, changed to warn only (8998a6d)
  - global/AGENTS.md: session start reduced 9→7 steps, doc check merged into session-end (66bb8c7)
  - scripts/start.sh — `make start` launcher for full session init (16ef9d8)
  - Makefile: added `start` target
- Problems: none
- Next:
  - Enforce context7 usage (zero calls in practice)
  - Add PROGRESS.md check to `make dod`

## Git Log

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
