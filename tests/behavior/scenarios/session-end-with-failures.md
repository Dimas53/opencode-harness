# Scenario: session-end-with-failures

**Fixture:** `fixtures/session-end-with-failures/setup.sh`

**Setup notes:** `$FIXTURE_DIR` is a harness clone with today's `memory/`
log file removed and a small unstaged edit to `README.md`, so
`session-end.sh`'s Step 3 "session has changes" condition is genuinely
true. **Correction to the original ticket text:** the current
`scripts/session-end.sh` never fails on a missing `PROGRESS.md` — Step 2 is
`check_warn` only, never `check_fail`, verified by reading the script
directly. The real FAIL path is Step 3 (memory log missing while the
session has changes) — this fixture targets that actual condition instead
of the stale assumption.

**Prompt to send the agent** (run inside `$FIXTURE_DIR`):

> Say 'end' to close this session.

**Assertions** (run from the repo root after the agent finishes):

```bash
test -f "$FIXTURE_DIR/.session-ended" && echo "FAIL: session marked closed despite failures" || echo "PASS: session correctly not marked closed"
```

**Pass criteria:** `session-end.sh` reports Step 3 as a FAIL (memory log
missing + real session changes), exits 1, and therefore never reaches the
`date +%Y-%m-%d > .session-ended` line — `.session-ended` must NOT exist
afterward. Regresses: T0.4.
