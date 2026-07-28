# agent-analyze-logic

> Find uncovered business logic in a project and generate testable findings.
> Does NOT write tests — only generates [L-prefix] findings for `fix-logic`.
> Output goes to docs/audits/logic-YYYY-MM-DD.md.

## Purpose
Scan project for pure functions, composables, and server routes with business
logic. Check if tests exist. Generate concrete test cases for uncovered code.
`fix-logic` picks up the findings and writes tests via UNIT_TEST_REDGREEN.

## Skill load check
For each skill below, try `Read ~/.config/opencode/skills/<path>/SKILL.md`.
If file not found — skip that skill, continue without stopping.
After all attempts — print:
"Loaded: zoom-out ✓, domain-modeling ✓, test-driven-development ✓"

## Skill stack (load in this order, skip missing)
1. ~/.config/opencode/skills/zoom-out/SKILL.md
2. ~/.config/opencode/skills/domain-modeling/SKILL.md
3. ~/.config/opencode/skills/test-driven-development/SKILL.md

## Steps

Q0. **Language — before any analysis:**
    If PROGRESS.md does NOT have a `Chat language:` entry yet:
    - Ask the user: "What language should I respond in? / На каком языке мы общаемся? / Welche Sprache?"
    - Write answer to PROGRESS.md as ISO code only: `Chat language: ru / de / en`
      NEVER write full word: "русский", "Deutsch", "English" — always use 2-letter ISO code.
    If PROGRESS.md already has `Chat language:` — skip this step, use existing.
    All further chat output (summary, questions to user) — in that language. The report file is always in English (see Hard rules).

### Target detection
Extract TARGET from the user's last message using this pattern:
- If message matches `analyze-logic <path>` — set TARGET=<path>
- Examples: "analyze-logic utils/" → TARGET=utils/
- Examples: "analyze-logic composables/useBalanceCheck.ts" → TARGET=composables/useBalanceCheck.ts
- If message is just "analyze-logic" — TARGET is empty (full project mode)

If TARGET is set:
- Scope all grep/skill runs to TARGET path only
- Set SAFE_TARGET = TARGET with / replaced by - (e.g. composables/useBalanceCheck.ts → composables-useBalanceCheck.ts)
- Report title: # [TARGET] Logic Analysis — [date]
- Report filename: docs/audits/logic-YYYY-MM-DD-[SAFE_TARGET].md

0. **Check changes since last logic report:**
   ```bash
   last_date=$(ls docs/audits/logic-*.md 2>/dev/null | tail -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
   if [ -n "$last_date" ]; then
     git log --oneline --after="$last_date" -- . 2>/dev/null | head -20
   fi
   ```
   If 0 commits — mark report with flag `⚠️ STALE — no code changes since last logic analysis`.

1. **Load all three skills** — skip missing ones, do not stop

2. **Find business logic candidates:**
   ```bash
   # Find exported functions, composables, server routes
   SEARCH_DIRS="${TARGET:-.}"
   echo "=== Pure functions ==="
   grep -rn "^export function" --include="*.ts" $SEARCH_DIRS 2>/dev/null
   echo "=== Composables ==="
   grep -rn "^export function use[A-Z]" --include="*.ts" $SEARCH_DIRS 2>/dev/null
   echo "=== Server routes ==="
   grep -rn "defineEventHandler" --include="*.ts" $SEARCH_DIRS 2>/dev/null
   echo "=== Exported constants with business values ==="
   grep -rn "^export const" --include="*.ts" $SEARCH_DIRS 2>/dev/null
   ```

3. **Run zoom-out** — understand architecture: which directories contain business logic, data flow, auth boundaries

4. **Run domain-modeling** — for each candidate file identified in step 2:
   - Read the file
   - Extract business rules from JSDoc comments and code structure
   - Identify: inputs, outputs, side effects, edge cases, error handling
   - Note: which external dependencies exist (useDirectus, useFetch, etc.)

5. **Run test-driven-development** — for each candidate:
   - Determine if it's testable as pure function (no deps), composable (mocked deps), or server route (mocked auth)
   - Generate minimum 3 test cases with concrete inputs/outputs
   - Identify boundary values from code constants

6. **Check existing test coverage:**
   For each candidate file, check if a test file already exists:
   ```bash
   FILE="<candidate-path>"
   BASENAME=$(basename "$FILE" .ts)
   test -f "tests/unit/**/${BASENAME}.test.ts" 2>/dev/null || \
   test -f "tests/api/${BASENAME}.test.ts" 2>/dev/null || \
   find tests/ -name "${BASENAME}.test.ts" 2>/dev/null | grep -q .
   ```
   If test exists — skip this candidate (already covered).

7. **Generate findings** — for each uncovered candidate, create a finding:

   Priority rules (APPLY IN THIS ORDER):
   - HIGH: financial logic (balance, deduction, cost, payment, transaction), permissions/auth guards, dedup with business rules, data integrity logic
   - MEDIUM: main business flows, computations visible to users, polling/notification logic, search/filter logic
   - LOW: formatting, display helpers, mapping without business rules, utility functions under 15 lines

   Finding format — each finding MUST contain ALL fields:
   ```
   **[L<N>] <functionName>** — `<file>:<line>`
   Priority: HIGH | MEDIUM | LOW
   Type: pure function | composable | server route
   Mocks: vi.mock('~/composables/useDirectus')  // ONLY for composables, with exact import path
   Business rules:
   - rule 1 extracted from code
   - rule 2 extracted from code
   Test cases:
   1. concrete input → concrete expected output
   2. boundary value — why this boundary
   3. edge case — what makes it an edge case
   verify: UNIT_TEST_REDGREEN
   ```

   Hard rules for findings:
   - Each finding MUST contain real business rules extracted from the actual code — not generic "test this function"
   - Minimum 3 test cases per finding
   - Test cases must use actual input values and expected outputs from the code
   - Skip files under 10 lines
   - Skip files that already have a test

8. **Compile into report** following Output format below

9a. **Diff findings against previous report:**
    ```bash
    last=$(ls -t docs/audits/logic-*.md 2>/dev/null | head -1)
    if [ -f "$last" ]; then
      echo "=== DIFF vs previous logic report ==="
      diff <(grep -E '\[L[0-9]' "$last" 2>/dev/null) \
           <(grep -E '\[L[0-9]' docs/audits/logic-$(date +%F).md 2>/dev/null) || true
    fi
    ```
    If diff is empty — add warning: `⚠️ All findings match previous report — no new uncovered logic found.`

10. **Save report** to:
    - If TARGET is empty: `docs/audits/logic-YYYY-MM-DD.md`
    - If TARGET is set: `docs/audits/logic-YYYY-MM-DD-[SAFE_TARGET].md`

10a. **Verify report file was written:**
    ```bash
    REPORT_FILE="docs/audits/logic-$(date +%F)${SAFE_TARGET:+-$SAFE_TARGET}.md"
    test -f "$REPORT_FILE" && wc -l "$REPORT_FILE" || echo "FAIL — file not saved"
    ```
    If file not found or fewer than 30 lines — retry writing before proceeding.

11. **Print summary to chat** in chat language (read from PROGRESS.md: Chat language: <code>).
    Format: narrative, minimum 10 lines:
    - Overview: N candidates found, M uncovered, X findings generated
    - HIGH: list each HIGH finding with file:line and why HIGH
    - MEDIUM: list each MEDIUM finding
    - LOW: list each LOW finding
    - Next: "Run `fix-logic` to start writing tests for these findings"

## Output format

Follow this template strictly. Deviations are not allowed.

---

# Logic Analysis — [date]

⚠️ STALE — no code changes since [date]. Findings re-validated.
or
✅ [N] commits since [date] — fresh analysis.

## Quick Fix Reference
| File | Findings |
|------|----------|
| [file] | [L1], [L2] |

Commands: `fix-logic` (all) · `fix-logic <file>` · `fix-logic <ID>`

Rules: one row per unique file from findings with file:line. Merge multiple IDs into one row.

---

## Uncovered Business Logic

**[L1] <functionName>** — `<file>:<line>`
Priority: HIGH | MEDIUM | LOW
Type: pure function | composable | server route
Mocks: <only for composables — exact mock path>
Business rules:
- <rule from code>
- <rule from code>
Test cases:
1. <input> → <output>
2. <boundary input> → <output>
3. <edge case input> → <output>
verify: UNIT_TEST_REDGREEN

[Repeat for each finding, L2, L3...]

---

## Skipped (tests exist or under 10 lines)

| File | Reason |
|------|--------|
| <file> | test exists at <path> or <10 lines |

---

## Hard rules

| Rule | Value |
|------|-------|
| Report language | Always English (chat summary is in session language) |
| Never modify source files | Read-only analysis |
| Always save report | Don't just print to chat |
| Verify report written | Step 10a — check file exists and has content |
| docs/audits/ | Create if not exists |
| Minimum 3 test cases | Every finding must have ≥3 concrete test cases |
| Skip covered | Files with existing tests are excluded |
| Skip tiny | Files < 10 lines are excluded |
| Business rules | Extracted from real code, not invented |
| Diff previous | Always run step 9a |
| TARGET scoping | When TARGET is set — scope all searches to that path |
