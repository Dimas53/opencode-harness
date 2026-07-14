# Global Rules

---

## Harness Shortcuts

When user types exactly:
- `new` — load and run `~/.config/opencode/skills/harness-init/agent-new-project.md`
- `existing` — load and run `~/.config/opencode/skills/harness-init/agent-init-existing.md`
- `analyze` — load and run `~/.config/opencode/skills/harness-init/agent-analyze.md`

**Fallback** (if shortcuts don't work):
```bash
cd /path/to/opencode-harness && make init PROJECT=$(pwd)
```
Scripts are kept as a backup path, not the primary workflow.

---

## Behavior

- Always make a plan before large changes
- After presenting a plan, WAIT for explicit user confirmation before starting implementation
- Present plans in the same language the user is currently writing in
- NEVER commit to git without explicit user confirmation
- NEVER push to git without explicit permission
- NEVER delete files without explicit confirmation
- NEVER modify lock files (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`)

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

## Safety Gates — STOP and ask user before doing any of these

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

## Access Restrictions

NEVER read or access these files/patterns without explicit user confirmation:
- `.env`, `.env.*`, `*.env`
- `docker-compose.prod.yml`, any file with `secret`, `credential`, or `password` in the name
- Private keys (`*.pem`, `*.key`, `id_rsa*`)

NEVER execute these operations without explicit confirmation:
- `DROP`, `DELETE`, `TRUNCATE` on any database table
- `rm -rf` on any directory
- Any command that writes outside the current project root

If a task requires reading a restricted file — stop and ask the user first,
explain why it's needed, and wait for explicit approval.

This is a behavioral safeguard, not a technical one — for real security,
the filesystem MCP server should be configured with restricted allowed paths
(see INSTALL.md "MCP Security" section).

---

## Safe to do autonomously

- Creating and editing source files (components, composables, server routes, modules)
- Adding new files to `docs/`
- Updating `docs/progress.md` and `docs/roadmap.md`
- Reading any project files
- Creating new collections or fields (NOT deleting)
- Adding JSDoc comments to existing files

---

## CSS / Layout Rules

- Never use absolute positioning except overlapping hero images or floating badges
- Always prefer flexbox or grid for layout
- All sizes in fixed px for mobile screens (not rem)
- No hover effects — use tap feedback (`active:scale-[0.98]` or equivalent)
- Follow the project's CSS framework conventions (Tailwind, SCSS, etc.)

---

## Code Style

- TypeScript strict mode always (where TypeScript is used)
- Follow conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- Python: PEP8 + type hints
- PHP / Symfony: PSR-12
- Vue / Nuxt: use `<script setup>`, composables for reusable logic, Pinia for global state
- Ionic: follow Ionic component conventions, use Angular or Vue patterns per project
- Always follow the conventions already established in the project

---

## Technology Standards

- Before implementing any feature with a framework or library — fetch latest docs via context7 MCP
- For Nuxt projects: always verify the Nuxt major version, follow the corresponding official directory structure
- For Symfony projects: verify the version and follow Symfony best practices
- For Ionic projects: verify target platform (iOS/Android/Web) before implementing native features
- Never assume framework conventions from training data — always resolve via context7 first

---

## Skills — Auto-Loading Rules

> ⚠️ Always read SKILL.md via filesystem path: `Read ~/.config/opencode/skills/foo/SKILL.md`
> Do NOT use the `skill` MCP tool — it only sees ~31 of 52 installed skills.

### Harness Entry Points
When user runs make init / make init-existing / make analyze:
→ Load ~/.config/opencode/skills/harness-init/SKILL.md first
→ harness-init detects scenario and delegates to correct agent-skill
→ Never skip harness-init and jump directly to an agent-skill

### Step 0 — Always load first (every session, every project)
```
Read ~/.config/opencode/skills/using-agent-skills/SKILL.md
```
Then check `docs/skills-cheatsheet.md` in the current project — it lists which skills apply to which tasks for THIS project.

### Security / Auth / Infrastructure
**Triggers:** auth, login, token, cookie, permissions, API route, server route,
`.env`, secrets, nginx, Docker, CORS, CSP, deploy, release, security audit,
new collection, new field
```
~/.config/opencode/skills/security/SKILL.md
```

### Codebase Health
**Triggers:** refactor, clean up, DRY, duplication, code health, assess codebase,
too big, messy code, what to refactor
```
~/.config/opencode/skills/codebase-health-check/SKILL.md
```

### Planning / Task Breakdown
**Triggers:** large or vague task, "plan", "break down", "where to start", unclear scope
```
~/.config/opencode/skills/planning-and-task-breakdown/SKILL.md
~/.config/opencode/skills/spec-driven-development/SKILL.md
~/.config/opencode/skills/grill-with-docs/SKILL.md
```

### New Feature / Implementation
**Triggers:** "add", "implement", "create", "build a component/page/endpoint"
```
~/.config/opencode/skills/incremental-implementation/SKILL.md
~/.config/opencode/skills/to-prd/SKILL.md
~/.config/opencode/skills/to-issues/SKILL.md
```

### UI / Frontend
**Triggers:** component, page, layout, form, styles, Tailwind, Nuxt UI
```
~/.config/opencode/skills/frontend-ui-engineering/SKILL.md
~/.config/opencode/skills/nuxt/SKILL.md
~/.config/opencode/skills/nuxt-ui/SKILL.md
~/.config/opencode/skills/vue/SKILL.md
~/.config/opencode/skills/tailwind-design-system/SKILL.md
```

### API / Backend
**Triggers:** endpoint, API, route, schema, collection
```
~/.config/opencode/skills/api-and-interface-design/SKILL.md
```

### Debugging / Error Fix
**Triggers:** "not working", "error", "bug", "why", "broken", error in logs
```
~/.config/opencode/skills/debugging-and-error-recovery/SKILL.md
~/.config/opencode/skills/diagnose/SKILL.md
~/.config/opencode/skills/systematic-debugging/SKILL.md
```

### Code Review / Refactoring
**Triggers:** "review", "improve", "refactor", "clean up", "optimize"
```
~/.config/opencode/skills/code-review-and-quality/SKILL.md
~/.config/opencode/skills/performance-optimization/SKILL.md
~/.config/opencode/skills/zoom-out/SKILL.md
~/.config/opencode/skills/improve-codebase-architecture/SKILL.md
~/.config/opencode/skills/code-simplification/SKILL.md
```

### TDD / Tests
**Triggers:** "write test", "cover with tests", "TDD", "failing test", "Playwright", "Vitest"
```
~/.config/opencode/skills/test-driven-development/SKILL.md
~/.config/opencode/skills/tdd/SKILL.md
~/.config/opencode/skills/browser-testing-with-devtools/SKILL.md
```

### Git / Commits
**Triggers:** commit, branch, merge, PR, versioning
```
~/.config/opencode/skills/git-workflow-and-versioning/SKILL.md
```

### Documentation
**Triggers:** "document", "write docs", ADR, terminology, onboarding, CONTEXT.md
```
~/.config/opencode/skills/documentation-and-adrs/SKILL.md
~/.config/opencode/skills/grill-with-docs/SKILL.md
~/.config/opencode/skills/zoom-out/SKILL.md
```

### Session Handoff
**Triggers:** "new session", "pass context", context limit reached
```
~/.config/opencode/skills/handoff/SKILL.md
```

### Token Saving
**Triggers:** "save tokens", "be brief", token budget concerns
```
~/.config/opencode/skills/caveman/SKILL.md
```

### Brainstorming / Idea Refinement
**Triggers:** "idea", "brainstorm", "not sure what to build", "help me think"
```
~/.config/opencode/skills/brainstorming/SKILL.md
~/.config/opencode/skills/idea-refine/SKILL.md
~/.config/opencode/skills/interview-me/SKILL.md
```

### Specs / Requirements
**Triggers:** "spec", "requirements", "what should this do", new feature without clear scope
```
~/.config/opencode/skills/spec-driven-development/SKILL.md
~/.config/opencode/skills/grill-me/SKILL.md
~/.config/opencode/skills/grill-with-docs/SKILL.md
```

### Parallel / Complex Tasks
**Triggers:** multiple independent subtasks, "do this in parallel"
```
~/.config/opencode/skills/dispatching-parallel-agents/SKILL.md
~/.config/opencode/skills/executing-plans/SKILL.md
~/.config/opencode/skills/subagent-driven-development/SKILL.md
```

### CI/CD / Deploy
**Triggers:** pipeline, GitHub Actions, deploy, Docker, production
```
~/.config/opencode/skills/ci-cd-and-automation/SKILL.md
~/.config/opencode/skills/shipping-and-launch/SKILL.md
~/.config/opencode/skills/docker-expert/SKILL.md
```

### Skill Discovery
When a new skill is installed or discovered in `~/.config/opencode/skills/`:
1. Read its SKILL.md
2. Add it to `docs/skills-cheatsheet.md` in the current project
3. Do this automatically — no need to ask the user

---

## Session Start — MANDATORY SEQUENCE

**Run this sequence at the start of EVERY session, regardless of what the user's first message is.
Complete all steps BEFORE responding to the user's request.**

**Step 1 — Load global skill**
```
Read ~/.config/opencode/skills/using-agent-skills/SKILL.md
```

**Step 2 — Load stack skills**
Check project `AGENTS.md` for the "Stack Skills" section and load all listed skills.

**Step 3 — Read git log**
```bash
git log --oneline -5
```

**Step 4 — Read progress.md**
```
Read docs/progress.md
```

**Step 5 — Sync check**
Compare git log with `progress.md`. If out of sync — update `progress.md` FIRST before anything else.

**Step 6 — Read roadmap.md**
```
Read docs/roadmap.md
```

**Step 7 — Load task-specific context**
Check project `AGENTS.md` "Task Context" table and load relevant docs for the current task.

**Step 8 — Load task-specific skills**
Check `docs/skills-cheatsheet.md` and load relevant skills per triggers above.

**Step 9 — Report session start**
Before writing any code, output:
```
✓ Session initialized.
Current phase: [phase name from roadmap]
Last commit: [hash — message]
Progress status: [one line from progress.md current status]
Working on: [what user asked for]
Skills loaded: [list]
```

---

## Definition of Done — MANDATORY CHECKLIST

**BEFORE saying "done", "ready", or "finished" — execute every step below without exception.
Skipping any step is a violation. "I only did X in this prompt" is NOT an excuse —
you must look at the ENTIRE conversation window, not just the last action.**

### STEP 0 — SESSION SCAN (do this first, before any other step)

Run both commands:
```bash
git log --oneline origin/main..HEAD
```
Also scroll back through this conversation and list EVERYTHING that was created, modified, or deployed:
- New flows, automations, or scheduled jobs
- New collections, tables, or schema changes
- Composables / modules / server routes / utilities
- Pages / components / templates
- Config / Docker / nginx / deploy scripts
- Any other file touched

Write this list explicitly. Then use it as input for every step below.
If git log shows nothing but you did work in this session — still list what you did.

---

### STEP 1 — progress.md
```
[ ] progress.md updated:
      — completed items moved to Current status
      — new Known issues added if any discovered
      — Next session plan updated
      — Git log section updated with latest commit hash
      — reflects EVERYTHING from SESSION SCAN, not just last action
```

### STEP 2 — Architecture docs
```
[ ] For EACH item in SESSION SCAN — ask: "Is there a doc that describes this?"
      IF YES → update it now
      IF NO and item is significant → create docs/architecture/feature-name.md

      Significant = new page, Flow, collection, composable with business logic, external service
      NOT significant = CSS tweak, typo fix, minor UI change

      DO NOT WAIT FOR USER TO ASK. DO NOT SKIP. DO NOT DEFER TO NEXT SESSION.
```

### STEP 3 — JSDoc
```
[ ] JSDoc added or updated for:
      — new composable/module created
      — existing composable/module significantly modified
      — new component with non-trivial logic
      — new server route or API endpoint
      — new utility function
```

### STEP 4 — Tests
```
[ ] If tests exist in this project — run them:
      — all existing tests must pass before push
      — if new feature added — add at least one test
      — if no test suite exists — skip this step
```

### STEP 5 — roadmap.md
```
[ ] roadmap.md checked:
      — if current Phase fully complete → mark ✅ with date
      — if Phase checkboxes changed → update them
```

### STEP 6 — Safety check
```
[ ] No Russian text introduced in project files
[ ] No .env, docker-compose, lock files modified without confirmation
```

---

**Only after ALL steps are confirmed — respond to the user with results.**

---

## Documentation Session — Trigger & Script

### When to trigger
After EVERY response, run this check silently:
```bash
git log --oneline -- docs/ | head -1
git log --oneline | head -1
```
If docs commit is more than 5 commits behind HEAD OR more than 1 week old:
→ After completing current task, ask:
> "Documentation is behind code changes. Want me to run a docs update session?
> I'll update CONTEXT.md, architecture files, and JSDoc. Separate commit, no logic changes."

### When a phase or major feature completes — always ask immediately:
> "Phase complete. Documentation update needed: CONTEXT.md, architecture files, JSDoc. Run now?"

### Documentation Session Script (run in order, no logic changes)
1. **CONTEXT.md** — add new domain terms, append only, do NOT delete existing
2. **docs/architecture/** — update or create file for changed/new feature
3. **docs/specs/** — if new feature built without spec → create `docs/specs/feature-name.md`
4. **JSDoc** — only files created or significantly changed since last docs session
5. **progress.md** — add line: `Docs updated: CONTEXT.md, [files], JSDoc for [list]`
6. **Commit:** `docs: update CONTEXT, architecture, JSDoc after [feature/phase name]`

### Rules during docs session
- Do NOT change any logic — only comments and `.md` files
- Do NOT re-document files unchanged since last docs session
- Do NOT mix docs update and feature work in the same session
- Do NOT delete existing sections in `CONTEXT.md` or `ARCHITECTURE.md` — only append

---

## Session End Protocol — triggered by `git push`

**Triggers:** agent just ran `git commit` OR agent just ran `git push` — regardless of how user asked for it.

When `git commit` completes → run Definition of Done (Steps 1-5 above).
When `git push` completes → run Session End Protocol below.

**Step 1 — Docs lag check**
```bash
git log --oneline -- docs/ | head -1
git log --oneline | head -1
```
If docs commit is more than 5 commits behind HEAD → ask:
> "Docs are behind code. Update now or next session?"

**Step 2 — Progress update**
Update `docs/progress.md`:
- Add brief summary of what was done this session
- Update Known issues if anything new discovered
- Update Next session plan with concrete next steps

**Step 3 — Session summary output**
```
Session closed.
Done: [brief list of what was accomplished]
Next: [top 1-2 items from Next session plan]
Docs status: [up to date / behind by N commits]
```

**Step 4 — Push**
Only after steps 1-3 are complete — run `git push`.

> If user exits without pushing — no protocol runs. That's on the user.
> Commit = Definition of Done. Push = Session End. This is the full cycle.

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

## Design System (Global Default)

- Always read `docs/design.md` before writing any UI code
- Use only color tokens and typography defined in `docs/design.md`
- Follow the icon library and component conventions defined in the project AGENTS.md
