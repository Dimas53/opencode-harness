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

1b. **Generate playwright.config.ts if missing:**
    ```bash
    test -f playwright.config.ts || test -f playwright.config.js || echo "MISSING"
    ```
    If no playwright config found:
    a) Find a free port:
       ```bash
       port=3000
       while lsof -i :$port >/dev/null 2>&1; do port=$((port + 1)); done
       echo "FREE_PORT=$port"
       ```
    b) Create `playwright.config.ts` with:
       ```ts
       import { defineConfig } from '@playwright/test';
       export default defineConfig({
         testDir: './tests/e2e',
         use: {
           baseURL: 'http://localhost:<FREE_PORT>',
           headless: false,
           launchOptions: { slowMo: 2000 },
         },
         timeout: 30000,
       });
       ```
       Replace `<FREE_PORT>` with the port found above.
    If playwright.config already exists — skip generation, use existing.

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
