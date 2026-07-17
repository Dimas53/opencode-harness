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
| `existing` | `make init-existing PROJECT=$(pwd)` |
| `analyze` | `make analyze PROJECT=$(pwd)` |
| `update-harness` | cd ~/.opencode-harness && git pull && make update |
| `sync-templates` | inline (check + copy missing) |

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
- This is the **template** installed to other projects.
- Changing it changes behavior of agents in ALL harness-enabled projects.
- Every edit to `global/AGENTS.md` MUST be mirrored to `templates/AGENTS.md`.
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

## Чего здесь нет

Намеренно исключено из этого файла (правила существуют в глобальном AGENTS.md,
но не применимы к Harness):

| Исключено | Почему |
|-----------|--------|
| Nuxt/Vue/Vite правила | В проекте нет .vue файлов |
| Directus коллекции/схемы | Нет Directus инстанса |
| Tailwind/CSS правила | Нет фронтенда |
| API endpoint правила | Нет API |
| TDD для Vitest/Playwright | Нет тестового раннера (будет BATS) |
| JSDoc на компонентах | Нет компонентов |
| Работа в Docker | Нет Docker Compose |
| Работа с БД/миграции | Нет БД |
| Prisma/Symfony/Laravel | Нет этих фреймворков |
| Браузерное тестирование | Нет UI для тестов |
| TypeScript strict mode | Нет TS (есть bash + Markdown) |
| Conventional commits | Нет релизного цикла |
| Проверка Nuxt/Directus версий | Нет зависимостей |

Если какой-то из этих пунктов появится в Harness — перенести сюда из глобального.
