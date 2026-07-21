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
    After the user answers, print one line acknowledging the language:
    "Understood, working in [language]. Setting up the project structure — this will take a few seconds."
    (print this in the session language from Q0, replacing [language] with the language name)
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
    - Extract technologies from the interview answers (Q1 stack).
    - List all installed skills:
        ls ~/.config/opencode/skills/
    - Match by semantic naming (e.g. "vue" covers Vue 3,
      "docker-expert" covers Docker, no match for Symfony → ❌).
    - Print a formatted block (do NOT block the interview):
      ```
      ┌─────────────────────────────────────┐
      │ ⚠️  SKILL GAP CHECK                 │
      │  ✅ vue — found                    │
      │  ✅ docker-expert — found          │
      │  ❌ symfony — not found             │
      │                                     │
      │  → will be repeated in hand-off below       │
      │  → https://mcpmarket.com/tools/skills│
      │  → https://www.skills.sh/           │
      └─────────────────────────────────────┘
      ```
      If all skills found — print the same block without ❌ lines,
      with header "✅ SKILL GAP CHECK — all ok".
    - **Store two lists for later use at step 8:**
      - `found_skills` = skills that matched (✅)
      - `missing_skills` = technologies with no skill match (❌)
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
 5. Before loading brainstorming, print a frame explaining why:
    ```
    ┌─ Brainstorming ──────────────────────────────┐
    │ Open questions remain — I will close them before      │
    │ planning. This takes 2-3 questions.       │
    └───────────────────────────────────────────────┘
    ```
    Load brainstorming — explore unknowns, surface assumptions
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
      - `docs/plan-main.md` — ONLY if Q-1 provided a spec/brief file: rewrite
        with the project's vision. If Q-1 answer was "no": delete this file
        (it's not needed — the user has no spec to formalise into a vision doc).
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
     **Specifically for AGENTS.md:**
      - Replace stack skills placeholder with the actual `found_skills` from step 4.4.
      - If `missing_skills` exists, add a comment line in the Stack Skills section:
        ```
        # Add missing skills here after installing:
        # https://mcpmarket.com/tools/skills/laravel/SKILL.md
        # https://www.skills.sh/laravel
        ```
 9. Commit: "chore: initialize harness docs for [project name]"
 10. Write a brief session log into `PROGRESS.md`: what was done, which files
    were created, and the next step (start M1 from the roadmap). Do NOT leave
    PROGRESS.md as the empty scaffold.
    Include the session language on its own line so the next session can
    resume in the same language without asking:
    ```
    Session language: [language from Q0, e.g. ru or en]
    ```
### Phase 2 — Hand off to the working session
11. Hand-off report — show the user a formatted visual block.
    IMPORTANT: print this entire hand-off in the session language
    (from Q0), not in English.
    Replace `[ProjectName]` with the real project name.
    Replace `[if missing: ❌ ...]` with the actual missing skills from
    step 4.4, one per line with ❌. If no missing skills — write
    "all required skills are installed" instead.
    ```
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ✅ [ProjectName] initialized

    📋 IN THIS SESSION:
      → Type `end`

    🚀 BEFORE NEXT SESSION:
      1. New session → `start`
      2. Add `docs/design.md` if a design system exists
      3. Add `docs/plan-main.md` if a broader vision document exists
      4. Fill HARNESS.md: Product contract + Decisions to inherit

    ⚠️ Missing skills:
      [if missing: ❌ skill — install command]
      [if all ok: all required skills are installed]
      → https://mcpmarket.com/tools/skills
      → https://www.skills.sh/
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ```
    After the hand-off block, print a separate line in the session language:
    ```
    ─────────────────────────────────────
    ▶ Done. Type `end` to close the session.
      Then Cmd+N (Mac) / Ctrl+N (Win/Linux) — new session.
    ─────────────────────────────────────
    ```
     Do NOT scaffold or run M1 here — `new` is docs + scaffold only.

## Hard rules
- Q0 (language) is ALWAYS first — before any other question, including Q-1
- Q-1 (spec file check) is asked AFTER Q0, so the question and all follow-ups
  are in the user's chosen language
- Never skip the interview — even if user seems to know everything
- NEVER write multiple files in one turn without confirmation between each one.
  One file = show draft → wait for confirmation → write → next file.
  Batch-writing all files at once is a VIOLATION.
- design.md is NOT generated here — user provides it manually
- Never touch the global AGENTS.md — only the project's scaffolded files
- `new` is documentation + scaffold only — project implementation (M1) happens
  in the next session, not here
- restate (step 4.5) is MANDATORY — no file is written before explicit "yes"
- NEVER create .env directly — only .env.example with placeholder values.
  Real .env is created by the developer manually and must be in .gitignore.
