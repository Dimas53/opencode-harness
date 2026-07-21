---
name: session-start
description: >
  Session start ritual for beginning every new session. Reads context,
  checks progress, loads skills, and reports session brief.
---

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
**Session started**

Last done: [from PROGRESS.md]
Current phase: [from roadmap.md]
Next step: [first unchecked item]
Blockers: [if any]

Ready. What's next?
---

## Rules

- Do NOT start coding before outputting the brief
- Keep the brief under 10 lines
- Ask ONE clarifying question if next step is unclear
