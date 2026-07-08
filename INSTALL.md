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
When OpenCode opens — type the command shown in the terminal to run the harness-init interview.

The agent will interview you (9 questions), analyze your stack, and generate all project documentation automatically.

---

## Starting an Existing Project

```bash
make init-existing PROJECT=/path/to/existing-project
```

This opens OpenCode in your project. Type the command shown in the terminal
to run harness-init in existing-project mode.

The agent will read your codebase first, build a hypothesis, and present it for confirmation before generating missing docs.

> **Note:** `make init` and `make init-existing` open interactive TUI (`opencode`
> without arguments). The one-shot command `opencode run` cannot handle
> harness-init's 9 interview questions, which is why TUI is required.

---

## Verify Installation

```bash
opencode --version      # OpenCode installed
rtk --version           # RTK installed
opencode mcp list       # MCP servers connected
ls ~/.config/opencode/skills/ | wc -l   # should show 50+ skills
```
