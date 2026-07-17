# Global Rules

---

## Harness Shortcuts

When user types exactly:
- `new` — load and run `~/.config/opencode/skills/harness-init/agent-new-project.md`
- `existing` — load and run `~/.config/opencode/skills/harness-init/agent-init-existing.md`
- `analyze` — load and run `~/.config/opencode/skills/harness-init/agent-analyze.md`

- `update-harness` — pull latest updates and apply globally:
  cd ~/.opencode-harness
  GIT_OUTPUT=$(git pull 2>&1)
  if echo "$GIT_OUTPUT" | grep -q "Already up to date"; then
    echo "✓ git pull: up to date"
  else
    echo "✓ git pull: commits pulled"
  fi
  make update
  echo "✓ AGENTS.md: check output above"
  echo "✓ Skills: check output above"

- `dod` — run `make dod` in current project directory
- `docs` — run `make session-end` and remind to update docs if code changed

- `sync-templates` — check for new harness template files missing in current project:
  missing=0
  for f in ~/.opencode-harness/templates/*.md; do
    fname=$(basename "$f")
    [ "$fname" = "AGENTS.md" ] && continue
    if [ ! -f "$(pwd)/$fname" ]; then
      echo "  + $fname — not in project"
      missing=1
    fi
  done
  [ ! -d "$(pwd)/memory" ] && echo "  + memory/ — directory not in project" && missing=1
  if [ "$missing" = "1" ]; then
    printf "Copy missing files to project? (y/n): "
    read -r answer
    if [ "$answer" = "y" ]; then
      for f in ~/.opencode-harness/templates/*.md; do
        fname=$(basename "$f")
        [ "$fname" = "AGENTS.md" ] && continue
        [ ! -f "$(pwd)/$fname" ] && cp "$f" "$(pwd)/$fname" && echo "✓ Copied $fname"
      done
      [ ! -d "$(pwd)/memory" ] && mkdir -p "$(pwd)/memory" && echo "✓ Created memory/"
    fi
  else
    echo "✓ Nothing to add — project is up to date"
  fi

**Fallback** (if shortcuts don't work):
```bash
cd /path/to/opencode-harness && make init PROJECT=$(pwd)
```
Scripts are kept as a backup path, not the primary workflow.

---

## Hard Limits

General — destructive actions regardless of project. Never do without explicit user confirmation:
- `git push` / `git push --force`
- `rm -rf` / deleting directories
- Modifying `.env.production`
- Any actions outside the current project
- Running scripts from external sources (`curl | sh`)

---

## Safety Gates — STOP and ask user before doing any of these

Project-level — configs and infrastructure that could break the project.

| Action | Reason |
|--------|--------|
| Modifying `docker-compose.yml` or `docker-compose.prod.yml` | Can destroy entire infrastructure |
| Modifying any `.env` file | Contains secrets, tokens, passwords |
| Deleting collections or migrations | Irreversible data loss |
| Running `git push` or `git push --force` | Implicit production deploy |
| Deleting files from `docs/` or `notes/` | Loss of documentation |
| Changing permissions for any role | Risk of privilege escalation |
| Running any deployment script (`Makefile`, `deploy.sh`, `rsync`, `scp`) | Show command first, wait for approval |
| Connecting to remote servers or SSH | External access requires explicit confirmation |
| Opening browser sessions or triggering webhooks | Requires explicit confirmation |
| Modifying `nuxt.config.ts` or `vite.config.ts` | Core config changes |
| Running database migrations | Schema changes |
| Installing new dependencies | Requires explicit confirmation |
| Modifying `composer.json` or `package.json` | Requires explicit confirmation |
| Modifying `AGENTS.md` or `CLAUDE.md` in any project | Changes agent's own rules — must be transparent |

**Tool approval dialogs:** always choose "once", never "always" unless explicitly instructed.

---

[ENFORCEMENT RULES: STARTUP]
- MANDATORY: Execute all 7 steps in ## Session Start below. Non-negotiable.
- STOP-CONDITION: Any step fails (non-zero exit, missing file, read error) — halt immediately. Report the exact error. Wait for user instruction. Do NOT proceed. Do NOT assume success.
- OUTPUT-LOCK: The first output of this session MUST be the Session Initialized report. No preamble, no greetings, no "I'll start". The block must appear before any other text.

[ENFORCEMENT RULES: COMMIT & DOD]
- TRIGGER-LOCK: Before every `git commit` — Definition of Done MUST execute first. You are forbidden to run `git commit` without completing DoD.
- MANDATORY: Execute all 6 steps in ## Definition of Done below before saying "done", "ready", or "finished".
- NO-BYPASS: "I only did X in this prompt" is not an excuse. Scan entire conversation.
- VERIFY-BEFORE-MARK: Do NOT mark any DoD step `[✓]` until confirmed executed. Use `[•]` in progress, `[ ]` todo.

[ENFORCEMENT RULES: SESSION END]
- TRIGGER-LOCK: On "end / done" or `git push` — Session End protocol MUST run.
- STOP-CONDITION: If docs lag check shows >3 commits — warn user before commit or push. Do not skip.
- MANDATORY: Save workarounds to `memory/YYYY-MM-DD.md` if any found. Do not wait, do not forget.
- OUTPUT-LOCK: The final output MUST be the "Session closed" report. Without it, session is not ended.

---

## Session Start

Execute these steps in order BEFORE any response to the user:

1. `pwd && git log --oneline -10`
2. Load `using-agent-skills` — try filesystem path first: `Read ~/.config/opencode/skills/using-agent-skills/SKILL.md`. If not found (built-in skill), load via `skill("using-agent-skills")` instead. Also check project `docs/skills-cheatsheet.md` for relevant skills matching current task triggers.
3. Read `PROGRESS.md` in project root — compare git log with progress status. If out of sync, update PROGRESS.md FIRST. If file doesn't exist — skip.
4. Read `docs/roadmap.md`
5. Read `MEMORY.md` and `memory/YYYY-MM-DD.md` if they exist (for today or yesterday)
6. Read `HARNESS.md` if it exists — apply project constraints and risk levels to session behavior
7. Report:
   ```
   Session initialized. Phase: [from roadmap]. Last commit: [hash — msg].
   Progress: [from progress.md]. Skills loaded: [list].
   ```

**If any step fails — stop, report the error, ask user how to proceed.**

→ Need more detail or troubleshooting? `load skills/startup/SKILL.md`

---

## Session End

**Triggers:** after `git commit` → run Definition of Done first. After `git push` or user says "end / done / finish / finished / close / session end / bye / Ende / Schluss / fertig / tschüss / bis dann" → run below.

1. Check docs lag:
   ```bash
   git log --oneline -- docs/ | head -1
   git log --oneline | head -1
   ```
   If docs commit is more than 3 commits behind HEAD → warn user.

2. `git add` and `git commit` if there are uncommitted changes.
3. Write to `PROGRESS.md` — append session summary: what was done overall, what's next (session-level summary, not per-task detail — DoD already handled that).
4. If you found a workaround or important error this session — write to `memory/YYYY-MM-DD.md` NOW. Do not wait.
5. Report:
   ```
   Session closed. Done: [what was accomplished]. Next: [items].
   ```
6. Ask user: "Push to remote? (y/n)" — wait for explicit confirmation before running `git push`.

**Note:** If user exits without push — no protocol runs. Commit = DoD. Push = Session End.

→ Need edge cases or troubleshooting? `load skills/session-end/SKILL.md`

---

## Definition of Done

**Triggers:** before saying "done" / "ready" / "finished" — execute ALL steps below. Must also run before every `git commit` (Session End calls this first). Skipping any step is a violation.

1. **Session scan:** `git log --oneline origin/main..HEAD`. List everything created/modified/deployed this session.
2. **Update docs (mandatory per item):**

   | What changed | Must update |
   |-------------|-------------|
   | new page/feature | `docs/architecture/feature-name.md` + `PROGRESS.md` |
   | new collection/field | `docs/schema.md` or schema section + `PROGRESS.md` |
   | new Flow/operation | `docs/flows.md` or flows section + `PROGRESS.md` |
   | new composable/utility | JSDoc on the function + `PROGRESS.md` |
   | config/deploy change | `docs/deployment.md` + `PROGRESS.md` |
   | bugfix/refactor | `PROGRESS.md` only |
   | risk level / product contract / security config change | `HARNESS.md` + `PROGRESS.md` |
   | anything else | `PROGRESS.md` always |

   `PROGRESS.md`: add completed items, known issues (per-task detail)
3. **JSDoc:** Add for new composables, modules, server routes, utility functions, components with non-trivial logic.
4. **Tests:** If test suite exists — run it. All tests must pass. If new feature — add at least one test.
5. **Safety check:** No Russian text in project files. No .env, docker-compose, or lock files modified without confirmation.
5b. **Skill feedback:** If any skill behaved unexpectedly or missed an important step — note in memory/YYYY-MM-DD.md what happened and what behavior was expected. Human decides whether to update SKILL.md.
6. **Respond with results** only after ALL steps are confirmed.

NEVER mark `[✓]` before executing. `[•]` = in progress, `[ ]` = todo, `[✓]` = confirmed done.

→ Full checklists with examples: `load skills/dod/SKILL.md`

---

## Behavior

- Always make a plan before large changes
- After presenting a plan, WAIT for explicit user confirmation before starting implementation
- Present plans in the same language the user is currently writing in
- NEVER commit to git without explicit user confirmation
- NEVER push to git without explicit permission
- NEVER delete files without explicit confirmation
- NEVER modify lock files (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`)
- If you execute the same action three times in a row without progress — STOP. Describe the problem to the user instead of continuing.
- For files > 200 lines — use grep to find the relevant section instead of reading the whole file. Exception: when full file context is required.
- If you are ever in doubt whether an action requires confirmation — assume it does and ask.
- Do not ask redundant questions. If you already have enough context to proceed — do it. Ask only when you genuinely cannot proceed without an answer.
- If a task will take more than 30 minutes or requires many steps — checkpoint mid-way. Save progress to PROGRESS.md and suggest starting a new session to avoid context Loss. This is a soft recommendation, not a hard rule.

---

## Language Rules

### Chat language
- Respond in whatever language the user writes their first message in
- If the user switches language mid-session — switch to match immediately
- No default language — always mirror the user's input language

### English-Only Policy (code & project files)
Russian is strictly prohibited in:
- source code, comments, variable/function/file names
- documentation, commit messages, pull requests
- TODOs, FIXMEs, UI text, logs, tests, config files, generated code

**Exception:** `notes/` folder — Russian is allowed there.

Before starting work in any repository:
1. Perform a one-time full-project scan for Cyrillic characters
2. Report detected Russian text and replace it with English whenever the affected file is touched
3. Before every commit: scan all modified files, replace any Cyrillic found

Never generate, insert, copy, or preserve Russian text in project files under any circumstances.

---

## Code Style — Comments

**Check: does the current project have harness files?**

Look for these files (ANY match = harness project):
- `scripts/init-project.sh`, `scripts/init-existing.sh`, `scripts/analyze.sh`
- `Makefile` with `init` or `init-existing` or `analyze` targets
- `global/AGENTS.md` with "Harness Shortcuts" section

**If YES (harness project):** JSDoc required for composables, server routes, utilities, and complex functions. Inline comments for non-obvious logic, workarounds, and edge cases. No comments on trivial getters/setters.

**If NO (not a harness project):** Ask the user ONCE at session start: "Should I add comments/documentation in this project?" Follow their answer for the entire session. Default to no if they don't answer.

### General rules
- TypeScript strict mode always
- Follow conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- Python: PEP8 + type hints. PHP/Symfony: PSR-12
- Vue/Nuxt: `<script setup>`, composables, Pinia
- Always follow the conventions already established in the project

---

## Working in External / Client Projects

- Do not add comments, docblocks, or inline documentation unless explicitly asked
- Do not create or modify README, CHANGELOG, ADR, or any documentation files
- Do not refactor or clean up code outside the scope of the requested change
- Do not install new dependencies without explicit confirmation
- Do not suggest architectural improvements unless asked
- Manual control only: do exactly what was asked, nothing more
- Before any file change: list the files that will be modified and wait for confirmation
- Never modify `composer.json` or `package.json` without explicit confirmation
- Never run migrations or schema changes
- Never touch `.env` or any config with credentials

---

## Honesty Over Guessing

If you're unsure about an API — say so. Don't guess and make up syntax.

Ask the user: "Should I check context7 for current docs?"

context7 is available for manual use when the user explicitly asks you to look up a specific framework or library. Not automatic on every framework touch.

---

## Access Restrictions

NEVER read or access these files/patterns without explicit user confirmation:
- `.env`, `.env.*`, `*.env`
- `docker-compose.prod.yml`, any file with `secret`, `credential`, or `password` in the name
- Private keys (`*.pem`, `*.key`, `id_rsa*`)

NEVER execute these operations without explicit confirmation:
- `DROP`, `DELETE`, `TRUNCATE` on any database table
- `rm -rf` on any directory
- Any command that writes outside the current project root

If a task requires reading a restricted file — stop and ask the user first, explain why it's needed, and wait for explicit approval.

---

## Safe to do autonomously

- Creating and editing source files (components, composables, server routes, modules)
- Adding new files to `docs/`
- Updating `PROGRESS.md` and `docs/roadmap.md`
- Reading any project files
- Creating new collections or fields (NOT deleting)
- Adding JSDoc comments to existing files

---

## File Roles — Separation of Concerns

| File | Purpose | Who writes |
|------|---------|------------|
| `AGENTS.md` | Behavior — what to do, what not to do, how to work | Agent (one-time setup) |
| `MEMORY.md` | Experience — what happened, lessons learned, workarounds | Agent (accumulates over time) |
| `PROGRESS.md` | Continuity — what was done between sessions | Agent (each session) |
| `PLAN.md` | Task plan with verify gates — for tasks > 30 minutes | Agent (per task, deleted after) |

- `AGENTS.md` is procedural memory — always present.
- `MEMORY.md` is experiential — accumulates across projects.
- `PROGRESS.md` is session continuity — accumulates within project.
- `PLAN.md` is task-specific — created for complex tasks, deleted after completion.

---

## CSS / Layout Rules

- No absolute positioning except overlapping heroes or floating badges
- All sizes in fixed px for mobile (not rem), no hover effects — use tap feedback

→ Full rules: `load skills/frontend/SKILL.md`

## Design System

- Always read `docs/design.md` before writing any UI code
- Use only tokens and components defined there

→ Full reference: `load skills/frontend/SKILL.md`

---

## Documentation Session

Use `docs` shortcut (see Harness Shortcuts above) when user asks to update docs. No auto-trigger.

If `make dod` step 6 warns about code changes without docs — update relevant files before closing.

→ Full session reference: `load skills/documentation/SKILL.md``

---

## Skills — Auto-Loading (trigger → skill map)

Always load SKILL.md via filesystem path: `Read ~/.config/opencode/skills/<domain>/SKILL.md`

| Domain | Triggers | Path |
|--------|----------|------|
| Security/Auth | auth, login, token, cookie, permissions, API route, server route, `.env`, secrets, nginx, Docker, CORS, CSP, deploy, release, collection, field | security/SKILL.md |
| Codebase Health | refactor, clean up, DRY, duplication, code health, assess codebase, messy | codebase-health-check/SKILL.md |
| Planning | plan, break down, where to start, unclear scope, large task | planning-and-task-breakdown/SKILL.md |
| Specification | spec, requirements, what should this do, new feature no clear scope | spec-driven-development/SKILL.md |
| Implementation | add, implement, create, build a component/page/endpoint, new feature | incremental-implementation/SKILL.md |
| UI/Frontend | component, page, layout, form, styles, Tailwind, Nuxt UI, Vue | frontend-ui-engineering/SKILL.md, nuxt/SKILL.md, vue/SKILL.md |
| API/Backend | endpoint, API, route, schema, collection | api-and-interface-design/SKILL.md |
| Debugging | not working, error, bug, why, broken, error in logs | debugging-and-error-recovery/SKILL.md |
| Code Review | review, improve, refactor, clean up, optimize | code-review-and-quality/SKILL.md |
| TDD/Tests | write test, cover with tests, TDD, failing test, Playwright, Vitest | test-driven-development/SKILL.md |
| Git | commit, branch, merge, PR, versioning, release | git-workflow-and-versioning/SKILL.md |
| Documentation | document, write docs, ADR, terminology, onboarding, CONTEXT.md | documentation-and-adrs/SKILL.md |
| Session | new session, pass context, handoff, context limit | handoff/SKILL.md |
| Token Saving | save tokens, be brief, caveman, token budget | caveman/SKILL.md |
| Brainstorming | idea, brainstorm, not sure what to build, help me think | brainstorming/SKILL.md |
| CI/CD | pipeline, GitHub Actions, deploy, Docker, production | ci-cd-and-automation/SKILL.md |
| Parallel Tasks | multiple independent subtasks, do in parallel | dispatching-parallel-agents/SKILL.md |
| Skill Discovery | new skill installed, discovered | — auto-detect and add to docs/skills-cheatsheet.md |
| Architecture/Code Design | module, seam, depth, interface design, refactor, code health, improve architecture | codebase-design/SKILL.md, improve-codebase-architecture/SKILL.md |
| Domain Modeling | domain term, glossary, CONTEXT.md, ADR, ubiquitous language, terminology | domain-modeling/SKILL.md, documentation-and-adrs/SKILL.md |
| Research | investigate, research, find docs, gather facts, learn API | research/SKILL.md |
| Merge Conflicts | merge conflict, rebase conflict, git merge, resolve conflict | resolving-merge-conflicts/SKILL.md |
| Wayfinding / Large Planning | huge task, multi-session, roadmap, chartered effort | wayfinder/SKILL.md, planning-and-task-breakdown/SKILL.md |
| TS Deep Modules | barrel files, dependency-cruiser, deep modules, entry points, package boundaries | setup-ts-deep-modules/SKILL.md, codebase-design/SKILL.md |

→ Full reference for when to use which skill: `read instructions/reference/03-skills-cheatsheet.md`
