# Skill Stacks — Orchestration Scenarios

Ready-made skill combinations for typical scenarios.
Principle: reuse existing skills in the right order, don't write new ones.
harness-init reads this file to know which stack to load per scenario.

---

## new-project

Trigger: `make init PROJECT=/path` on empty directory

```
Order:
1. interview-me                ← Q0-Q9 interview
2. planning-and-task-breakdown ← structure the plan
3. doc-generator               ← generate all docs from templates
4. design-init                 ← generate design.md (if Q8=yes)
5. spec-writer                 ← generate specs/phase-1.md (if Q9=yes)
6. security                    ← flag any security concerns from interview
```

Skills to load at session start (after init):
→ Read project AGENTS.md "Stack Skills" section

---

## existing-project

Trigger: `make init-existing PROJECT=/path` on project with code

```
Order:
1. codebase-health-check     ← map the system first
2. grill-with-docs           ← fill gaps agent couldn't detect
3. doc-generator             ← generate or update docs
4. security                  ← check for existing vulnerabilities
```

---

## feature-development

Trigger: starting work on a new feature

```
Order:
1. grill-with-docs           ← clarify requirements, update CONTEXT.md
2. spec-driven-development   ← write spec before code
3. incremental-implementation ← build step by step
4. code-reviewer             ← self-review before "done"
5. security                  ← if feature touches auth/API/data
```

---

## debugging

Trigger: something is broken

```
Order:
1. diagnose                  ← systematic debug cycle
2. debugging-and-error-recovery ← reproduce → minimize → fix
3. verification-before-completion ← confirm fix works
```

---

## audit

Trigger: before release, or when codebase feels messy

```
Order:
1. codebase-health-check     ← map system, find duplication
2. security                  ← auth, secrets, API vulnerabilities
3. premortem                 ← what could go wrong
Output: save results to docs/audits/YYYY-MM-DD-audit.md
```

---

## onboarding-foreign-project

Trigger: joining an existing project you didn't write

```
Order:
1. codebase-health-check     ← understand the system
2. zoom-out                  ← explain code in system context
3. grill-with-docs           ← fill knowledge gaps
4. security                  ← find existing vulnerabilities
5. premortem                 ← assess risks before touching anything
Output: save findings to docs/audits/YYYY-MM-DD-onboarding.md
```

---

## docs-update

Trigger: docs fell behind code, or phase just completed

```
Order:
1. zoom-out                  ← get current state of the system
2. doc-generator             ← update changed docs
3. grill-with-docs           ← update CONTEXT.md with new patterns
```
