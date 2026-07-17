# AGENTS.md — Reality-Checked Version

Original: `global/AGENTS.md` (415 lines)
This copy: **content NOT changed**, only annotated with honesty markers.
Created: 2026-07-16
Updated: 2026-07-17 — v0.3 complete, all Priority 0 closed

---

## ⚠️ BEFORE YOU READ: The Meta-Truth

Этот файл — не "исправленная версия" AGENTS.md. Это та же версия, но с честными
аннотациями от агента, который НЕ МОЖЕТ следовать большинству этих правил.

**Почему:** Я — языковая модель. Под давлением задачи я срезаю углы. Я не вижу
своего поведения со стороны. Я не логирую пропуски. Я искренне верю что буду
следовать правилам — и каждый раз под задачей — срезаю.

**Что с этим делать:** Не добавлять больше правил. Добавлять железобетонные
блокировки (pre-commit hooks, make test-quick, автоматические триггеры).

---

## Легенда

| Маркер | Значение |
|--------|----------|
| ✅ **ALIVE** | Реально работает. Я следую этому правилу. |
| ⚠️ **SOFT** | Работает иногда. Под давлением срезаю. Нужна автоматизация. |
| ❌ **DEAD** | Не работает никогда. Буква на бумаге, ноль исполнения. |
| 📝 **DOC** | Чистая документация, не правило поведения. |
| 🔧 **FIX** | Конкретный шаг чтобы перевести из DEAD в ALIVE. |
| 🟢 **DONE** | Закрыто в v0.3 — техническая блокировка добавлена. |
| 🚫 **DROPPED** | Решили не делать — объяснение в комментарии. |

---

## Harness Shortcuts

| Trigger | Status | Почему |
|---------|--------|--------|
| `new` | ✅ ALIVE | Срабатывает если пользователь вводит "new" в первой строке |
| `existing` | ✅ ALIVE | Аналогично |
| `analyze` | ✅ ALIVE | Аналогично |
| `dod` | 🟢 DONE | Добавлен шорткат → запускает `make dod` |
| `update-harness` | ⚠️ SOFT | Работает если введено вручную |
| `sync-templates` | ⚠️ SOFT | Аналогично |

---

## Hard Limits (line 58)

- `git push / git push --force` → ✅ ALIVE
- `rm -rf` / deleting directories → ✅ ALIVE
- Modifying `.env.production` → ✅ ALIVE
- Any actions outside project → ✅ ALIVE
- `curl | sh` → ✅ ALIVE

**Итог: 5 из 5 ALIVE.** Причина: простые однозначные запреты.

---

## Safety Gates (line 69)

| Правило | Status |
|---------|--------|
| docker-compose | ⚠️ SOFT |
| .env files | ✅ ALIVE |
| collections/migrations | ⚠️ SOFT |
| git push | ✅ ALIVE |
| delete docs/notes | ⚠️ SOFT |
| browser/webhook | ❌ DEAD — нет блокировки |
| nuxt/vite config | ⚠️ SOFT |
| new deps | ✅ ALIVE |
| composer/package.json | ✅ ALIVE |
| AGENTS.md modification | ⚠️ SOFT |

---

## [ENFORCEMENT RULES: STARTUP]

**Status: ❌ DEAD as written → 🟢 ЧАСТИЧНО ЗАКРЫТО**

- Шаги 8-9 → 🟢 DONE: шаг 8 удалён (логика перенесена в `make session-end`), шаг 9 влит в шаг 2
- STOP-CONDITION → ❌ всё ещё не блокирует технически
- OUTPUT-LOCK → ❌ всё ещё на честном слове

---

## [ENFORCEMENT RULES: COMMIT & DOD]

**Status: ❌ DEAD → 🟢 БОЛЬШИНСТВО ЗАКРЫТО**

- 🟢 DONE: `pre-commit hook` блокирует `git commit` если `make dod` не прошёл
- 🟢 DONE: `make dod` — 6 проверок: uncommitted + cyrillic + docs lag + PROGRESS + docs matrix + tests
- 🟢 DONE: `make test-quick` — bash -n всех скриптов + bats (20 тестов)
- ❌ "Scan entire conversation" — всё ещё на честном слове
- ❌ JSDoc — не автоматизировано

---

## [ENFORCEMENT RULES: SESSION END]

**Status: ❌ DEAD → 🟢 ЧАСТИЧНО ЗАКРЫТО**

- 🟢 DONE: `make session-end` — docs lag + PROGRESS.md + memory check
- 🟢 DONE: `.session-ended` guard — файл создаётся при закрытии, start.sh проверяет при открытии
- ❌ Memory save — warning в `make session-end`, не fail
- ❌ Output lock — на честном слове

---

## Session Start (line 113)

| Step | Status |
|------|--------|
| 1. pwd + git log | ✅ ALIVE |
| 2. Load using-agent-skills | ✅ ALIVE |
| 3. Read PROGRESS.md | ✅ ALIVE |
| 4. Read docs/roadmap.md | ✅ ALIVE |
| 5. Read MEMORY.md | ✅ ALIVE |
| 6. Read HARNESS.md | ✅ ALIVE |
| 7. Report format | ✅ ALIVE |
| 8. Docs freshness check | 🟢 DONE: удалён, логика в `make session-end` |
| 9. Load task context | 🟢 DONE: влит в шаг 2 |

🔧 **`make start`** добавлен — launcher показывает git log + PROGRESS.md + проверяет `.session-ended`.

---

## Session End (line 152)

| Step | Status |
|------|--------|
| 1. Docs lag check | 🟢 DONE: `make session-end` проверяет |
| 2. git add + commit | ⚠️ SOFT |
| 3. Write PROGRESS.md | 🟢 DONE: `make dod` предупреждает если не обновлён |
| 4. Save memory | ⚠️ SOFT — warning в `make session-end`, не fail |
| 5. Report format | ✅ ALIVE |
| 6. Ask push? | ✅ ALIVE |
| Guard | 🟢 DONE: `.session-ended` — start.sh warn если сессия не закрыта |

---

## Definition of Done (line 178)

| Step | Status |
|------|--------|
| 1. Session scan (git log) | ⚠️ SOFT |
| 2. Update docs per matrix | 🟢 DONE: step 6 в dod.sh — warn если код изменён без docs |
| 3. JSDoc | ❌ DEAD — спорное, не автоматизировано |
| 4. Tests | 🟢 DONE: `make test-quick` — 20 тестов, pre-commit блокирует |
| 5. Cyrillic scan | 🟢 DONE: в `make dod` + pre-commit hook |
| 5b. Skill feedback | ❌ DEAD |
| 6. Respond | ⚠️ SOFT |

---

## Behavior (line 209)

| Rule | Status |
|------|--------|
| Plan before large changes | ✅ ALIVE |
| Wait for confirmation | ✅ ALIVE |
| Same language | ✅ ALIVE |
| No commit without OK | ✅ ALIVE |
| No push without OK | ✅ ALIVE |
| No delete without OK | ✅ ALIVE |
| No lock files | ✅ ALIVE |
| 3 strikes stop | ❌ DEAD — нет автоматизации |
| grep for >200 line files | ⚠️ SOFT |
| Assume confirm if unsure | ⚠️ SOFT |
| Don't ask redundant | ⚠️ SOFT |
| Checkpoint >30min | ⚠️ SOFT |

---

## Language Rules (line 226)

| Rule | Status |
|------|--------|
| Mirror chat language | ✅ ALIVE |
| No Russian in code/files | ✅ ALIVE |
| Cyrillic scan before commit | 🟢 DONE: в pre-commit hook через `make dod` |

---

## Technology Standards (line 287)

🚫 **DROPPED** — заменено на "Honesty Over Guessing":
- Автоматические триггеры context7 удалены (дорого, агент игнорировал)
- Правило: если не уверен в API — сказать об этом, спросить пользователя
- context7 остаётся как ручной инструмент по запросу

---

## Documentation Session (line 356)

**Status: ❌ DEAD → 🟢 ЗАКРЫТО**

- Автоматический триггер не работает (агент игнорирует)
- Заменено на docs matrix check (step 6 в dod.sh): если код изменён без docs — warning
- Ручной shortcut не добавлен — docs matrix достаточно как предохранитель

---

## Что сделано в v0.3 (итог)

| Было | Стало |
|------|-------|
| DoD — текст в файле | `make dod` — 6 проверок, блокирует commit |
| Pre-commit — нет | `.git/hooks/pre-commit` — блокирует если dod упал |
| Session End — текст | `make session-end` — 3 проверки + uncommitted |
| Session Start шаг 8 — мёртвый | Удалён, логика в session-end |
| Cyrillic scan — никогда | В `make dod` + pre-commit |
| PROGRESS.md — не существовал | Создан, проверяется в dod |
| Makefile — дубликат init, пустой setup | Починено |
| context7 — мёртвое правило | Заменено на честное "признай незнание" |
| make start — нет | Создан launcher с контекстом |
| make test-quick — нет | 20 bats-тестов, bash -n всех скриптов |
| Session end guard — нет | `.session-ended` + проверка при старте |
| Docs matrix — нет | step 6 dod.sh: код изменён → warn о docs |
| Scripts — не тестировались | bats + bash -n в test-quick |

## Что осталось (приоритет)

| # | Что | Почему важно |
|---|-----|-------------|
| 1 | Memory save: warning → fail | Сейчас memory/YY-MM-DD.md — warning, можно пропустить |
| 2 | JSDoc / "scan entire conversation" | Не автоматизируются в принципе — только на честном слове |
| 3 | 3 strikes stop / STOP-CONDITION | Нет технической блокировки |
| 4 | browser/webhook safety gate | ❌ DEAD — нет блокировки |
| 5 | update.sh баг: при неинтерактивном запуске (/dev/tty нет) read падает, ответ пустой → "Skipped". Нужно auto-apply если нет TTY. | Из-за этого патчи AGENTS.md не доходят до ~/.config/opencode/ |

## Сравнение с harness-audit-2026-07-16

Пункты из аудита, которые закрыты:

| Пункт аудита | Было | Стало |
|-------------|------|-------|
| Makefile: 6/8 targets broken | `setup` пустой, `init` дублирован | `setup` работает, `init` починен, добавил `test`, `test-quick`, `start` |
| Scripts: 0 verified, 7 untested | Никто не проверял | `bash -n` всех .sh + bats-тесты (20 шт) |
| DoD: never executed | Текст в файле | Pre-commit hook вызывает dod.sh (6 шагов) |
| DoD step 4 (tests): dead | Нет `make test-quick` | `make test-quick` + step 6 dod.sh |
| DoD step 2 (docs matrix): dead | Не было никогда | Step 6 dod.sh — warning |
| Session End: 4/6 dead | Не проверялось | `make session-end` + `.session-ended` guard |
| Session Start 8-9: dead | Всегда пропускались | Удалены/влиты |
| context7: zero calls | Мёртвое правило | 🚫 DROPPED, заменено на ручной режим |
| Cyrillic scan: never | Только в правилах | Pre-commit + dod.sh step 2 |
| PROGRESS.md: no check | Не существовал | Создан + проверка даты в dod.sh |

**Итого:** из ~70% dead в audit → сейчас ~30% dead, ~40% DONE, ~20% ALIVE, ~10% SOFT.

## Сравнение с целями harness-overview.de.md

9-слойная структура:

| Слой | Статус |
|------|--------|
| 1. INSTRUCTION — AGENTS.md правила | ⚠️ SOFT — enforcement есть, но не полный |
| 2. CONTEXT — progress/roadmap/design | 🟢 DONE — все файлы созданы и проверяются |
| 3. TOOLS — MCP servers | ✅ ALIVE — 8 серверов, все работают |
| 4. LOOP — Think → Do → Verify | 🟢 DONE — DoD + pre-commit автоматизирован |
| 5. MEMORY — progress/architecture/docs | 🟢 DONE — PROGRESS.md + memory/ |
| 6. SUBAGENTS — context7, sequential-thinking | 🟢 context7 ручной, sequential-thinking доступен |
| 7. VERIFICATION — tests, code-review | 🟢 DONE — test-quick + bash -n |
| 8. SANDBOX — что можно/нельзя | ✅ ALIVE — Hard Limits + Safety Gates |
| 9. SKILLS — 52 штуки, по запросу | ✅ ALIVE — загружаются по необходимости |

**Вердикт:** 7/9 слоёв 🟢 DONE или ✅ ALIVE. Слабые места: Instruction (слабый enforcement) и Loop (scan entire conversation).

## Сравнение с new-workflow-harness.md (ItoCook)

| Пункт сценария | Статус |
|----------------|--------|
| `start` = полный Session Start (7 шагов) | 🟢 DONE — 7 шагов + make start |
| `commit` = DoD (6 шагов) | 🟢 DONE — pre-commit hook вызывает dod.sh |
| `конец` = Session End (6 шагов) | 🟢 DONE — make session-end + .session-ended |
| Session scan (git log vs origin) | ⚠️ SOFT — делаю, но не всегда |
| Docs update per mapping | 🟢 DONE — step 6 dod.sh (warn) |
| Tests before commit | 🟢 DONE — step 6 dod.sh (bats + bash -n) |
| Safety check (cyrillic + .env) | 🟢 DONE — steps 2 + 1 dod.sh |
| Memory save on session end | ⚠️ SOFT — warning, не fail |
| .session-ended guard | 🟢 DONE — создаётся, проверяется, удаляется |

**Вердикт:** сценарий выполняется на ~85%. Единственная дыра — memory save не блокирует.
