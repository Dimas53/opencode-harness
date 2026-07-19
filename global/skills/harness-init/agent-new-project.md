# agent-new-project

## Purpose
Initialize a brand new project from scratch.
Scaffold the harness structure, collect requirements via interview,
then fill the scaffolded template files with the project's context.

## Skill stack (load in this order)
1. ~/.config/opencode/skills/interview-me/SKILL.md
2. ~/.config/opencode/skills/brainstorming/SKILL.md
3. ~/.config/opencode/skills/planning-and-task-breakdown/SKILL.md
4. ~/.config/opencode/skills/spec-driven-development/SKILL.md

## Steps

### Phase 0 — Scaffold (BEFORE the interview)
1. Run the harness scaffold so the project has the full structure
   (HARNESS.md, MEMORY.md, PLAN.md, PROGRESS.md, memory/, docs/ tree,
   and the project AGENTS.md skeleton):
   ```bash
   cd "<project directory>" && make init PROJECT="$(pwd)" --no-open
   ```
   - `--no-open` prevents launching a second OpenCode instance (we are
     already inside one). The scaffold copies everything from
     `templates/` and runs `git init` + hooks.
   - If the user invoked `new` from a folder that is NOT yet the target
     project, ask which directory to scaffold into, then run `make init`
     there.
   - Do NOT edit the global AGENTS.md (`~/.config/opencode/AGENTS.md`) —
     it lives outside the project and is managed by `make setup` only.

### Phase 1 — Interview + fill the scaffold
2. Ask Q0: what language should I respond in? (Ask this FIRST so the entire
   interview runs in the user's chosen language.)
3. Ask Q-1: "Do you have a requirements document, design brief, or any existing
   spec? If yes — share it now, I will read it first and ask only clarifying
   questions about what is missing. If no — just say 'no' and we will go
   through the full interview."
   - If user provides a file → read it, ask max 2-3 clarifying questions,
     skip anything already covered in the file
   - If "no" → proceed to standard interview
   - Q-1 is asked AFTER Q0 so the question and all follow-ups are in the
     user's chosen language
4. Load interview-me — run structured interview with the fixed question order
   below. Each question: state your guess, wait for the answer, one at a time.
   - Q1: Project name and purpose (2-3 sentences)
   - Q2: Team size + authorization model (solo / team / public? login via
     Directus? per-user data?)
   - Q3: Stage (MVP / production-critical) + deployment target (local Docker /
     Vercel / self-hosted)
   - Q4: External integrations + sensitive data? (payments, external APIs, PII)
   - Q5: Design system? (if yes — user adds docs/design.md manually) + core
     entity/field model (e.g. task fields: title, status, assignee…)
   - Q6: Project plan? (phases / milestones, or single MVP iteration)
   - HARNESS questions (ask before writing files): critical paths of the
     project, and risk levels for each area (per HARNESS.md vocabulary)
4.5. MANDATORY restate — before generating any file, show a summary and wait
    for explicit "yes". Format:
    ```
    - Purpose:     <one line>
    - Users:       <one line>
    - Success:     <one line — how we know it worked>
    - Constraint:  <one line — binding limit>
    - Out of scope:<one line — explicitly NOT building>
    ```
    Do NOT proceed to file generation until the user confirms. If they refine —
    fold in and restate.
5. Load brainstorming — explore unknowns, surface assumptions
6. Load planning-and-task-breakdown — structure phases and tasks
7. Load spec-driven-development — write phase-1 spec
8. Fill the scaffolded template files with the interview context. The files
   already exist from Phase 0 — DO NOT generate them from scratch, fill or
   rewrite them in place:
   - `AGENTS.md` — replace `[Project Name]`, `[Framework + version]`,
     `[path]` placeholders, stack skills, file map, backend/UI rules
   - `ARCHITECTURE.md` — write the real architecture
   - `CONTEXT.md` — REWRITE, removing the example domain terms; use the
     project's own ubiquitous language
   - `roadmap.md` — REWRITE the example phases; use the real MVP phases
   - `skills-cheatsheet.md` — keep as-is or trim to relevant skills
   - `docs/specs/phase-1.md` — write the phase-1 spec
   Each file: show draft → wait for ok → write → next file.
9. Commit: "chore: initialize harness docs for [project name]"
10. Remind user: "Add docs/design.md if you have a design system.
    Add docs/plan-main.md if you have a broader vision document."

### Phase 2 — Hand off to the working session
11. Hand-off report — show the user a formatted summary:
    ```
    Project [name] initialized.

    Created:
    - AGENTS.md, ARCHITECTURE.md, CONTEXT.md, roadmap.md
    - skills-cheatsheet.md, docs/specs/phase-1.md
    - HARNESS.md, MEMORY.md, PLAN.md, PROGRESS.md, memory/

    Next step:
    -> Open a NEW session in this folder and type `start`
       (triggers internal Session Start -> continues from roadmap M1)

    Reminder:
    - add docs/design.md if a design system appears
    - add docs/plan-main.md if there is a broader vision document
    ```
    Do NOT scaffold or run M1 here — `new` is docs + scaffold only.

## Hard rules
- Q0 (language) is ALWAYS first — before any other question, including Q-1
- Q-1 (spec file check) is asked AFTER Q0, so the question and all follow-ups
  are in the user's chosen language
- Never skip the interview — even if user seems to know everything
- Never generate all files at once — one at a time with confirmation
- design.md is NOT generated here — user provides it manually
- Never touch the global AGENTS.md — only the project's scaffolded files
- `new` is documentation + scaffold only — project implementation (M1) happens
  in the next session, not here
- restate (step 4.5) is MANDATORY — no file is written before explicit "yes"
