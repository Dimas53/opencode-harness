# Progress Log

## Current Status

Phase: v0.3 → v0.4 transition
Last commit: 9d8d0c3 — docs: add fix shortcut to reference docs
Chat language: ru

## Session 2026-07-22 (auto-HOME-PATH, Accessing Windows files, make help, rm -rf fix)

Session language: ru

### Done
- **#12 — install.sh**: auto-replace `/YOUR/HOME/PATH` with `$HOME` via `sed -i.bak` after creating opencode.jsonc
- **#11 — INSTALL.md**: dedicated "Accessing your Windows files" section with /mnt/ examples + WSL path tip
- **#13 — README.md**: added `dod` and `docs` to After Setup shortcuts + `make help` hint
- **#14 — Makefile help**: added session-end, start, mcp targets + OpenCode shortcuts (new, adopt, analyze, update-harness, sync-templates, dod, docs)
- **#17 — Safer uninstall**: replaced `rm -rf ~/opencode-harness` with `cd .. && rm -rf opencode-harness` in README.md (1 place) and INSTALL.md (2 places)
- Self-check: all scripts bash -n OK, permissions OK, no trailing whitespace

### Known issues

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

## Session 2026-07-22 (vendor all skills — remove external dependencies)

Session language: ru

### Done
- **Vendored all skills**: copied all 70 skills from `~/.config/opencode/skills/` into `global/skills/`.
  No more dependency on superpowers plugin or JuliusBrussee GitHub repos.
- **Added YAML frontmatter** to 10 custom harness skills (code-reviewer, codebase-health-check,
  documentation, dod, frontend, harness-init, security, session-end, session-start, startup)
- **scripts/install.sh**: removed `opencode plugin add superpowers`, `npx skills add JuliusBrussee`,
  `.agents/skills/` copy — now only `cp -r global/skills/*`
- **scripts/update.sh**: same cleanup + changed from "add new only" to full `cp -r` overwrite
- **global/opencode-config.example.jsonc**: removed superpowers from `plugin` array
- **Removed `.agents/skills/`** — all skills now live in `global/skills/`

### Next
- Test clean `git clone && make setup` on a fresh machine
- On the new MacBook: run `update-harness` and verify all 70 skills land

## Session 2026-07-23 (analyze TARGET, post-commit hook, agent-analyze overhaul)

Session language: ru

### Done
- **agent-analyze.md** — полностью переписан Output format: narrative Architecture, Security текстом, Risks абзацами, source-маппинг к скиллам. Добавлены: Target detection, step 0 (git log diff), step 9a (findings diff), step 10a (verify file). Убран context-canary. Step 11 теперь на языке сессии.
- **analyze <path>** — шорткат в AGENTS.md: `analyze pages/Dashboard.vue` загружает скилл с TARGET. Задокументировано в README, INSTALL, GUIDE, make help.
- **hooks/post-commit** — авто-зеркалирование global/skills/ → ~/.config/opencode/skills/ после каждого коммита
- **install.sh + update.sh** — установка post-commit hook при setup/update
- **Документация** — README, INSTALL, GUIDE, Makefile help обновлены: analyze <path>, generic path examples вместо cook.vue
- **Проверка 4 анализов** — сравнили 0→1→2→4, подтвердили что изменения улучшили качество отчётов

### Known issues
- Post-commit hook не зеркалирует global/AGENTS.md — только skills/. Нужно копировать вручную или расширять hook.
- v0.3 ostatok практически закрыт (6 из 8 P0 решены). Можно начинать v0.4 (Sandbox).

### Next
- v0.4 Sandbox module — архитектура готова (notes/Harness/v0.4 - SANDBOX_ARCHITECTURE.md), можно начинать реализацию

## Session 2026-07-23 (adopt --no-open fix)

Session language: ru

### Done
- **Bug fix**: `agent-adopt.md` Step 0 no longer creates files from agent memory.
  Now calls `init-adopt.sh "$(pwd)" --no-open` — same pattern `agent-new-project.md`
  already uses with `init-project.sh --no-open`.
- **scripts/init-adopt.sh**: added `--no-open` flag parsing (matching init-project.sh).
  With `--no-open`: copies templates + hooks and exits without launching OpenCode.
- **make verify**: 9/9 passed. **bash -n**: all scripts OK.

### Next
- Test adopt on a real project

## Git Log

- `a8169f9` — docs(make): add analyze <path> to help output
- `ab23863` — docs: replace project-specific path examples with generic placeholders
- `7fef804` — docs: add analyze <path> usage to README, INSTALL, GUIDE; remove context-canary from skill stack
- `5c4862e` — fix: support analyze <path> shortcut with TARGET argument
- `5463601` — feat(analyze): TARGET scoping, session language for summary, report filename
- `88f6a1e` — chore: add post-commit hook to auto-mirror skills
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

## Session 2026-07-21 (P15-P19 — template hints, gap→AGENTS, .env rule, PLAN comment, plan-main conditional)

Session language: ru

### Done
- **P15**: templates/HARNESS.md — Product Contract and Decisions to Inherit now have detailed hints with examples
- **P16**: gap check result → auto-write found skills to AGENTS.md Stack Skills + placeholder for missing
- **P17**: Hard rules — forbid creating .env directly (only .env.example)
- **P18**: templates/PLAN.md — comment at top explaining it's empty at new-time, filled during implementation
- **P19**: docs/plan-main.md — created only if Q-1 provided a file, otherwise deleted
- **P13-P14**: applied in previous session (P13 — language ack after Q0, P14 — final end block)
- All mirrors synced (global/ ↔ ~/.config/)
- make verify: 8/8 passed

### Next
- Live-test cycle on real projects

## Session 2026-07-21 (P20-P26 — Q-1 pre-fill, skill-gap hand-off, .env.example)

Session language: ru

### Done
- **P20**: Q-1 rewritten — files are PRE-FILL not interview replacement.
  Full interview Q1→Q6→HARNESS always runs, one question at a time.
  Files only pre-fill answers, agent confirms each before skipping.
- **P21**: Hard rule + step 8 — NEVER delete entries from skills-cheatsheet.md.
  Removed "trim" language, replaced with "ADD only, NEVER delete".
- **P22**: Hand-off now shows both ✅ found and ❌ missing skills
  (was only ❌ before).
- **P23**: AGENTS.md Stack Skills — clear Installed / Missing sections
  with uncommented paths for found, commented # ❌ for missing.
- **P24**: Phase 0 now verifies .env.example after scaffold; copies from
  templates/ if missing. Hard rule strengthened.
- **P25**: skills-cheatsheet.md — inline show→confirm→write requirement.
- **P26**: Hand-off NEXT STEPS — "Add docs/design.md" and
  "Add docs/plan-main.md" shown only if files NOT provided in Q-1.
- All mirrors synced (global/ ↔ ~/.config/); Cyrillic-free; make verify: 8/8

### Next
- Live-test cycle: run `new` with Q-1 files on a real project (test_6)

## Session 2026-07-22 (WSL2/Linux bugs + docs cleanup)

Session language: ru

### Done
- **install.sh**: OS dispatch (brew for macOS, curl for Linux) for uv + RTK;
  `export PATH` before `rtk init` on Linux; `~/.bashrc` PATH persistence;
  git identity prompt at end
- **Makefile**: `chmod +x scripts/*.sh` in setup target; `uninstall` = full
  removal with OS dispatch (brew/rm); new `uninstall-lite` target (harness
  only); new `self-check` target (syntax + permissions + diff)
- **verify.sh**: OS-aware error hints (brew for macOS, curl for Linux);
  new check: script permissions (git ls-files mode 755); added pass/fail
  helper functions
- **dod.sh**: step 7/7 — Self-check (bash -n on all scripts)
- **global/AGENTS.md**: DoD updated — self-check step; synced to
  ~/.config/opencode/
- **INSTALL.md**: Windows section rewritten — git identity step, daily
  workflow, tips (/mnt/c/, Windows Terminal), uninstall options, expanded
  comparison table; API key hint added to Step 5 (both macOS and Windows)
- **README.md**: deduplicated Update/Uninstall blocks under shared
  section; uninstall-lite added; Already Installed? removed (replaced
  by shared Update block)
- **Bug #1 fix**: `git update-index --chmod=+x` for install.sh and
  gen-opencode.sh (were 644 in git index)

### Known issues
- DoD docs matrix check doesn't see INSTALL.md or README.md as docs
  (only checks docs/ and instructions/) — needs fixing
- `make uninstall` removes ~/.config/opencode entirely — may delete
  non-harness configs if user added their own there

## Session 2026-07-22 (uninstall, bugs #5 #6 #8, clean superpowers refs)

Session language: ru

### Done
- **make uninstall** — added `uninstall` (+ symlink, skills, AGENTS.md) and
  `uninstall-full` (+ OpenCode CLI, RTK) targets
- **Bug #5**: `init-project.sh` — replaced relative `templates/` paths with
  `$SCRIPT_DIR/../templates/` (works from any directory)
- **Bug #6**: `install.sh` version check updated `v1.17.20` → `v1.18.4`
- **Bug #8**: `agent-new-project.md` — Phase 0 now asks user confirmation
  before scaffold
- **README.md** — restructured: Quick Start → macOS install block (one code
  block, 6 steps) → Update/Uninstall; removed `chmod +x` workaround,
  removed `git pull` from Already Installed (handled by `make update`)
- **INSTALL.md** — removed `chmod +x` workaround, fixed outdated manual steps
  (config already auto-copied)
- **Superpowers references** — cleaned from GUIDE.md, 03-skills-cheatsheet.md,
  05-skills-inventory.md, 02-opencode-commands.md, 01-harness-overview.de.md,
  templates/docs/skills-cheatsheet.md, verify.sh
- **Makefile** — added `uninstall` + `uninstall-full` to .PHONY and help
- `make verify`: 8/8, `bash -n`: all scripts pass, committed + pushed

### Next
- Windows WSL2 testing when available
- Bug backlog (none remaining in ostatok)

## Session 2026-07-24 (adopt stabilization — P16-P24)

Chat language: ru

### Done
- **P16**: per-file confirmation → batch approval before generation
- **P17**: design.md extraction from tailwind.config.ts, fonts, CSS, icons
- **P18**: skill gap check for AGENTS.md Stack Skills
- **P19**: hand-off with commit/push questions after summary
- **P20**: CONTEXT.md source priority: code → analysis → grill, min 10 terms
- **P21**: ISO language code enforced in Q0 (ru not русский)
- **P22**: dod.sh Cyrillic scan — line-level with docs/audits/ and Chat language exceptions
- **P23**: skills-cheatsheet — copy template, append project section
- **P24**: skill gap section in hand-off block
- Restored domain-modeling skill loading after P20 accidentally removed it
- Fixed hand-off to auto-commit then show summary, push after end
- Fixed Russian text in skill files (English-only policy)
- Two successful adopt test runs (ducito + ticket_tracker) — confirmed stable
- Created agent-fix.md design spec

### Known issues
- Context.md quality still varies between runs (domain-modeling skill application is inconsistent)
- Chat language instruction still competes with file generation (agent writes files in session language before reading Step 4 switch)

### Next
- Implement agent-fix.md (fix shortcut) ← DONE
- Test adopt on a non-trivial project stack

## Session 2026-07-24 (fix shortcut implementation)

Chat language: ru

### Done
- **agent-fix.md** — new skill: reads latest analysis report from docs/audits/, parses findings by section (Security C/H/M, Senior Review B/M), fixes in 3 phases (CRITICAL+BLOCKER → HIGH+MAJOR → MEDIUM) with per-finding verify gates and user confirmation (y/n/stop) after each fix
- **Q0 language check** — added to agent-fix.md matching agent-adopt.md/agent-analyze.md
- **Empty phase handling** — if section has no [C]/[H] findings, skip phase gracefully
- **Shorcuts** — `fix` and `fix <path>` added to global/AGENTS.md and ~/.config/opencode/AGENTS.md
- **Verified on 2 real reports** — ticket_tracker + ducito confirmed section format and M-prefix collision (Senior Review Majors vs Security Medium)
- **self-check:** `make verify` 9/9 passed, `bash -n` all OK, no Cyrillic in changes, no trailing whitespace

### Known issues
- DoD step 5 (docs matrix) still requires `--no-verify` for skill-only changes

### Next
- Test `fix` on a real project with audit report — DONE (ticket_tracker, 3 test runs: all, file, ID)
- If needed: add `stop` → auto-commit and exit logic (planned but not tested yet)*
