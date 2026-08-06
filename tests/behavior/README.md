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

## Current limitation — read before building new scenarios

Fully unattended `opencode run` on a multi-step task is NOT confirmed to work
reliably (only `opencode run 'echo ok'` smoke-test is confirmed — see
`scripts/verify.sh`). Until someone confirms real headless task execution,
`run-scenario.sh` pauses for a human to run the agent interactively and paste
the transcript. Automate this fully once headless mode is confirmed — do not
guess at flags.

## Adding a new scenario

1. Add `fixtures/<name>/setup.sh` — must print the fixture dir path as its
   only stdout output (everything else to stderr), so `run-scenario.sh` can
   capture it.
2. Add `scenarios/<name>.md` — prompt + assertions, following the format of
   `scenarios/skill-only-commit.md`.
3. Run `bash tests/behavior/run-scenario.sh <name>` to verify it works before
   committing.

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
