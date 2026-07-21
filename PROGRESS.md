# Progress Log

## Current Status

Phase: v0.3 — Infrastructure stabilization
Last commit: 5c46838 — refactor(harness): rename existing → adopt
Session language: ru

## Known Issues

- Makefile: duplicate `init` target, empty `setup` target
- `make session-start` target does not exist
- context7 MCP: zero usage in practice (rule exists, no enforcement)
- DoD Step 2 (docs update per mapping) not implemented
- `instructions/reference/` 8 files need consolidation → target 4-5
- `session-end.sh` PROGRESS.md + memory/ warnings expected for meta-project
- `notes/` has 6 stale session artifacts — archive candidate

## Session 2026-07-21 (Analyze quality gate + notes archive)

### Done
- agent-analyze.md: expanded from 4 to 7 skills (context-canary, junior-to-senior,
  code-review-and-quality); reordered logically; Quality Gate (≥5 concrete
  findings with file+line); report sections: Context Check, Senior Review, Quality
- Archived stale premortems (07-07/07-08) → notes/old/
- Synced global/AGENTS.md → ~/.config (language persistence)
- Verified Directus 11 wildcard gotcha doc fix

### Next
- Consider running `analyze` on a real project to validate the new skill stack
- On Directus prod migration: remove admin_access, replace with per-collection grants
- Consider merging `instructions/reference/` (8 files → 4-5)

## Session 2026-07-20 (Directus MCP — per-project generated config)

### Done
- **Architecture:** Directus MCP is now per-project from `.env`. Removed the
  global `directus` block from `~/.config/opencode/opencode.jsonc` and deleted
  the `switch-directus` shortcut/logic everywhere. No global Directus MCP to
  switch — each project gets its own gitignored `opencode.jsonc`.
- **scripts/gen-opencode.sh** (new) — reads `.env` (`DIRECTUS_URL` +
  `MCP_DIRECTUS_TOKEN`), merges the global OpenCode config, writes a local
  `opencode.jsonc` with the per-project `directus` block.
- **Makefile** — added `mcp` target. **scripts/start.sh** — regenerates
  `opencode.jsonc` from `.env` before launching OpenCode.
- **templates/.env.example** (new) — `DIRECTUS_URL` + `MCP_DIRECTUS_TOKEN`
  placeholders; `init-project.sh` copies it to `.env` when absent.
- **instructions/directus-mcp-setup.md** — rewritten: enable MCP server, create
  Access Policy → Role → User → Static Token, `.env`, `make mcp`, open project.
- **global/AGENTS.md** — Session Start step 7 simplified (local `opencode.jsonc`
  used automatically; else warn to create `.env` + `make mcp`). Synced to
  `~/.config/opencode/AGENTS.md`.
- **README.md** — removed `switch-directus`; `## Directus MCP` now per-project.

### Known issues
- (none)

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
  - init scripts: hook installation appended to init-project.sh and init-adopt.sh
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
  - Removed 6 downloadable skills from global/skills/ (not in repo — installed via npx skills add JuliusBrussee/skills -y)
  - Updated scripts/install.sh: added npx skills add JuliusBrussee/skills -y + copy .agents/skills/ to OpenCode config
  - Updated scripts/update.sh: added JuliusBrussee skill enrichment on make update
- Problems:
  - Russian-language trigger removed from junior-to-senior — rejected by DoD cyrillic check, removed per user confirmation
- Next:
  - v0.4 planning
  - Test: fresh `git clone && make setup` on clean machine
  - Add .agents/ .claude/ skills-lock.json to .gitignore

### 2026-07-17 (v0.4 — continued)

- Done:
  - Pushed 3 commits: JuliusBrussee skills install, trigger table, skill repo cleanup
  - scripts/install.sh: added npx skills add + copy to OpenCode config
  - scripts/update.sh: added JuliusBrussee skill enrichment
  - global/skills/: removed 6 downloadable skills (installed via npx)
- Problems:
  - `make update` re-runs npx skills add, creates .agents/ + .claude/ + skills-lock.json artifacts in repo — need .gitignore
- Next:
  - Clean up .gitignore

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

### 2026-07-19 (new-flow fix)

- Done:
  - scripts/init-project.sh: added `--no-open` flag — scaffolds project
    (copies templates, git init, hooks) without launching a second OpenCode
    instance. Used by `new` flow from inside OpenCode.
  - global/skills/harness-init/agent-new-project.md (+ synced to
    ~/.config/opencode/skills/): restructured into 3 phases:
    - Phase 0 — Scaffold: runs `make init PROJECT="$(pwd)" --no-open` BEFORE
      interview, so HARNESS.md/MEMORY.md/PLAN.md/PROGRESS.md/memory/ always exist
    - Phase 1 — fixed interview question order (Q1 name/purpose, Q2 team/auth,
      Q3 stage/deploy, Q4 integrations/sensitive, Q5 design/fields, Q6 plan) +
      HARNESS questions (critical paths, risk levels); MANDATORY restate (4.5)
      with explicit "yes" before any file is written; fill/REWRITE scaffolded
      templates in place (no generate-from-scratch)
    - Phase 2 — formatted hand-off report: lists created files, instructs user
      to open new session and type `start` (continues from roadmap M1)
  - templates/AGENTS.md: restored to PROJECT skeleton (was accidentally
    overwritten with global AGENTS.md) — placeholders only, no global content
  - templates/docs/CONTEXT.md + roadmap.md: cleaned of example domain data
    (Cook/Deduction/Hetzner/Tailwind) — structure + instruction comment only
  - Root cause fixed: `new` previously generated only 6 docs files and missed
    HARNESS/MEMORY/PLAN/PROGRESS/memory/ because the skill never called
    `make init` and ignored templates/
- Problems:
  - templates/AGENTS.md was a duplicate of global AGENTS.md — would have created
    a redundant mirror in every new project; corrected to project skeleton
- Next:
  - Touch-test the `new` flow in an empty folder; verify full file set appears
  - Fix Makefile known issues (duplicate `init` target, empty `setup` target)

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

## Session 2026-07-19 (stack→skill map + sync cleanup)

Session language: ru

### Done
- **Stack → Required Skills** section added to `templates/docs/skills-cheatsheet.md`
  and `instructions/reference/03-skills-cheatsheet.md` (table: technology →
  skill folder → install command). Directus → `npx skills add directus`;
  TypeScript covered by `tdd` + `test-driven-development` (no standalone skill).
- **agent-new-project.md** — new step `4.4 SKILL GAP CHECK` before restate
  (4.5): reads the Stack→Required Skills table, matches against interview
  stack, `ls ~/.config/opencode/skills/<name>` per skill, shows ✅/❌ with
  install command. Informational only — does NOT block the interview.
- **Sync cleanup** — `global/skills/*` mirrored into `~/.config/opencode/skills/`:
  harness-init (agent-analyze, agent-adopt, SKILL), security (SKILL +
  06-directus-nuxt.md was missing), session-start, code-reviewer. All 25 skill
  files now in sync; AGENTS.md in sync.
- **session-start/SKILL.md** — output block translated RU→EN (English-Only Policy
  for global/ files).

### Known issues
- (none new)

## Session 2026-07-19 (rename existing → adopt)

Session language: ru

### Done
- Renamed shortcut `existing` → `adopt` (global/AGENTS.md + ~/.config/AGENTS.md
  + repo AGENTS.md + README + INSTALL + GUIDE).
- Renamed skill file `agent-init-existing.md` → `agent-adopt.md` (global/ +
  ~/.config), updated all cross-references (SKILL.md, agent-analyze.md, GUIDE,
  04-skill-stacks, README, INSTALL, PROGRESS).
- Renamed Makefile target `init-existing` → `init-adopt`; updated all docs.
- Renamed script `scripts/init-existing.sh` → `scripts/init-adopt.sh` (git mv),
  updated internal references + install-hooks.sh comment.
- Renamed `04-skill-stacks.md` section `existing-project` → `adopt-project`.
- All 25 skill files verified in sync (global/ ↔ ~/.config); AGENTS.md synced;
  bash syntax OK; no Cyrillic introduced.

### Known issues
- (none)

---

## Session — Directus MCP setup strategy

### Done
- Added `instructions/directus-mcp-setup.md`: full guide for the Directus MCP
  server — mcp service-account user creation (scope = developer's choice:
  read-only or read+write), global shared `Bearer` token in
  `~/.config/opencode/opencode.jsonc` (`type: remote`, `url`, `headers.Authorization`),
  per-project URL auto-correction on Session Start, per-project `opencode.jsonc`
  override, and `switch-directus` semantics.
- Updated `global/AGENTS.md` Session Start step 7: local project `opencode.jsonc`
  takes priority (fully overrides global, skips mismatch check); MCP URL now read
  from `mcpServers.directus.url` with `Bearer` auth. Synced to ~/.config/AGENTS.md.
- Shortened `README.md` `switch-directus` section to 3 lines + link to the setup guide.
- Added `opencode.jsonc` to `templates/.gitignore` (init-project.sh copies
  .gitignore only when absent — override stays per-project, gitignored).
- Added Directus `mcp` user reminder to hand-off of both `agent-new-project.md`
  and `agent-adopt.md`. Synced to ~/.config/skills/.
- All modified batch files verified Cyrillic-free; bats tests pass (14/14).

### Known issues
- (none)

---

## Session — README cleanup (top-level commands only)

### Done
- README.md: removed Fallback make-commands block, Symlink block, and From
  terminal block. Kept only OpenCode shortcuts (`new`/`adopt`/`analyze`/
  `update-harness`/`sync-templates`/`switch-directus`), Daily Workflow trigger
  words, and links to INSTALL.md / GUIDE.md. Terminal `make` commands remain
  documented in INSTALL.md and instructions/GUIDE.md.
- Verified no make command was lost — `make link`, `make init`, `make start`
  all still present in INSTALL.md / GUIDE.md.

### Known issues
- (none)

---

## Session 2026-07-21 (fix: agent-new-project.md — test_3 bugs)

Session language: ru

### Done
- **P1**: Removed duplicate step 11 from Phase 1 (design.md reminder inlined in Phase 2)
- **P2**: Added session language instruction before hand-off block
- **P3**: Reformatted hand-off with visual frames (━━━), ✅📋🚀⚠️ sections, marketplace URLs
- **P4**: Added skill gap box after step 4.4, repeated in hand-off
- **P5**: Added brainstorming explanation frame before step 5
- **P6**: Replaced weak batch-write rule with VIOLATION-level hard rule
- **P7**: Stripped template example data (#8966FA, Jost, h-56px, phosphor-icons) → TBD
- **P8**: Removed TypeScript pinning and example gotchas from templates/MEMORY.md
- **P9**: Changed step 4.4 from table-based gap to dynamic `ls` check
- **P10**: Updated instructions/reference/04-skill-stacks.md new-project section
- **Cyrillic cleanup**: Removed from 5 project files (agent-new-project.md ×2, design.md, MEMORY.md, 04-skill-stacks.md)
- **Mirror verified**: global/skills/ and ~/.config/opencode/skills/ agent-new-project.md are identical
- **make verify**: 8/8 passed

### Next
- Close session

## Session 2026-07-21 (ostatok reorg + cleanup)

### Done
- **`notes/harness/ostatok-po-versii-0.3.md`** — reorganised: deduplicated from ~15
  source docs, sorted P0→P3→DEAD→Completed, with priority tables
- **`notes/harness/ostatok-po-versii-0.3.full.md`** — created: full reference with
  per-document tables, colored status markers (🔴🟡🟢), no deduplication
- **`notes/AGENTS.reality-check.md`** → `notes/harness/old/` — moved out of root
  `notes/`, removed from git tracking (`git rm --cached`)
- **Status corrections**: marked superpowers issue ✅ (user confirmed resolved),
  stale question count ✅ (GUIDE/INSTALL/diagram already clean)
- New `notes/harness/old/` directory for archived documents

### Next
- Live-test cycle: `new` on empty project, `analyze` on RecipeBox/ItoCook,
  `adopt` on non-harness project, clean install on MacBook — fix real issues
- Then: backlog or Sandbox module
