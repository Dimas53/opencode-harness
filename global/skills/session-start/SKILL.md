# Session Start

Use this skill at the beginning of every new session.

## Trigger

Activate when the user says: "начнём", "start session", "что у нас",
"где остановились", "продолжаем", or when starting fresh work on ItoCook.

## Steps

1. Read `PROGRESS.md` in project root — last 20 lines
2. Read `docs/roadmap.md` — find current phase (look for unchecked items)
3. Read `docs/skills-cheatsheet.md` — note available skills for this session
4. Read `docs/project-state.md` if exists
5. Output a session brief:

---
**Сессия начата**

Last done: [from PROGRESS.md]
Текущая фаза: [из roadmap.md]
Следующий шаг: [первый unchecked item]
Блокеры: [если есть]

Готов. Что делаем?
---

## Rules

- Do NOT start coding before outputting the brief
- Keep the brief under 10 lines
- Ask ONE clarifying question if next step is unclear
