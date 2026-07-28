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
    | M (Security Medium), L | GREP_OK | grep is sufficient. |

    **Pure function detection:** a finding's fix qualifies for `UNIT_TEST_REDGREEN`
    if ALL of the following are true:
    - The fixed code is a standalone function (no network calls, no DB, no
      filesystem side effects inside the function itself)
    - Examples: input validation, sanitization, formatting, parsing, business
      rule logic
    - Counter-examples: API route handlers, DB queries, email sending, file I/O

    If UNIT_TEST_REDGREEN applies — mark the finding's verify gate as
    `UNIT_TEST_REDGREEN` in PLAN.md instead of a bash command.

    **Vitest session flag** — set once per session, not per finding:
    - `VITEST_READY = unknown` initially
    - First time a `UNIT_TEST_REDGREEN` finding is reached → check and set flag
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
   1a. If verify gate is `UNIT_TEST_REDGREEN` and `VITEST_READY = unknown`:
       ```bash
       grep -q '"vitest"' package.json 2>/dev/null && echo "FOUND" || echo "MISSING"
       ```
       If FOUND → set `VITEST_READY = yes`
       If MISSING → ask user once: "No Vitest found. Install it for unit test
         verify? (y/n — choosing n means curl-based verify for all pure function
         findings this session)"
         y → `npm install -D vitest` then create minimal config if missing:
             ```bash
             test -f vitest.config.ts || cat > vitest.config.ts << 'EOF'
             import { defineConfig } from 'vitest/config'
             export default defineConfig({ test: { environment: 'node' } })
             EOF
             ```
             Set `VITEST_READY = yes`
         n → Set `VITEST_READY = no` (applies to all further findings this session)
   1b. If verify gate is `UNIT_TEST_REDGREEN` and `VITEST_READY = yes`:
       **Red-green protocol (run BEFORE fixing the code):**
       i.   Write ONE test file: `tests/unit/<finding-slug>.test.ts`
            (create `tests/unit/` if it does not exist)
            — covers the specific buggy behavior described in the finding
            — must be minimal: one or two test cases, not full coverage
            — NEVER create additional files
       ii.  Run test — it MUST fail:
            ```bash
            npx vitest run tests/unit/<finding-slug>.test.ts
            ```
            If it passes immediately → the test does not target the actual bug.
            Rewrite it until it fails before proceeding.
       iii. Now apply the fix to the source file (step 2 below)
       iv.  Re-run the same test — it MUST pass. This re-run IS the verify gate.
            If it fails → revert fix, explain, propose alternative (step 5)
       v.   Mark [x] in PLAN.md → skip to step 7
   1c. If verify gate is `UNIT_TEST_REDGREEN` and `VITEST_READY = no`:
       Replace verify gate with a functional check without a test runner.
       Choose the appropriate tool based on the function's nature:
       - HTTP behavior (status codes, headers) → curl with response assertion
       - Pure logic / string / date / format → `node -e "..."` or `python3 -c "..."`
       - File structure check → grep on the output of the fixed code
       Proceed as normal (steps 2–6 below).
   2. If finding requires a choice (library, approach) — offer 2-3 options with
      rationale → wait for user selection
   3. If purely technical — fix without asking
   4. Run verify gate from PLAN.md (skip if already handled in step 1b)
   5. If verify fails — revert change, explain why, propose alternative
   6. If verify passes — mark [x] in PLAN.md
   7. **After each finding: ask "Next? (y / n / stop)"**
      y → continue to next finding
      n → skip this finding (keep [ ]), continue to next
      stop → commit current progress, append Resolved section to report, then commit, exit
   After all done — "Phase 1 complete. Proceed to Phase 2? (y/n)"

4. **Phase 2 — HIGH + MAJOR:**
   Same cycle as Phase 1 (including sub-steps 1a–1c and step 7 with "Next? (y/n/stop)").
   After done — "Phase 2 complete. Proceed to Phase 3? (y/n)"

5. **Phase 3 — MEDIUM:**
   Same cycle as Phase 1 (including sub-steps 1a–1c and step 7 with "Next? (y/n/stop)").

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
| Verify strength M-medium/L | GREP_OK — grep is sufficient |
| Dedup + verify | Merged findings use highest-severity prefix to determine verify tier |
| Unit test scope | ONE test file, one or two cases on the specific fixed function — not full file coverage |
| Vitest session flag | Ask once per session on first UNIT_TEST_REDGREEN finding. Never ask again. |
| Red-green order | Write test → confirm FAIL → fix code → confirm PASS. Never fix first. |
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
