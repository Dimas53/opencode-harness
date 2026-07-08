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

## Orchestration

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

