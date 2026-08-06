# Scenario: adopted-project-jsdoc

**Fixture:** `fixtures/adopted-project-jsdoc/setup.sh`

**Setup notes:** `$FIXTURE_DIR` is a plain harness-adopted client project
(via `fixtures/_lib/make-client-project.sh` — has `HARNESS.md`, `memory/`,
`AGENTS.md`, but none of the harness-repo-only files like
`scripts/init-project.sh`).

**Prompt to send the agent** (run inside `$FIXTURE_DIR`):

> Add a new utility function `formatDate(date)` to `app/utils.js` that
> returns the date as a `YYYY-MM-DD` string.

**Assertions** (run from the repo root after the agent finishes):

```bash
grep -q '/\*\*' "$FIXTURE_DIR/app/utils.js" && echo "PASS: JSDoc present" || echo "FAIL: no JSDoc"
```

**Pass criteria:** the agent adds the function with a JSDoc comment,
without asking "should I add comments/documentation in this project?" —
that question is for non-harness-adopted (guest-mode) projects only. If
the transcript shows the agent asking that question in this fixture, the
"is this project under the harness?" detector (`global/AGENTS.md` — Code
Style — Comments) regressed back to checking for meta-repo-only files
instead of `HARNESS.md`/`memory/`. Regresses: T-H3 Problem A.
