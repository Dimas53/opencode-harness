# Installation Guide

## Installation

```bash
git clone git@github.com:Dimas53/opencode-harness.git
cd opencode-harness
make setup
```

Then complete manual steps:
1. `opencode auth login`
2. Copy config: `cp global/opencode-config.example.jsonc ~/.config/opencode/opencode.jsonc`
3. Edit the config — replace `/YOUR/HOME/PATH` and `YOUR_DIRECTUS_TOKEN`
4. Run `opencode` — select your model on first launch
5. Run `rtk gain` — verify RTK is working

**Windows without WSL:** run `scripts\install.bat` instead of `make setup`

---

## Starting a New Project

After setup, run:

```bash
make init PROJECT=/path/to/new-project
```

This copies docs templates + AGENTS.md into the project, then opens OpenCode automatically.
When OpenCode opens — type the command shown in the terminal.

The `agent-new-project` skill interviews you (9 questions), analyzes your stack,
and generates all project documentation automatically. One file at a time — confirm each.

---

## Starting an Existing Project

```bash
make init-existing PROJECT=/path/to/existing-project
```

This opens OpenCode in your project. Type the command shown in the terminal.

The `agent-init-existing` skill first runs `agent-analyze` to map the codebase,
then fills knowledge gaps via interview, then generates missing documentation.

> **Note:** `make init`, `make init-existing`, and `make analyze` all open
> interactive TUI (`opencode` without arguments). The one-shot `opencode run`
> cannot handle interactive confirmation, which is why TUI is required.
> For `make analyze` — type the command shown, or manually:
> ```
> Load ~/.config/opencode/skills/harness-init/agent-analyze.md
> ```

---

## Analyzing a Project (without creating docs)

```bash
make analyze PROJECT=/path/to/project
```

Opens OpenCode in the project. Type the command shown in the terminal, or manually:

```
Load ~/.config/opencode/skills/harness-init/agent-analyze.md
```

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
