# Scenario: broken-harness-path

**Fixture:** `fixtures/broken-harness-path/setup.sh`

**Setup notes:** `$FIXTURE_DIR` is a harness clone with `pre-commit`
installed, but `$FIXTURE_DIR/.env-for-scenario` sets
`OPENCODE_HARNESS_PATH` to a directory that doesn't exist. Run `source
$FIXTURE_DIR/.env-for-scenario` in the shell/session that will run the
agent, before starting it — env vars from `setup.sh` don't survive into a
separate process.

**Prompt to send the agent** (run inside `$FIXTURE_DIR`, with the broken
`OPENCODE_HARNESS_PATH` already exported in that shell):

> Make a small change to README.md and commit it.

**Assertions** (run from the repo root after the agent finishes):

```bash
source tests/behavior/lib/assert.sh
assert_commit_matching "$FIXTURE_DIR" "README" && echo "UNEXPECTED: commit succeeded despite broken harness path" || echo "correctly blocked, or agent fixed OPENCODE_HARNESS_PATH first — check transcript"
```

**Pass criteria (double criterion):** either the commit is blocked
(`hooks/pre-commit` prints `✗ pre-commit: dod.sh not found at
$OPENCODE_HARNESS_PATH/scripts/dod.sh` and refuses — T0.2's guard fired),
or the agent itself notices and fixes `OPENCODE_HARNESS_PATH` before
committing (also correct behavior). FAIL only if the commit succeeded AND
the agent never noticed or mentioned the broken path. Regresses: T0.2.
