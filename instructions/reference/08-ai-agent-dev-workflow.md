# AI Agent Dev Workflow (2026)

## 0. System Model

```text
IDE (JetBrains)
    +
Terminal Agent (OpenCode)
    ↓
RTK (context optimization)
    ↓
LLM (Google / OpenAI / Anthropic)
    ↓
MCP (tools)
    ↓
Project Layer (AGENTS.md + rules + skills)
    ↓
Codebase
```

---

## 1. System Layers

### GLOBAL (machine-level)
- OpenCode config (`~/.config/opencode/opencode.jsonc`)
- MCP servers (filesystem, git, fetch, context7, sequential-thinking)
- Global rules (`~/.config/opencode/AGENTS.md`)
- Global skills (`~/.config/opencode/skills/`)
- RTK (token optimization)

### PROJECT (repository)
- `AGENTS.md` — project map (architecture, commands, restrictions)
- `.opencode/skills/` — project-specific skills

### SESSION (current task)
- agent plan → diff → file changes → commit

---

## 2. Installation Order

### Step 1 — OpenCode

```bash
npm install -g opencode-ai
opencode --version   # verify
```

Providers are configured via TUI on first launch (`opencode`).
Supported: Google (Gemini), OpenAI, GitHub Copilot, Anthropic and others.

**Recommended models by task:**

| Task | Model |
|---|---|
| Routine, small fixes | Gemini 2.5 Flash |
| Architecture, complex refactoring | Claude Sonnet |
| Complex reasoning, algorithms | DeepSeek R1 |
| Image-related tasks | Gemini 2.5 Flash |

👉 Do not use expensive models for routine tasks — this is the main source of token waste.

---

### Step 2 — RTK (token optimization)

```bash
brew install rtk-ai/tap/rtk       # install (use this specific tap, not plain brew install rtk)
rtk init -g --opencode             # initialize for OpenCode
rtk --version                      # verify: rtk x.y.z
rtk gain                           # savings statistics
```

RTK intercepts command output and compresses it before sending to the LLM.
Savings: git status -80%, npm test -90%, ls/tree -80%.

**Note:** the `No hook installed` warning is for Claude Code, not OpenCode. Ignore it.

---

### Step 3 — MCP Servers

Config: `~/.config/opencode/opencode.jsonc`

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "filesystem": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-filesystem", "/YOUR/HOME/PATH"]
    },
    "git": {
      "type": "local",
      "command": ["uvx", "mcp-server-git"]
    },
    "fetch": {
      "type": "local",
      "command": ["uvx", "mcp-server-fetch"]
    },
    "context7": {
      "type": "remote",
      "url": "https://mcp.context7.com/mcp"
    },
    "sequential-thinking": {
      "type": "local",
      "command": ["npx", "-y", "@modelcontextprotocol/server-sequential-thinking"]
    }
  }
}
```

**Important:**
- `git` and `fetch` are Python packages — run via `uvx` (not npx!)
- `uvx` comes with `uv`: `brew install uv`
- `context7` is a remote MCP — no npx needed
- Check in OpenCode: `/mcps`

### Chrome DevTools MCP

**Purpose:** agent can see the browser — console, network, DOM, screenshots.

**Requires:** a separate Chrome instance with a debug port (start manually before session).

```bash
# Alias in ~/.zshrc
alias chrome-debug="/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --remote-debugging-port=9222 \
  --user-data-dir=/tmp/chrome-debug \
  http://localhost:3000"
```

Add to `~/.config/opencode/opencode.jsonc`:

```jsonc
"chrome-devtools": {
  "type": "local",
  "command": ["npx", "-y", "chrome-devtools-mcp"],
  "env": {
    "CHROME_DEBUGGING_PORT": "9222"
  }
}
```

**Agent capabilities:**
- Console — errors, warnings, logs
- Network requests — status codes, headers, response bodies
- DOM — accessibility tree, screenshots
- Interaction — clicks, form filling
- Emulation — viewport, user-agent, geolocation, color scheme, network
- Performance — tracing (LCP, INP, CLS), Lighthouse
- Heap snapshot — memory leak detection

**Important:** the agent cannot start Chrome on its own. If browser debugging is needed —
run `chrome-debug` in the terminal, then open `localhost:3000` in that window.

---

### Directus MCP

**Purpose:** the agent manages Directus — schema, data, flows — without the UI.

**Requires:** a static MCP user token in Directus.

**Setup:**
1. Directus → Settings → AI → Model Context Protocol → **MCP Server: Enabled** → Save
2. User Directory → Create User → name `MCP User` → role Administrator → Token → Generate → Save
3. Add to `~/.config/opencode/opencode.jsonc`:

```jsonc
"directus": {
  "type": "remote",
  "url": "http://localhost:8055/mcp",
  "headers": {
    "Authorization": "Bearer YOUR_TOKEN"
  }
}
```

**Requires Directus v11.12+.** Check: `docker exec <container> node -e "const p = require('/directus/package.json'); console.log(p.version)"`

**Agent capabilities:**
- Schema — inspect collections, fields, relations
- Collections — create / modify
- Fields — add / configure types and validation
- Relations — M2O, O2M, M2M, M2A
- CRUD — read / create / update / delete items
- Files — upload, read metadata
- Flows — create and run automations
- Folders — organize files

**Add later (when needed):**

| Server | Purpose | Requires |
|---|---|---|
| `postgres` | direct database access | connection string |
| `brave-search` | web search | API key (free) |
| `puppeteer` | screenshots, UI testing | — |

---

### Step 4 — Global Rules

File: `~/.config/opencode/AGENTS.md`

```markdown
# Global Rules

## Behavior
- Always make a plan before large changes
- Confirm before committing to git
- Never push to git without explicit permission
- Never delete files without explicit confirmation
- Never modify lock files (package-lock.json, yarn.lock, pnpm-lock.yaml)

## Forbidden without explicit permission
- Do not touch .env files
- Do not modify nuxt.config.ts or vite.config.ts
- Do not run database migrations
- Do not modify docker-compose.yml

## Code style
- TypeScript strict mode always
- Use script setup in Vue components
- Use composables for reusable logic
- Use Pinia stores for global state
- Prefer Nuxt UI components over custom CSS
- Follow conventional commits (feat:, fix:, chore:, etc.)
- Python: follow PEP8, use type hints
- PHP: follow PSR-12

## Stack
- Frontend: Nuxt 3 / Nuxt 4 / Vue 3 / TypeScript / Tailwind / Pinia / Nuxt UI
- Backend: Directus / Symfony / PHP / FastAPI / Python
- DB: PostgreSQL
- Automation: Directus Flows
```

**Important:** global AGENTS.md applies to all sessions.
The project AGENTS.md in the repo root applies on top — both are loaded together.

---

### Step 5 — Global Skills

Skills are agent behavior patterns loaded on demand.
The agent sees the list of skills and loads the right one when the task matches the description.

**Tool:** `skills.sh` (npm for skills)

```bash
npx skills --help                  # help
npx skills find nuxt               # find skills by topic
npx skills find tailwind
npx skills find directus
npx skills ls -g                   # list globally installed
npx skills ls -g -a opencode       # only for OpenCode
npx skills update -g               # update all global skills
```

**What we installed:**

```bash
# Universal workflow skills (from Addy Osmani, Google tech lead)
git clone https://github.com/addyosmani/agent-skills.git ~/agent-skills-src
mkdir -p ~/.config/opencode/skills
cp -r ~/agent-skills-src/skills/* ~/.config/opencode/skills/

# Stack-specific skills
npx skills add antfu/skills@nuxt -g           # Nuxt 3/4 by Anthony Fu
npx skills add nuxt/ui@nuxt-ui -g             # Nuxt UI official
npx skills add onmax/nuxt-skills@vue -g       # Vue 3
npx skills add wshobson/agents@tailwind-design-system -g  # Tailwind
```

**Agent issue:** skills via `npx skills add` sometimes get installed
in `~/.agents/skills/` instead of `~/.config/opencode/skills/`.
If `npx skills ls -g -a opencode` does not show a skill — copy manually:

```bash
cp -r ~/.agents/skills/nuxt ~/.config/opencode/skills/
cp -r ~/.agents/skills/nuxt-ui ~/.config/opencode/skills/
cp -r ~/.agents/skills/vue ~/.config/opencode/skills/
cp -r ~/.agents/skills/tailwind-design-system ~/.config/opencode/skills/
```

**Installed skills for OpenCode:**

Universal (by Addy Osmani):
- `planning-and-task-breakdown` — task planning
- `spec-driven-development` — spec before code
- `incremental-implementation` — step-by-step implementation
- `debugging-and-error-recovery` — debugging
- `code-review-and-quality` — code review
- `test-driven-development` — TDD
- `git-workflow-and-versioning` — git workflow
- `frontend-ui-engineering` — UI development
- `api-and-interface-design` — API design
- `security-and-hardening` — security
- `performance-optimization` — optimization
- `using-agent-skills` — meta-skill (required)
- and others...

Stack-specific:
- `nuxt` — Nuxt 3/4 patterns
- `nuxt-ui` — Nuxt UI components
- `vue` — Vue 3 composables, script setup
- `tailwind-design-system` — Tailwind system

---

## 3. Working with Projects

### New project

```bash
cd ~/projects
mkdir myapp && cd myapp
opencode
```

Command for the agent:
```
create Nuxt 4 project with Tailwind, Pinia, Nuxt UI, TypeScript strict,
then create AGENTS.md for this project
```

The agent creates the project and `AGENTS.md` with the project map.

### Existing project (legacy)

```bash
cd ~/projects/myapp
opencode
```

Command for the agent:
```
analyze project and create AI onboarding layer: AGENTS.md with architecture,
directory structure, key commands and agent restrictions
```

---

## 4. AGENTS.md Template for Projects

```markdown
# AGENTS.md

## Project
MyApp — internal team coordination app (example project used throughout this guide).
Stack: Nuxt 4, Directus, PostgreSQL, FastAPI, Docker Compose.

## Architecture
- Frontend: Nuxt 4 + Nuxt UI + Tailwind + Pinia
- Backend: Directus (CMS + API) + FastAPI (AI features)
- DB: PostgreSQL
- Infra: Docker Compose

## Directory Structure
/components — UI components (Nuxt UI based)
/composables — reusable logic
/pages — file-based routes
/server/api — server endpoints
/stores — Pinia stores

## Key Commands
- dev: `npm run dev`
- build: `npm run build`
- lint: `npm run lint`
- docker: `docker compose up -d`

## Patterns
- Always use script setup
- Composables for reusable logic
- Pinia stores for global state
- server/api for backend calls (not direct DB)
- Nuxt UI components, no custom CSS unless necessary

## Agent Restrictions
- Never touch .env
- Never delete migrations
- Never modify nuxt.config.ts without discussion
- Never run DB migrations without explicit permission
- Commit only after confirmation
```

---

## 5. Daily Workflow

```
1. cd ~/projects/myapp
2. opencode                              ← launch the agent
3. [agent reads AGENTS.md + global rules + loads relevant skills]
4. "add meal sign-up page with cost split"   ← task
5. [agent creates a plan]
6. you confirm the plan
7. [agent writes code]
8. you review in WebStorm
9. git commit (with agent confirmation)
```

**Agent modes:**

| Mode | Behavior |
|---|---|
| SAFE | always plan → diff → confirmation |
| BALANCED (recommended) | big changes → confirm, small changes → auto |
| AUTO | autonomous work, minimal intervention |

---

## 6. IDE vs Agent

```
JetBrains IDE    = targeted fixes, debugging, navigation, UI polish
OpenCode Agent   = architecture, code generation, large changes, refactoring
You              = system orchestrator
```

---

## 7. What the Agent NEVER Does (without explicit permission)

- does NOT touch `.env` and secrets
- does NOT delete files
- does NOT push to git
- does NOT change lock files
- does NOT change build configs
- does NOT run database migrations

---

## 8. Useful Commands

```bash
# OpenCode
opencode                           # launch in current directory
opencode run "task description"    # launch with a task immediately
opencode stats                     # statistics

# Inside OpenCode TUI
/mcps                              # list MCP servers
/skills                            # list available skills
/models                            # switch model
/new                               # new session
/exit                              # exit

# RTK
rtk gain                           # token savings statistics
rtk gain --graph                   # ASCII graph for last 30 days
rtk gain --daily                   # daily breakdown
rtk ls ~/.config/opencode/         # view config

# Skills
npx skills find <query>            # find skills
npx skills add <owner/repo@skill> -g  # install globally
npx skills ls -g                   # list global
npx skills ls -g -a opencode       # only for OpenCode
npx skills update -g               # update all
npx skills remove <name> -g        # remove

# MCP
opencode mcp list                  # list MCP with auth status
opencode mcp auth <server>         # authorize OAuth MCP
```

---

## 9. DESIGN.md — UI Workflow

Before any UI task the agent must read `DESIGN.md` in the project.

**Tools for generating DESIGN.md:**

| Tool | Purpose |
|---|---|
| [refero](https://styles.refero.design/) | 2000+ ready-made DESIGN.md, Tailwind 4, CSS tokens |
| [designmd.me](https://designmd.me/) | paste site URL → get DESIGN.md |
| [designmd.supply](https://designmd.supply/) | similar to designmd.me |
| [getdesign.md](https://getdesign.md/) | URL-based generator |

**Workflow:**
1. Find a reference on refero → download DESIGN.md
2. Place it in `/design/DESIGN.md` in the project
3. In the project AGENTS.md add: `Always read /design/DESIGN.md before any UI task`

---

## 10. Config File Structure

```
~/.config/opencode/
├── opencode.jsonc          ← MCP servers, config
├── AGENTS.md               ← global rules
└── skills/                 ← global skills
    ├── nuxt/SKILL.md
    ├── nuxt-ui/SKILL.md
    ├── vue/SKILL.md
    ├── tailwind-design-system/SKILL.md
    ├── planning-and-task-breakdown/SKILL.md
    ├── debugging-and-error-recovery/SKILL.md
    └── ... (23+ skills)

~/projects/myapp/
├── AGENTS.md               ← project rules (loaded on top of global)
├── .opencode/skills/       ← project-specific skills (optional)
└── ...
```
