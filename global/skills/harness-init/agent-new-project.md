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
7. Each file: show draft → wait for ok → write → next file
8. Commit: "chore: initialize harness docs for [project name]"
9. Remind user: "Add docs/design.md if you have a design system.
   Add docs/plan-main.md if you have a broader vision document."

## Hard rules
- Q0 (language) is always first, before anything else
- Never skip the interview — even if user seems to know everything
- Never generate all files at once — one at a time with confirmation
- design.md is NOT generated here — user provides it manually
- After commit — ALWAYS print a reminder about plan-main.md and design.md. This is mandatory, not optional. No exceptions.
