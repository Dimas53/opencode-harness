# AGENTS.md — opencode-harness (project-level)

This is the harness meta-project. Rules here override global AGENTS.md.
We don't write app code here. We write: bash scripts, Makefile targets,
templates, reference docs, notes.

---

## Directory Map

```
global/
  AGENTS.md         → deployed to each project during install
  skills/           → skill files deployed with harness
scripts/            → bash scripts (init, install, verify, update)
templates/          → copied to new projects during `make init`
instructions/
  reference/        → doc files (8 files, ~1300 lines)
  diagrams/         → HTML architecture diagrams
notes/              → free-form, Russian allowed
Makefile            → build orchestration (caution: has bugs)
```

---

## Shortcuts

| User types | Action |
|------------|--------|
| `new` | `make init PROJECT=$(pwd)` |
| `adopt` | `make init-adopt PROJECT=$(pwd)` |
| `analyze` | `make analyze PROJECT=$(pwd)` |
| `fix` | Inside OpenCode: reads last analysis report, fixes findings (3-phase) — no make fallback |
| `update-harness` | cd ~/.opencode-harness && git pull && make update |
| `update-project` | inline (check + copy missing + hook drift) |

---

## What's Different Here vs Regular Projects

| This project | Normal web project |
|--------------|-------------------|
| Bash + Make + text | TypeScript/Vue/PHP |
| Templates + docs | API routes + components |
| No databases | Directus collections |
| No npm deps (mock tools only) | package.json + dependencies |
| No frontend | Nuxt/Tailwind |

---

## File-Specific Rules

### global/AGENTS.md
- This is the **global config** installed to `~/.config/opencode/AGENTS.md`.
- Changing it changes behavior of agents in ALL harness-enabled projects.
- `templates/AGENTS.md` is a **project-specific template** (`{{PLACEHOLDER}}` format). Do NOT replace it with `global/AGENTS.md`. Only sync relevant global shortcut additions if they affect the template structure.
- Don't add rules that only make sense for Harness itself.

### scripts/*.sh
- Bash strict mode preferred: `set -euo pipefail`
- Test with `bash -n script.sh` before saying it works.
- All scripts must be idempotent (running twice = same result).
- Don't hardcode paths — use `$HARNESS_PATH` derived from script location.

### templates/
- Must be generic — no references to specific projects, users, or paths.
- Templates use `{{PLACEHOLDER}}` syntax for project-specific values.
- Don't put example content that looks real (users might keep it).

### instructions/reference/
- Reference material only. No behavioral rules.
- 8 files is too many. Target: 4-5. Merge 03+05, trim 08, remove 01.
- `07-models.md` is perishable — note the staleness risk.

### Makefile
- **Known bugs:** duplicate `init` target, empty `setup` target.
- Don't add new targets until these are fixed.
- New targets should be simple (1-3 commands), not complex scripts.

### notes/
- Russian allowed.
- Session artifacts (premortems, old plans) should be archived periodically.
- Keep `notes/harness-audit-*.md`, `notes/testing-strategy.md`,
  `notes/AGENTS.*.md` as living documents.

---

## Working Style

- Write shellcheck-clean bash. Use `[[ ]]` over `[ ]`. Quote all variables.
- Prefer `make target` over long inline scripts in AGENTS.md.
- If a make target doesn't exist yet, flag it as 🔧 NEEDS CREATE.
- Don't add aspirational rules. If it can't be enforced, don't write it.
- Test scripts by running them. Saying "it should work" is not enough.

---

## Before Commit in This Project

```
make verify            → runs verify.sh
bash -n scripts/*.sh   → syntax check all bash scripts
git diff --check       → no trailing whitespace
```

If `make verify` doesn't exist yet: run `scripts/verify.sh` directly.
If it fails — don't commit.

---

## What's Not Here

Intentionally excluded from this file (rules exist in global AGENTS.md
but don't apply to Harness):

| Excluded | Reason |
|----------|--------|
| Nuxt/Vue/Vite rules | No .vue files in this project |
| Directus collections/schema | No Directus instance |
| Tailwind/CSS rules | No frontend |
| API endpoint rules | No API |
| TDD for Vitest/Playwright | No test runner yet (will be BATS) |
| JSDoc on components | No components |
| Docker workflow | No Docker Compose |
| Database / migrations | No database |
| Prisma/Symfony/Laravel | None of these frameworks |
| Browser testing | No UI to test |
| TypeScript strict mode | No TS (bash + Markdown only) |
| Conventional commits | No release cycle |
| Nuxt/Directus version checks | No dependencies |

If any of these ever appear in Harness — move the rule here from global.
