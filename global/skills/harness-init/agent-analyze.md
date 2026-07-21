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
"Loaded: zoom-out ✓, context-canary ✓, codebase-health-check ✓, junior-to-senior ✓, code-review-and-quality ✓, security ✓, premortem ✓"

## Skill stack (load in this order, skip missing)
1. ~/.config/opencode/skills/zoom-out/SKILL.md
2. ~/.config/opencode/skills/context-canary/SKILL.md
3. ~/.config/opencode/skills/codebase-health-check/SKILL.md
4. ~/.config/opencode/skills/junior-to-senior/SKILL.md
5. ~/.config/opencode/skills/code-review-and-quality/SKILL.md
6. ~/.config/opencode/skills/security/SKILL.md
7. ~/.config/opencode/skills/premortem/SKILL.md

## Steps
1. Load all seven skills above — skip missing ones, do not stop
2. Run zoom-out → explain architecture in plain language
3. Run context-canary → check for context rot, degradation
4. Run codebase-health-check → system map, duplication, priorities
5. Run junior-to-senior → senior-level design/approach findings
6. Run code-review-and-quality → multi-axis code review
7. Run security → find auth, API, secrets vulnerabilities
8. Run premortem → what could go wrong, top 5 risks
9. Compile results into one report
10. Save report to docs/audits/YYYY-MM-DD-analysis.md
11. Print summary to chat

**Quality gate:** every skill run must produce at least 5 concrete findings
with specific code examples (file + line). Generic statements like
«improve code quality» are not allowed — each finding names the exact file,
line, and what a senior would change. If fewer than 5 findings are available,
note «less than 5 findings available» and explain why.

## Output format
```
## Project Analysis — [date]

### Architecture
[zoom-out findings]

### Context Check
[context-canary — context rot, degradation signs]

### Health
[codebase-health-check — system map, duplication, priorities]

### Senior Review
[junior-to-senior — design altitude, senior-level findings]

### Quality
[code-review-and-quality — correctness, readability, architecture, security, perf]

### Security
[security findings — critical first]

### Risks
[premortem — top 5 risks]

### Recommended next steps
[prioritized list]
```

## Hard rules
- NEVER modify source files
- NEVER create docs/ structure — only write to docs/audits/
- If docs/audits/ doesn't exist — create it first
- Always save the report, don't just print to chat
