# agent-adopt

> Use this skill for: connecting harness to an existing project.
> Runs analysis first, then generates docs and AGENTS.md.
> For read-only audit only → use agent-analyze.md instead.

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
0. **Bootstrap templates:**
   Run:
   ```bash
   ~/.opencode-harness/scripts/init-adopt.sh "$(pwd)" --no-open
   ```
   Wait for the command to complete before proceeding.
   Do NOT create files from memory — always use the script.

Q0. **Language — before any analysis:**
    First question after bootstrap, before anything else:
    "What language should I respond in? / На каком языке мы общаемся? / Welche Sprache?"
    After answer — write to PROGRESS.md:
    ```
    Session language: [ru / de / en / ...]
    ```
    All further questions, analysis, output, and file generation — in that language only.
    Only after receiving the answer — proceed to Step 1.

1. **Run agent-analyze in full protocol — do not improvise:**
   - Load all 6 sub-skills from agent-analyze.md:
     zoom-out, codebase-health-check, junior-to-senior,
     code-review-and-quality, security, premortem
   - Follow agent-analyze.md step by step (steps 0–10a)
   - Save report to docs/audits/YYYY-MM-DD-analysis.md
   - Verify the report file was written (step 10a from agent-analyze)
   - Print summary in session language (from Q0)
   FORBIDDEN: reading files manually instead of running the full protocol.
2. Present findings to user, ask for corrections
3. Load grill-with-docs — fill gaps agent couldn't detect from code:
   - What is the business purpose?
   - What's the current phase?
   - What integrations are planned but not yet in code?
    - Any constraints or decisions not visible in code?
    - HARNESS: Are there critical paths that must never break? (e.g., payments, auth, DB)
    - HARNESS: What is the risk level for DB operations, external API integrations, and auth?
4. Generate documentation using docs/ in current project as reference:
   - ARCHITECTURE.md (from codebase-health-check findings)
   - CONTEXT.md (domain terms discovered during analysis)
   - roadmap.md (current phase + next steps)
   - AGENTS.md (project-specific rules based on stack)
   - skills-cheatsheet.md (based on detected stack)
    - docs/specs/phase-1.md (if project plan requested)
    - HARNESS.md — use HARNESS.md already present in project root. If not present — create from skill memory following standard structure. Fill Entry point + Risk levels from analysis + grill answers, leave Product contract and Decisions to inherit as empty sections for user
5. Each file: show draft → wait for ok → write → next file
6. Write session log to PROGRESS.md: "chore: initialize harness docs for [project name]"
7. Commit: "chore: initialize harness docs for [project name]"
 8. Remind user: "Add docs/design.md if you have a design system.
    Add docs/plan-main.md if you have a broader vision document.
    If this project uses Directus, create a dedicated `mcp` user (service
    account) in that Directus instance and put its static access token in the
    global `~/.config/opencode/opencode.jsonc` under
    `mcpServers.directus.headers.Authorization: \"Bearer <token>\"`. Scope
    (read-only vs read+write) is the developer's choice. See
    `instructions/directus-mcp-setup.md`."

## Hard rules
- Q0 (language) — always after bootstrap, always before analysis. No exceptions.
- Step 1 — always the full agent-analyze protocol with report saved. Manual file analysis instead of the protocol is a violation.
- Never ask what you can detect from code
- Never overwrite existing docs/ files without showing diff first
- One file at a time, always wait for confirmation
- design.md is NOT generated here — user provides it manually
- If a task takes >30 min — create PLAN.md in project root. Use PLAN.md already present in project root. If not present — create from skill memory following standard structure. Mark milestones [x] only after running verify: command. Delete PLAN.md when task is done.
