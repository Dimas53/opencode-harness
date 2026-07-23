# agent-analyze

> Use this skill for: read-only audit of an existing project.
> Does NOT create docs, AGENTS.md, or project setup.
> For full project setup → use agent-adopt.md instead.

## Purpose
Deep analysis of an existing project — understand architecture, find
vulnerabilities, assess risks. Does NOT create or modify any project files.
Output goes to docs/audits/ only.

## Skill load check
For each skill below, try `Read ~/.config/opencode/skills/<path>/SKILL.md`.
If file not found — skip that skill, continue without stopping.
After all attempts — print:
"Loaded: zoom-out ✓, codebase-health-check ✓, junior-to-senior ✓, code-review-and-quality ✓, security ✓, premortem ✓"

## Skill stack (load in this order, skip missing)
1. ~/.config/opencode/skills/zoom-out/SKILL.md
2. ~/.config/opencode/skills/codebase-health-check/SKILL.md
3. ~/.config/opencode/skills/junior-to-senior/SKILL.md
4. ~/.config/opencode/skills/code-review-and-quality/SKILL.md
5. ~/.config/opencode/skills/security/SKILL.md
6. ~/.config/opencode/skills/premortem/SKILL.md

## Steps

Q0. **Language — before any analysis:**
    If PROGRESS.md does NOT have a `Chat language:` entry yet:
    - Ask the user: "What language should I respond in? / На каком языке мы общаемся? / Welche Sprache?"
    - Write answer to PROGRESS.md: `Chat language: [ru / de / en / ...]`
    If PROGRESS.md already has `Chat language:` — skip this step, use existing.
    All further chat output (summary, questions to user) — in that language. The report file is always in English (see Hard rules).

### Target detection
Extract TARGET from the user's last message using this pattern:
- If message matches `analyze <path>` — set TARGET=<path>
- Examples: "analyze pages/Dashboard.vue" → TARGET=pages/Dashboard.vue
- Examples: "analyze server/api/" → TARGET=server/api/
- If message is just "analyze" — TARGET is empty (full project mode)

If TARGET is set:
- Scope all skill runs to TARGET path only
- Set SAFE_TARGET = TARGET with / replaced by - (e.g. pages/Dashboard.vue → pages-Dashboard.vue)
- Report title: # [TARGET] Analysis — [date]
- Report filename: docs/audits/YYYY-MM-DD-analysis-[SAFE_TARGET].md
- Sections not applicable to a single file (Architecture, Risks) → replace with one line:
  "Full project analysis required for this section — run `analyze` without arguments."

0. Check changes since last analysis report:
   ```bash
   last_date=$(ls docs/audits/*-analysis.md 2>/dev/null | tail -1 | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}')
   if [ -n "$last_date" ]; then
     git log --oneline --after="$last_date" -- frontend/
   fi
   ```
   Include output in Health section as "Changed since last analysis: N commits".
   If 0 commits — mark report with flag `⚠️ STALE — no code changes since last analysis`.

1. Load all six skills above — skip missing ones, do not stop
2. Run zoom-out → explain architecture in plain language
3. Run codebase-health-check → system map, duplication, priorities
4. Run junior-to-senior → senior-level design/approach findings
5. Run code-review-and-quality → multi-axis code review
6. Run security → find auth, API, secrets vulnerabilities
7. Run premortem → what could go wrong, top 5 risks
8. Compile results into one report
9a. Diff findings against previous report:
    ```bash
    last=$(ls -t docs/audits/*-analysis.md 2>/dev/null | head -1)
    if [ -f "$last" ]; then
      echo "=== DIFF vs previous report ==="
      diff <(grep -E '\[C[0-9]|\[H[0-9]|\[M[0-9]|\[R[0-9]' "$last") \
           <(grep -E '\[C[0-9]|\[H[0-9]|\[M[0-9]|\[R[0-9]' docs/audits/$(date +%F)-analysis.md) || true
    fi
    ```
    If diff is empty — add warning to report: `⚠️ All findings match previous report — analysis may not have found new issues or may not have refreshed`.

10. Save report to:
    - If TARGET is empty: docs/audits/YYYY-MM-DD-analysis.md
    - If TARGET is set: docs/audits/YYYY-MM-DD-analysis-[SAFE_TARGET].md
10a. Verify report file was written:
     ```bash
     # Use correct filename based on TARGET
     REPORT_FILE="docs/audits/$(date +%F)-analysis${SAFE_TARGET:+-$SAFE_TARGET}.md"
     test -f "$REPORT_FILE" && wc -l "$REPORT_FILE" || echo "FAIL — file not saved"
     ```
     If file not found or fewer than 80 lines — retry writing before proceeding.

11. Print summary to chat in chat language (read from PROGRESS.md: Chat language: <code>).
    Format: narrative, NOT a table. Minimum 20 lines. Structure:
    - Architecture: 3-5 sentences — what the system does, why this stack, key decision
    - Health: 3-5 sentences — file count, biggest problems, duplication, linter status
    - Security: each Critical and High finding as a paragraph with file:line
    - Risks: top 3 risks in one sentence each
    - Recommended next steps: numbered list CRITICAL → HIGH → MEDIUM
    Generic one-liners like "improve code quality" are not allowed.
    Each finding must name exact file and line.

**Quality gate:** every skill run must produce at least 5 concrete findings
with specific code examples (file + line). Generic statements like
«improve code quality» are not allowed — each finding names the exact file,
line, and what a senior would change. If fewer than 5 findings are available,
note «less than 5 findings available» and explain why.

## Output format

Follow this template strictly. Deviations are not allowed.

---

# Project Analysis — [date]

[If there is a previous report — one status line:]
⚠️ STALE — no code changes since [date]. Findings re-validated.
or
✅ [N] commits since [date] — new findings possible.

---

## Architecture     ← source: zoom-out

[MANDATORY: first paragraph — narrative. What the system does in one sentence.
Why this specific stack — one sentence. What problem the key architecture
decision solves — one sentence. Do NOT start with a table or heading.]

[Then — Layer Map as a tree, not a table:]
```
Browser (PWA)
  └─ ...
```

### Data Flow
[critical path as numbered list]
[after list — one paragraph about auth flow]

### Key Architecture Decisions
| Decision | Rationale |
|----------|-----------|

---

## Health           ← source: codebase-health-check

### System Map
[one line: N pages, N components, N composables, N server routes. Total: ~N lines]

### File Size Problems (files > 400 lines)
| File | Lines | Problem |
|------|-------|---------|

[After table — paragraph about the largest file: what is inside,
how a senior would split it, specific composable/component names]

### Duplication
[numbered list, each item: name + file:line where it occurs]

### `any` Type Usage
[one line: N occurrences across N files. Primary cause: ...]

### No Linter
[paragraph: what is missing, why this is HIGH priority]

### Priorities
[numbered list of HIGH/MEDIUM/LOW]

### npm Audit [run: cd frontend && npm audit 2>/dev/null || true]
| Severity | Count | Notable |
|----------|-------|---------|
[one line: which are exploitable in production]

### Changed since last analysis
[git log output or "0 commits — stale check"]

---

## Senior Review    ← source: junior-to-senior

[TEXT ONLY — no tables]

### Design Altitude
[one line overall rating: Mixed/Strong/Weak + why]

### Blockers
[each blocker — paragraph:]
**[B1] Title** — `file:line` what is wrong. Concrete scenario when it breaks.
What the project's own AGENTS.md says about this if relevant.

### Majors
[each major — paragraph with file:line and concrete solution:]
**[M1] Title** — concrete example. A senior would: concrete solution.
Ref: `file:line`.

### What the junior got right
[bullets — at least 4, concrete decisions with explanation why they are correct]

---

## Quality          ← source: code-review-and-quality

### Correctness
[bullets: edge cases correct and incorrect, file:line]

### Readability
[bullets with numbers: N any usages, N console.log, which files are unreadable]

### Security
See [Security] section below.

### Performance
[bullets: what is good and what creates load with concrete examples]

---

## Security         ← source: security

### Critical
[each Critical — paragraph, not table:]
**[C1] Title** — `file:line`. Description. Why critical. What breaks.

### High
[each High — paragraph:]
**[H1] Title** — `file:line`. Description + concrete impact.

### Medium
[bullets:]
- **[M1]** `file:line` description

### Low
[bullets:]
- **[L1]** description

---

## Risks            ← source: premortem

### Top 5 Failure Scenarios (Premortem)
[each risk — numbered paragraph:]
1. **[R1] Title** — concrete scenario: step by step what happens →
what the user sees. **Impact: X. Likelihood: Y** (reason for rating).

---

## Recommended Next Steps   ← source: all skills, your prioritization

[numbered list with priority prefix:]
1. **CRITICAL —** ...
2. **HIGH —** ...
3. **MEDIUM —** ...
4. **LOW —** ...

## Hard rules
- Report file is always written in English regardless of session language. Session language applies only to the chat summary (Step 11).
- NEVER modify source files
- NEVER create docs/ structure — only write to docs/audits/
- If docs/audits/ doesn't exist — create it first
- Always save the report, don't just print to chat
- After saving report — always run file existence check (step 10a)
- Always run git log diff before analysis (step 0)
- Always run findings diff after compiling (step 9a)
- If TARGET is set — scope all skill runs to TARGET path only
- Report filename must include TARGET name when TARGET is set
