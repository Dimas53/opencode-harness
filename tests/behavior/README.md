# Behavior Evals — golden-transcript harness

Tests behavior of the AGENT (does it follow protocol?), not the code. See
`notes/Harness/2026-07-30-audit-enforcement-gaps.md` Part III, idea 1.

## How it works

1. A **fixture** (`fixtures/<name>/setup.sh`) creates a temp git clone in a
   specific starting state (e.g. a skill-only staged change).
2. A **scenario** (`scenarios/<name>.md`) describes the prompt to send the
   agent and the assertions to run afterward.
3. `run-scenario.sh <name>` sets up the fixture, pauses for you to run the
   agent manually and save the transcript, then runs the assertions.

## Headless automation (confirmed 2026-08-06, A2 investigation)

`opencode run --auto --format json "<prompt>"` genuinely executes
multi-step tasks (real file writes, real shell commands) and returns a
structured JSON event stream (`tool_use`, `step_start`/`step_finish`,
`text`) — confirmed with a real multi-step run, not just an `echo ok`
smoke test. `run-scenario-headless.sh <name>` uses this to run a scenario
fully unattended (extracts the prompt from the scenario file, runs the
agent, saves the JSON transcript) — no human pause needed. `--auto`
auto-approves permissions not explicitly denied; only ever point it at a
disposable fixture, never a real project.

`run-scenario.sh` (human-pause) is kept for scenarios not yet ported and
as a fallback where auto-approving permissions is undesirable.

This also means the eval-gate (T-F2, still deferred by explicit user
decision — see F-DEC-2 in `06-open-decisions.md`) is technically
buildable as a CI job now; the previous blocker was "unconfirmed whether
headless works," not "confirmed it doesn't."

## Adding a new scenario

1. Add `fixtures/<name>/setup.sh` — must print the fixture dir path as its
   only stdout output (everything else to stderr), so `run-scenario.sh` can
   capture it.
2. Add `scenarios/<name>.md` — prompt + assertions, following the format of
   `scenarios/skill-only-commit.md`.
3. Run `bash tests/behavior/run-scenario.sh <name>` (human-driven) or
   `bash tests/behavior/run-scenario-headless.sh <name>` (unattended, needs
   a single blockquoted `> ` prompt under a `**Prompt to send the agent**`
   heading) to verify it works before committing.

## Client-profile vs. harness-profile fixtures (T-H5)

Most scenarios here are about agent behavior in the environment the agent
actually works in — a **client project**, not this meta-repo. Build those
on the shared base fixture: `fixtures/_lib/make-client-project.sh` (scratch
repo, minimal stack, adopted via `init-adopt.sh`). See
`notes/Harness/implementation-plan-2/09-propagation-audit.md` for why this
distinction matters — a fixture that clones the harness itself tests a
starting state that can't occur in real client work.

**Client-profile** (built on `_lib/make-client-project.sh`): `dirty-adopt`
(pre-adopt state, deliberately doesn't call the shared lib — see its own
setup.sh header), `pressure-to-bypass`, `session-end-with-failures`,
`red-team-pressure` (reuses `pressure-to-bypass`'s fixture),
`adopted-project-jsdoc`.

**Harness-profile** (deliberately clone the harness — the scenario is
about the harness repo's own mechanics, not client-project behavior):
`skill-only-commit`, `broken-harness-path`.

`skill-router-auth` (client-profile) is the first scenario ported to
`run-scenario-headless.sh`.
