# agent-new-project

## Purpose
Initialize a brand new project from scratch.
Collect requirements via interview, generate full documentation.

## Skill load check
After loading all skills in the stack — print:
"Loaded: interview-me ✓, brainstorming ✓, planning-and-task-breakdown ✓, spec-driven-development ✓"
If any skill failed to load — STOP and report to user before proceeding.

## Skill stack (load in this order)
1. ~/.config/opencode/skills/interview-me/SKILL.md
2. ~/.config/opencode/skills/brainstorming/SKILL.md
3. ~/.config/opencode/skills/planning-and-task-breakdown/SKILL.md
4. ~/.config/opencode/skills/spec-driven-development/SKILL.md

## Steps
0. Ask Q-1: "Do you have a requirements document, design brief, or any existing spec? If yes — share it now, I will read it first and ask only clarifying questions about what is missing. If no — just say 'no' and we will go through the full interview."
   - If user provides a file → read it, ask max 2-3 clarifying questions, skip anything already covered in the file
   - If "no" → proceed to standard interview from Q0
1. Ask Q0: what language should I respond in?
2. Load interview-me — run structured interview:
   - Project name and purpose (2-3 sentences)
   - Tech stack (frontend, backend, database, deployment)
   - Team size
   - Stage (MVP or production-critical)
   - External integrations
   - Sensitive data?
   - Deployment target
   - Design system? (if yes — user adds design.md manually before session)
    - Project plan? (phases and milestones)
    - HARNESS: Are there critical paths that must never break? (e.g., payments, auth, DB)
    - HARNESS: What is the risk level for DB operations, external API integrations, and auth?
3. Load brainstorming — explore unknowns, surface assumptions
4. Load planning-and-task-breakdown — structure phases and tasks
5. Load spec-driven-development — write phase-1 spec
6. Generate documentation using templates/docs/ as reference:
   - AGENTS.md
   - ARCHITECTURE.md
   - CONTEXT.md
   - roadmap.md
   - skills-cheatsheet.md
    - docs/specs/phase-1.md
    - HARNESS.md (from templates/HARNESS.md — use interview answers to fill Entry point + Risk levels, leave Product contract and Decisions to inherit as empty sections for user to complete)
7. Each file: show draft → wait for ok → write → next file
8. Commit: "chore: initialize harness docs for [project name]"
9. Remind user: "Add docs/design.md if you have a design system.
   Add docs/plan-main.md if you have a broader vision document."

## Hard rules
- Q-1 (spec file check) is always first — before any other question
- If user provided a spec file — read it, limit follow-ups to 2-3, do not repeat what's in the file
- If "no" — Q0 (language) is next, then full interview
- Never skip the interview — even if user seems to know everything
- Never generate all files at once — one at a time with confirmation
- design.md is NOT generated here — user provides it manually
- After commit — ALWAYS print a reminder about plan-main.md and design.md. This is mandatory, not optional. No exceptions.
