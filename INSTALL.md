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
  → git log, progress.md, roadmap.md, task context
```

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

```bash
make init-existing PROJECT=/path/to/existing-project
```

This opens OpenCode in your project and automatically starts the `agent-init-existing` skill.

The skill first runs `agent-analyze` to map the codebase,
then fills knowledge gaps via interview, then generates missing documentation.

> **Note:** All three commands pass the skill reference via `--prompt` flag,
> so the agent starts working immediately — no manual typing needed.

---

## Analyzing a Project (without creating docs)

```bash
make analyze PROJECT=/path/to/project
```

Opens OpenCode in the project and automatically starts the `agent-analyze` skill.

The agent runs 4 audits: codebase health, architecture zoom-out, security review,
and premortem — then saves a report to `docs/audits/YYYY-MM-DD-analysis.md`.
No source files are modified.

---

## Verify Installation

```bash
opencode --version      # OpenCode installed
rtk --version           # RTK installed
opencode mcp list       # MCP servers connected
ls ~/.config/opencode/skills/ | wc -l   # should show 50+ skills
```

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
