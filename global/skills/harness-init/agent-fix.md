# agent-fix

> Fix findings from an analysis report. Reads the latest report from
> docs/audits/, groups findings by priority, and fixes them phase by phase.
> Requires a prior analyze run. Does NOT create project docs — only fixes code.

## Purpose
Bridge between analyze and fixing: parse analysis report → create PLAN.md with
verify gates → fix CRITICAL/BLOCKER → HIGH/MAJOR → MEDIUM.

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
   Report summary to user: "Found: N CRITICAL/BLOCKER, M HIGH/MAJOR, K MEDIUM. Start? (y/n)"

2. **Create PLAN.md** in project root:
   - [ ] C1: <title> — <file:line>
     | verify: <bash command>
   - [ ] B1: <title> — <file:line>
     | verify: <bash command>
   Verify gate must be a concrete bash command (grep, curl, python -c, pytest).
   Never a verbal check.

3. **Phase 1 — CRITICAL + BLOCKER:**
   Show list → ask user to confirm → for each finding:
   1. Read file:line — scope: only this file, do not touch adjacent files
   2. If finding requires a choice (library, approach) — offer 2-3 options with rationale → wait for user selection
   3. If purely technical — fix without asking
   4. Run verify gate from PLAN.md
    5. If verify fails — revert change, explain why, propose alternative
    6. If verify passes — mark [x] in PLAN.md → ask: "Next? (y / n / stop)"
       y → continue to next finding
       n → skip this finding, keep it marked [ ], continue to next
       stop → commit current progress, update report with resolved, exit
   After all done — "Phase 1 complete. Proceed to Phase 2? (y/n)"

4. **Phase 2 — HIGH + MAJOR:** Same cycle as Phase 1 (including stop flow).
   After done — "Phase 2 complete. Proceed to Phase 3? (y/n)"

5. **Phase 3 — MEDIUM:** Same cycle as Phase 1 (including stop flow).

6. **Update docs/roadmap.md if exists:**
   ```bash
   test -f docs/roadmap.md && echo "## Fixed $(date +%Y-%m-%d)" >> docs/roadmap.md
   ```
   Append list of resolved findings.

7. **git add + commit:**
   Message: "fix: resolve N CRITICAL/B M HIGH findings from $(date +%Y-%m-%d) analysis"

8. **Append resolved section to the original analysis report:**
   ## Resolved (YYYY-MM-DD)
   - C1: ✅ <title> — <what was done>
   - B1: ✅ <title> — <what was done>
   Append before commit (step 7) so the report update is included.

## Hard Rules

| Rule | Value |
|------|-------|
| Phase confirmation | User confirms each phase before start |
| Empty phase | No [C] / [H] / [B] in section — skip phase, not an error. Report: "Phase N: only <prefix>-findings (N items)" |
| Scope per finding | Only the file from the finding, do not touch adjacent files |
| Verify gate | Concrete bash command, exit code or output check, never verbal |
| Choice of approach | Agent offers 2-3 options with rationale → user picks |
| TARGET no arg | Full latest report |
| TARGET with arg | `fix server/api/` — filter findings by path prefix; `fix auth.py` — exact file match |
| Playwright | Only if finding is about browser UI behavior. Otherwise grep, curl, npm test |
| B-prefix | Blockers from Senior Review = CRITICAL-equivalent → Phase 1 |
| M-prefix | Majors (Senior Review) = HIGH-equivalent → Phase 2 |
| | Medium (Security) = MEDIUM → Phase 3 |
| roadmap.md | Check `test -f` before writing |
