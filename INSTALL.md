# Installation Guide

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

Pick a provider (Anthropic, OpenRouter) and enter your API key.

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

Windows requires **WSL2** (Windows Subsystem for Linux). Your Windows system stays completely untouched — WSL2 installs Ubuntu as an app alongside Windows. You get a separate Ubuntu terminal that you open when needed; everything else on your machine stays as-is.

### Prerequisites (one-time for clean machines)

Run in PowerShell as Administrator:

```powershell
wsl --install
```

Restart your computer. After restart, Ubuntu opens automatically — create a username and password.

Then inside the Ubuntu terminal:

```bash
# Step 1 — Install make and Node.js
sudo apt update && sudo apt install -y make curl

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc
nvm install 20
```

Verify: `make --version && node --version && npm --version`

### Steps

**Step 2 — Clone**
```bash
cd ~
git clone https://github.com/Dimas53/opencode-harness.git
cd opencode-harness
```

**Step 3 — Install**
```bash
make setup
```

During setup:
- RTK telemetry → `n`
- Playwright → `y`
- Version warning → `y`

**Step 4 — Authorize**
```bash
opencode auth login
```

Pick a provider (Anthropic, OpenRouter) and enter your API key.

**Step 5 — Edit config**
```bash
nano ~/.config/opencode/opencode.jsonc
```

Replace `/YOUR/HOME/PATH` with `/home/your-username`. If no Directus — delete the `YOUR_DIRECTUS_TOKEN` line.

**Step 6 — Verify**
```bash
make verify
ls ~/.config/opencode/skills/ | wc -l   # 70
```

**Step 7 — First run**
```bash
mkdir ~/my-project && cd ~/my-project
opencode
```

Inside OpenCode, type `new` to start project setup.

### Updating

```bash
cd ~/opencode-harness
make update
```

### What differs from macOS

| | macOS | WSL2 |
|---|---|---|
| opencode | npm | npm |
| uv | brew | curl installer |
| RTK | brew | curl installer |
| make verify | 8/8 | 8/8 |

---

## Uninstalling

Run `make uninstall` in the harness directory, or follow the steps below.

To remove the harness from your machine (without removing OpenCode or RTK):

**Step 1 — Remove harness files**
```bash
rm ~/.opencode-harness                          # symlink
rm -rf ~/.config/opencode/skills                # skills
rm ~/.config/opencode/AGENTS.md                 # global rules
```

> `~/.config/opencode/opencode.jsonc` is not deleted automatically — it may contain
> Directus tokens for your projects. Delete it manually if needed.

**Step 2 — Remove the repo** (optional)
```bash
rm -rf ~/Documents/opencode-harness
```

**Step 3 — Remove OpenCode CLI** (optional)
```bash
npm uninstall -g opencode-ai
```

**Step 4 — Remove RTK** (optional)
```bash
brew uninstall rtk
```

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
