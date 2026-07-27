# agent-analyze-ui — UI Behavior Analysis

> Static UI analysis. No full project audit — only frontend behavior check.
> Saves report to docs/audits/ui/

## Steps

Q0. **Language — same as agent-analyze.md:**
    If PROGRESS.md does NOT have a `Chat language:` entry yet:
    - Ask the user: "What language should I respond in? / На каком языке мы общаемся? / Welche Sprache?"
    - Write answer to PROGRESS.md as ISO code only: `Chat language: ru / de / en`

### Target detection
Extract TARGET from user message:
- `analyze-ui <path>` or `analyze-ui <path>` with path → set TARGET=<path>
- `analyze-ui` alone → TARGET empty (full frontend scan)

### Steps

1. **Load frontend-behavior/SKILL.md (analysis mode).**
   Read ~/.config/opencode/skills/frontend-behavior/SKILL.md.
   Follow checklist and output format sections only.
   Skip "After Analysis" section — this script handles saving and Playwright.

2. **Run checklist** on TARGET (if set) or full frontend (if no TARGET).

3. **Save report:**
   ```bash
   mkdir -p docs/audits/ui
   ```
   Report file: `docs/audits/ui/YYYY-MM-DD-ui-analysis${SAFE_TARGET:+-$SAFE_TARGET}.md`

   Report format:
   ```
   # UI Analysis — YYYY-MM-DD

   ## Quick Fix Reference
   | File | Findings |
   |------|----------|
   | [file] | [U1-pw], [U2] |

   Commands: `fix-ui` (all) · `fix-ui <file>` · `fix-ui <ID>`

   ---

   ## UI Behavior      ← source: frontend-behavior
   [findings from frontend-behavior go here]
   ```

4. **After report** — if standalone mode:
   - Present findings
   - If any `[U-pw]` findings exist → ask "Run Playwright tests on [N] UI findings? (y/n)"
     If y → load ~/.config/opencode/skills/harness-init/agent-e2e.md
            pass: all [U-pw] findings with file:line and Test: criteria
     If n → done.
   - If no [U-pw] findings → "All findings are static-only."

5. **Print summary** to chat in chat language.

## Hard Rules

| Rule | Value |
|------|-------|
| TARGET scope | If set — only check files under TARGET path |
| Save dir | docs/audits/ui/ (create if not exists) |
| Report filename | YYYY-MM-DD-ui-analysis.md or YYYY-MM-DD-ui-analysis-[TARGET].md |
| No file modification | Read-only. Never modify source files. |
