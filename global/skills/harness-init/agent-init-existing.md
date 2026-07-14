# agent-init-existing

## Purpose
Analyze an existing project AND create full documentation structure.
For projects that have code but no harness docs yet.

## Skill load check
After loading all skills in the stack — print:
"Loaded: agent-analyze ✓, grill-with-docs ✓, planning-and-task-breakdown ✓"
If any skill failed to load — STOP and report to user before proceeding.

## Skill stack (load in this order)
1. ~/.config/opencode/skills/harness-init/agent-analyze.md  ← run analysis first
2. ~/.config/opencode/skills/grill-with-docs/SKILL.md ← fill knowledge gaps
3. ~/.config/opencode/skills/planning-and-task-breakdown/SKILL.md

## Steps
1. Run agent-analyze first — get full picture of the project
2. Present findings to user, ask for corrections
3. Load grill-with-docs — fill gaps agent couldn't detect from code:
   - What is the business purpose?
   - What's the current phase?
   - What integrations are planned but not yet in code?
    - Any constraints or decisions not visible in code?
    - HARNESS: Are there critical paths that must never break? (e.g., payments, auth, DB)
    - HARNESS: What is the risk level for DB operations, external API integrations, and auth?
4. Generate documentation using templates/docs/ as reference:
   - ARCHITECTURE.md (from codebase-health-check findings)
   - CONTEXT.md (domain terms discovered during analysis)
   - roadmap.md (current phase + next steps)
   - AGENTS.md (project-specific rules based on stack)
   - skills-cheatsheet.md (based on detected stack)
    - docs/specs/phase-1.md (if project plan requested)
    - HARNESS.md (from templates/HARNESS.md — fill Entry point + Risk levels from analysis + grill answers, leave Product contract and Decisions to inherit as empty sections for user)
5. Each file: show draft → wait for ok → write → next file
6. Commit: "chore: initialize harness docs for [project name]"
7. Remind user: "Add docs/design.md if you have a design system.
   Add docs/plan-main.md if you have a broader vision document."

## Hard rules
- Run agent-analyze BEFORE asking any questions
- Never ask what you can detect from code
- Never overwrite existing docs/ files without showing diff first
- One file at a time, always wait for confirmation
- design.md is NOT generated here — user provides it manually
- If a task takes >30 min — create PLAN.md in project root from templates/PLAN.md. Mark milestones [x] only after running verify: command. Delete PLAN.md when task is done.
