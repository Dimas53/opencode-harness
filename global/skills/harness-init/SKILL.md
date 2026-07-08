# harness-init

## Purpose
Detect the project scenario and delegate to the correct agent-skill.
Does NOT run interviews or generate files itself — each agent-skill
has its own workflow and skill stack.

## When to use
- User runs `make init PROJECT=/path` on a new project
- User runs `make init-existing PROJECT=/path` on an existing project
- User runs `make analyze PROJECT=/path` to audit without modifying files
- User says "init harness", "set up this project", "initialize docs", "analyze", "audit"

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

## Orchestration

> Full scenario reference: see instructions/reference/04-skill-stacks.md

harness-init detects the scenario and hands off to the right agent-skill.
It does NOT run interviews or generate docs itself.

### Detection logic

**NEW PROJECT** — current directory has:
- No source files (no .vue, .tsx, .php, .py)
- No package.json or composer.json
- No git history (or only 1 commit)
→ Load ~/.config/opencode/skills/harness-init/agent-new-project.md

**ANALYZE ONLY** — user says "analyze", "just look", "audit",
"what is this project", or runs `make analyze`
→ Load ~/.config/opencode/skills/harness-init/agent-analyze.md

**EXISTING PROJECT** — current directory has source code AND user wants docs
→ Load ~/.config/opencode/skills/harness-init/agent-init-existing.md

### How to detect user intent

After mode detection, confirm with user:
"I detected [mode]. Is that correct, or did you want [other option]?"

Wait for confirmation before loading the agent-skill.

### Hard rules

- harness-init never runs interviews itself — delegates to agent-skills
- harness-init never generates files itself — delegates to agent-skills
- make init → always delegate to agent-new-project
- make init-existing → always delegate to agent-init-existing
- make analyze → always delegate to agent-analyze
- Never mix scenarios — if unsure, ask user which they want

