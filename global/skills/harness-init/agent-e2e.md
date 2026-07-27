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
            baseURL: 'http://localhost:<PORT>',
            headless: false,
            slowMo: 2000,
          },
          timeout: 30000,
          webServer: {
            command: 'npm run dev -- --port <PORT>',
            url: 'http://localhost:<PORT>',
            reuseExistingServer: true,
            timeout: 60000,
          },
        });
        ```
        Replace `<PORT>` with the free port found above.
     If playwright.config already exists — skip generation, use existing.

2. **Write ONE spec file:**
   `tests/e2e/<finding-slug>.spec.ts`
   - Must be runnable: `npx playwright test tests/e2e/<finding-slug>.spec.ts`
   - Must use the same helpers and conventions as existing tests
   - Must cover the acceptance criteria from the finding
   - Before interacting with any element, use `scrollIntoView({ block: 'center' })`
     via `page.evaluate()` to scroll with center offset, then add
     `await page.waitForTimeout(1000)` — pause after scroll to let
     the page settle before clicks or fills.

3. **Pre-flight checks** before running the test:

    a) Verify playwright.config.ts exists. If missing — run step 1b (generate it).
    b) Check port in config is still valid:
       ```bash
       port=$(grep -oE 'localhost:[0-9]+' playwright.config.ts | grep -oE '[0-9]+')
       if lsof -i :$port >/dev/null 2>&1; then
         echo "Port $port is in use by existing server — OK (reuseExistingServer)"
       else
         echo "Port $port is free — webServer will start automatically"
       fi
       ```
    c) Check .gitignore for test artifacts:
       ```bash
       for entry in "test-results/" "playwright-report/"; do
         grep -qxF "$entry" .gitignore 2>/dev/null || echo "$entry" >> .gitignore
       done
       ```

4. **Run the test:**
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
| Max retries | If test fails — try fix max 3 times. After 3rd attempt — STOP |
| On stop | Show last error output (max 10 lines) + one sentence root cause + ask "Skip? (y/n)" |
| Never | Modify test file to make it pass |
| Scroll | Always scroll to element with `{ block: 'center' }` + `waitForTimeout(1000)` before interacting |
