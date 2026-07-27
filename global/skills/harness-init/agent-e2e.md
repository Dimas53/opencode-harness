# agent-e2e — Playwright verify gate

> Sub-protocol. Called from agent-fix-ui.md to verify a UI fix via Playwright.
> Not a standalone shortcut.
> This protocol does NOT fix code — the fix was already applied by the
> caller BEFORE calling this verify phase.

## Input (from agent-fix-ui)

- file:line — the file and line from the finding
- finding description — what the issue is
- acceptance criteria — extracted from finding text, describes expected behavior

## Phase 1 — Verify the fix (write test + run)
Note: source code fix must already be applied before this phase.

0. **Check @playwright/test is installed:**
   ```bash
   grep -q '"@playwright/test"' package.json || echo "MISSING"
   ```
   If MISSING:
   - Ask user: "Install @playwright/test + browsers? (y/n)"
   - If y → run `npm install -D @playwright/test && npx playwright install`
   - If n → stop, cannot proceed without it

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
        **Guard:** Do not deviate from these values (`headless: false`, `slowMo: 2000` at top-level `use:`) without explicit user confirmation.
     If playwright.config already exists — skip generation, use existing.

2. **Write ONE spec file:**
   `tests/e2e/<finding-slug>.spec.ts`
   - Must be runnable: `npx playwright test tests/e2e/<finding-slug>.spec.ts`
   - Must use the same helpers and conventions as existing tests
   - Must cover the acceptance criteria from the finding
   - NEVER create additional files — no debug-*.spec.ts, no helpers, no temp files.
     Only ONE spec file per run. To debug — edit the same file, not create a new one.
   - Before interacting with an element, use this copy-paste block
     (replace '#your-selector' with the actual CSS selector):
     ```ts
     await page.evaluate((sel) => {
       document.querySelector(sel)?.scrollIntoView({ block: 'center' });
     }, '#your-selector');
     await page.waitForTimeout(1000);
     ```

3. **Pre-flight checks** before running the test:

    a) Verify playwright.config.ts exists. If missing — run step 1b (generate it).
    b) If config exists — check and patch it:
       - Check for `webServer` block: `grep -q 'webServer' playwright.config.ts`
       - If NO webServer → add it before the last `}`:
         Extract PORT from existing baseURL (`grep -oE 'localhost:[0-9]+' | grep -oE '[0-9]+'`)
         Append to config (before trailing `}`):
         ```
           webServer: {
             command: 'npm run dev -- --port <PORT>',
             url: 'http://localhost:<PORT>',
             reuseExistingServer: true,
             timeout: 60000,
           },
         ```
       - If webServer exists → keep config unchanged.
       - Check slowMo location: if `slowMo` is inside `launchOptions` — keep as is.
         If `slowMo` is NOT in config at all — add `launchOptions: { slowMo: 2000 }` inside `use:`.
    c) Check port in config is still valid:
       ```bash
       port=$(grep -oE 'localhost:[0-9]+' playwright.config.ts | grep -oE '[0-9]+')
       if lsof -i :$port >/dev/null 2>&1; then
         echo "Port $port is in use by existing server — OK (reuseExistingServer)"
       else
         echo "Port $port is free — webServer will start automatically"
       fi
       ```
    d) Check .gitignore for test artifacts:
       ```bash
       for entry in "test-results/" "playwright-report/"; do
         grep -qxF "$entry" .gitignore 2>/dev/null || echo "$entry" >> .gitignore
       done
       ```

4. **Run the test (with retry guard):**
   **Execution rule:** Set `workdir` to the project root and run the block below as a standalone multi-line bash command.
   Do NOT prepend `cd ... &&` to this block — compound commands (`while`/`if`) after `&&` break in zsh.
   ```bash
   RETRY=0
   PASSED=""
   while [ $RETRY -lt 3 ]; do
     if npx playwright test tests/e2e/<finding-slug>.spec.ts; then
       PASSED=1; break
     else
       RETRY=$((RETRY + 1))
       echo "Attempt $RETRY/3 failed" >&2
     fi
   done
   if [ -n "$PASSED" ]; then
     echo "PASS"
   else
     echo "FAIL after 3 attempts"
   fi
   ```
   If FAIL after 3 retries — extract last 10 lines of error output,
   write one sentence root cause, then ask user "Skip? (y/n)":
     y → mark finding as skipped, return to agent-fix
     n → stop entirely, commit current progress, exit

5. **Return to agent-fix:**
   - PASS → `"PASS. Test saved at tests/e2e/<finding-slug>.spec.ts"`
   - FAIL → `"FAIL after 3 attempts. Output: <last 10 lines>. Test saved as regression doc."`

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
| Never | Modify test file to make it pass |
