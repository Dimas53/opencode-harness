# Changelog

All notable changes to opencode-harness are documented here.

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
