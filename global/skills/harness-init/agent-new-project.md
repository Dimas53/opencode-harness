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
    ~/.opencode-harness/scripts/init-project.sh "$(pwd)" --no-open
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
    - Q5: Core entity/field model (e.g. task fields: title, status, assignee…).
      ALWAYS ask for the entity/field model.
      The design-system sub-question is CONDITIONAL — follow strictly:
      - If Q-1 answer was "no" (no spec file): DO NOT ask about the design
        system at all. Silently note that the user adds docs/design.md manually
        later if one appears. Asking about design system here is a VIOLATION.
      - If Q-1 provided a file: ask about the design system ONLY IF the file
        did not already cover it. If covered, SKIP it.
   - Q6: Project plan? (phases / milestones, or single MVP iteration)
    - HARNESS questions (ask before writing files): critical paths of the
      project, and risk levels for each area (per HARNESS.md vocabulary)
 4.4. SKILL GAP CHECK — after the interview, before restate:
    - Read `docs/skills-cheatsheet.md`, section "Stack → Required Skills".
    - Match the table against the stack from the interview (Q1).
    - For each required skill, check it exists:
        ls ~/.config/opencode/skills/<name>
    - Show the result (do NOT block the interview):
        ✅ found: <name>
        ❌ missing: <name> — install: <install command from the table>
    - This is informational only; proceed to restate (4.5) regardless.
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
    - `HARNESS.md` — fill the interview-derived sections:
        - Entry point: dev server command, test command, lint command
        - Risk levels: copy the risk levels from the HARNESS-questions answers
          in the interview (e.g. auth = high, public sharing = high)
      Before writing HARNESS.md Entry point, check for port conflicts:
        - Host ports (macOS / Linux):
            lsof -nP -iTCP -sTCP:LISTEN | grep -E ':(3000|3001|8055|8056|5432)'
          (Linux fallback if lsof is missing: `ss -tlnp | grep -E ':(3000|3001|8055|8056|5432)'`)
        - Docker containers (catches ports not visible to lsof on the host):
            docker ps --format "table {{.Names}}\t{{.Ports}}"
      Show the result to the user. If a port the project needs is taken,
      propose free alternatives:
        - Frontend (Nuxt): 3000 / 3001
        - Directus:         8055 / 8056
        - PostgreSQL:       5432 / 5433
      Record the chosen ports in HARNESS.md Entry point (and in `.env` /
      docker-compose when the implementation session runs).
      Leave these sections EMPTY for the user to fill later:
        - Product contract (what must never break)
        - Decisions to inherit (architectural choices future agents must know)
    Each file: show draft → wait for ok → write → next file.
 9. Commit: "chore: initialize harness docs for [project name]"
 10. Write a brief session log into `PROGRESS.md`: what was done, which files
    were created, and the next step (start M1 from the roadmap). Do NOT leave
    PROGRESS.md as the empty scaffold.
    Include the session language on its own line so the next session can
    resume in the same language without asking:
    ```
    Session language: [language from Q0, e.g. ru or en]
    ```
 11. Remind user: "Add docs/design.md if you have a design system.
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
     Follow this order EXACTLY:
     1. Type `end` in THIS session to close it correctly — this triggers the
        Session End protocol (final commit + PROGRESS.md update + "Session
        closed" report). Do NOT skip this.
     2. Open a NEW session in this folder.
     3. Type `start` in the new session
        (triggers internal Session Start -> continues from roadmap M1)

     Reminder:
     - add docs/design.md if a design system appears
     - add docs/plan-main.md if there is a broader vision document
     - If this project uses Directus, create a dedicated `mcp` user (service
       account) in that Directus instance and put its static access token in
       the global `~/.config/opencode/opencode.jsonc` under
       `mcpServers.directus.headers.Authorization: "Bearer <token>"`. Scope
       (read-only vs read+write) is the developer's choice. See
       `instructions/directus-mcp-setup.md`.
     - Fill HARNESS.md sections — Product contract (what must never break) and
       Decisions to inherit (architectural choices future agents must know) —
       these require your input, not the agent's.
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
