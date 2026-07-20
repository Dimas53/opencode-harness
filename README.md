# opencode-harness

One command to set up AI-assisted development on any machine.

**OpenCode version:** v1.17.20 (tested)

See [INSTALL.md](./INSTALL.md) for full installation guide.

## Quick Start

```bash
git clone git@github.com:Dimas53/opencode-harness.git
cd opencode-harness
make setup
```

## Already Installed? Update to Latest

Already have the harness? Just pull and update:

```bash
cd ~/path/to/opencode-harness
git pull
make update
```

## After Setup — Start Any Project

Open OpenCode in any directory and type one of these (the only commands you need
day to day — everything else lives in [INSTALL.md](./INSTALL.md) /
[instructions/GUIDE.md](./instructions/GUIDE.md)):
- `new` — new project: interview → full doc structure generated
- `adopt` — existing project: auto-analysis first → fills missing docs
- `analyze` — read-only audit: architecture map + security review + risk report
- `update-harness` — pull latest harness updates and apply globally
- `sync-templates` — check for new template files missing in current project
- `switch-directus` — repoint the Directus MCP URL (manual lever). See [Directus MCP Setup](instructions/directus-mcp-setup.md).

## Directus MCP

One global Directus MCP server, one shared `mcp` user token. The project URL is
taken from `.env` and auto-corrected on Session Start. `switch-directus` is a
manual lever that updates only the URL. Full setup:
[instructions/directus-mcp-setup.md](instructions/directus-mcp-setup.md).

## Daily Workflow

### Automatically (no command needed)

- **`git commit`** — pre-commit hook runs `make dod` (6 checks) automatically.
  If any check fails, the commit is blocked.

### Trigger words inside OpenCode

| Say this | What happens |
|----------|-------------|
| `Start` | Session Start — 7-step init sequence |
| `end` / `done` / `Ende` | Session End — docs lag check, PROGRESS.md update |
| `dod` | Definition of Done — 6 checks manually (same as pre-commit) |

## Documentation

- [INSTALL.md](./INSTALL.md) — full installation guide
- [instructions/GUIDE.md](./instructions/GUIDE.md) — how the harness works
- [instructions/reference/](./instructions/reference/) — OpenCode commands, models, RTK workflow
- [instructions/diagrams/](./instructions/diagrams/) — architecture and installation diagrams
