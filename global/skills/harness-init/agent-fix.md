---
name: agent-fix
trigger: "fix, fix <path>, fix <ID>"
when_to_use: >
  After an `analyze` run produced a report in docs/audits/ — fixes
  CRITICAL/HIGH/MEDIUM findings phase by phase with verify gates. Requires a
  prior analyze run.
stack: any
---

# agent-fix

> Fix findings from an analysis report. Reads the latest report from
> docs/audits/, groups findings by priority, and fixes them phase by phase.
> Requires a prior analyze run. Does NOT create project docs — only fixes code.

## Purpose
Bridge between analyze and fixing: parse analysis report → classify verify
strength → create PLAN.md with correct gates → fix CRITICAL/BLOCKER →
HIGH/MAJOR → MEDIUM.

## Steps

Q0. **Language check:**
    If PROGRESS.md does NOT have a `Chat language:` entry yet:
    - Ask the user: "What language should I respond in? / На каком языке мы общаемся? / Welche Sprache?"
    - Write answer to PROGRESS.md as ISO code only: `Chat language: ru / de / en`
    If PROGRESS.md already has `Chat language:` — skip this step, use existing.

0. **Find latest analysis report:**
   ```bash
   ls -t docs/audits/*-analysis.md 2>/dev/null | head -1
   ```
   If none found — report: "No reports in docs/audits/. Run `analyze` first."
   If TARGET is set (from `fix <path>`) — store for filtering in Step 1.
   If TARGET matches pattern `[CBMH][0-9]+` (e.g. C2, H1, B2) — treat as ID
   filter, not path filter. Store as TARGET_ID. In Step 1 — keep only findings
   where prefix+number matches TARGET_ID.

0b. **Check for existing PLAN.md:**
    ```bash
    test -f PLAN.md && grep -E '^\s*- \[x\]' PLAN.md | grep -oE '[A-Z]+[0-9]+' | tr '\n' ', '
    ```
    If PLAN.md exists with `[x]` entries — extract fixed IDs, store as skip list for Step 1.
    If PLAN.md exists with no `[x]` — treat as fresh start (will overwrite in Step 2).
    If all findings in PLAN.md are `[x]` — print "All findings already fixed." and exit.
    If no PLAN.md — create new one in Step 2 as usual.

1. **Parse findings by section:**
   Read the report. Track current section by `##` headers.
   For each line matching pattern `**[X+N]**` — extract type, number, title, file:line.
    Section mapping:
    | Report section | Prefix | Maps to |
    |---|---|---|
    | `## Security` → `### Critical` | C | Phase 1 (CRITICAL) |
    | `## Security` → `### High` | H | Phase 2 (HIGH) |
    | `## Security` → `### Medium` | M (with leading `- `) | Phase 3 (MEDIUM) |
    | `## Senior Review` → `### Blockers` | B | Phase 1 (CRITICAL-equivalent) |
    | `## Senior Review` → `### Majors` | M (no leading `- `) | Phase 2 (HIGH-equivalent) |
    | `## Logic Analysis` | L | Phase 1 (UNIT_TEST_REDGREEN always) |
   Skip `## Recommended Next Steps` — summary, not source findings.
   If TARGET is set — keep only findings where file:line contains TARGET.
   **Deduplicate by file:line:** if two findings share the same file:line —
   merge into one entry. Keep the higher-priority prefix (C > B > H > M),
   combine titles with " + ". Fix once, verify once. Verify strength uses the
   winning (highest) prefix — see Step 1a.
   Print summary as exact table (no other format):
   ```
   | Phase | Count | IDs |
   |-------|-------|-----|
   | Phase 1 CRITICAL/BLOCKER | N | C1, B1, ... |
   | Phase 2 HIGH/MAJOR | N | H1, M1, ... |
   | Phase 3 MEDIUM | N | M1, M2, ... |
   ```
   Ask: "Start Phase 1? (y/n)"

1a. **Classify verify strength for each finding (before creating PLAN.md):**
    For each parsed finding assign a verify tier:

    | Prefix | Verify tier | What is allowed |
    |--------|-------------|-----------------|
    | C, B | FUNCTIONAL | curl with response code assertion, or UNIT_TEST_REDGREEN for pure functions. grep-only is a violation. |
    | H, M (Senior Majors) | FUNCTIONAL_PREF | Functional preferred; grep acceptable only for purely structural facts (duplicate IDs, missing `lang="ts"`, file existence). |
    | M (Security Medium) | GREP_OK | grep is sufficient. |
    | L | UNIT_TEST_REDGREEN always | Never curl, never grep — always write a unit test. |

    **Pure function detection:** a finding's fix qualifies for `UNIT_TEST_REDGREEN`
    if ALL of the following are true:
    - The fixed code is a standalone function (no network calls, no DB, no
      filesystem side effects inside the function itself)
    - Examples: input validation, sanitization, formatting, parsing, business
      rule logic
    - Counter-examples: API route handlers, DB queries, email sending, file I/O

    If UNIT_TEST_REDGREEN applies — mark the finding's verify gate as
    `UNIT_TEST_REDGREEN` in PLAN.md instead of a bash command.

    **Test runner session flag** — set once per session, not per finding:
    - `RUNNER_READY = unknown` initially, `TEST_RUNNER = unknown`
    - First time a `UNIT_TEST_REDGREEN` finding is reached → detect runner and set flag
      (see Step 3, sub-step 1a)
    - All subsequent `UNIT_TEST_REDGREEN` findings use the stored flag without
      asking again

2. **Create or update PLAN.md:**
   If PLAN.md exists (resume from Step 0b) — append new unfixed findings, keep
   existing `[x]` entries intact.
   If no PLAN.md — create new one in project root.

   Format — verify gate reflects the tier from Step 1a:
   ```
   - [ ] C1: <title> — <file:line>
     | verify: curl -s -o /dev/null -w "%{http_code}" -X POST ... | grep -q "400"
   - [ ] C2: <title> — <file:line>
     | verify: UNIT_TEST_REDGREEN
   - [ ] H1: <title> — <file:line>
     | verify: grep -c 'EMAIL_REGEX' server/api/contact.post.ts | grep -q '[^0]'
   - [ ] M1: <title> — <file:line>
     | verify: grep -q 'lang="ts"' app/components/Jobs.vue
   ```
   Never write a verbal check ("check that it works", "review manually").

3. **Phase 1 — CRITICAL + BLOCKER:**
   Show list → ask user to confirm → for each finding:
   1. Read file:line — scope: only this file, do not touch adjacent files
    1a. If verify gate is `UNIT_TEST_REDGREEN` and `RUNNER_READY = unknown`:
        **Test runner detection (once per session, before first UNIT_TEST_REDGREEN):**
        ```bash
        # JS/TS runners
        PKG_JSON=$(find . -name "package.json" -not -path "*/node_modules/*" \
          -exec grep -lE '"vitest"|"jest"|"jasmine"' {} \; 2>/dev/null | head -3)
        # Python
        PY_FILES=$(find . \( -name "requirements*.txt" -o -name "pyproject.toml" \) \
          2>/dev/null | head -1)
        # PHP
        COMPOSER=$(find . -name "composer.json" -not -path "*/vendor/*" 2>/dev/null | head -1)
        # Go
        GOMOD=$(find . -name "go.mod" 2>/dev/null | head -1)
        ```
        Result mapping (check in order):
        - vitest in package.json → TEST_RUNNER = vitest
        - jest in package.json → TEST_RUNNER = jest
        - jasmine in package.json → TEST_RUNNER = jasmine
        - requirements.txt / pyproject.toml → TEST_RUNNER = pytest
        - composer.json → TEST_RUNNER = phpunit
        - go.mod → TEST_RUNNER = go_test
        - nothing found → ask user: "No test runner detected. Which one? (vitest / jest / pytest / phpunit / other)"

        Then verify runner is installed:
        - vitest → `grep -q '"vitest"' package.json 2>/dev/null`
        - jest → `grep -q '"jest"' package.json 2>/dev/null`
        - pytest → `python3 -m pytest --version 2>/dev/null`
        - phpunit → `./vendor/bin/phpunit --version 2>/dev/null`
        - go_test → always ready (built-in)

        If not installed → ask user once:
        "TEST_RUNNER not installed. Install now? (y/n — choosing n means
        write-only mode for all UNIT_TEST_REDGREEN findings this session)"
        On y → install with the appropriate command (ask only, auto-install):
        - vitest → `npm install -D vitest`
        - jest → `npm install -D jest @types/jest ts-jest`
        - pytest → ask: "Install pytest? (pip install pytest)"
        - phpunit → ask: "Install PHPUnit? (composer require --dev phpunit/phpunit)"
        On n → Set `RUNNER_READY = no` (write-only mode, no test execution)

        Set `RUNNER_READY = yes` when runner is confirmed installed.
        Store TEST_RUNNER value for all subsequent steps.
    1b. If verify gate is `UNIT_TEST_REDGREEN` and `RUNNER_READY = yes` and finding prefix is NOT `L`:
        **Red-green protocol (bug findings only — code must be incorrect):**
        i.   Write ONE test file: `tests/unit/<finding-slug>.test.ts`
             (create `tests/unit/` if it does not exist)
             — covers the specific buggy behavior described in the finding
             — must be minimal: one or two test cases, not full coverage
             — NEVER create additional files
             Use correct test syntax per TEST_RUNNER:
             - vitest/jest → describe/it/expect with vi.mock()/jest.mock()
             - pytest → functions with assert, unittest.mock.patch()
             - phpunit → class extending TestCase, methods starting with test
             - go_test → func TestXxx(t *testing.T)
        ii.  Run test — it MUST fail:
             ```bash
             # Command per TEST_RUNNER:
             # vitest:  npx vitest run tests/unit/<finding-slug>.test.ts
             # jest:    npx jest tests/unit/<finding-slug>.test.ts
             # pytest:  python3 -m pytest tests/unit/<finding-slug>.py -v
             # phpunit: ./vendor/bin/phpunit tests/unit/<finding-slug>.php
             # go_test: go test ./... -run TestFunctionName -v
             ```
             If it passes immediately → the test does not target the actual bug.
             Rewrite it until it fails before proceeding.
        ii-b. If test fails with ReferenceError on framework globals (ref,
              computed, defineEventHandler, etc.) — this is ONLY for vitest/jest.
              Fix via setup file:
              (1) Create tests/unit/setup.ts with vi.stubGlobal / jest.fn() calls
              (2) Add setupFiles: ['./tests/unit/setup.ts'] to vitest/jest config
              (3) Update the test import to import the function directly from
                  the source file instead of through the framework wrapper
              (4) Re-run test. If still fails for same reason — report to user.
              NEVER modify the source file's module structure or add exports
              to work around import errors.
              For pytest/phpunit/go: framework globals are not auto-imported —
              use explicit imports in the test file instead.
         iii. Now apply the fix to the source file (step 2 below)
         iv.  Re-run the same test — it MUST pass. This re-run IS the verify gate:
              ```bash
              # Same command as step ii per TEST_RUNNER
              ```
              If it fails → revert fix, explain, propose alternative (step 5)

        MANDATORY OUTPUT BLOCK — cannot skip, cannot reorder, must appear after GREEN:
        "This test will fail if [X] breaks because [Y]"
        X = specific business rule being tested. Y = concrete consequence.
        > [ID] — verify: UNIT_TEST_REDGREEN (PASS)
        > Next? (y / n / stop)
        Wait for user answer before any action.
    1b-L. If verify gate is `UNIT_TEST_REDGREEN` and `RUNNER_READY = yes` and finding prefix is `L`:
          **Coverage protocol (L-findings only — code is correct, no bug to fix):**

          All chat output in this protocol (confirmations, explanations, verify output)
          must be in session language. Read from PROGRESS.md: `Chat language: <code>`.

          Before writing test — check finding Type and enforce minimum scenarios:
          - pure function   → (1) happy path  (2) null/undefined/zero input  (3) boundary value
          - composable      → (1) success path  (2) API error (mock rejects)  (3) missing/null dependency
          - server route    → (1) valid request  (2) missing required fields → 400  (3) unauthorized → 401
          Each test case must use expect()/assert() with concrete values. toBeTruthy() alone is not allowed.
          Minimum 3 test cases per finding — one per scenario above.

          Use correct test syntax per TEST_RUNNER (same as step 1b.i).

          i.   Write ONE test file: `tests/unit/<finding-slug>.test.ts`
               (or .py / .php per TEST_RUNNER convention)
               — use ALL test cases from the finding exactly as listed
               — for composables (vitest/jest): apply setup.ts with vi.stubGlobal if needed
                 (see step 1b.ii-b for ReferenceError handling — same approach)
               — NEVER create additional files except setup.ts if needed
          ii.  Run test — it SHOULD pass immediately (code is correct):
               ```bash
               # Command per TEST_RUNNER (same as step 1b.ii)
               ```
               If it FAILS:
               - ReferenceError on framework globals → apply step 1b.ii-b
                 (vitest/jest only). Re-run.
               - Logic failure (wrong output) → this may be a real bug.
                 Report to user before proceeding. Do NOT fix source
                 without user confirmation.

          MANDATORY OUTPUT BLOCK — cannot skip, cannot reorder, must appear after test run:
          "This test will fail if [X] breaks because [Y]"
          X = specific business rule being tested. Y = concrete consequence.
          > [ID] — verify: UNIT_TEST_REDGREEN (PASS)
          > Next? (y / n / stop)
          Wait for user answer before any action.
    1c. If verify gate is `UNIT_TEST_REDGREEN` and `RUNNER_READY = no`:
       Replace verify gate with a functional check without a test runner.
       Choose the appropriate tool based on the function's nature:
       - HTTP behavior (status codes, headers) → curl with response assertion
       - Pure logic / string / date / format → `node -e "..."` or `python3 -c "..."`
       - File structure check → grep on the output of the fixed code
       Proceed as normal (steps 2–6 below).
   2. If finding requires a choice (library, approach) — offer 2-3 options with
      rationale → wait for user selection
   3. If purely technical — fix without asking
    4. **Run verify gate — output + Next? are one block:**
       After verify produces PASS or FAIL, output EXACTLY:
         > [ID] — verify: [TOOL] (PASS/FAIL)
         > Next? (y / n / stop)
       Wait for user answer BEFORE any action:
       - PASS + y → mark [x] in PLAN.md, continue to next finding
       - PASS + n → mark [x] in PLAN.md (bypassed), continue
       - PASS + stop → append Resolved to report, update PLAN.md,
         exit. Then ask: "Commit? (y/n)" — user decides.
       - FAIL → revert change, explain why, propose alternative.
         Then ask "Next?" again with same template.
       For UNIT_TEST_REDGREEN findings: the MANDATORY OUTPUT BLOCK
       in step 1b/1b-L already includes the verify result + Next? prompt.
       Do NOT output step 4 template again — the block IS the verify gate.
   After all done — "Phase 1 complete. Proceed to Phase 2? (y/n)"

4. **Phase 2 — HIGH + MAJOR:**
   Same cycle as Phase 1 (including sub-steps 1a–1c and step 4 verify+Next? block).
   After done — "Phase 2 complete. Proceed to Phase 3? (y/n)"

5. **Phase 3 — MEDIUM:**
   Same cycle as Phase 1 (including sub-steps 1a–1c and step 4 verify+Next? block).

6. **Update docs/roadmap.md if exists:**
   ```bash
   test -f docs/roadmap.md && echo "## Fixed $(date +%Y-%m-%d)" >> docs/roadmap.md
   ```
   Append list of resolved findings.

7. **Append Resolved section to the original analysis report:**
   ## Resolved (YYYY-MM-DD)
   - C1: ✅ <title> — <what was done>
   - B1: ✅ <title> — <what was done>

8. **git add + commit:**
   Message: "fix: resolve N CRITICAL/B M HIGH findings from $(date +%Y-%m-%d) analysis"

## Hard Rules

| Rule | Value |
|------|-------|
| Phase confirmation | User confirms each phase before start |
| Empty phase | No [C] / [H] / [B] in section — skip phase, not an error. Report: "Phase N: only <prefix>-findings (N items)" |
| Scope per finding | Only the file from the finding, do not touch adjacent files |
| Verify gate | Concrete bash command, exit code or output check, never verbal |
| Verify strength C/B | FUNCTIONAL required — curl+response code or UNIT_TEST_REDGREEN. grep-only is a violation. |
| Verify strength H/M-major | FUNCTIONAL preferred — grep only for structural facts (file existence, attribute presence) |
| Verify strength M-medium | GREP_OK — grep is sufficient |
| Verify strength L | UNIT_TEST_REDGREEN always — never curl, never grep |
| Dedup + verify | Merged findings use highest-severity prefix to determine verify tier |
| Unit test scope | ONE test file, one or two cases on the specific fixed function — not full file coverage |
| Test runner session flag | Detect once per session on first UNIT_TEST_REDGREEN finding. Never ask again. |
| Test runner install | Always ask user before installing any test runner package. Never install silently. |
| Red-green order | Write test → confirm FAIL → fix code → confirm PASS. Never fix first. |
| Framework auto-imports | If test fails with ReferenceError on framework globals (ref, computed, defineEventHandler, etc.) — fix via vitest setup file (vi.stubGlobal or setupFiles). Never modify source file structure. Try in order: (1) vi.stubGlobal in tests/unit/setup.ts, (2) official test-utils package for the framework. If neither works — report to user, do NOT touch source. |
| Choice of approach | Agent offers 2-3 options with rationale → user picks |
| Env var findings | If finding involves env var / secret key — scope extends to `.env.example` and `docker-compose.yml` in addition to the source file |
| TARGET no arg | Full latest report |
| TARGET with arg | `fix server/api/` — filter findings by path prefix; `fix auth.py` — exact file match |
| TARGET as ID | `fix C2` — only this finding by ID. Pattern: letter + number (C2, H1, B2, M3) |
| Playwright | Only if finding is about browser UI behavior. Otherwise grep, curl, vitest |
| B-prefix | Blockers from Senior Review = CRITICAL-equivalent → Phase 1 |
| M-prefix | Majors (Senior Review) = HIGH-equivalent → Phase 2 |
| | Medium (Security) = MEDIUM → Phase 3 |
| roadmap.md | Check `test -f` before writing |
