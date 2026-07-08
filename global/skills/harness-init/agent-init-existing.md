# agent-init-existing

## Purpose
Analyze an existing project AND create full documentation structure.
For projects that have code but no harness docs yet.

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
4. Generate documentation using templates/docs/ as reference:
   - ARCHITECTURE.md (from codebase-health-check findings)
   - CONTEXT.md (domain terms discovered during analysis)
   - roadmap.md (current phase + next steps)
   - AGENTS.md (project-specific rules based on stack)
   - skills-cheatsheet.md (based on detected stack)
5. Each file: show draft → wait for ok → write → next file
6. Commit: "chore: initialize harness docs for [project name]"

## Hard rules
- Run agent-analyze BEFORE asking any questions
- Never ask what you can detect from code
- Never overwrite existing docs/ files without showing diff first
- One file at a time, always wait for confirmation
