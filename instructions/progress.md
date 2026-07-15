# OpenCode Harness — Progress

## Current status
- [x] Repository scaffold created
- [x] global/AGENTS.md (generic, multi-stack)
- [x] install.sh + install.bat
- [x] harness-init skill
- [x] templates/docs/ (8 files)
- [x] instructions/ reference folder (GUIDE, diagrams, reference docs)
- [x] instructions/reference/ (models, opencode-commands, rtk-workflow)
- [x] Installation flow diagram
- [x] DoD Step 2 hardened with mandatory matrix
- [x] Documentation Session set to auto-run (no ask)
- [x] install.sh protects existing opencode.jsonc
- [x] agent-new-project: template check instead of copy, no external paths

## Known issues
- harness-init not tested on real project yet
- install scripts not tested on clean machine
- `opencode run` is non-interactive — init scripts now use TUI instead

## Next session — plan
- Test make init on recruitment-app
- Fix any issues found during real test

## Git log
- `96a9c5f` — fix: sync install.bat, fix stale 7 to 9 questions refs
