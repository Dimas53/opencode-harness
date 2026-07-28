# opencode-harness

One command to set up AI-assisted development on any machine.

## Quick Start

```bash
git clone https://github.com/Dimas53/opencode-harness.git
cd opencode-harness
make setup
```

## Installing on macOS

One block from zero to running:

> **Prerequisites:** `git`, `make`, `node 20+` required.
> Missing something? → [INSTALL.md — macOS prerequisites](./INSTALL.md#prerequisites)

```bash
# 1 — Clone the harness
cd ~/Documents
git clone https://github.com/Dimas53/opencode-harness.git
cd opencode-harness

# 2 — Install
make setup
# During setup: RTK telemetry → n, Playwright → y, version warning → y

# 3 — Authorize OpenCode
opencode auth login

# 4 — Edit MCP paths
nano ~/.config/opencode/opencode.jsonc     # replace /YOUR/HOME/PATH

# 5 — Verify
make verify

# 6 — First project
mkdir -p ~/Documents/my-project && cd ~/Documents/my-project
opencode                                    # type `new` inside
```

## Installing on Windows

> **Requires WSL2.** Ubuntu installs alongside Windows as an app — Windows stays untouched.

```powershell
# PowerShell as Administrator
wsl --install
```

After restart — open Ubuntu terminal, then:

```bash
# Install dependencies
sudo apt update && sudo apt install -y make curl
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.bashrc && nvm install 20

# Set git identity
git config --global user.email "you@example.com"
git config --global user.name "Your Name"

# Clone and install
git clone https://github.com/Dimas53/opencode-harness.git
cd opencode-harness && make setup

# Authorize and verify
opencode auth login
make verify
```

> **Tip:** Install [Windows Terminal](https://aka.ms/terminal) from Microsoft Store —
> better copy/paste and Ubuntu + PowerShell in one window as tabs.

Full guide: [INSTALL.md — Installing on Windows](./INSTALL.md#installing-on-windows)

### Update
```bash
cd ~/opencode-harness && make update
```

### Uninstall

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

## After Setup — Start Any Project

Open OpenCode in any directory and type one of these:

### Core (project setup + bug fixes)
- `new` — new project: interview → full doc structure generated
- `adopt` — existing project: auto-analysis first → fills missing docs
- `analyze` — read-only audit: architecture + security + risk report
- `analyze <path>` — focused audit of a specific file or folder
- `fix` — fix findings from the last analysis report (3-phase: CRITICAL → HIGH → MEDIUM)
- `fix <path>` — fix findings only for a specific file or folder
- `fix <ID>` — fix a specific finding by ID (e.g. `fix C1`, `fix H2`)

### Testing & Coverage (write + verify tests automatically)

**Coverage (business logic)**
- `analyze-logic` — find uncovered business logic, generate test cases
- `analyze-logic <path>` — focused scan of a specific directory or file
- `fix-logic` — write tests for all uncovered logic (coverage, no source changes)
- `fix-logic <ID>` — write test for a specific finding (e.g. `fix-logic L1`)

**UI Behavior**
- `analyze-ui` — UI behavior analysis: forms, buttons, navigation, states, auth
- `analyze-ui <path>` — focused UI analysis of a specific file
- `fix-ui` — fix UI findings from the last UI analysis report
- `fix-ui <path>` — fix UI findings for a specific file
- `fix-ui <ID>` — fix a specific UI finding by ID (e.g. `fix-ui U1`)

### Utility
- `update-harness` — pull latest harness updates and apply globally
- `sync-templates` — check for new template files missing in current project
- `dod` — run Definition of Done checks (6 steps)
- `docs` — session end + prompt to update docs if code changed

> Full reference: [Test Workflows](instructions/reference/09-test-workflows.md) — how all testing skills chain together.

Or run `make help` in the harness directory to list all available commands.

## Directus MCP

Configured per project from the project's `.env` (see
[Directus MCP Setup](instructions/directus-mcp-setup.md)). There is no global
Directus MCP config — each project generates its own gitignored `opencode.jsonc`
pointing at that project's Directus instance.

Generate the config (run from the project root):
- `make mcp` — generate `opencode.jsonc` from `.env`. Re-run after editing
- `make start` — same as `make mcp`, then launches OpenCode

## Daily Workflow

### Automatically (no command needed)
- **`git commit`** — pre-commit hook runs `make dod` (6 checks) automatically.

### Trigger words inside OpenCode
| Say this | What happens |
|----------|-------------|
| `Start` | Session Start — 7-step init sequence |
| `end` / `done` / `Ende` | Session End — docs lag check, PROGRESS.md update |
| `dod` | Definition of Done — 6 checks manually |
| `analyze` | Full project audit — architecture, security, risks |
| `analyze <path>` | Focused audit of a specific file or folder |
| `fix` | Fix CRITICAL/HIGH/MEDIUM findings |
| `fix <path>` | Fix findings for a specific path |
| `fix <ID>` | Fix finding by ID (e.g. `fix C1`, `fix H2`) |
| `analyze-logic` | Find uncovered business logic, generate test cases |
| `analyze-logic <path>` | Focused logic scan of a directory or file |
| `fix-logic` | Write tests for all uncovered logic findings |
| `fix-logic <ID>` | Write test for specific finding (e.g. `fix-logic L1`) |
| `analyze-ui` | UI behavior analysis — forms, buttons, nav, auth |
| `analyze-ui <path>` | Focused UI analysis of a specific file |
| `fix-ui` | Fix UI findings from the last UI report |
| `fix-ui <path>` | Fix UI findings for a specific file |
| `fix-ui <ID>` | Fix a specific UI finding by ID (e.g. `fix-ui U1`) |

## Documentation

- [INSTALL.md](./INSTALL.md) — full installation guide
- [instructions/GUIDE.md](./instructions/GUIDE.md) — how the harness works
- [instructions/reference/](./instructions/reference/) — reference docs
- [instructions/diagrams/](./instructions/diagrams/) — architecture diagrams
