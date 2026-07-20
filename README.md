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

If you cloned before `make link` existed — run it once to enable shortcuts:

```bash
make link
```

After that, `update-harness` shortcut works from anywhere inside OpenCode.

## After Setup — Start Any Project

### Primary path — shortcuts inside OpenCode

Open OpenCode in any directory and type:
- `new` — new project: interview → full doc structure generated
- `adopt` — existing project: auto-analysis first → fills missing docs
- `analyze` — read-only audit: architecture map + security review + risk report
- `update-harness` — pull latest harness updates and apply globally
- `sync-templates` — check for new template files missing in current project
- `switch-directus` — repoint the Directus MCP URL (manual lever). See [Directus MCP Setup](instructions/directus-mcp-setup.md).

### Fallback — make commands (if OpenCode is not open yet)

```bash
make init PROJECT=/path/to/new-project
make init-adopt PROJECT=/path/to/project  
make analyze PROJECT=/path/to/project
```

Copies templates and opens OpenCode automatically.

### Symlink (required for update-harness and sync-templates)

Run once after cloning to enable the update shortcuts:

```bash
make link
```

This creates `~/.opencode-harness` pointing to your local clone.

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
| `end` / `done` / `Ende` | `make session-end` — docs lag check, PROGRESS.md update, `.session-ended` guard |
| `dod` | `make dod` — 6 checks manually (same as pre-commit) |

### From terminal (optional)

```bash
make start         # context summary + open opencode
make session-end   # close session from terminal
make test-quick    # run 20 bats tests
make verify        # check harness installation
```

## Documentation

- [INSTALL.md](./INSTALL.md) — full installation guide
- [instructions/GUIDE.md](./instructions/GUIDE.md) — how the harness works
- [instructions/reference/](./instructions/reference/) — OpenCode commands, models, RTK workflow
- [instructions/diagrams/](./instructions/diagrams/) — architecture and installation diagrams
