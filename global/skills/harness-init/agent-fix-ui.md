# agent-fix-ui — Fix UI findings

> Reads from docs/audits/ui/. Same cycle as agent-fix but only U-prefix findings.
> U-pw → Playwright via agent-e2e.md. U → static verify.

## Steps

Q0. **Language check — same as agent-fix.md:**
    If PROGRESS.md does NOT have a `Chat language:` entry yet:
    - Ask the user → write to PROGRESS.md as ISO code.
    If PROGRESS.md already has `Chat language:` — skip, use existing.

0. **Aggregate findings from ALL UI analysis reports:**
   ```bash
   ls docs/audits/ui/*-ui-analysis*.md 2>/dev/null
   ```
   If none found — report: "No UI reports in docs/audits/ui/. Run `analyze-ui` first."
   Parse findings from ALL report files, not just the latest.
   Deduplicate findings by file:line (same bug in multiple reports = one entry).
   If TARGET matches pattern `U[0-9]+` (e.g. U1, U2-pw) — treat as ID filter.
     Strip -pw suffix for matching (U1 matches U1-pw).
   If TARGET is a path matching a report file (`*-ui-analysis*.md`) — parse only that report.
   If TARGET is a path matching a component (`app/Contact.vue`, `pages/`, etc.) — filter by file:line in Step 1 across all reports.
   If TARGET is `all-pw` — keep only findings with `-pw` suffix, drop static U findings entirely.

0b. **Check for existing PLAN.md:**
   ```bash
   test -f PLAN.md && grep -E '^\s*- \[x\]' PLAN.md | grep -oE 'U[0-9]+' | tr '\n' ', '
   ```
   If PLAN.md exists with `[x]` entries — extract fixed IDs, store as skip list.
   If all findings in PLAN.md are `[x]` — print "All UI findings already fixed." and exit.

1. **Parse findings** — from `## UI Behavior` section only.
   For each line matching `**[U+N]**` — extract prefix (U or U-pw), number, title, file:line.
   If TARGET is `all-pw` — drop all findings without `-pw` suffix (static only).
   Print mode line if applicable:
   ```
   Mode: Playwright-only (TARGET=all-pw)
   ```
   Print table:
   ```
   | Type | Count | IDs |
   |------|-------|-----|
   | Playwright (U-pw) | N | U1-pw, U2-pw |
   | Static (U) | N | U3, U4 |
   ```
   (If a type has 0 findings — omit its row.)
   Ask: "Start fixing? (y/n)"

2. **Create PLAN.md:**
   - [ ] U1-pw: <title> — <file:line>
     | verify: PLAYWRIGHT
   - [ ] U2: <title> — <file:line>
     | verify: static

3. **Fix cycle** (for each finding in PLAN.md):
   1. Read file:line — scope: only this file
   2. If finding requires a choice (library, approach) — offer 2-3 options → wait
   3. Fix the code in file:line — do this BEFORE loading agent-e2e
   4. MANDATORY — before running ANY playwright command for this finding, you MUST load ~/.config/opencode/skills/harness-init/agent-e2e.md via Read tool. This applies even if tests/e2e/*.spec.ts or playwright.config.ts already exist from a previous attempt — loading is not conditional on whether files exist.
      NEVER call `npx playwright test` or any playwright command directly from agent-fix-ui logic. All test execution for this finding must go through agent-e2e.md's retry-guard (its step 4), no exceptions.
       If verify is PLAYWRIGHT → load agent-e2e.md now:
         pass: file:line, description, acceptance criteria
         on return: PASS → go to step 6
                    FAIL → show output, ask "Skip this finding? (y/n)"
                      y → mark [x] (bypassed), go to step 6
                      n → fall through to step 5
       If verify is static → grep check the fix exists — PASS → step 6, FAIL → step 5
    5. If verify fails — revert change, explain why, propose alternative
    6. **After verify (PASS or FAIL after revert):**
       Output EXACTLY:
         > [ID] — verify: [TOOL] (PASS/FAIL)
         > Next? (y / n / stop)
       Wait for user answer BEFORE any action:
       - PASS + y → mark [x] in PLAN.md, continue to next finding
       - PASS + n → mark [x] (bypassed), continue
       - PASS + stop → append Resolved to report, update PLAN.md, exit.
         Then ask: "Commit? (y/n)" — user decides.
       - FAIL → revert change, explain why, propose alternative.
         Then ask "Next?" again with same template.

4. **Append Resolved section to the UI analysis report:**
   ## Resolved (YYYY-MM-DD)
   - U1-pw: ✅ <title> — <what was done>
   - U2: ✅ <title> — <what was done>

5. **git add + commit:**
   Message: "fix(ui): resolve N U-pw M U findings from $(date +%Y-%m-%d) ui analysis"

## Hard Rules

| Rule | Value |
|------|-------|
| Report source | only docs/audits/ui/*-ui-analysis.md |
| Prefixes | U (static) and U-pw (Playwright) only |
| U-pw verify | Always Playwright via agent-e2e — no question needed |
| U verify | static — grep/check fix exists |
| Scope per finding | Only the file from the finding |
| Phase confirmation | User confirms before start |
| TARGET as ID | `fix-ui U1` — matches U1 or U1-pw across all reports |
| TARGET as report path | `fix-ui docs/audits/ui/FILE.md` — findings from this report only |
| TARGET as component path | `fix-ui app/Contact.vue` — filter by file across all reports |
| TARGET all-pw | `fix-ui all-pw` — only U*-pw findings, skip static, auto-PLAYWRIGHT verify |
