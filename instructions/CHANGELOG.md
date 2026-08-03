# Changelog

All notable changes to opencode-harness are documented here.

## 2026-08-04

### T2.6 — AGENTS.md: extract inline bash from Harness Shortcuts

- **scripts/update-harness-shortcut.sh (new)** and **scripts/sync-templates.sh
  (new)**: the `update-harness` (~10 lines) and `sync-templates` (~55 lines,
  loops/conditionals/`.gitignore` merge logic) shortcut bodies moved out of
  `global/AGENTS.md` verbatim — no logic changes, just added shebang +
  `set -euo pipefail` + a header comment. Both `chmod +x`.
- **global/AGENTS.md `## Harness Shortcuts`**: both blocks replaced with a
  one-line `Run: bash ~/.opencode-harness/scripts/<name>.sh` pointer.
  467→444 lines is less reduction than the roadmap's ~90-100 estimate — the
  actual inline blocks were ~65 lines combined, not ~90-100.
- Scope: mechanical code relocation ONLY. Did NOT touch the Hard
  Limits/Safety Gates/Behavior/Access Restrictions consolidation or the
  skills-auto-loading table trim that the same roadmap phase also lists —
  those change safety-critical text and need explicit human review per-line,
  not a drive-by in a cleanup wave. Left for a future ticket if wanted.
- Noted risk (not fixed, out of scope): `sync-templates.sh` line `gt="~/.opencode-harness/templates/.gitignore"`
  is quoted, so `~` never tilde-expands — a pre-existing bug carried over
  verbatim from the original inline block (this ticket's job was moving code,
  not fixing it).
- Verified: `bash -n` clean on both new scripts; manual line-by-line
  comparison against the pre-edit AGENTS.md content confirms identical logic.
- Source: `notes/Harness/implementation-plan/03-wave2-transplant-cleanup.md` T2.6.

### T2.5 — remove `--no-verify` legitimization from active docs

- **PROGRESS.md** (two "Known issues" entries, lines shifted from the
  ticket's 551/630 to 680/759 after prior waves' edits — found by text
  search): both said the docs-matrix false positive "still requires
  `--no-verify`". Rewritten to describe the actual fix (T0.3's
  same-day-CHANGELOG fallback, T2.1's DOCS_FILES check) instead of
  recommending a bypass that disables all 7 DoD checks.
- **memory/2026-07-22.md**: this file is committed to git and read at
  Session Start (unlike `notes/`, which is gitignored) — the only one of
  the five sites the audit flagged that needed a real content fix, not just
  a superseded-marker. "Fix: commit with `--no-verify`" replaced with the
  actual fix and an explicit "do not use it" note.
- Grepped `PROGRESS.md memory/ instructions/ global/AGENTS.md` for
  remaining `no-verify` mentions: all surviving ones describe it as the
  problem being avoided/fixed (correct usage), none recommend it as a
  solution.
- Not touched (per ticket scope): `notes/Harness/v0.5 -
  harness-roadmap.full.md:75` (already SUPERSEDED in T2.4) and
  `notes/Harness/ostatok-po-versii-0.3.full.md:140` (archival source doc).
- Source: `notes/Harness/implementation-plan/03-wave2-transplant-cleanup.md` T2.5.

### T2.4 — consolidate multiple roadmaps into one canon

- **instructions/roadmap.md**: replaced stale Phase 2/3 content (referenced a
  since-deleted `recruitment-app` test project) with a pointer to
  `notes/Harness/v0.5 - harness-roadmap.new.md` as the canonical roadmap.
  Phase 1 checkboxes verified still true (repo structure, install scripts —
  now under `scripts/`, AGENTS.md, harness-init, templates/docs/,
  instructions/ all present). Phase 2/3 items left unchecked — no clear
  evidence in PROGRESS.md/git log that "test on Windows machine" or "update
  GUIDE.md from real experience" were completed as discrete milestones (GUIDE.md
  has been edited many times, but not traceable to a single real-usage test).
  Confirmed no active Session-Start hook loads this file — only two
  historical mentions in PROGRESS.md/CHANGELOG citing a line number.
- **notes/Harness/v0.5 - harness-roadmap.md and .full.md**: added a
  `SUPERSEDED` banner pointing to `.new.md` as canonical. These two files are
  under `notes/` (gitignored — "Local notes, not versioned"), so the banner
  edits are on-disk only and don't appear in this commit's diff.
- Source: `notes/Harness/implementation-plan/03-wave2-transplant-cleanup.md` T2.4.

### T2.3 — Directus: remove false "Vendored in harness" claim

- **templates/docs/skills-cheatsheet.md `Stack → Required Skills`**: the
  Directus row claimed `directus` was "Vendored in harness" — no such skill
  folder exists under `global/skills/`. Directus is the harness's primary
  target-stack backend (see `templates/docs/ARCHITECTURE.md`,
  `.env.example`), so this false positive meant skill-gap-check
  (`agent-new-project.md` step 4.4) would report ✅ on the single most common
  project scenario instead of ❌.
- Replaced with an honest "— (not vendored)" plus a pointer to the partial
  coverage that does exist (`security/06-directus-nuxt.md`) and to external
  skill marketplaces.
- Did **not** write a full `global/skills/directus/SKILL.md` in this ticket
  — that's a separate content task (scope: schema management, permissions
  model, MCP tool usage, Flows) that needs its own ticket with explicit user
  review, not a drive-by inside a cleanup wave. Recommended as a follow-up.
- Source: `notes/Harness/implementation-plan/03-wave2-transplant-cleanup.md` T2.3.

### T2.2 — remove 10 phantom skills from skills-cheatsheet.md

- **templates/docs/skills-cheatsheet.md**: removed 10 table rows referencing
  skills that don't exist under `global/skills/` (`find-skills`, `triage`,
  `receiving-code-review`, `prototype`, `setup-matt-pocock-skills`,
  `write-a-skill`, `teach`, `finishing-a-development-branch`,
  `using-git-worktrees`, `subagent-driven-development`). These are dead
  references in a file that ships to every new project via `make init`/
  `adopt` — following one would 404 on `Read
  ~/.config/opencode/skills/<name>/SKILL.md`.
- Confirmed all 10 missing via `[ -d global/skills/<name>]` before editing;
  none had reappeared since the audit. `directus` is also phantom but has a
  separate fix (T2.3), left untouched here per the ticket's scope split.
- Source: `notes/Harness/implementation-plan/03-wave2-transplant-cleanup.md` T2.2.

### T2.1 — dod.sh docs-matrix recognizes INSTALL.md/README.md

- **scripts/dod.sh Step 5**: added a `DOCS_FILES="INSTALL.md README.md"`
  exact-match list alongside the existing `DOCS_DIRS` prefix list. Previously
  a commit touching `Makefile` (in `CODE_DIRS`) together with `INSTALL.md`/
  `README.md` failed the docs-matrix check, because those two root-level
  files were in neither `CODE_DIRS` nor `DOCS_DIRS` — the check only
  recognized `docs/` and `instructions/` as documentation.
- Verified in an isolated clone: staging `Makefile` + `INSTALL.md` and
  running `PRE_COMMIT=1 bash scripts/dod.sh` now passes Step 5 (previously
  failed).
- Source: `notes/Harness/implementation-plan/03-wave2-transplant-cleanup.md` T2.1.

### T1.3 — automatic DoD sync checker (`make check-docs-sync`)

- **scripts/check-dod-sync.sh (new)**: compares step count and step titles
  between `global/AGENTS.md ## Definition of Done` and
  `global/skills/dod/SKILL.md`, so the two can't silently re-diverge the way
  they already had once (T1.1). Cheap first version of the audit's
  `rules.yaml` codegen idea — a checker, not a generator.
- **Makefile**: added `check-docs-sync` target + `.PHONY` entry + help line.
- Not wired into the pre-commit hook — that belongs to Wave 3 (CI, T3.4),
  not Wave 1; this ticket only adds the manual command.
- Two bugs found and fixed during verify, both in the ticket's own proposed
  script (documented so a future re-implementation doesn't reintroduce them):
  - The step-title extraction for `dod/SKILL.md` (unlike the AGENTS.md side)
    wasn't scoped to a section, so it also matched the illustrative
    `### STEP 1` / `### STEP 2` example lines inside "## Checklist format"
    at the end of the file — inflating the count to 11 instead of 9 even
    when genuinely in sync. Fixed by truncating the file at that heading
    before extracting steps.
  - The first-word title comparison broke on single-word AGENTS.md titles
    like `**JSDoc:**` — the trailing colon is captured as part of the (only)
    word, but `dod/SKILL.md`'s plain `### STEP 3 — JSDoc` heading has none,
    so genuinely synced steps 3/4/8 reported as mismatched. Fixed by
    stripping a trailing colon before comparing.
- Verified: positive case (`make check-docs-sync` on the real, synced files)
  passes; negative case (renaming a STEP heading in an isolated temp copy)
  correctly exits 1 and reports the divergence.
- Source: `notes/Harness/implementation-plan/02-wave1-single-source-of-truth.md` T1.3.

## 2026-08-03

### T1.2 — consolidate Session Start (drop the ItoCook-leaking duplicate)

- **global/AGENTS.md `[ENFORCEMENT RULES: STARTUP]`**: no longer hardcodes
  "Execute all 7 steps" (the section actually has 8) — same drift class as
  T1.1's DoD fix. Also fixed inconsistent leading-space indentation on
  steps 3/4/6/7/8 in `## Session Start` that could break ordered-list
  rendering in some Markdown renderers.
- **Removed `global/skills/session-start/SKILL.md`**: it was an orphaned
  duplicate of `global/skills/startup/SKILL.md` — `AGENTS.md` already links
  to `startup/SKILL.md` for details, not to this file, and nothing else
  referenced it. It also leaked a specific client project name ("ItoCook")
  into its trigger phrase and referenced `docs/project-state.md`, a file
  that doesn't exist in any template. Two genuinely useful behavioral rules
  it had that `startup/SKILL.md` lacked — keep the session-start report
  under 10 lines, ask ONE clarifying question if the next step is unclear —
  were carried over into `startup/SKILL.md`'s Step 12 before deletion.
- **global/skills/startup/SKILL.md**: dropped its own stale "(6 steps)"
  reference to AGENTS.md's Session Start (it has 8, and hardcoding either
  number invites the same drift T1.1 fixed for DoD) — now points at the
  section itself as the source of truth instead of a number.
- **Flagged, not touched (out of this ticket's file list, left for Wave 2
  T2.2/T2.3 "phantom skills in cheatsheet"):** `session-start` is still
  listed as an available skill in `templates/docs/skills-cheatsheet.md`,
  `instructions/reference/03-skills-cheatsheet.md`,
  `instructions/reference/05-skills-inventory.md`, and
  `instructions/reference/01-harness-overview.de.md` — now phantom entries
  after this deletion. `instructions/roadmap.md:22`'s "Consider generic
  version of session-start" TODO is now moot for the session-start half.
  Separately, "ItoCook" also appears in `global/skills/security/` reference
  docs and `global/skills/archify/notes/` — pre-existing, unrelated to
  Session Start, not part of this ticket's scope.
- Source: `notes/Harness/implementation-plan/02-wave1-single-source-of-truth.md` T1.2.

### T1.1 — one Definition of Done, not three

- **global/AGENTS.md `## Definition of Done`**: now the single source of
  truth (9 steps: Session scan, Update docs, JSDoc, Tests, Commit Gate,
  Safety check, Skill feedback, Cleanup, Respond). Added a new explicit
  **Commit Gate** step wrapping `make dod` — previously the mechanical
  `scripts/dod.sh` gate wasn't mentioned in the behavioral checklist at all.
  `[ENFORCEMENT RULES: COMMIT & DOD]` no longer hardcodes a step count
  ("all 6 steps") that can silently drift out of sync with the list below it.
- **global/skills/dod/SKILL.md**: rewritten to mirror AGENTS.md 1:1 (same 9
  steps, same order, same numbering) instead of its own independent 7-step
  list (STEP 0-6 + 5b) that had already drifted from AGENTS.md's "6 steps."
- **instructions/GUIDE.md**: removed a THIRD independent hardcoded DoD
  description (a 6-item list under "### Definition of Done" that matched
  neither AGENTS.md nor dod/SKILL.md) — replaced with a reference to
  AGENTS.md as source of truth. Also dropped stale "(6 steps)" mentions in
  two command-reference tables.
- **README.md**: dropped stale "(6 steps)" from the `dod` shortcut description.
- Also fixed: `global/AGENTS.md` Step 7 (formerly Step 9, "Self-check") used
  to say "run `make self-check` in the harness repo" unconditionally — that
  target doesn't exist in projects that adopt the harness (only in this
  meta-repo). Now scoped as optional/harness-repo-only.
- Source: `notes/Harness/implementation-plan/02-wave1-single-source-of-truth.md` T1.1.

### T0.7 — make unadopt backs up harness files before deleting them

- **Makefile `unadopt` target**: previously deleted `AGENTS.md`, `MEMORY.md`,
  `PLAN.md`, `PROGRESS.md`, `HARNESS.md` and `memory/` with no backup — any
  pre-adopt custom `AGENTS.md` or months of `PROGRESS.md` history was gone
  with no recovery path. Now copies each existing file (and `memory/`) to
  `.harness-unadopt-backup/` before removing it.
- **templates/.gitignore**: added `.harness-unadopt-backup/` so the backup
  directory doesn't get committed in adopted projects.
- Bug found during verify: the original ticket's `for`/`cp` pattern let the
  exit code of the *last* missing optional file abort the whole `make`
  target midway (before the actual `rm`), since a for-loop's exit status is
  its last command's. Added `|| true` after the loop and the `memory/` line
  so a missing optional file is a graceful skip, not a mid-target abort.
- Source: `notes/Harness/implementation-plan/01-wave0-stop-the-bleeding.md` T0.7.

### T0.6 — dod.sh: manual `make dod` no longer false-fails on Step 1

- **scripts/dod.sh Step 1**: outside the pre-commit hook, `make dod` is
  normally run right before a commit — exactly when uncommitted changes are
  expected to exist. It previously `check_fail`ed on that every single time,
  training agents/users to distrust the manual check and rely only on the
  hook (which is one step away from `--no-verify`). Now: unstaged changes
  are a warning in manual mode, still a hard fail inside the pre-commit hook
  (`PRE_COMMIT=1`) where it correctly means "unstaged changes at commit time."
- Source: `notes/Harness/implementation-plan/01-wave0-stop-the-bleeding.md` T0.6.

### T0.5 — dod.sh: docs-lag sees instructions/, tests-skipped warning is explicit

- **scripts/dod.sh Step 3 (docs-lag)**: `DOCS_DIR` was hardcoded to `"docs"`,
  so in this repo (which documents itself under `instructions/`) the check
  always short-circuited to "No docs/ directory — skipping" even when
  `instructions/` was genuinely stale. Now checks `docs/` first, falls back
  to `instructions/`, matching the pattern already used in `session-end.sh`.
- **scripts/dod.sh Step 6 (tests)**: when `bats` isn't installed, the warning
  now says explicitly "TESTS NOT RUN" with an install hint, instead of the
  easy-to-miss "skipping tests". Real enforcement stays in CI (Wave 3) — this
  is not a fail here, only a louder warning.
- Source: `notes/Harness/implementation-plan/01-wave0-stop-the-bleeding.md` T0.5.

### T0.3 — dod.sh docs matrix: legal cheap pass for skill-only commits

- **scripts/dod.sh Step 5**: a commit touching only `global/skills/**` was
  classified as "code changed" (global/ is in `CODE_DIRS`) with no legal cheap
  way to satisfy the docs-matrix check other than `--no-verify` (which
  disables all 7 checks, not just this one). Now: if every non-doc changed
  file lives under `global/skills/`, a same-day dated section in
  `instructions/CHANGELOG.md` (like this one) satisfies the check. Any other
  `CODE_DIRS` path (`scripts/`, `hooks/`, `tests/`, `templates/`, `Makefile`)
  still requires a real docs/instructions update — this fallback does not
  weaken the rule for those.
- Source: `notes/Harness/implementation-plan/01-wave0-stop-the-bleeding.md` T0.3.

### T0.2 — pre-commit hook fails closed when dod.sh is missing

- **hooks/pre-commit**: a missing `dod.sh` (broken `~/.opencode-harness`
  symlink, wrong `OPENCODE_HARNESS_PATH`) previously printed a warning and
  `exit 0` — git treated the hook as passed and the commit went through with
  zero checks run. Now prints to stderr and `exit 1`, refusing the commit
  until the harness path is fixed.
- Source: `notes/Harness/implementation-plan/01-wave0-stop-the-bleeding.md` T0.2.

### T0.1 — init-adopt/init-project no longer overwrite existing project files

- **scripts/init-adopt.sh, scripts/init-project.sh**: template copy over an
  existing project (`AGENTS.md`, `MEMORY.md`, `PLAN.md`, `PROGRESS.md`,
  `HARNESS.md`) now backs up any differing existing file to `<file>.bak`
  before installing the template, instead of overwriting silently. `docs/`
  and `memory/` now copy with `cp -rn` (no-clobber) so existing files inside
  are preserved.
- Added `set -euo pipefail` to both scripts so a mid-script failure stops
  execution instead of continuing past it.
- Source: `notes/Harness/implementation-plan/01-wave0-stop-the-bleeding.md` T0.1.

## 2026-07-22

### Vendor all skills — removed external dependencies

- **All skills now in-repo** (`global/skills/`): copied 70 skills from superpowers
  plugin + JuliusBrussee directly into the harness. Zero external dependencies.
- **install.sh/update.sh**: removed `opencode plugin add superpowers@...`,
  `npx skills add JuliusBrussee/skills`, `.agents/skills/` copy. Only
  `cp -r global/skills/*` remains.
- **10 custom skills** (code-reviewer, codebase-health-check, etc.) got YAML
  frontmatter (`---`) — required for OpenCode skill discovery.
- **global/opencode-config.example.jsonc**: removed superpowers from `plugin` array.
- **`.agents/skills/`** deleted from repo (all skills now in `global/skills/`).

### WSL2/Linux support — install, verify, docs

- **scripts/install.sh**: added `OS=$(uname -s)` dispatch — uv and RTK installed
  via `brew` on macOS, via `curl` installers on Linux. `export PATH` added before
  `rtk init` to ensure `~/.local/bin` is on PATH in the current shell.
- **INSTALL.md**: full Windows installation section — WSL2 setup, prerequisites,
  step-by-step clone/install/auth/verify/first-run, comparison table (macOS vs WSL2).
- **README.md**: added `## Installing on Windows` — one-block quick-start with
  PowerShell + bash code blocks, matching macOS section structure.

- **All skills now in-repo** (`global/skills/`): copied 70 skills from superpowers
  plugin + JuliusBrussee directly into the harness. Zero external dependencies.
- **install.sh/update.sh**: removed `opencode plugin add superpowers@...`,
  `npx skills add JuliusBrussee/skills`, `.agents/skills/` copy. Only
  `cp -r global/skills/*` remains.
- **10 custom skills** (code-reviewer, codebase-health-check, etc.) got YAML
  frontmatter (`---`) — required for OpenCode skill discovery.
- **global/opencode-config.example.jsonc**: removed superpowers from `plugin` array.
- **`.agents/skills/`** deleted from repo (all skills now in `global/skills/`).

## 2026-07-21

### agent-new-project — P20-P26 fixes

- **P20**: Q-1 files now PRE-FILL not interview replacement. Full interview
  Q1→Q6→HARNESS always runs; files only pre-fill answers, agent confirms each.
- **P21**: Hard rule — NEVER delete entries from skills-cheatsheet.md (only ADD).
- **P22**: Hand-off shows both ✅ found and ❌ missing skills.
- **P23**: AGENTS.md Stack Skills — clear Installed / Missing sections.
- **P24**: Phase 0 verifies .env.example after scaffold, copies if missing.
- **P25**: skills-cheatsheet.md — inline show→confirm→write requirement.
- **P26**: Hand-off conditional hints — "Add docs/design.md" / "Add plan-main.md"
  shown only if files NOT provided in Q-1.

### Analyze skill — expanded skill stack

- **global/skills/harness-init/agent-analyze.md** — skill stack expanded from 4 to
  7 skills: zoom-out → context-canary → codebase-health-check → junior-to-senior →
  code-review-and-quality → security → premortem.
- Added **context-canary** (context rot/degradation check) after zoom-out.
- Added **junior-to-senior** (senior-level design/approach findings).
- Added **code-review-and-quality** (multi-axis code review).
- Reordered for logical flow: architecture first, then health, then quality, then
  security/risks.
- Introduced **Quality Gate**: every skill must produce at least 5 concrete
  findings with specific file+line examples. Generic statements not allowed.
- Report output now includes sections: Context Check, Senior Review, Quality.

## 2026-07-20

### Session language persisted in PROGRESS.md

- **global/AGENTS.md** — Session Start step 3 now instructs the agent to WRITE
  `Session language: <chosen>` into `PROGRESS.md` (create the file if missing)
  after the user picks a language, so it is never asked again. Previously the
  protocol only said "ask" and never persisted the choice, so the prompt
  re-appeared every session.
- **Directus 11 wildcard gotcha** — `instructions/directus-mcp-setup.md` corrected:
  the `All Collections (*)` permission does NOT reliably apply to existing
  collections in Directus 11. For local/dev use Admin Access (`admin_access:
  true`) on the `mcp` policy; for production use explicit per-collection grants.

## 2026-07-20

### Directus MCP — per-project generated config (switch-directus removed)

- **Architecture change:** Directus MCP is now configured **per project** from
  the project's `.env`. There is **no global `directus` block** in
  `~/.config/opencode/opencode.jsonc` and the `switch-directus` shortcut is
  removed. Each project generates its own gitignored `opencode.jsonc` that fully
  overrides the global config, so three projects = three independent MCP
  connections, each pointed at its own Directus instance.
- **scripts/gen-opencode.sh** (new) — reads `.env` (`DIRECTUS_URL` +
  `MCP_DIRECTUS_TOKEN`), merges the global OpenCode config, and writes a local
  `opencode.jsonc` with the per-project `directus` MCP block.
- **Makefile** — added `mcp` target (`bash scripts/gen-opencode.sh $(PROJECT)`).
- **scripts/start.sh** — regenerates `opencode.jsonc` from `.env` before
  launching OpenCode when `.env` has `DIRECTUS_URL`.
- **templates/.env.example** (new) — `DIRECTUS_URL` + `MCP_DIRECTUS_TOKEN`
  placeholders; `init-project.sh` copies it to `.env` when absent.
- **instructions/directus-mcp-setup.md** — rewritten for the per-project flow
  (enable MCP server, create Access Policy → Role → User → Static Token, put
  credentials in `.env`, `make mcp`, open project).
- **global/AGENTS.md** — Session Start step 7 simplified: if a local
  `opencode.jsonc` exists it is used automatically; otherwise warn the user to
  create `.env` and run `make mcp`. All `switch-directus` references removed.
- **README.md** — `switch-directus` shortcut and old global-MCP section removed;
  `## Directus MCP` now describes the per-project flow.

## 2026-07-20

### README cleanup — keep only top-level commands

- Removed terminal `make` command blocks (Fallback, Symlink, From terminal) from
  README. Those live in INSTALL.md / instructions/GUIDE.md. README now shows only
  the day-to-day shortcuts typed inside OpenCode plus links to detailed docs.

## 2026-07-20

### Directus MCP setup strategy

- **instructions/directus-mcp-setup.md** — new guide: create a dedicated `mcp`
  service-account user in each Directus instance (scope is the developer's
  choice — read-only or read+write), store one shared `Bearer` token in the
  global `~/.config/opencode/opencode.jsonc` (`mcpServers.directus` as a remote
  server with `url` + `headers.Authorization`), auto-correct the project URL on
  Session Start, and override per-project via a gitignored `opencode.jsonc`.
- **global/AGENTS.md** — Session Start step 7 now prioritizes a project-level
  `opencode.jsonc` (full override, skips mismatch check) and reads the MCP URL
  from `mcpServers.directus.url` with `Bearer` auth.
- **README.md** — `switch-directus` section shortened to a 3-line summary linking
  to the setup guide.
- **templates/.gitignore** — added `opencode.jsonc`.
- **agent-new-project.md / agent-adopt.md** — hand-off now reminds the user to
  create the Directus `mcp` user when the project uses Directus.

## 2026-07-19

### `new` flow — restructure into a single coherent mechanism

- **scripts/init-project.sh** — added `--no-open` flag. The script now copies
  `templates/` into the project, runs `git init` + hooks, and (unless
  `--no-open`) launches OpenCode with the `agent-new-project.md` prompt. Used
  by the `new` flow from inside an already-running OpenCode session so it does
  not spawn a second instance.
- **global/skills/harness-init/agent-new-project.md** — restructured into three
  phases:
  - **Phase 0 — Scaffold:** runs `make init PROJECT="$(pwd)" --no-open` BEFORE
    the interview, so `HARNESS.md`, `MEMORY.md`, `PLAN.md`, `PROGRESS.md`,
    `memory/` and the `docs/` tree always exist in the new project.
  - **Phase 1 — Interview + fill:** fixed question order (Q1 name/purpose,
    Q2 team/auth, Q3 stage/deploy, Q4 integrations/sensitive, Q5 design/fields,
    Q6 plan) plus HARNESS questions (critical paths, risk levels). Mandatory
    restate (step 4.5) with explicit "yes" before any file is written. Fills or
    rewrites the scaffolded template files in place — no generate-from-scratch.
  - **Phase 2 — Hand-off:** formatted report listing created files and
    instructing the user to open a new session and type `start` (continues from
    roadmap M1). `new` is scaffold + docs only; project implementation happens
    in the next session.
- **templates/AGENTS.md** — restored to a PROJECT skeleton (placeholders only).
  It had been accidentally overwritten with the global AGENTS.md; now it no
  longer creates a redundant mirror in every new project.
- **templates/docs/CONTEXT.md** and **templates/docs/roadmap.md** — cleaned of
  example domain data (Cook / Deduction / Hetzner / Tailwind). Structure plus an
  instruction comment only; the agent rewrites them with the project's own
  context during the interview.

### Root cause fixed

The `new` shortcut previously generated only 6 documentation files and missed
`HARNESS.md`, `MEMORY.md`, `PLAN.md`, `PROGRESS.md` and `memory/` because the
skill never called `make init` and ignored `templates/`. The `new` flow now
drives the scaffold through `make init`, then fills it via interview.

## 2026-07-19 (touch-test pass 2 — harness behaviour fixes)

Fixes from the `new` touch-test (RecipeBox) and follow-up notes:

- **templates/.gitignore** — added standard ignore set (`.DS_Store`, `.idea/`,
  `.vscode/`, `node_modules/`, `.env*`, `*.log`, `.nuxt/`, `.output/`, `dist/`).
- **scripts/init-project.sh** — copies `templates/.gitignore` into the project
  only if one does not already exist (no merge logic; merge lives in the
  `sync-templates` shortcut).
- **global/AGENTS.md** (`sync-templates` shortcut) — `.gitignore` is now merged
  (missing lines reported, never overwritten) and copied when absent.
- **agent-new-project.md (Step 4 / Q5)** — design-system question is now
  conditional: skipped when Q-1 = "no", asked only if a provided spec file did
  not already cover it.
- **agent-new-project.md (Step 8)** — `HARNESS.md` now filled with Entry point
  (dev/test/lint) and Risk levels from the interview; Product contract and
  Decisions to inherit are left for the user. Port conflict check added
  (host: `lsof`/`ss`; Docker: `docker ps`) with free alternatives proposed and
  chosen ports recorded in HARNESS.md Entry point.
- **agent-new-project.md (Step 10)** — session log written to `PROGRESS.md`
  including `Session language: [from Q0]`.
- **agent-new-project.md (Step 11 / hand-off)** — explicit order: `end` → new
  session → `start`.
- **global/AGENTS.md (Session Start)** — language persisted via `Session
  language:` line in PROGRESS.md; resumed without re-asking. Directus MCP
  instance verified against project `DIRECTUS_URL`; mismatch stops Session
  Start with a clear warning and points to `switch-directus`. New `switch-directus`
  shortcut repoints the global MCP config (explicit confirmation required).
- **global/AGENTS.md (English-Only Policy)** — `memory/` is now English ONLY,
  regardless of session language; no Cyrillic quotes even in workarounds.
- **templates/MEMORY.md & global/MEMORY.md** — Known Gotcha: pin
  `typescript@5.6.3` + `vue-tsc@2.1.10` + `@types/node` on Node 20 (newer
  versions break the typecheck toolchain).
- **README.md** — documented the `switch-directus` shortcut and the Directus
  MCP switching flow.

## 2026-07-19 — Stack→Skill map + sync cleanup

- **templates/docs/skills-cheatsheet.md** & **instructions/reference/03-skills-cheatsheet.md**
  — added `## Stack → Required Skills` table (technology → skill folder →
  install command). Directus → `npx skills add directus`; TypeScript covered
  by `tdd` + `test-driven-development` (no standalone skill).
- **global/skills/harness-init/agent-new-project.md** — new step `4.4 SKILL GAP
  CHECK` before restate: reads Stack→Required Skills, matches interview
  stack, `ls ~/.config/opencode/skills/<name>` per skill, shows ✅/❌ with
  install command. Informational only — does not block the interview.
- **Sync** — `global/skills/*` fully mirrored to `~/.config/opencode/skills/`
  (25 files in sync). Recovered missing `security/06-directus-nuxt.md`.
- **session-start/SKILL.md** — output block translated RU→EN (English-Only Policy).
