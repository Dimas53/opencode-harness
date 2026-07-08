# harness-init

## Purpose
Initialize a new or existing project with the full harness structure.
Conduct an interview, perform gap analysis, generate all documentation.
This skill orchestrates other skills — do not write logic from scratch.

## When to use
- User runs `make init PROJECT=/path` on a new project
- User runs `make init-existing PROJECT=/path` on an existing project
- User says "init harness", "set up this project", "initialize docs"

## Other skills to load before starting
```
~/.config/opencode/skills/interview-me/SKILL.md
~/.config/opencode/skills/grill-with-docs/SKILL.md
~/.config/opencode/skills/spec-driven-development/SKILL.md
~/.config/opencode/skills/planning-and-task-breakdown/SKILL.md
```

## Skill Stack for This Scenario

Before starting, check docs/skill-stacks.md (if it exists in this repo)
for the exact skill order for "new-project" or "existing-project" scenario.
If skill-stacks.md doesn't exist yet, use the default order in this file.

## How to Use Template Files

Before generating any documentation file:

1. Read the matching file from `templates/docs/[FILENAME]`
   (path relative to the harness repo root, not the project being initialized)
2. The file contains a `<!-- EXAMPLE: ... -->` comment at the top —
   read it carefully, it explains what to keep and what to replace
3. Use the file's STRUCTURE (sections, tables, format) as the template
4. Replace ALL content with project-specific information from the interview
5. Never copy ItoCook-specific terms, file paths, or domain concepts
6. The comment header must be REMOVED from the generated file —
   it's an instruction for the agent, not for the project

---

## DETECT MODE FIRST

Before doing anything — detect which mode applies:

**NEW PROJECT mode** — if the current directory has:
- No `src/`, `app/`, `pages/`, `components/` folders
- No `package.json` or `composer.json`
- No git history (or only 1 commit)

**EXISTING PROJECT mode** — if the current directory has:
- Source code files
- `package.json` / `composer.json`
- Git history with multiple commits

Tell the user which mode was detected and ask for confirmation before proceeding.

---

## NEW PROJECT MODE

### Phase 0 — Self-diagnostic (run silently, before asking user anything)

Check what is available on this machine:
```bash
ls ~/.config/opencode/skills/
cat ~/.config/opencode/config.json
```

Build a mental list of:
- Available skills (grouped: custom / superpowers / stack-specific)
- Connected MCP servers
- Any existing code in current directory

Do NOT show this to the user yet — use it in Phase 2 gap analysis.

### Phase 1 — Interview (use interview-me skill)

Ask these questions ONE AT A TIME. Wait for answer before next question.
Do NOT ask all at once.

```
Q0: On what language should I respond during this project's sessions?
    (I will use this language for all conversation going forward,
    unless you switch languages yourself.)

Q1: What is the project name and what does it do? (2-3 sentences)

Q2: What is the tech stack?
    (frontend framework, backend, database, deployment)

Q3: How many developers will work on this?
    (solo / small team / larger team)

Q4: What stage is this?
    (MVP — move fast, or production-critical — strict gates from day one)

Q5: What external integrations will you need?
    (APIs, payment systems, auth providers, databases, CMS)

Q6: Will this handle sensitive data?
    (user accounts, payments, medical, legal — affects security priority)

Q7: Where will this be deployed?
    (VPS, cloud provider, local only, not sure yet)

Q8: Do you need a design system?
    (colors, typography, component library, icon set)
    If yes — we will create docs/design.md during setup.

Q9: Do you want to create a project plan now?
    (phases, milestones, initial roadmap)
    If yes — we will generate docs/roadmap.md with real phases based on your answers.
```

After all 10 answers — summarize what you understood and ask:
> "Here's what I understood: [summary]. Is this correct before I generate docs?"

Wait for confirmation. If user corrects something — update your understanding.

### Phase 2 — Gap Analysis (run after interview, before generating docs)

Based on interview answers, check available skills vs project needs:

```
Project uses Vue/Nuxt     → need: nuxt, vue, nuxt-ui, tailwind skills
Project uses React        → need: react skill — check if installed
Project uses PHP/Symfony  → need: symfony/php skill — check if installed
Project uses Python       → need: python/fastapi skill — check if installed
Project uses Stripe       → need: payments skill — check if installed
Project needs auth        → security skill should be loaded
Project has CI/CD         → ci-cd skill should be available
```

For each gap found — present options:
```
"I don't have a [framework] skill installed.
Options:
a) Search for one to install now
b) Continue without it — I'll use general knowledge
c) You install it manually later"
```

Wait for user choice before continuing.

Also check MCP servers vs project needs:
```
Project uses Directus   → directus MCP should be connected
Project uses databases  → relevant MCP helpful
Project needs browser testing → playwright MCP should be connected
```

Report gaps and continue only after user confirms.

### Phase 3 — Generate Documentation (delegate, don't write directly)

harness-init does NOT generate doc content itself. It orchestrates:

For each file, before generating:
1. Read the matching example from templates/docs/examples/[FILENAME]
   (if it exists) as a structural reference
2. Load the relevant sub-skill:
   - AGENTS.md, ARCHITECTURE.md, roadmap.md, CONTEXT.md, skills-cheatsheet.md
     → load ~/.config/opencode/skills/doc-generator/SKILL.md
   - design.md → load ~/.config/opencode/skills/design-init/SKILL.md
   - specs/phase-1.md → load ~/.config/opencode/skills/spec-writer/SKILL.md
3. Pass interview answers + example file content to that skill
4. Show the draft, wait for "ok", move to next file

If a sub-skill is not yet installed — fall back to generating inline
using the example as reference, and note to the user that installing
the sub-skill would improve future runs.

### Phase 4 — Finalize

After all files are confirmed:

```bash
git add .
git commit -m "chore: initialize harness docs for [project name]"
```

Then output:
```
✓ Harness initialized for [project name].

Created:
- AGENTS.md (project-specific rules)
- docs/ARCHITECTURE.md
- docs/roadmap.md (with real phases if Q9 answered YES)
- docs/CONTEXT.md
- docs/design.md (if Q8 answered YES)
- docs/skills-cheatsheet.md
- docs/specs/phase-1.md (if Q9 answered YES)

Stack skills to load on every session:
[list based on tech stack]

MCP servers configured:
[list connected servers]

Start your first session with: Start
```

Remind the user:
> "Next time you open this project, start with 'Start' — I'll read
> progress.md and git log automatically before doing anything else."

---

## EXISTING PROJECT MODE

### Phase 0 — Autonomous research (run silently, no questions yet)

Read as much as possible without asking:
```bash
cat package.json 2>/dev/null || cat composer.json 2>/dev/null
git log --oneline -2
ls -la
find . -name "*.vue" -o -name "*.tsx" -o -name "*.php" | head -20
cat .env.example 2>/dev/null
ls docs/ 2>/dev/null
```

Build a hypothesis about:
- Tech stack (from package.json dependencies)
- Architecture pattern (from folder structure)
- What was recently worked on (from git log)
- External integrations (from .env.example)
- Existing documentation quality (from docs/ if present)

### Phase 1 — Present hypothesis (do NOT ask open questions)

Show what you found:
```
"Here's what I understand about this project:

Stack: [detected stack]
Pattern: [detected architecture]
Recent work: [from git log]
Integrations: [from .env.example]
Docs: [exists/missing/outdated]

Is this correct? What did I miss or misunderstand?"
```

Wait for corrections. Ask follow-up questions ONLY about what you couldn't determine.

### Phase 2 — Gap Analysis (same as new project mode)

Check skills vs detected stack.
Check MCP servers vs project integrations.
Report gaps, get user confirmation.

### Phase 3 — Generate or Update Documentation

If docs/ already exists:
- Do NOT overwrite existing files
- Show what you would ADD or UPDATE
- Ask for confirmation before each change

If docs/ is missing:
- Follow same Phase 3 as new project mode

### Phase 4 — Finalize (same as new project mode)

---

## Hard Rules

```
RULE 1: Never generate all files at once without showing drafts.
        One file → show draft → wait for ok → next file.

RULE 2: Never skip the interview in NEW PROJECT mode.
        Even if user seems impatient — all 10 questions must be answered.

RULE 3: Never skip gap analysis.
        Undiscovered skill gaps cause problems in future sessions.

RULE 4: In EXISTING PROJECT mode — never ask what you can detect yourself.
        Read code first, present findings, ask only about gaps.

RULE 5: The project AGENTS.md generated here must NOT contain global rules.
        Global rules live in ~/.config/opencode/AGENTS.md automatically.

RULE 6: After generating docs — always commit before finishing.
        Uncommitted harness is not a harness.
```
