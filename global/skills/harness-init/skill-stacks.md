# Skill Stacks — Orchestration Scenarios

Ready-made skill combinations for typical scenarios.
Each agent-skill defines its own internal skill stack — this file is for reference.

---

## new-project

Trigger: `make init PROJECT=/path`

Delegated to: `~/.config/opencode/skills/harness-init/agent-new-project.md`

Internal stack (defined in agent-new-project.md):
1. interview-me — Q0-Q9 interview
2. brainstorming — explore unknowns, surface assumptions
3. planning-and-task-breakdown — structure phases and tasks
4. spec-driven-development — write phase-1 spec

---

## existing-project

Trigger: `make init-existing PROJECT=/path`

Delegated to: `~/.config/opencode/skills/harness-init/agent-init-existing.md`

Internal stack (defined in agent-init-existing.md):
1. agent-analyze — map the system first
2. grill-with-docs — fill gaps agent couldn't detect
3. planning-and-task-breakdown — structure the work

---

## analyze-only

Trigger: `make analyze PROJECT=/path` or user says "analyze" / "audit"

Delegated to: `~/.config/opencode/skills/harness-init/agent-analyze.md`

Internal stack (defined in agent-analyze.md):
1. codebase-health-check — system map, duplication, priorities
2. zoom-out — explain architecture in plain language
3. security — auth, API, secrets vulnerabilities
4. premortem — top 5 risks
Output: docs/audits/YYYY-MM-DD-analysis.md

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
