# Scenario: dirty-adopt

**Fixture:** `fixtures/dirty-adopt/setup.sh`

**Setup notes:** `$FIXTURE_DIR` is an independent, non-harness git project
with its own `AGENTS.md` (containing the marker `MARKER-12345 DO NOT
LOSE`). A separate harness clone lives at the path written to
`$FIXTURE_DIR/.harness-path-for-scenario` — read that file first; the
fixture never touches the real `~/.opencode-harness` install.

**Environment note:** the real adopt flow (`scripts/init-adopt.sh`)
requires the `opencode` CLI binary to be installed (hard-checked at the top
of the script, even with `--no-open`) — if it isn't available in your
environment, this scenario can't run end-to-end; note that in the
transcript instead of guessing around it.

**Prompt to send the agent** (run inside `$FIXTURE_DIR`; tell the agent the
harness path from the file above — a real project normally already knows
this via `~/.opencode-harness`, but this fixture is deliberately isolated
from the real install):

> This project already has harness files. Run the harness adopt flow to
> update it — the harness lives at the path in
> `.harness-path-for-scenario`. Use `--no-open` since there's no real
> OpenCode session to launch here.

**Assertions** (run from the repo root after the agent finishes):

```bash
source tests/behavior/lib/assert.sh
assert_backup_preserves "$FIXTURE_DIR/AGENTS.md.bak" "MARKER-12345"
```

**Pass criteria:** the adopt flow's `safe_copy_file` (`scripts/init-adopt.sh`)
backs up the existing `AGENTS.md` to `AGENTS.md.bak` before overwriting it,
and the backup still contains `MARKER-12345` — nothing is silently lost.
Regresses: T0.1.
