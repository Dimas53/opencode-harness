# agent-adopt

> Use this skill for: connecting harness to an existing project.
> Runs analysis first, then generates docs and AGENTS.md.
> For read-only audit only → use agent-analyze.md instead.

## Purpose
Analyze an existing project AND create full documentation structure.
For projects that have code but no harness docs yet.

## Skill load check
After loading all skills in the stack — print:
"Loaded: agent-analyze ✓, grill-with-docs ✓, domain-modeling ✓, documentation-and-adrs ✓, planning-and-task-breakdown ✓"
If any skill failed to load — STOP and report to user before proceeding.

## Skill stack (load in this order)
1. ~/.config/opencode/skills/harness-init/agent-analyze.md  ← run analysis first
2. ~/.config/opencode/skills/grill-with-docs/SKILL.md ← fill knowledge gaps
3. ~/.config/opencode/skills/domain-modeling/SKILL.md ← extract technical terms for CONTEXT.md
4. ~/.config/opencode/skills/documentation-and-adrs/SKILL.md ← document architecture decisions
5. ~/.config/opencode/skills/planning-and-task-breakdown/SKILL.md

## Steps
0. **Bootstrap templates:**
   Run:
   ```bash
   ~/.opencode-harness/scripts/init-adopt.sh "$(pwd)" --no-open
   ```
   Wait for the command to complete before proceeding.
   Do NOT create files from memory — always use the script.

Q0. **Language — before any analysis:** SEQUENCE RULE
    First question after bootstrap, before anything else.
    Step 0 (bootstrap script) must complete fully before Q0 is shown.
    Q0 must be shown as a standalone message — no other text, no mode confirmation, no explanations.
    "What language should I respond in? / На каком языке мы общаемся? / Welche Sprache?"
    After answer — write to PROGRESS.md:
    ```
    Chat language: [ru / de / en / ...]
    ```
    All further chat messages, questions to user, and step-by-step interaction — in that language only. Report files and generated docs are always in English (see Hard rules).
    Only after receiving the answer — proceed to Step 1.
    Never combine Q0 with any other output.

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
4. Generate documentation — SWITCH TO ENGLISH FOR ALL FILES IN THIS STEP.
   Session language applies only to chat messages. All generated files must be in English.
   Source: use findings from agent-analyze report (docs/audits/YYYY-MM-DD-analysis.md).
   Before generating any files — show the user a list of all files that will be created/overwritten and ask once:
   'Ready to generate all documentation files? (yes/no)'
   After confirmation — generate and write ALL files without stopping between them.
   After all files are written — print a summary list of what was created.

   a) docs/CONTEXT.md — run domain-modeling extraction BEFORE writing:
      → Load and run domain-modeling skill:
        Read ~/.config/opencode/skills/domain-modeling/SKILL.md
        Apply methodology to the steps below.
      1. Read ALL files in: app/composables/, server/api/, app/components/
         For each file — extract: name, what it does, file:line, related files
      2. Write extracted terms table FIRST (Term | Definition | File:Line | Related)
      3. Then add Patterns from analysis report (repeating architectural concepts)
      4. Then add Gotchas from analysis CRITICAL and HIGH findings
      5. ONLY THEN add anything from grill answers as additional context
      Source priority: code extraction first, analysis report second, grill answers last.
      EXCLUDE: company names, partner names, product descriptions, marketing copy.
      Those belong in HARNESS.md, not CONTEXT.md.
      Minimum 10 terms with file:line. If fewer found — read deeper into components.

   b) docs/ARCHITECTURE.md — high-level overview:
      - Narrative paragraph: what the system does in one sentence, why this stack, key tradeoff
      - Tech stack table
      - Layer map as directory tree
      - Key Architecture Decisions table with rationale AND alternatives considered
      - Links to docs/architecture/*.md for each domain

   c) docs/architecture/ — one file per architectural domain:
      Before writing docs/architecture/*.md:
      → Load and run documentation-and-adrs skill:
        Read ~/.config/opencode/skills/documentation-and-adrs/SKILL.md
        Apply to document key architectural decisions. Use output as architecture/*.md content.
      Delete or overwrite the placeholder feature-name.md.
      Identify domains from the codebase (minimum: contact form, deployment).
      For each domain create a file named after the domain (e.g. contact-form.md, deployment.md).
      Each file structure:
      ## What It Does
      ## Files Involved (with file:line)
      ## Step-by-step Flow
      ## Key Decisions (why this approach, what was the alternative)
      ## Gotchas
      Minimum 2 files. More if codebase has distinct domains.

   d) docs/roadmap.md:
      - Current phase with date
      - Completed milestones
      - Next: take CRITICAL and HIGH findings from analysis report, convert to tasks
      - Icebox: LOW findings

   e) docs/skills-cheatsheet.md:
      Use ONLY 2-column tables. Format: | Skill | When to use |
      Separator must be: |---|---|
      NEVER use 3-column format |---|---|---|
      Remove skills irrelevant to this project's stack.

   f) AGENTS.md:
      Before writing AGENTS.md Stack Skills section:
      Run skill gap check — same as agent-new-project.md Step 4.4:
      - Extract technologies from analysis findings
      - List installed skills: ls ~/.config/opencode/skills/
      - Match by name (nuxt → nuxt skill, vue → vue skill, etc.)
      - In AGENTS.md Stack Skills write ONLY installed skills with full paths
      - Add comment for missing skills: # ❌ [technology] — skill not found
      - If all found — write only installed section
      - If some missing — write both installed and missing sections
      Then compose the rest:
      - Framework Structure with real paths from this project
      - Critical Rules derived from analysis findings
      - DoD section
      - Gotchas from analysis (CRITICAL and HIGH findings)

   g) HARNESS.md:
      - Entry Point: real commands from package.json / docker-compose
      - Product Contract: critical paths from grill answers
      - Risk Levels: calibrated to actual project risks
      - Decisions to Inherit: key architectural choices from analysis

   h) docs/design.md — extract design system from code:
      Read these files to extract actual design tokens:
      1. tailwind.config.ts — extract all colors from theme.extend.colors (name + hex)
      2. nuxt.config.ts — extract fonts from googleFonts.families (family name + weights)
      3. app/assets/css/*.css — extract custom CSS variables and @apply patterns
      4. package.json — check for icon libraries (@phosphor-icons, lucide-vue, etc.)
      Fill docs/design.md with real values found in code.
      If a value is not found — leave as TBD.
      Never leave design.md as an empty template if tailwind.config.ts exists.
5. Write session log to PROGRESS.md: "chore: initialize harness docs for [project name]"
6. Hand-off — print this block in session language:

   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ✅ [ProjectName] adopted

   📋 В ЭТОЙ СЕССИИ:
     → Analysis: docs/audits/YYYY-MM-DD-analysis.md
     → Файлы: [список всех созданных файлов]

   ⚠️ Критические findings:
     [CRITICAL и HIGH из отчёта, максимум 5]

   🚀 ПЕРЕД СЛЕДУЮЩЕЙ СЕССИЕЙ:
     1. Новая сессия → `start`
     2. Заполнить HARNESS.md: Product contract + Decisions to inherit
     3. Запустить `fix` для исправления критических находок

   📦 Незакоммиченные файлы:
     [список файлов из git status]
   Коммитить? (да/нет)

   После коммита:
   Пушить? (да/нет)
   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

   If user says yes to commit → run: git add + git commit -m "chore: initialize harness docs for [project name]"
   If commit succeeded → ask: "Push?" If yes → git push
   If user says no to commit → skip, remind: "Не забудьте закоммитить позже"

7. Remind user: "Add docs/plan-main.md if you have a broader vision document.
     If this project uses Directus, create a dedicated `mcp` user (service
     account) in that Directus instance and put its static access token in the
     global `~/.config/opencode/opencode.jsonc` under
     `mcpServers.directus.headers.Authorization: \"Bearer <token>\"`. Scope
     (read-only vs read+write) is the developer's choice. See
     `instructions/directus-mcp-setup.md`."

## Hard rules
- Q0 (language) — always after bootstrap, always before analysis. No exceptions.
- Step 1 — always the full agent-analyze protocol with report saved. Manual file analysis instead of the protocol is a violation.
- All generated files (ARCHITECTURE.md, CONTEXT.md, roadmap.md, AGENTS.md, HARNESS.md, PROGRESS.md) must always be written in English, regardless of session language. Session language applies only to chat messages and questions to the user.
- File content must be entirely in English. No mixing of languages anywhere inside generated files — including inline comments, section headers, and placeholder text.
- If --no-verify is needed for a commit — explain the reason to the user before using it and wait for explicit confirmation.
- Never ask what you can detect from code
- Never overwrite existing docs/ files without showing diff first
- design.md is filled from existing design tokens (tailwind.config.ts, fonts, icons) — never left as empty template
- If a task takes >30 min — create PLAN.md in project root. Use PLAN.md already present in project root. If not present — create from skill memory following standard structure. Mark milestones [x] only after running verify: command. Delete PLAN.md when task is done.
