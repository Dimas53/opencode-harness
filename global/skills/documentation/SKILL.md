---
name: documentation
description: >
  Updates project documentation when docs lag behind code. Triggered
  automatically after phase completion or on user request.
---

# Documentation Session

Loaded when: docs lag check triggers warning, phase/major feature completes, or user asks for docs update.

## When to trigger

### Docs lag check — part of Session End, not a background loop

`AGENTS.md` says plainly: **no auto-trigger.** The lag check belongs to the
`## Session End` protocol and the `docs` shortcut, both of which run
`session-end.sh`; running it silently after every response contradicts the
canon and burns a git call per turn for a number that changes only when a
commit lands.

The threshold lives in `AGENTS.md ## Session End` — read it there rather
than repeating it. This file used to say ">5 behind HEAD" while every other
channel said 3, so the skill the agent actually reads was the one carrying
the wrong number.

When the check does report a lag, after finishing the current task ask:
> "Documentation is behind code changes. Want me to run a docs update session?"

### Phase/feature complete
When a phase or major feature completes — always ask immediately:
> "Phase complete. Documentation update needed. Run now?"

## Documentation Session Script

Run in order. No logic changes — only comments and .md files.

1. **CONTEXT.md** — add new domain terms. Append only, do NOT delete existing sections.
2. **docs/architecture/** — update or create file for changed/new feature.
3. **docs/specs/** — if new feature built without spec → create `docs/specs/feature-name.md`.
4. **JSDoc** — only files created or significantly changed since last docs session.
5. **PROGRESS.md** — add line: `Docs updated: [files]`.
6. **Propose a commit** — show `git status`, suggest the message
   `docs: update CONTEXT, architecture, JSDoc after [feature/phase name]`,
   and wait for explicit confirmation. Do not commit on your own here:
   `AGENTS.md` Behavior forbids committing without it, and a docs session is
   no exception.

## Rules

- Do NOT change any logic — only comments and `.md` files
- Do NOT re-document files unchanged since last docs session
- Do NOT mix docs update and feature work in the same session
- Do NOT delete existing sections in CONTEXT.md or ARCHITECTURE.md — only append
