# agent-e2e — Playwright verify gate

> Sub-protocol. Called from agent-fix.md when finding requires UI verification.
> Not a standalone shortcut.

## Input (from agent-fix)

- file:line — the file and line from the finding
- finding description — what the issue is
- acceptance criteria — extracted from finding text, describes expected behavior

## Phase 1 — Write test + Run (no autofix)

1. **Check existing test patterns:**
   ```bash
   ls tests/e2e/ 2>/dev/null || echo "NOT_FOUND"
   ```
   If tests/e2e/ does not exist — create it.
   If it exists — scan for page objects, fixtures, login setup helpers.
   Use the same conventions as existing tests.

2. **Write ONE spec file:**
   `tests/e2e/<finding-slug>.spec.ts`
   - Must be runnable: `npx playwright test tests/e2e/<finding-slug>.spec.ts`
   - Must use the same helpers and conventions as existing tests
   - Must cover the acceptance criteria from the finding

3. **Run the test:**
   ```bash
   npx playwright test tests/e2e/<finding-slug>.spec.ts
   ```

4. **Return to agent-fix:**
   - PASS → `"PASS. Test saved at tests/e2e/<finding-slug>.spec.ts"`
   - FAIL → `"FAIL. Output: <error>. Test saved as regression doc."`

## Output

| Result | What agent-fix does |
|--------|---------------------|
| PASS | Marks `[x]` in PLAN.md, continues to next finding |
| FAIL | Shows output, asks user "Skip this finding?" |

## Hard Limits

| Rule | Value |
|------|-------|
| Scope | Only the file from finding + new test file |
| No autofix | Never modify source code to make test pass |
| No delete | Never delete existing passing tests |
| No push | Only write files, agent-fix handles commit |
| Playwright only | Never use curl/grep as verify here |
