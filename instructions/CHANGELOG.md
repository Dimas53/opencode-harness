# Changelog

All notable changes to opencode-harness are documented here.

## 2026-08-03

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
