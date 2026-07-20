# Installation Guide

## Installation

```bash
git clone git@github.com:Dimas53/opencode-harness.git
cd opencode-harness
make setup
```

Setup chain:

```
git clone → cd opencode-harness
  ↓
make setup → scripts/install.sh
  ├── npm install -g opencode-ai                     # OpenCode CLI
  ├── brew install uv                                 # uv for MCP git+fetch
  ├── brew install rtk → rtk init -g --opencode       # RTK token optimizer
  ├── npm i -g @modelcontextprotocol/server-filesystem
  ├── npm i -g @modelcontextprotocol/server-sequential-thinking
  ├── npm i -g chrome-devtools-mcp
  ├── npm i -g @playwright/mcp
  ├── npx playwright install                           # Browsers
  ├── opencode plugin add superpowers@git+...          # 40+ skills
  ├── cp global/AGENTS.md → ~/.config/opencode/       # Global rules
  ├── cp global/opencode-config.example.jsonc → ...    # MCP config
  └── cp -r global/skills/* → ~/.config/opencode/skills/  # Custom skills
       ↓
Manual steps:
  ├── opencode auth login
  ├── Copy & edit ~/.config/opencode/opencode.jsonc   # MCP servers + plugins
  └── opencode → select model
       ↓
First run: load AGENTS.md → load skills
  → using-agent-skills/SKILL.md (every session)
  → git log, PROGRESS.md, roadmap.md, task context
```

A symlink `~/.opencode-harness` is created pointing to your clone.
This enables the `update-harness` and `sync-templates` shortcuts.

Then complete manual steps:
1. `opencode auth login`
2. Copy config: `cp global/opencode-config.example.jsonc ~/.config/opencode/opencode.jsonc`
3. Edit the config — replace `/YOUR/HOME/PATH` and `YOUR_DIRECTUS_TOKEN`
   (If you don't use Directus — delete the `YOUR_DIRECTUS_TOKEN` line entirely)
4. Run `opencode` — select your model on first launch
5. Run `rtk gain` — verify RTK is working

**Windows without WSL:** run `scripts\install.bat` instead of `make setup`

---

## Starting a New Project

### Primary path
Open OpenCode in any directory and type `new`.
The agent starts the interview immediately — no make command needed.

### Fallback (make command)
After setup, run:

```bash
make init PROJECT=/path/to/new-project
```

This copies docs templates + AGENTS.md into the project, then opens OpenCode
and automatically starts the `agent-new-project` skill.

The skill interviews you (9 questions), analyzes your stack,
and generates all project documentation automatically. One file at a time — confirm each.

---

## Starting an Existing Project

### Primary path
Open OpenCode in the project directory and type `adopt`.

### Fallback (make command)
```bash
make init-adopt PROJECT=/path/to/existing-project
```

This opens OpenCode in your project and automatically starts the `agent-adopt` skill.

The skill first runs `agent-analyze` to map the codebase,
then fills knowledge gaps via interview, then generates missing documentation.

> **Note:** All three commands pass the skill reference via `--prompt` flag,
> so the agent starts working immediately — no manual typing needed.

---

## Analyzing a Project (without creating docs)

### Primary path
Open OpenCode in the project directory and type `analyze`.

### Fallback (make command)
```bash
make analyze PROJECT=/path/to/project
```

Opens OpenCode in the project and automatically starts the `agent-analyze` skill.

The agent runs 4 audits: codebase health, architecture zoom-out, security review,
and premortem — then saves a report to `docs/audits/YYYY-MM-DD-analysis.md`.
No source files are modified.

---

## Keeping the Harness Updated

### Inside OpenCode (from any project)

Type `update-harness` — pulls latest changes and updates global files.
Requires `make link` to have been run once after cloning.

### Via terminal

```bash
cd ~/.opencode-harness && git pull && make update
```

---

## Verify Installation

```bash
opencode --version      # OpenCode installed
rtk --version           # RTK installed
opencode mcp list       # MCP servers connected
ls ~/.config/opencode/skills/ | wc -l   # should show 60+ skills
```

---

## Directus MCP (per project)

Each project gets its own Directus MCP connection, generated from the project's
`.env` into a gitignored `opencode.jsonc`. There is no global `directus` block.

From the project root:

```bash
make mcp      # generate opencode.jsonc from .env (re-run after editing
              # .env or the global OpenCode config)
make start    # same as `make mcp`, then launches OpenCode
```

> Note: launching OpenCode directly (without `make start`) does NOT regenerate
> `opencode.jsonc`. The local file is a snapshot — new common MCPs added to the
> global config, or a changed `MCP_DIRECTUS_TOKEN` in `.env`, are picked up only
> after re-running `make mcp` (or `make start`). Prefer `make start` so the config
> stays current. Full setup: [instructions/directus-mcp-setup.md](instructions/directus-mcp-setup.md).

---

## MCP Security — Restricting Filesystem Access

The filesystem MCP server accepts allowed directories as command-line
arguments — anything outside those paths is rejected at the server level,
not just discouraged by AGENTS.md rules.

Example config in `~/.config/opencode/opencode.jsonc`:

```jsonc
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "/path/to/your/projects/root"
      ]
    }
  }
}
```

Replace the path with your actual projects directory. You can list
multiple allowed directories as additional array entries.
