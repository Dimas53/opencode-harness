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
"Loaded: codebase-health-check ✓, zoom-out ✓, security — not found (skipped), premortem ✓"

## Skill stack (load in this order, skip missing)
1. ~/.config/opencode/skills/codebase-health-check/SKILL.md
2. ~/.config/opencode/skills/zoom-out/SKILL.md
3. ~/.config/opencode/skills/security/SKILL.md
4. ~/.config/opencode/skills/premortem/SKILL.md

## Steps
1. Load all four skills above — skip missing ones, do not stop
2. Run codebase-health-check → system map, duplication, priorities
3. Run zoom-out → explain architecture in plain language
4. Run security → find auth, API, secrets vulnerabilities
5. Run premortem → what could go wrong, top 5 risks
6. Compile results into one report
7. Save report to docs/audits/YYYY-MM-DD-analysis.md
8. Print summary to chat

## Output format
```
## Project Analysis — [date]

### Architecture
[zoom-out findings]

### Health
[codebase-health-check findings — top issues]

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
