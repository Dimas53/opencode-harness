# Installation Guide

## Table of Contents

- [Installation](#installation)
- [Installing on macOS](#installing-on-macos)
- [Installing on Windows](#installing-on-windows)
- [Uninstalling](#uninstalling)
- [Starting a New Project](#starting-a-new-project)
- [Starting an Existing Project](#starting-an-existing-project)
- [Analyzing a Project (without creating docs)](#analyzing-a-project-without-creating-docs)
- [Keeping the Harness Updated](#keeping-the-harness-updated)
- [Verify Installation](#verify-installation)
- [Directus MCP (per project)](#directus-mcp-per-project)
- [MCP Security — Restricting Filesystem Access](#mcp-security--restricting-filesystem-access)

---

## Installation

```bash
git clone git@github.com:Dimas53/opencode-harness.git
cd opencode-harness
make setup
```

A symlink `~/.opencode-harness` is created pointing to your clone.
This enables the `update-harness` and `sync-templates` shortcuts.

### What `make setup` installs

| Package | Purpose |
|---------|---------|
| `opencode-ai` (npm) | OpenCode CLI — AI coding assistant |
| `uv` (brew) | Fast Python package manager — runs git + fetch MCP servers |
| `rtk` (brew) | Token optimizer — compresses terminal output (~80% savings) |
| `@modelcontextprotocol/server-filesystem` (npm) | MCP: read/write project files |
| `@modelcontextprotocol/server-sequential-thinking` (npm) | MCP: structured reasoning |
| `chrome-devtools-mcp` (npm) | MCP: browser DevTools control |
| `@playwright/mcp` (npm) | MCP: browser automation |
| Playwright browsers (npx) | Chromium ~300MB for browser testing |
| `~/.config/opencode/AGENTS.md` | Global agent rules (safety, process, language) |
| `~/.config/opencode/opencode.jsonc` | MCP server config — edit paths + Directus token |
| `~/.config/opencode/skills/` (70 skills) | Reusable agent skills for debugging, security, UI, etc. |
| `~/.opencode-harness` symlink | Enables `update-harness` and `sync-templates` shortcuts |

### What `make setup` does NOT do (manual)

- `opencode auth login` — authorize AI provider (API key)
- Select a model on first `opencode` launch

Then complete manual steps:
1. `opencode auth login`
2. Check `~/.config/opencode/opencode.jsonc` — created automatically.
   Edit if needed: replace `/YOUR/HOME/PATH` with your actual home path.
   If you don't use Directus — delete the `YOUR_DIRECTUS_TOKEN` line entirely.
3. Run `opencode` — select your model on first launch

**Windows:** see [Installing on Windows](#installing-on-windows) below

---

## Installing on macOS

> If you already have Xcode CLI Tools, Homebrew, and Node.js — skip to step 3.

### Prerequisites (one-time for clean machines)

Run these if your machine doesn't have them yet:

```bash
# Step 0 — Xcode CLI Tools (git + make)
xcode-select --install

# Step 1 — Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Step 2 — Node.js 20
brew install node@20
```

Verify: `git --version && make --version && node --version && npm --version`

### Steps

**Step 3 — Clone**
```bash
cd ~/Documents
git clone https://github.com/Dimas53/opencode-harness.git
cd opencode-harness
```

**Step 4 — Install**
```bash
make setup
```

During setup:
- RTK telemetry → `n`
- Playwright → `y`
- Version warning → `y`

**Step 5 — Authorize**
```bash
opencode auth login
```

You need an API key. Register at [opencode.ai](https://opencode.ai) — the
built-in model is free for basic use. Or use any provider (Anthropic, OpenRouter)
with your own key.

**Step 6 — Edit config**
```bash
nano ~/.config/opencode/opencode.jsonc
```

Replace `/YOUR/HOME/PATH` with `/Users/your-username`. If no Directus — delete the `YOUR_DIRECTUS_TOKEN` line.

**Step 7 — Verify**
```bash
make verify
ls ~/.config/opencode/skills/ | wc -l   # 70
```

**Step 8 — First run**
```bash
mkdir ~/Documents/test-project && cd ~/Documents/test-project
opencode
```

Inside OpenCode, type `new` to start project setup.

### Updating

```bash
cd ~/Documents/opencode-harness
make update
```

`make update` runs `git pull` then copies skills to `~/.config/opencode/skills/`.

---

## Installing on Windows

WSL2 installs Ubuntu as an app alongside Windows — your Windows system stays
completely untouched. You get a separate Ubuntu terminal that you open when
needed; everything else on your machine stays as-is.

### Prerequisites (one-time for clean machines)

**Step 0 — Install WSL2 with Ubuntu**

In PowerShell as Administrator:

```powershell
wsl --install
```

Restart your computer. After restart, Ubuntu opens automatically — create a
username and password.

**Step 1 — Inside Ubuntu terminal: install make and Node.js**

```bash
sudo apt update && sudo apt install -y make curl
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc && nvm install 20
```

Verify: `make --version && node --version && npm --version`

**Step 2 — Set git identity**

```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```

### Steps

**Step 3 — Clone**

```bash
git clone https://github.com/Dimas53/opencode-harness.git
cd opencode-harness
```

**Step 4 — Install**

```bash
make setup
```

During setup: RTK telemetry → `n`, Playwright → `y`, version warning → `y`

**Step 5 — Authorize**

```bash
opencode auth login
```

You need an API key. Register at [opencode.ai](https://opencode.ai) — the
built-in model is free for basic use. Or use any provider (Anthropic, OpenRouter)
with your own key.

**Step 6 — Edit config**

```bash
nano ~/.config/opencode/opencode.jsonc
```

Replace `/YOUR/HOME/PATH` with `/home/your-username`.
If no Directus — delete the `YOUR_DIRECTUS_TOKEN` line.

**Step 7 — Verify**

```bash
make verify
ls ~/.config/opencode/skills/ | wc -l   # 70
```

**Step 8 — First run**

```bash
mkdir ~/my-project && cd ~/my-project
opencode
```

Inside OpenCode, type `new` to start project setup.

### Daily workflow

Every time you work with the harness — open Ubuntu terminal (or the Ubuntu
tab in Windows Terminal). Everything works exactly like on macOS: type `new`,
`start`, `analyze` inside any OpenCode session.

### Accessing your Windows files

Your existing Windows projects are accessible directly from Ubuntu:

```bash
# Drive C:
cd /mnt/c/Users/YourName/Documents/my-project

# Drive D:
cd /mnt/d/server/my-project
```

No need to move projects into Ubuntu.
Tip: bookmark the Ubuntu home folder in Windows Explorer:
`\\wsl$\Ubuntu\home\your-username`

### Tips

**Paste in terminal:** right mouse click, or enable Ctrl+Shift+V in terminal
settings (right-click title bar → Properties → Options).

**Windows Terminal** (recommended): install free from Microsoft Store.
Gives you PowerShell and Ubuntu as tabs in one window. Recommended over
the default WSL terminal — better copy/paste, tabs, themes.

### Uninstalling

**Full removal** (harness + OpenCode + RTK):
```bash
cd ~/opencode-harness && make uninstall
cd .. && rm -rf opencode-harness
```

**Harness only** (keep OpenCode and RTK):
```bash
cd ~/opencode-harness && make uninstall-lite
cd .. && rm -rf opencode-harness
```

### What differs from macOS

| | macOS | WSL2 |
|---|---|---|
| opencode | npm | npm |
| uv | brew | curl installer |
| RTK | brew | curl installer |
| Projects location | ~/Documents/ | ~/ or /mnt/c/ /mnt/d/ |
| Terminal | any | Ubuntu tab in Windows Terminal |
| make verify | 8/8 | 8/8 |

---

## Uninstalling

### Full removal (harness + OpenCode + RTK)

```bash
cd ~/opencode-harness && make uninstall
cd .. && rm -rf opencode-harness
```

### Harness only (keep OpenCode and RTK)

```bash
cd ~/opencode-harness && make uninstall-lite
cd .. && rm -rf opencode-harness
```

---

## Starting a Project

Open OpenCode in any directory and type a shortcut:

### Project setup
- `new` — new project: interview → full doc structure generated
- `adopt` — existing project: auto-analysis first → fills missing docs

### Audit & fix (bugs, security, architecture)
- `analyze` — full project audit (6 analyses)
- `analyze <path>` — focused audit of a specific file or folder
- `fix` — fix findings from the last report (3-phase)
- `fix <path>` — fix findings for a specific path
- `fix <ID>` — fix a specific finding by ID (e.g. `fix C1`)

### Testing & coverage
- `analyze-logic` — find uncovered business logic, generate test cases
- `fix-logic` — write tests for all uncovered logic findings
- `analyze-ui` — UI behavior analysis: forms, buttons, nav, auth
- `fix-ui` — fix UI findings from the last UI analysis report

See full reference: [Test Workflows](instructions/reference/09-test-workflows.md)

### Utility
- `update-harness` / `sync-templates` / `dod` / `docs`

> **Fallback** (if shortcuts don't trigger):
> ```bash
> cd ~/opencode-harness
> make init PROJECT=$(pwd)       # new project
> make init-adopt PROJECT=$(pwd) # existing project
> make analyze PROJECT=$(pwd)    # audit only
> ```
> These open OpenCode with the skill pre-loaded.

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
ls ~/.config/opencode/skills/ | wc -l   # should show 70 skills
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
