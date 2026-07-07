# Installation Guide

## Scenario 1 — Fresh machine (nothing installed)

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

## Scenario 2 — OpenCode already installed (add harness to existing setup)

```bash
git clone git@github.com:Dimas53/opencode-harness.git
cd opencode-harness
make setup-lite
```

`setup-lite` only copies global files (AGENTS.md, skills, config) — does not reinstall OpenCode or MCP servers.

Then complete manual steps 2-5 from Scenario 1.

---

## Scenario 3 — Already have OpenCode + skills installed (docs only)

```bash
git clone git@github.com:Dimas53/opencode-harness.git
cd opencode-harness
make docs-only PROJECT=/path/to/your/project
```

This copies doc templates only. No installs.

---

## Starting a New Project

After setup, go to your project folder and run opencode:

```bash
cd /path/to/your/project
opencode
```

Then type exactly this:

```
Start
```

Wait for session brief. Then type:

```
Load ~/.config/opencode/skills/harness-init/SKILL.md and run it.
```

The agent will interview you (9 questions), analyze your stack, and generate all project documentation automatically.

---

## Starting an Existing Project

```bash
cd /path/to/existing/project
opencode
```

Type:

```
Start
```

Then:

```
Load ~/.config/opencode/skills/harness-init/SKILL.md and run it in existing-project mode.
```

The agent will read your codebase first, present a hypothesis, and ask only what it couldn't determine from code.

---

## Verify Installation

```bash
opencode --version      # OpenCode installed
rtk --version           # RTK installed
opencode mcp list       # MCP servers connected
ls ~/.config/opencode/skills/ | wc -l   # should show 50+ skills
```
