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
- `switch-directus` — repoint the global Directus MCP server to this project's
  Directus URL (see [Directus MCP switching](#switching-the-directus-mcp-instance))

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

## Switching the Directus MCP instance

OpenCode has a single **global** Directus MCP config shared by every project.
When you work on more than one Directus project, the MCP may point at the wrong
instance. This is detected at Session Start: if the MCP instance differs from
the project's expected `DIRECTUS_URL`, the agent stops and warns you.

To repoint the MCP without editing config files by hand, type:

```
switch-directus
```

What happens step by step:

1. The agent reads `DIRECTUS_URL` from the current project's `.env`.
   (Or pass an explicit URL: `switch-directus https://directus.example.com`.)
2. It locates the MCP config (`~/.config/opencode/opencode.jsonc`, then a
   project-level `opencode.jsonc` if present).
3. It shows the change: old URL → new URL in the `directus` mcp-server block.
4. It asks for explicit confirmation before writing — nothing is changed until
   you say yes.
5. On confirmation it rewrites the `directus` server's URL in the config.
6. The MCP reconnects on the next call / session restart. Re-run `start` or
   continue — the agent now sees the correct instance.

> **Note:** the Directus MCP is global. If a second project is open in another
> session, switching here also affects that session. This is intentional and
> only happens on your explicit `switch-directus` command.

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
