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
