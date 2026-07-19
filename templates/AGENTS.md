# [Project Name] — Project Rules

> Global rules live in `~/.config/opencode/AGENTS.md` and apply to all projects.
> This file contains [Project Name]-specific rules only. In case of conflict — this file wins.

---

## Stack Skills (load on every session start)

After loading `using-agent-skills`, immediately load these stack skills:
```
# Add paths to relevant stack skills based on project tech stack
# Example:
# ~/.config/opencode/skills/nuxt/SKILL.md
# ~/.config/opencode/skills/vue/SKILL.md
```

---

## [Framework/Stack] Structure (MANDATORY)

- This project uses **[Framework + version]**
- [Key structural rule — e.g. folder layout, naming convention]
- [Second rule if needed]
- If unsure — check context7 first, not training data

---

## Project File Map

| What | Path |
|------|------|
| Pages / Views | `[path]` |
| Components | `[path]` |
| Composables / Services | `[path]` |
| Global styles | `[path]` |
| Design reference | `docs/design.md` |
| Progress log | `PROGRESS.md` |
| Roadmap | `docs/roadmap.md` |
| Architecture overview | `docs/ARCHITECTURE.md` |
| Domain glossary | `docs/CONTEXT.md` |
| Skills reference | `docs/skills-cheatsheet.md` |
| Global skills | `~/.config/opencode/skills/` |

---

## Task Context (used in Session Start Step 7)

When starting a task, load the relevant doc based on what you are working on:

| Task area | Read before starting |
|-----------|---------------------|
| Any UI / frontend work | `docs/design.md` |
| [Feature area 1] | `docs/architecture/[feature-1].md` |
| [Feature area 2] | `docs/architecture/[feature-2].md` |
| Overall architecture or new feature | `docs/ARCHITECTURE.md` |
| Backend / API schema | [Run relevant MCP tool before creating anything] |

---

## Definition of Done — [Project Name] Specific

**Runs IN ADDITION to global Definition of Done (global AGENTS.md).**

### Architecture file mapping — for each changed area, find its doc:

```
[Feature / domain area 1]  →  docs/architecture/[file-1].md

[Feature / domain area 2]  →  docs/architecture/[file-2].md

New feature with NO matching file above  →  CREATE docs/architecture/feature-name.md
```

### CONTEXT.md — update if session includes any of:
```
[ ] New collection, service, or composable name introduced
[ ] New technical pattern or gotcha discovered
[ ] New external service or MCP connected
[ ] New domain concept future agent needs to know
```

### Hard rules — no exceptions:
```
RULE 1: "I only deployed, I didn't create it" — NOT accepted.
        Deploy = same doc update as create.

RULE 2: "I'll update docs next session" — NOT accepted.
        Docs update happens NOW, before saying done.

RULE 3: "It's a small change" — only CSS tweaks and typo fixes are exempt.
        Any logic, API, collection, or route change requires doc update.
```

---

## Git Workflow

### When to commit
- After completing a full Milestone or major feature
- Never commit broken or half-done code
- Small fixes (warnings, typos, minor CSS) — wait for explicit commit instruction

### Commit message format
```
<type>(<scope>): <what was done>
```
Types: `feat`, `fix`, `docs`, `chore`, `refactor`

### "Commit and push" sequence
When user says "commit and push" — do NOT execute both at once:
1. Create the commit
2. Run full Definition of Done
3. Only after DoD verified — run `git push`

---

## MCP Servers Available

| MCP | Use for |
|-----|---------|
| `filesystem` | Read/write any project file |
| `git` | Git operations |
| `context7` | Live framework docs — use when user asks to check docs |
| `fetch` | External HTTP requests |
| `sequential-thinking` | Complex multi-step reasoning |
| [Add project-specific MCPs] | [Purpose] |

---

## [Backend / API] Rules

- [Key rule about backend — e.g. always check schema before creating collections]
- [Permission/access rule]
- [Any project-specific gotcha]

---

## [Framework] Gotchas

<!-- Add known pitfalls discovered during development -->
<!-- Example format:
1. **[Short title]**
   [What goes wrong and why]
   Fix: [solution]
-->

---

## UI Rules

- No UI code without reading `docs/design.md` first
- Use only color tokens from `docs/design.md`
- [Icon library rule if applicable]
- TypeScript required: all component files must have typed scripts

---

## Docs Update Matrix

| File | Updated by | Trigger |
|------|-----------|---------|
| `PROGRESS.md` | Agent — automatic | Every commit + push |
| `docs/roadmap.md` | Agent — automatic | Phase completed |
| `docs/architecture/*.md` | Agent — automatic | Architecture changed |
| `docs/CONTEXT.md` | Agent — on request | Documentation session |
| `docs/specs/*.md` | Agent — on request | Before new feature |
| `docs/design.md` | Developer manually | Design decision changed |