# Skills Cheatsheet

## Always loaded on session start

| Skill | Triggers | When to use |
|-------|----------|-------------|
| `using-agent-skills` | Meta-skill — auto-loads at every session start | After `Start` command |
| `harness-init` | First project setup, `make init` | Initialize new or existing project with docs |
| `session-start` | After global using-agent-skills | Stack-specific daily session init |

## Planning & Design

| Skill | Triggers | When to use |
|-------|----------|-------------|
| `brainstorming` | New feature, unclear requirements | Before any code — ask questions first |
| `grill-with-docs` | New feature, want docs updated | Stress-test plan + update CONTEXT.md |
| `spec-driven-development` | "spec", "requirements" | Write spec before implementation |
| `incremental-implementation` | Large feature, multi-file change | Implement step by step, small commits |
| `planning-and-task-breakdown` | "break down", "where to start" | Split work into ordered tasks |
| `writing-plans` | Multi-step task with file paths | 2-5 minute task breakdown |
| `premortem` | "premortem this", "what could kill this" | Stress-test a plan or decision |

## Development

| Skill | Triggers | When to use |
|-------|----------|-------------|
| `frontend-ui-engineering` | UI component, page, layout | Build production-quality interfaces |
| `api-and-interface-design` | API endpoint, module boundary | Design stable interfaces |
| `vue` | `.vue` files, composables | Vue 3 Composition API patterns |
| `tailwind-design-system` | Styles, design tokens | Systematic Tailwind usage |
| `nuxt` | Nuxt app, server routes | Nuxt patterns, SSR, auto-imports |
| `nuxt-ui` | UI components with @nuxt/ui | Use Nuxt UI components |
| `code-reviewer` | Before "done", "ready" | Check work against checklist |

## Debugging & Quality

| Skill | Triggers | When to use |
|-------|----------|-------------|
| `diagnose` | Bug, error, "not working" | Systematic debug cycle |
| `debugging-and-error-recovery` | Unexpected error, build fails | Root-cause analysis |
| `systematic-debugging` | Hard bug, regression | 8-step debug loop |
| `code-review-and-quality` | "review this code" | Multi-axis quality review |
| `verification-before-completion` | "done", "ready" (before commit) | Verify before claiming done |

## Testing

| Skill | Triggers | When to use |
|-------|----------|-------------|
| `test-driven-development` | "write tests", "TDD" | Red-green-refactor |
| `tdd` | "write tests", "TDD" | Red-green-refactor (alternative) |
| `browser-testing-with-devtools` | Debug in browser | Console, network, DOM inspection |

## Security & Infrastructure

| Skill | Triggers | When to use |
|-------|----------|-------------|
| `security` | Auth, login, token, .env, deploy | Security audit for any change |
| `security-and-hardening` | User input, auth, data storage | Harden against vulnerabilities |
| `docker-expert` | Docker, compose, container | Docker optimization and debugging |
| `ci-cd-and-automation` | Pipeline, GitHub Actions, deploy | Setup build and deploy pipelines |
| `shipping-and-launch` | Deploy to production | Pre-launch checklist |

## Git & Docs

| Skill | Triggers | When to use |
|-------|----------|-------------|
| `git-workflow-and-versioning` | Commit, branch, merge, PR | Git workflow patterns |
| `documentation-and-adrs` | "document", ADR, CONTEXT.md | Record architecture decisions |
| `handoff` | "new session", context limit | Pack context for fresh session |
| `zoom-out` | "how does this fit" | Broader system perspective |

## Performance & Architecture

| Skill | Triggers | When to use |
|-------|----------|-------------|
| `performance-optimization` | Slow, bottleneck, optimize | Find and fix perf issues |
| `code-simplification` | Complex code, unclear logic | Simplify without changing behavior |
| `improve-codebase-architecture` | Refactor, DRY, clean up | Find architectural improvements |
| `codebase-health-check` | "assess codebase", "health" | Full codebase analysis |
| `doubt-driven-development` | Critical change, security-sensitive | Adversarial review before acting |
