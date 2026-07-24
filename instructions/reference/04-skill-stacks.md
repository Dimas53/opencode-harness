# Skill Stacks — Orchestration Scenarios

Ready-made skill combinations for typical scenarios.
Each agent-skill defines its own internal skill stack — this file is for reference.

**Trigger types:**
- `new-project` / `adopt-project` / `analyze-only` — triggered via make commands
- `feature-development` / `debugging` / `audit` / `onboarding-foreign-project` / `docs-update` — manual reference stacks, load by telling the agent which scenario you're in

---

## new-project

Trigger: `make init PROJECT=/path`

Delegated to: `~/.config/opencode/skills/harness-init/agent-new-project.md`

Internal stack (defined in agent-new-project.md):
1. interview-me — Q0-Q9 interview
2. 4.4. Skill gap check — `ls ~/.config/opencode/skills/`, semantic match
   against stack, print ✅/❌ block with marketplace URLs.
   **P16**: found skills auto-written to AGENTS.md Stack Skills section;
   missing skills get placeholder with marketplace links.
3. brainstorming — explore unknowns, surface assumptions
4. planning-and-task-breakdown — structure phases and tasks
5. spec-driven-development — write phase-1 spec
Phase 2: formatted hand-off block with ━━━ frames, 📋🚀⚠️ sections,
conditional missing skills list, links to mcpmarket.com + skills.sh

### Phase 0
Before the interview, scaffold runs via `init-project.sh --no-open`.
**P19**: `docs/plan-main.md` is deleted if Q-1 had no spec file.

### Hard rules added
- **P13**: language acknowledgment line after Q0
- **P14**: explicit `end` block after hand-off
- **P17**: forbid creating .env — only .env.example
- `NEVER write multiple files in one turn` — one file = draft → confirm → write → next

### Templates updated
- `templates/HARNESS.md` **P15**: Product Contract and Decisions to Inherit now have detailed hints in comments
- `templates/PLAN.md` **P18**: comment at top explaining it's empty at new-time, filled during implementation sessions

---

## adopt-project

Trigger: `make init-adopt PROJECT=/path`

Delegated to: `~/.config/opencode/skills/harness-init/agent-adopt.md`

Internal stack (defined in agent-adopt.md):
1. agent-analyze — map the system first
2. grill-with-docs — fill gaps agent couldn't detect
3. planning-and-task-breakdown — structure the work

---

## analyze-only

Trigger: `make analyze PROJECT=/path` or user says "analyze" / "audit"

Delegated to: `~/.config/opencode/skills/harness-init/agent-analyze.md`

Internal stack (defined in agent-analyze.md):
1. zoom-out — explain architecture in plain language
2. codebase-health-check — system map, duplication, priorities
3. frontend-behavior — static UI analysis (forms, buttons, nav, states, auth)
4. junior-to-senior — senior-level design/approach findings
5. code-review-and-quality — multi-axis code review
6. security — auth, API, secrets vulnerabilities
7. premortem — top 5 risks
Output: docs/audits/YYYY-MM-DD-analysis.md

---

## ui-analysis

Trigger: user says "ui" / "ui <path>" — static UI analysis of frontend code.

Delegated to: `~/.config/opencode/skills/frontend-behavior/SKILL.md` (standalone mode)

Standalone mode: runs the same checklist as analyze but on one file/directory.
After analysis: asks "Run Playwright tests? (y/n)" and loads agent-e2e.md if yes.

---

## fix-findings

Trigger: user says "fix" / "fix <path>" / "fix <ID>" after an analysis report exists

Delegated to: `~/.config/opencode/skills/harness-init/agent-fix.md`

Sub-protocol: agent-e2e.md — Playwright verify gate (loaded when finding has U-pw prefix or path matches UI files).

Verify gate types:
- U-pw finding → PLAYWRIGHT (writes + runs Playwright test via agent-e2e.md)
- U finding → static (grep/check the fix exists)
- Path-based (vue/component file) → ask user, then PLAYWRIGHT or grep
- All other → bash command (grep, curl, pytest)

---

## feature-development

Trigger: starting work on a new feature

```
Order:
1. grill-with-docs           — clarify requirements, update CONTEXT.md
2. spec-driven-development   — write spec before code
3. incremental-implementation — build step by step
4. code-reviewer             — self-review before "done"
5. security                  — if feature touches auth/API/data
```

---

## debugging

Trigger: something is broken

```
Order:
1. diagnose                  — systematic debug cycle
2. debugging-and-error-recovery — reproduce → minimize → fix
3. verification-before-completion — confirm fix works
```

---

## audit

Trigger: before release, or when codebase feels messy

```
Order:
1. codebase-health-check     — map system, find duplication
2. security                  — auth, secrets, API vulnerabilities
3. premortem                 — what could go wrong
Output: save results to docs/audits/YYYY-MM-DD-audit.md
```

---

## onboarding-foreign-project

Trigger: joining an existing project you didn't write

```
Order:
1. codebase-health-check     — understand the system
2. zoom-out                  — explain code in system context
3. grill-with-docs           — fill knowledge gaps
4. security                  — find existing vulnerabilities
5. premortem                 — assess risks before touching anything
Output: save findings to docs/audits/YYYY-MM-DD-onboarding.md
```

---

## docs-update

Trigger: docs fell behind code, or phase just completed

```
Order:
1. zoom-out                  — get current state of the system
2. doc-generator             — update changed docs
3. grill-with-docs           — update CONTEXT.md with new patterns
```
