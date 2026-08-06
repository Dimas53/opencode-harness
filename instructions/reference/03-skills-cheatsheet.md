# Skills Cheatsheet

**Source:** All skills vendored in `global/skills/` — no external install needed.

## Core — always in use

| Skill | When to tell the agent |
|---|---|
| `using-agent-skills` | Meta-skill — auto-loads at every session start |
| `startup` | Full startup ritual with explanations — load if inline steps fail |
| `session-end` | Session end protocol — triggered on commit/push/"end session" |
| `dod` | Definition of Done checklist — runs before every commit |
| `frontend` | CSS/Layout rules + Design System — for UI/frontend work |
| `documentation` | Documentation session — triggered by docs lag or phase complete |
| `brainstorming` | Before a new feature — ask questions first, code after |
| `grill-with-docs` | Before a new feature — stress-test plan, update CONTEXT.md |
| `grill-me` | Stress-test an idea or plan — interrogation without doc writing |
| `interview-me` | Requirements are fuzzy — extract what the user actually needs |
| `incremental-implementation` | Implement step by step, small iterations |
| `planning-and-task-breakdown` | Break task into ordered steps before starting |
| `writing-plans` | Break task into 2-5 minute steps with exact file paths |
| `handoff` | Session is long — pack context for a fresh session |
| `diagnose` | Something is broken — run diagnostic cycle |
| `nuxt` | Working with Nuxt — apply Nuxt patterns |
| `nuxt-ui` | Use Nuxt UI components, don't build custom ones |
| `vue` | Apply Vue 3 / script setup / composables patterns |

---

## Architecture & Documentation

| Skill | When to tell the agent |
|---|---|
| `zoom-out` | Explain this code in context of the whole system |
| `improve-codebase-architecture` | Find architectural improvements |
| `spec-driven-development` | Write spec first, code after |
| `documentation-and-adrs` | Document architecture decisions — ADR, CONTEXT.md, specs |
| `source-driven-development` | Check official docs before implementing |
| `to-prd` | Turn our conversation into a PRD |
| `to-issues` | Break PRD into individual issues |
| `codebase-design` | Vocabulary for deep module design — interface, seam, depth, adapter. Before creating a new module |
| `domain-modeling` | Refine domain model: clarify terms, create ADR, update CONTEXT.md. Before complex architecture decisions |
| `research` | Investigate from primary sources (docs, API, specs) via background agent. Don't start code without research |
| `wayfinder` | Task exceeds one session — break into decision tickets on issue tracker. For multi-session epics |
| `setup-ts-deep-modules` | Set up dependency-cruiser and deep modules (entry points, subfolders private). For new or growing Nuxt 4 monorepo |
| `resolving-merge-conflicts` | Merge/rebase conflict — resolve systematically: understand each change's intent, preserve where possible |

---

## Code Quality

| Skill | When to tell the agent |
|---|---|
| `code-reviewer` | Check your work against checklist before "done" (TS, Vue, Directus, design) |
| `verification-before-completion` | Verify everything works before saying "done" |
| `tdd` | Write failing test first, then fix |
| `test-driven-development` | Addy Osmani variant of TDD |
| `code-review-and-quality` | Review this code across all quality axes |
| `debugging-and-error-recovery` | Debug systematically: reproduce → minimise → fix (supersedes `systematic-debugging`, M3) |
| `doubt-driven-development` | Adversarial review before critical changes (prod, security, irreversible) |
| `browser-testing-with-devtools` | Debug/test in browser — console, network, DOM, screenshots via Chrome DevTools |

---

## Stack & Tools

| Skill | When to tell the agent |
|---|---|
| `tailwind-design-system` | Use Tailwind systematically, design tokens |
| `api-and-interface-design` | Design API by the rules |
| `git-workflow-and-versioning` | Apply git workflow patterns |
| `security` | Security check — auth, secrets, API, infra |
| `security-and-hardening` | Harden against vulnerabilities |
| `make-interfaces-feel-better` | Polish UI — typography, shadows, rounding, micro-animations |
| `performance-optimization` | Find bottlenecks, optimize |
| `caveman` | Token saving mode — respond briefly |
| `frontend-ui-engineering` | UI task — apply frontend patterns |
| `codebase-health-check` | Codebase health analysis: system map, duplicate detection, prioritization, refactoring plan |

---

## Rare but useful

| Skill | When to tell the agent |
|---|---|
| `codebase-health-check` | Assess codebase health, find messy/duplicate code, plan refactoring |
| `junior-to-senior` | Review and improve code quality — make it better, more maintainable |
| `context-canary` | Detect context rot/degradation, install canary signal for long sessions |
| `fuck-slop` | De-slop pass — remove AI writing artifacts, polish text |
| `interface-kit` | Design accessible, performant UIs with animation and spatial principles |
| `last-20-percent` | Finish the last 20% — polish, final details, experiential layer |
| `loop-factory` | Run a spec-driven agent loop with inbox → active → archive workflow |
| `dispatching-parallel-agents` | 2+ independent tasks — run them in parallel |
| `executing-plans` | Have a ready plan — execute with checkpoints |
| `archify` | Architecture diagrams — workflow, sequence, data-flow, lifecycle, export PNG/SVG |
| `docker-expert` | Docker / docker-compose issues |
| `premortem` | Stress-test a plan/release/decision — imagine it failed 6 months from now and explain why |

---

## Stack → Required Skills

Map your project stack to the skills the agent needs. At `new`-time the agent
reads this section, matches it against the interview stack, and checks each
skill folder with `ls ~/.config/opencode/skills/<name>`.

| Technology | Skill folder | Notes |
|---|---|---|---|
| Nuxt | `nuxt` | Vendored in harness |
| Nuxt UI | `nuxt-ui` | Vendored in harness |
| Vue | `vue` | Vendored in harness |
| Tailwind | `tailwind-design-system` | Vendored in harness |
| Docker | `docker-expert` | Vendored in harness |
| TDD / tests | `tdd` | Vendored in harness |
| TypeScript | covered by `tdd` + `test-driven-development` (no standalone skill) | — |
