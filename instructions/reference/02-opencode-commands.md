# OpenCode (.ai) Command Reference

### Terminal Commands

- **`opencode`** — launch the AI agent in the current project directory.
- **`opencode models`** — list all available and configured models.
- **`opencode auth list`** — show authorized AI providers.
- **`opencode auth login`** — authorize a new provider (enter API key or configure a local address).
- **`opencode --model <ID>`** — start a session with a specific model (e.g. `ollama/llama3`).
- **`opencode plugin add <url>`** — install a plugin from a URL.
- **`opencode upgrade`** — upgrade OpenCode to the latest version.

---

### Session Commands (inside the interface)

- **`/models`** — open an interactive menu to switch between models.
- **`/connect`** — quickly configure a connection to a local or cloud provider.
- **`/help`** — show full help for all available agent commands.
- **`/exit`** (or **`/quit`**) — end the current session and exit OpenCode.

---

### Context and Code Commands (inside the interface)

- **`/init`** — create an `AGENTS.md` file to describe project architecture to the agent.
- **`/compact`** — compress the chat history to save tokens and clear memory.
- **`/undo`** — revert the last action or code change made by the agent.
- **`/redo`** — redo a reverted action.
- **`/clear`** — completely clear the current dialog history, starting context from scratch.

---

### Viewing Tokens and Logs

- **`/tokens`** — an internal chat command that shows the current context size, tokens used in the current session, and the remaining model limit.
- **`opencode run --verbose`** — launch the agent from the terminal with verbose output. In this mode, all system prompts, request metadata, and exact token counts are printed to the console in real time for each step.
- **`tail -f ~/.opencode/logs/main.log`** — view the agent's system log in real time via the terminal (Windows PowerShell: `Get-Content ~\.opencode\logs\main.log -Wait`). All API calls, errors, and session statistics are recorded here.

---

### In-Interface Navigation

- **`Ctrl+P`** / **`Cmd+P`** — open the command palette (quick access to all commands).
- **`/`** — prefix for all in-interface commands (e.g. `/models`, `/help`, `/compact`).

---

## Harness Make Commands

### Automatic (triggered by git hook)

- **`make dod`** — 6‑check Definition of Done: uncommitted, Cyrillic scan, docs lag, PROGRESS.md, docs matrix, quick tests. Runs automatically via pre‑commit hook on every `git commit`.

### Trigger words inside OpenCode

- **`make session-end`** — run on `end / done / Ende`: checks docs lag, updates PROGRESS.md, creates `.session-ended` guard.

### Manual (from terminal)

- **`make start`** — show git log + PROGRESS.md + .session-ended check, then open OpenCode
- **`make test-quick`** — run 20 bats tests (all scripts + templates)
- **`make verify`** — check harness installation (scripts exist, config in place)
- **`make update`** — pull latest harness + copy global files to `~/.config/opencode/`
- **`make init PROJECT=/path`** — new project: copy templates + interview via OpenCode
- **`make init-adopt PROJECT=/path`** — existing project: analyze + docs generation
- **`make analyze PROJECT=/path`** — read‑only audit: architecture + security + risk
- **`fix` (inside OpenCode)** — fix CRITICAL/BLOCKER → HIGH/MAJOR → MEDIUM findings from last analysis report
- **`fix <path>`** — fix findings only for a specific file, folder, or ID (e.g. `fix main.py`, `fix C2`)

---

## Keyboard Shortcuts

| Key | Action |
|-----|--------|
| `Ctrl+P` / `Cmd+P` | Command palette |
| `Ctrl+C` | Interrupt current agent action |
| `Esc` | Cancel input |
| `↑` / `↓` | Navigate message history |
