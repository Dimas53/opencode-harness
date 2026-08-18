# {{PROJECT_NAME}} — Project Rules

> Global rules live in `~/.config/opencode/AGENTS.md` and apply to all projects.
> This file contains {{PROJECT_NAME}}-specific rules only. In case of conflict — this file wins.
> 
> ⚠️ DO NOT replace this file with global/AGENTS.md. This is a PROJECT-SPECIFIC TEMPLATE.
>    It is used by the `new` / `adopt` OpenCode shortcuts to bootstrap new project AGENTS.md files.
>    Edit placeholders ({{...}}), not the structure.

---

## Stack Skills (load on every session start)

After loading `using-agent-skills`, immediately load these stack skills:
```
{{STACK_SKILLS}}
```

---

## Framework Structure (MANDATORY)

{{FRAMEWORK_NOTES}}

---

## Project File Map

| What | Path |
|------|------|
| Source root | `{{SOURCE_ROOT}}` |
| Components | `{{COMPONENTS_PATH}}` |
| Pages / Views | `{{PAGES_PATH}}` |
| Global styles | `{{STYLES_PATH}}` |
| Design reference | `docs/design.md` |
| Progress log | `PROGRESS.md` |
| Roadmap | `docs/roadmap.md` |
| Architecture overview | `docs/ARCHITECTURE.md` |
| Domain glossary | `docs/CONTEXT.md` |
| Skills reference | `docs/skills-cheatsheet.md` |
| Global skills | `~/.config/opencode/skills/` |

---

## Task Context (loaded during the Session Start step that loads skills and task context)

When starting a task, load the relevant doc based on what you are working on:

| Task area | Read before starting |
|-----------|---------------------|
| Any UI / frontend work | `docs/design.md` |
| {{FEATURE_1}} | `docs/architecture/{{FEATURE_1_FILE}}.md` |
| {{FEATURE_2}} | `docs/architecture/{{FEATURE_2_FILE}}.md` |
| Overall architecture or new feature | `docs/ARCHITECTURE.md` |
| Backend / API schema | Read relevant docs before creating anything |

---

## Definition of Done — {{PROJECT_NAME}} Specific

**Runs IN ADDITION to global Definition of Done (global AGENTS.md).
Use the SESSION SCAN output from the global Session scan step as input here.**

### Architecture file mapping — for each item in SESSION SCAN, find its doc:

```
{{ARCHITECTURE_MAPPING}}

New feature with NO matching file above  →  CREATE docs/architecture/feature-name.md
```

# === HARNESS-MANAGED START — do not edit between these markers, `update-project --refresh-agents` overwrites this region. Add your own rules above START or below END; they survive updates. ===

### CONTEXT.md — update if SESSION SCAN includes any of:
```
[ ] New module, service, or composable name introduced
[ ] New technical pattern discovered (e.g. new gotcha, workaround)
[ ] New external service or MCP connected
[ ] New domain concept that future agent would need to know
```

### Hard rules — no exceptions:
```
RULE 1: "I only deployed, I didn't create it" — NOT accepted.
        Deploy = same doc update as create. SESSION SCAN catches it.

RULE 2: "I'll update docs next session" — NOT accepted.
        Docs update happens NOW, in this session, before saying done.

RULE 3: "It's a small change" — only CSS tweaks and typo fixes are exempt.
        Any logic, flow, collection, or route change requires doc update.
```

# === HARNESS-MANAGED END ===

---

# === HARNESS-MANAGED START — do not edit between these markers, `update-project --refresh-agents` overwrites this region. Add your own rules above START or below END; they survive updates. ===

## Git Workflow

### When to commit
- After completing a full Milestone or major feature (new page, new component, new flow)
- Never commit broken or half-done code
- Small fixes (warnings, typos, minor CSS) — make changes, wait for explicit commit instruction

### Commit message format
```
<type>(<scope>): <what was done>
```
Types: `feat`, `fix`, `docs`, `chore`, `refactor`

### After every commit — immediately update PROGRESS.md
```
## Git log
- `<hash>` — commit message
```

### "Commit and push" sequence
When user says "commit and push" (or equivalent) — do NOT execute both at once.
Follow this exact order:
1. Create the commit
2. Run the full Definition of Done (see global AGENTS.md — do not restate the step count here)
3. Only after DoD is verified — run `git push`

# === HARNESS-MANAGED END ===

---

# === HARNESS-MANAGED START — do not edit between these markers, `update-project --refresh-agents` overwrites this region. Add your own rules above START or below END; they survive updates. ===

## Database Migrations (if this project has a database)

Every schema migration MUST have a paired rollback file:
```
migrations/
├── YYYY_MM_DD_description.up.sql    ← apply
└── YYYY_MM_DD_description.down.sql  ← rollback, exact reverse order
```

**Hard rule: no migration PR merges without a `.down.sql` file**, especially
when it includes any `DROP`. The agent writes BOTH files. The developer
reviews DOWN as carefully as UP — a migration without a tested rollback is
not recoverable.

**Example — UP:**
```sql
CREATE TABLE authors (id SERIAL, name VARCHAR);
INSERT INTO authors (name) SELECT DISTINCT author FROM recipes;
ALTER TABLE recipes ADD COLUMN author_id INTEGER;
UPDATE recipes SET author_id = (SELECT id FROM authors WHERE name = recipes.author);
ALTER TABLE recipes DROP COLUMN author;
```

**Example — DOWN (exact reverse order):**
```sql
ALTER TABLE recipes ADD COLUMN author VARCHAR;
UPDATE recipes SET author = (SELECT name FROM authors WHERE id = recipes.author_id);
ALTER TABLE recipes DROP COLUMN author_id;
DROP TABLE authors;
```

# === HARNESS-MANAGED END ===

---

## MCP Servers Available

| MCP | Use for |
|-----|---------|
| `filesystem` | Read/write any project file |
| `git` | Git operations |
| `context7` | Live framework docs — always prefer over training data |
| `fetch` | External HTTP requests |
| `sequential-thinking` | Complex multi-step reasoning |
| `playwright` | E2E tests, explore mode, screenshots |
| `chrome-devtools` | Console errors, network requests, Lighthouse |
{{EXTRA_MCP}}

---

## Framework-Specific Gotchas

{{FRAMEWORK_GOTCHAS}}

---

## UI Rules

- No UI code without reading `docs/design.md` first
- Use only color tokens from `docs/design.md`
- Icons: {{ICON_LIBRARY}}
- TypeScript required in all source files where applicable

---

## Operational Notes

{{OPERATIONAL_NOTES}}

---

# === HARNESS-MANAGED START — do not edit between these markers, `update-project --refresh-agents` overwrites this region. Add your own rules above START or below END; they survive updates. ===

## Docs Update Matrix

| File | Updated by | Trigger |
|------|-----------|---------|
| `PROGRESS.md` | Agent — automatic | Every commit + push |
| `docs/roadmap.md` | Agent — automatic | Phase completed |
| `docs/architecture/*.md` | Agent — automatic | Architecture changed |
| `docs/CONTEXT.md` | Agent — on request | Documentation Session |
| `docs/specs/*.md` | Agent — on request | Before new feature |
| `docs/design.md` | Developer manually | Design decision changed |
| `docs/audits/*.md` | Agent — on request | Audit session |
| `docs/skills-cheatsheet.md` | Agent — automatic | New skill installed |

# === HARNESS-MANAGED END ===
