# === HARNESS-MANAGED START — do not edit between these markers, `update-harness` overwrites this region on every run. Add your own rules above START or below END; they survive updates. ===

# Global Rules

---

## Harness Shortcuts

When user types:
- `new` — load and run `~/.config/opencode/skills/harness-init/agent-new-project.md`
- `adopt` — load and run `~/.config/opencode/skills/harness-init/agent-adopt.md`
- `analyze` — load and run `~/.config/opencode/skills/harness-init/agent-analyze.md` (full project, no TARGET)
- `analyze <path>` — load and run `~/.config/opencode/skills/harness-init/agent-analyze.md`, set TARGET=<path> (e.g. `analyze pages/Dashboard.vue` → TARGET=pages/Dashboard.vue)

- `fix` — load and run `~/.config/opencode/skills/harness-init/agent-fix.md`
- `fix <path>` — load and run `~/.config/opencode/skills/harness-init/agent-fix.md`, set TARGET=<path> (e.g. `fix server/api/` → TARGET=server/api/)

- `analyze-ui` — load and run `~/.config/opencode/skills/harness-init/agent-analyze-ui.md`
- `analyze-ui <path>` — load and run `~/.config/opencode/skills/harness-init/agent-analyze-ui.md`, set TARGET=<path>
- `fix-ui` — load and run `~/.config/opencode/skills/harness-init/agent-fix-ui.md`
- `fix-ui <path>` — load and run `~/.config/opencode/skills/harness-init/agent-fix-ui.md`, set TARGET=<path>
- `fix-ui <ID>` — load and run `~/.config/opencode/skills/harness-init/agent-fix-ui.md`, set TARGET=<ID> (e.g. `fix-ui U1`)
- `fix-ui all-pw` — load and run `~/.config/opencode/skills/harness-init/agent-fix-ui.md`, set TARGET=all-pw (Playwright findings only)

- `analyze-logic` — load and run `~/.config/opencode/skills/harness-init/agent-analyze-logic.md`
- `analyze-logic <path>` — load and run `~/.config/opencode/skills/harness-init/agent-analyze-logic.md`, set TARGET=<path>
- `fix-logic` — load and run `~/.config/opencode/skills/harness-init/agent-fix.md`, set SOURCE=docs/audits/logic-*.md (latest)
- `fix-logic <ID>` — load and run `~/.config/opencode/skills/harness-init/agent-fix.md`, set TARGET=<ID> (e.g. `fix-logic L1`)

- `update-harness` — pull latest updates and apply globally:
  Run: `bash ~/.opencode-harness/scripts/update-harness-shortcut.sh`

- `dod` — run the DoD gate manually: `make dod` if this project has a
  Makefile (harness repo only by design), otherwise
  `bash ~/.opencode-harness/scripts/dod.sh` directly. Client projects don't
  need this before every commit — the pre-commit hook already runs it
  automatically — this is for a manual pre-check.
- `docs` — run `bash ~/.opencode-harness/scripts/session-end.sh` (in the
  harness repo `make session-end` does the same) and remind to update docs
  if code changed. This is the same script as step 1 of `## Session End`,
  not a second path — the shortcut just lets you run it mid-session.

- `unadopt` — remove all harness files from the CURRENT project (AGENTS.md,
  MEMORY.md, PLAN.md, PROGRESS.md, HARNESS.md, `.agentignore`, memory/,
  both git hooks, the `.session-ended` / `.dod-run.log` state files, and the
  `.harness/` scratch directory).
  Run: `bash ~/.opencode-harness/scripts/unadopt.sh`
  Everything removed is backed up to `.harness-unadopt-backup/` first. Keeps
  `docs/` unless confirmed.
- `update-project` — bring THIS project up to date with the harness: new
  template files/doc structure, `.gitignore` entries, and git hooks
  (existing filled files are never overwritten — additions only). Also
  offers the optional CI gate if the project has none — as a separate
  question, never as part of the bulk confirmation.
  Run: `bash ~/.opencode-harness/scripts/update-project.sh`
- `refresh-agents` (also `update-project --refresh-agents`) — pull harness
  rule updates into THIS project's `AGENTS.md`. Only the regions marked
  `# === HARNESS-MANAGED START/END ===` are replaced; everything you filled
  in yourself is untouched. If the file has no markers, the script refuses
  and prints a diff instead — that is the correct outcome, not an error.
  Run: `bash ~/.opencode-harness/scripts/update-project.sh --refresh-agents`

**Both of these ask questions. Never answer them yourself.** A confirmation
the user never saw is not a confirmation. Do not pipe input into a harness
script (`printf 'y\n' | ...`), do not pass a default, do not "save the user a
step".

You cannot forward the user's keystrokes into a subprocess, so use the flags
that exist for exactly this — three steps, no shortcuts:

1. `bash ~/.opencode-harness/scripts/update-project.sh --dry-run` — prints the
   plan, changes nothing.
2. Show that output verbatim and **ask the user**, including the CI question
   separately (H-DEC-4: the CI gate is never installed silently).
3. Re-run carrying their answer:
   `… update-project.sh --yes --ci=none` (or `--ci=github` / `--ci=gitlab`),
   or `… update-project.sh --refresh-agents --yes`.

The flags report a decision the user made; they never stand in for one. Run
without them and with no terminal, the script exits with a message rather than
doing nothing — that is deliberate, so a silent no-op cannot be mistaken for
"already up to date". Same rule for `unadopt`.

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
- `git commit --no-verify` (or any other way of bypassing the pre-commit
  hook) — this disables ALL DoD checks at once, not just the one causing
  trouble. If a specific check genuinely looks like a false positive, use
  `DOD_SKIP=<step-name>` (documented at the top of `~/.opencode-harness/scripts/dod.sh`) to skip
  ONLY that named step — never the whole gate. A post-commit guard will
  detect a commit that bypassed DoD and roll it back automatically
  (`git reset --soft HEAD~1` — your change is not lost, but the bad commit
  is undone until you fix it).

---

## Self-Check Rule (applies to all multi-step tasks)

After every file edit, script change, or code modification:
- Re-read the modified block
- Verify the change is correct and doesn't conflict with adjacent code
- Only then proceed to the next step

For tasks with 3+ sequential changes — create PLAN.md with verify gates:
- `[ ] Step description | verify: <concrete command that proves it worked>`
Mark step `[x]` only after running the verify command and seeing expected output.
Never mark done without running verify.

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
- MANDATORY: Execute every step listed in ## Session Start below, in order.
  Non-negotiable. Do not paraphrase or hardcode the step count anywhere.
- STOP-CONDITION: Any step fails (non-zero exit, missing file, read error) — halt immediately. Report the exact error. Wait for user instruction. Do NOT proceed. Do NOT assume success.
- OUTPUT-LOCK: The first output of this session MUST be the Session Initialized report. No preamble, no greetings, no "I'll start". The block must appear before any other text.

[ENFORCEMENT RULES: COMMIT & DOD]
- TRIGGER-LOCK: Before every `git commit` — Definition of Done MUST execute first. You are forbidden to run `git commit` without completing DoD.
- MANDATORY: Execute every step listed in ## Definition of Done below, in the
  order given, before saying "done", "ready", or "finished". Do not
  paraphrase or hardcode the step count anywhere — read the section itself.
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

1. **Orient:** `pwd && git log --oneline -10`
   Also check that whatever the project needs to run is actually running
   (`docker ps`, dev server, `curl localhost:PORT`) — before you touch code,
   not after a failure makes you look.
2. **Load skills:** load `using-agent-skills` by calling the `skill` tool with that name. Only if the tool cannot find it, fall back to `Read ~/.config/opencode/skills/using-agent-skills/SKILL.md`. Also load the project's own stack skills (project `AGENTS.md` -> "Stack Skills") and check `docs/skills-cheatsheet.md` plus the project `AGENTS.md` "Task Context" table for anything matching the current task.
3. **Progress:** read `PROGRESS.md` in project root — compare git log with progress status. If out of sync, update PROGRESS.md FIRST. If file doesn't exist — skip.
   Older sessions live in `docs/progress-archive/` (rotated out by Session End) — read those only when the task actually reaches back that far, never as part of startup.
   After reading PROGRESS.md, look for a line starting with `Chat language:`.
   - If present — use that language for all chat messages and questions. Generated files are always in English (see hard rules in project or global AGENTS.md).
   - If absent — ask the user for their language explicitly before proceeding,
     then WRITE `Chat language: <chosen>` into `PROGRESS.md` (create the file
     if it does not exist) so the choice persists and is never asked again.
4. **Roadmap:** read `docs/roadmap.md`
5. **Memory:** read `MEMORY.md` if it exists. Its `## Index — memory/` section lists every note in `memory/` with a one-line summary, newest first — read a note's body only when the current task touches it.
   Do not read `memory/` by date: "today or yesterday" made everything older unreachable (14 notes in a live project, 2 readable), while the write side kept adding to it every session.
   Notes describe the past. If one names a file, function, flag or table, check it still exists before relying on it.
6. **Harness constraints:** read `HARNESS.md` if it exists — apply project constraints and risk levels to session behavior
7. **Directus MCP:** if the project uses the Directus MCP server (`.env` has DIRECTUS_URL, or
   HARNESS.md declares a Directus instance):
   - If a project-level `opencode.jsonc` exists in the project root — it is
     used automatically when OpenCode starts (it fully overrides the global
     config). No further action needed here. This is a READ only — never
     modify the config here.
   - If NO local `opencode.jsonc` exists — warn the user:
     "⚠️ Directus MCP is not configured for this project. Create `.env`
     (DIRECTUS_URL + MCP_DIRECTUS_TOKEN) and run
     `bash ~/.opencode-harness/scripts/gen-opencode.sh "$(pwd)"`
     (see ~/.opencode-harness/instructions/directus-mcp-setup.md)."
   - Do NOT modify any config. There is no global directus config to compare
     against and no switching.
8. **Report:**
   ```
   Session initialized. Phase: [from roadmap]. Last commit: [hash — msg].
   Progress: [from progress.md]. Skills loaded: [list].
   ```

**If any step fails — stop, report the error, ask user how to proceed.**

→ Need more detail or troubleshooting? `load skills/startup/SKILL.md`

---

## Session End

**Triggers:** after `git commit` → run Definition of Done first. After `git push` or user says "end / done / finish / finished / close / session end / bye / Ende / Schluss / fertig / tschüss / bis dann" → run below.

1. Run the mechanical session-end gate:
   ```bash
   bash ~/.opencode-harness/scripts/session-end.sh
   ```
   It checks docs lag, PROGRESS.md freshness, the memory log, doc
   placeholders, and uncommitted changes; it appends today's DoD audit trail
   to `memory/YYYY-MM-DD.md` and warns if `## Retro` is missing. Address
   everything it prints before continuing. It never blocks — a warning you
   ignore is a warning you own. Do not re-do its checks by hand; the steps
   below are what it cannot do for you.

2. If there are uncommitted changes — show `git status` and **ask** for
   confirmation. Commit only after an explicit "yes", staging named paths
   (or `git add -p`), never `git add -A`. Without confirmation: list what is
   uncommitted in the Session closed report and leave the index untouched.
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

**Single source of truth for this checklist.** `~/.config/opencode/skills/dod/SKILL.md`
mirrors this list exactly, step for step, for elaboration and examples only —
it must never define its own step or its own numbering. If the two ever
disagree, THIS section wins and the skill file is stale.

**Triggers:** before saying "done" / "ready" / "finished" — execute every step
below, in order. Also runs before every `git commit` (Session End calls this
first). Skipping any step is a violation. "I only did X in this prompt" is not
an excuse — scan the entire conversation.

1. **Session scan:** `git log --oneline origin/main..HEAD`. List everything
   created/modified/deployed this session.
2. **Update docs (mandatory per item):**

   | What changed | Must update |
   |-------------|-------------|
   | new page/feature | `docs/architecture/feature-name.md` + `PROGRESS.md` |
   | new DB collection/field (DB-backed projects only) | `docs/schema.md` or a schema section in an existing doc + `PROGRESS.md` — N/A if the project has no database |
   | new Directus Flow/operation (Directus projects only) | `docs/flows.md` or a flows section in an existing doc + `PROGRESS.md` — N/A if the project isn't Directus |
   | new composable/utility | JSDoc on the function + `PROGRESS.md` |
   | config/deploy change | `docs/deployment.md` + `PROGRESS.md` |
   | bugfix/refactor | `PROGRESS.md` only |
   | risk level / product contract / security config change | `HARNESS.md` + `PROGRESS.md` |
   | anything else | `PROGRESS.md` always |

   `PROGRESS.md`: add completed items, known issues (per-task detail).
3. **JSDoc:** Add for new composables, modules, server routes, utility
   functions, components with non-trivial logic.
4. **Tests:** If test suite exists — run it. All tests must pass. If new
   feature — add at least one test.
5. **Commit Gate:** The mechanical, exit-code-enforced gate
   (`~/.opencode-harness/scripts/dod.sh` — uncommitted changes, Cyrillic scan, docs lag,
   PROGRESS.md freshness, docs matrix, quick tests, self-check,
   `.agentignore` file-level check) runs AUTOMATICALLY via the pre-commit
   hook on every `git commit` — no manual command needed, and it must exit
   0 for the commit to go through. `make dod` runs the same checks
   manually, as a pre-check before you even attempt to commit — but it
   only works where a Makefile exists. Client projects don't ship one by
   design (the automatic hook already covers them); don't run `make dod`
   there, it will just error on a missing Makefile. This is a DIFFERENT
   check from steps 1-4 — those are judgment calls about product
   completeness, this is an automated mechanical gate. Both are required.
   Every run appends one line to `.dod-run.log` (local, gitignored). That
   file is a journal, not clutter: `session-end.sh` builds the
   `## Session audit trail` memory section from it, and the post-commit
   guard reads it to tell a real bypass from a gate disagreement. Never
   delete it. Same for `.session-ended` — it is the marker `start.sh` reads
   to know the previous session was closed properly.
6. **Safety check:** No Russian text in project files. No `.env`,
   docker-compose, or lock files modified without confirmation.
7. **Skill feedback:** If any skill behaved unexpectedly or missed an
   important step — note in `memory/YYYY-MM-DD.md` what happened and what
   behavior was expected. Human decides whether to update SKILL.md.
8. **Cleanup:** No leftover debug code (`console.log`, etc.) unless
   intentional. No TODO/FIXME left without a note explaining why it's
   deferred.
9. **Respond with results** only after ALL steps above are confirmed.

   Optional, harness-repo only: if this project defines a `make self-check`
   target (syntax/permissions/diff check) — run it as part of step 5. Most
   projects do not have this target; skip if absent.

NEVER mark `[✓]` before executing. `[•]` = in progress, `[ ]` = todo,
`[✓]` = confirmed done.

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

**Scope is the contract.** The rules above are all about not doing too much.
Quiet under-delivery is the more common failure and needs saying too:

- The requested scope IS the deliverable. Do not silently narrow it, widen it,
  or swap it for an adjacent task.
- Finish the whole task, not the easy part. If one part is genuinely blocked,
  complete every other part in full and say plainly what you left out and why.
  Cutting scope down is the user's call, not yours.
- Report faithfully: tests failed — say so and show the output; a step was
  skipped — say which; done and verified — say it plainly, without hedging.
- Found a problem with the request itself? Say it in a sentence or two and keep
  working under stated assumptions. Stop and wait only when proceeding under any
  reasonable assumption would be unsafe or useless.
- If the user reaffirms a request after your objection, that is their decision:
  record it and carry out the request in full.

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

 **Exception override — `memory/` is English ONLY:**
 - Entries in `memory/YYYY-MM-DD.md` are ALWAYS written in English,
   regardless of the session language (even if Q0 / Session language is ru).
 - No Cyrillic quotes or snippets, even inside workaround descriptions.
 - Rationale: memory files are cross-session agent knowledge; they must be
   machine-scannable and language-stable.

 Before starting work in any repository:
1. Perform a one-time full-project scan for Cyrillic characters
2. Report detected Russian text and replace it with English whenever the affected file is touched
3. Before every commit: scan all modified files, replace any Cyrillic found

Never generate, insert, copy, or preserve Russian text in project files under any circumstances.

---

## Code Style — Comments

**Check: is this project under the harness?**

Look for these files in the project root (ANY match = harness-adopted):
- `HARNESS.md`
- `AGENTS.md` together with `PROGRESS.md`
- `memory/` directory

**If YES (harness-adopted):** JSDoc required for composables, server routes, utilities, and complex functions. Inline comments for non-obvious logic, workarounds, and edge cases. No comments on trivial getters/setters. (This matches Definition of Done step 3, which requires JSDoc unconditionally — the two must not disagree.)

**If NO (not harness-adopted):** Ask the user ONCE at session start: "Should I add comments/documentation in this project?" Follow their answer for the entire session. Default to no if they don't answer.

### General rules
- TypeScript strict mode always
- Follow conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`
- Python: PEP8 + type hints. PHP/Symfony: PSR-12
- Vue/Nuxt: `<script setup>`, composables, Pinia
- Always follow the conventions already established in the project
- Function max 25 lines. Component max 150 lines. If exceeded — refactor before committing.

---

## Working in Non-Harness Projects (guest mode)

> Applies ONLY to projects that are NOT harness-adopted (no `HARNESS.md`,
> no `memory/`). In a harness-adopted project the Definition of Done
> wins: documentation is mandatory, not optional — this section does not
> apply there.

- Do not refactor or clean up code outside the scope of the requested change
- Do not install new dependencies without explicit confirmation
- Do not suggest architectural improvements unless asked
- Manual control only: do exactly what was asked, nothing more
- Before any file change: list the files that will be modified and wait for confirmation
- Never modify `composer.json` or `package.json` without explicit confirmation
- Never run migrations or schema changes
- Never touch `.env` or any config with credentials

Guest mode limits WIDTH, not completeness: "do exactly what was asked" means do
not step outside the request, never leave the request half-done. Scope-is-the-
contract above still applies inside those boundaries.

---

## Honesty Over Guessing

If you're unsure about an API — say so. Don't guess and make up syntax.

Ask the user: "Should I check context7 for current docs?"

context7 is available for manual use when the user explicitly asks you to look up a specific framework or library. Not automatic on every framework touch.

### Corrections and trust

- Correct something you said earlier only when the error changes code,
  conclusions, or a decision the user has to make. Fix small slips silently and
  move on.
- No apologising, no self-criticism, no tallying past mistakes. Several
  corrections go in one block, not a numbered list.
- A follow-up question is not by itself evidence you got something wrong.
  Answer what was asked instead of re-auditing a correct answer.
- Do not take another agent's report at face value. "Done" without the actual
  command output is a claim, not proof — the same standard the tickets apply
  with their "how to prove it" field.

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

**Project-specific additions:** if `.agentignore` exists in the project root,
treat every pattern in it exactly like the patterns above — same rule, same
"ask first" requirement. `~/.opencode-harness/scripts/dod.sh` mechanically blocks commits that
touch a path matching `.agentignore` (Step 8) as a backstop, but the primary
defense is: don't read these files in the first place.

---

## Safe to do autonomously

- Creating and editing source files (components, composables, server routes, modules)
- Adding new files to `docs/`
- Updating `PROGRESS.md` and `docs/roadmap.md`
- Reading any project files
- Creating new collections or fields (NOT deleting)
- Adding JSDoc comments to existing files
- Creating, editing and deleting files inside `.harness/scratch/` — that is the
  agent's scratch space, git-ignored and yours to manage. Temporary files belong
  there: not in the project root, where they show up as uncommitted work and the
  DoD gate reports them, and not in `/tmp`, which is outside the project and
  therefore needs confirmation like any other outside path.

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

If the DoD docs-matrix step reports code changed without a docs update — update relevant files before closing.

→ Full session reference: `load skills/documentation/SKILL.md`

---

## Skills — Auto-Loading (trigger → skill map)

**MANDATORY, every incoming user message, before doing anything else:**
scan the message text against every row's Triggers column below. Any
match — even one word, even if the message is "just a quick fix" — means
**calling the `skill` tool with that skill's name** before responding or
touching code. The name is the last segment of the path in the table
below (`security/SKILL.md` → `skill` with name `security`).
This is a deterministic lookup, not something to rely on remembering:
nothing loads a skill on your behalf — the `skill` tool is invoked by you,
like any other tool — so skipping this scan is the single most common way
a model silently drops a required skill. Measured 2026-08-20: five
identical runs of the same refactor prompt loaded the right skill once.
Multiple matches → load all of them. When unsure whether a word counts as
a match, treat it as one — loading an extra skill costs a `Read`, missing
one costs a real defect.

No trigger word appears in two rows — a checker in the harness repo enforces
that before this table ships, because "load all matches" turned a single
ambiguous word into three skill reads, and the more carefully a model
followed the rule the more context it burned. If two matches still happen
(different words, overlapping meaning), the LOWER row wins — rows run from
general to specific.

**Load a skill by calling the `skill` tool with its name** — never by reading
the file. OpenCode registers every skill in `~/.config/opencode/skills/` as
that tool, and its description (including the SKIP rules) is already in your
system prompt under `<available_skills>`; the table below tells you which
name to pick, not where to find a file. `Read ~/.config/opencode/skills/<name>/SKILL.md`
is a fallback for the one case where the tool cannot reach a skill: a
`SKILL.md` with no YAML frontmatter is not registered at all.

**Load the skill before gathering facts, not after.** Reading the code
first and consulting the skill afterwards turns it into a reference for
writing up conclusions you have already reached — the point is to shape
how you investigate.

| Domain | Triggers | Path |
|--------|----------|------|
| Security/Auth | auth, login, token, cookie, permissions, API route, server route, `.env`, secrets, nginx, CORS, CSP, deploy secrets, docker secrets, release credentials, collection permissions, field permissions | security/SKILL.md |
| Codebase Health | clean up, code health, messy, assess, dead code | codebase-health-check/SKILL.md |
| Junior-to-Senior | improve quality, make it better, level up this code | junior-to-senior/SKILL.md |
| Planning | plan, break down, where to start, unclear scope, large task | planning-and-task-breakdown/SKILL.md |
| Specification | spec, requirements, what should this do, new feature no clear scope | spec-driven-development/SKILL.md |
| Implementation | add, implement, create, build a component/page/endpoint, new feature | incremental-implementation/SKILL.md |
| Last 20% | last 20%, polish, finish the remaining, experiential layer, final details | last-20-percent/SKILL.md |
| UI/Frontend | component, page, layout, form, styles, Tailwind, Nuxt UI, Vue | frontend-ui-engineering/SKILL.md + this project's framework skill if one exists (`nuxt/SKILL.md`, `vue/SKILL.md`, `nuxt-ui/SKILL.md` — check this project's own `AGENTS.md` Stack Skills for what it actually uses; not every framework has a dedicated skill yet, frontend-ui-engineering alone still applies) |
| Interface Design | UI design, interface design, accessible UI, animation principles | interface-kit/SKILL.md |
| API/Backend | endpoint, API, route, schema, collection, field | api-and-interface-design/SKILL.md |
| Debugging | not working, error, bug, why, broken, error in logs | debugging-and-error-recovery/SKILL.md |
| Code Review | review, optimize, code review, critique this code | code-review-and-quality/SKILL.md |
| De-Slop | de-slop, anti-slop, polish text, remove AI artifacts, clean up AI writing | fuck-slop/SKILL.md |
| TDD/Tests | write test, cover with tests, TDD, failing test, Playwright, Vitest | test-driven-development/SKILL.md |
| Git | commit, branch, merge, PR, versioning, release | git-workflow-and-versioning/SKILL.md |
| Documentation | document, write docs, onboarding, README, changelog | documentation-and-adrs/SKILL.md |
| Session | new session, pass context, handoff, context limit | handoff/SKILL.md |
| Context Canary | context canary, context rot, context degradation, canary check | context-canary/SKILL.md |
| Token Saving | save tokens, be brief, caveman, token budget | caveman/SKILL.md |
| Brainstorming | idea, brainstorm, not sure what to build, help me think | brainstorming/SKILL.md |
| CI/CD | pipeline, GitHub Actions, deploy, Docker, production | ci-cd-and-automation/SKILL.md |
| Parallel Tasks | multiple independent subtasks, do in parallel | dispatching-parallel-agents/SKILL.md |
| Skill Discovery | new skill installed, discovered | — auto-detect and add to docs/skills-cheatsheet.md |
| Architecture/Code Design | module, seam, depth, module boundary, refactor, improve architecture | codebase-design/SKILL.md, improve-codebase-architecture/SKILL.md |
| Domain Modeling | domain term, glossary, CONTEXT.md, ADR, ubiquitous language, terminology | domain-modeling/SKILL.md, documentation-and-adrs/SKILL.md |
| Research | investigate, research, find docs, gather facts, learn API | research/SKILL.md |
| Merge Conflicts | merge conflict, rebase conflict, git merge, resolve conflict | resolving-merge-conflicts/SKILL.md |
| Wayfinding / Large Planning | huge task, multi-session, roadmap, chartered effort | wayfinder/SKILL.md, planning-and-task-breakdown/SKILL.md |
| Loop Factory | spec-driven loop, agent factory, loop factory, repeatable agent work, markdown specs inbox | loop-factory/SKILL.md |
| TS Deep Modules | barrel files, dependency-cruiser, deep modules, entry points, package boundaries | setup-ts-deep-modules/SKILL.md, codebase-design/SKILL.md |

→ Full reference for when to use which skill: `read ~/.opencode-harness/instructions/reference/03-skills-cheatsheet.md` (harness-wide reference); in a project, `docs/skills-cheatsheet.md` is the project-local list

# === HARNESS-MANAGED END ===
