# Skills Inventory

Generated: 2026-07-06
Machine: DSAITO's MacBook

---

## 1. Complete Skill Table

**How this list is kept honest:** every directory under `global/skills/`
must appear here, and every row here must exist on disk —
`scripts/check-docs-refs.sh` enforces both directions and fails CI otherwise
(T-I6). It drifted twice before that check existed: 15 skills were missing
and one phantom row survived a hand fix. Do not add a hardcoded total; the
count belongs to `ls`, not to prose.

### 1a. Skills shipped by the harness (`global/skills/`)

Mirrored to `~/.config/opencode/skills/` on every commit that touches
`global/`. `vendored` = brought in from an external skill collection and
kept as-is; `custom (harness)` = written for this harness, and the ones the
protocol itself depends on.

| Skill | Origin | Notes |
|---|---|---|
| `api-and-interface-design` | `vendored` | mirrored to `~/.config/opencode/skills/api-and-interface-design/` |
| `archify` | `vendored` | mirrored to `~/.config/opencode/skills/archify/` |
| `brainstorming` | `vendored` | mirrored to `~/.config/opencode/skills/brainstorming/` |
| `browser-testing-with-devtools` | `vendored` | mirrored to `~/.config/opencode/skills/browser-testing-with-devtools/` |
| `caveman` | `vendored` | mirrored to `~/.config/opencode/skills/caveman/` |
| `ci-cd-and-automation` | `vendored` | mirrored to `~/.config/opencode/skills/ci-cd-and-automation/` |
| `code-review-and-quality` | `vendored` | mirrored to `~/.config/opencode/skills/code-review-and-quality/` |
| `code-reviewer` | `custom (harness)` | harness-authored |
| `code-simplification` | `vendored` | mirrored to `~/.config/opencode/skills/code-simplification/` |
| `codebase-design` | `vendored` | mirrored to `~/.config/opencode/skills/codebase-design/` |
| `codebase-health-check` | `custom (harness)` | origin unclear — see section 2 |
| `context-canary` | `vendored` | mirrored to `~/.config/opencode/skills/context-canary/` |
| `context-engineering` | `vendored` | mirrored to `~/.config/opencode/skills/context-engineering/` |
| `debugging-and-error-recovery` | `vendored` | mirrored to `~/.config/opencode/skills/debugging-and-error-recovery/` |
| `deprecation-and-migration` | `vendored` | mirrored to `~/.config/opencode/skills/deprecation-and-migration/` |
| `diagnose` | `vendored` | mirrored to `~/.config/opencode/skills/diagnose/` |
| `dispatching-parallel-agents` | `vendored` | mirrored to `~/.config/opencode/skills/dispatching-parallel-agents/` |
| `docker-expert` | `vendored` | mirrored to `~/.config/opencode/skills/docker-expert/` |
| `documentation` | `custom (harness)` | protocol skill — docs session |
| `documentation-and-adrs` | `vendored` | mirrored to `~/.config/opencode/skills/documentation-and-adrs/` |
| `dod` | `custom (harness)` | protocol skill — Definition of Done |
| `domain-modeling` | `vendored` | mirrored to `~/.config/opencode/skills/domain-modeling/` |
| `doubt-driven-development` | `vendored` | mirrored to `~/.config/opencode/skills/doubt-driven-development/` |
| `executing-plans` | `vendored` | mirrored to `~/.config/opencode/skills/executing-plans/` |
| `frontend` | `custom (harness)` | harness-authored |
| `frontend-behavior` | `vendored` | mirrored to `~/.config/opencode/skills/frontend-behavior/` |
| `frontend-ui-engineering` | `vendored` | mirrored to `~/.config/opencode/skills/frontend-ui-engineering/` |
| `fuck-slop` | `vendored` | mirrored to `~/.config/opencode/skills/fuck-slop/` |
| `git-workflow-and-versioning` | `vendored` | mirrored to `~/.config/opencode/skills/git-workflow-and-versioning/` |
| `grill-me` | `vendored` | mirrored to `~/.config/opencode/skills/grill-me/` |
| `grill-with-docs` | `vendored` | mirrored to `~/.config/opencode/skills/grill-with-docs/` |
| `handoff` | `vendored` | mirrored to `~/.config/opencode/skills/handoff/` |
| `harness-init` | `custom (harness)` | agent protocols (new/adopt/analyze/fix/e2e) |
| `idea-refine` | `vendored` | mirrored to `~/.config/opencode/skills/idea-refine/` |
| `improve-codebase-architecture` | `vendored` | mirrored to `~/.config/opencode/skills/improve-codebase-architecture/` |
| `incremental-implementation` | `vendored` | mirrored to `~/.config/opencode/skills/incremental-implementation/` |
| `interface-kit` | `vendored` | mirrored to `~/.config/opencode/skills/interface-kit/` |
| `interview-me` | `vendored` | mirrored to `~/.config/opencode/skills/interview-me/` |
| `junior-to-senior` | `vendored` | mirrored to `~/.config/opencode/skills/junior-to-senior/` |
| `last-20-percent` | `vendored` | mirrored to `~/.config/opencode/skills/last-20-percent/` |
| `loop-factory` | `vendored` | mirrored to `~/.config/opencode/skills/loop-factory/` |
| `make-interfaces-feel-better` | `vendored` | mirrored to `~/.config/opencode/skills/make-interfaces-feel-better/` |
| `nuxt` | `vendored` | mirrored to `~/.config/opencode/skills/nuxt/` |
| `nuxt-ui` | `vendored` | mirrored to `~/.config/opencode/skills/nuxt-ui/` |
| `performance-optimization` | `vendored` | mirrored to `~/.config/opencode/skills/performance-optimization/` |
| `planning-and-task-breakdown` | `vendored` | mirrored to `~/.config/opencode/skills/planning-and-task-breakdown/` |
| `premortem` | `vendored` | mirrored to `~/.config/opencode/skills/premortem/` |
| `research` | `vendored` | mirrored to `~/.config/opencode/skills/research/` |
| `resolving-merge-conflicts` | `vendored` | mirrored to `~/.config/opencode/skills/resolving-merge-conflicts/` |
| `security` | `custom (harness)` | harness-authored (de-identified by T-B5) |
| `security-and-hardening` | `vendored` | mirrored to `~/.config/opencode/skills/security-and-hardening/` |
| `session-end` | `custom (harness)` | protocol skill — Session End |
| `setup-ts-deep-modules` | `vendored` | mirrored to `~/.config/opencode/skills/setup-ts-deep-modules/` |
| `shipping-and-launch` | `vendored` | mirrored to `~/.config/opencode/skills/shipping-and-launch/` |
| `source-driven-development` | `vendored` | mirrored to `~/.config/opencode/skills/source-driven-development/` |
| `spec-driven-development` | `vendored` | mirrored to `~/.config/opencode/skills/spec-driven-development/` |
| `startup` | `custom (harness)` | protocol skill — Session Start |
| `systematic-debugging` | `vendored` | mirrored to `~/.config/opencode/skills/systematic-debugging/` |
| `tailwind-design-system` | `vendored` | mirrored to `~/.config/opencode/skills/tailwind-design-system/` |
| `tdd` | `vendored` | mirrored to `~/.config/opencode/skills/tdd/` |
| `test-driven-development` | `vendored` | mirrored to `~/.config/opencode/skills/test-driven-development/` |
| `to-issues` | `vendored` | mirrored to `~/.config/opencode/skills/to-issues/` |
| `to-prd` | `vendored` | mirrored to `~/.config/opencode/skills/to-prd/` |
| `using-agent-skills` | `vendored` | mirrored to `~/.config/opencode/skills/using-agent-skills/` |
| `verification-before-completion` | `vendored` | mirrored to `~/.config/opencode/skills/verification-before-completion/` |
| `vue` | `vendored` | mirrored to `~/.config/opencode/skills/vue/` |
| `wayfinder` | `vendored` | mirrored to `~/.config/opencode/skills/wayfinder/` |
| `writing-plans` | `vendored` | mirrored to `~/.config/opencode/skills/writing-plans/` |
| `zoom-out` | `vendored` | mirrored to `~/.config/opencode/skills/zoom-out/` |

### 1b. Installed on demand (not in `global/skills/`)

The find-skills ecosystem installs these into a project's `.agents/skills/`
when asked. They are deliberately absent from `global/skills/`, so the
completeness check above skips them by allowlist.

| Skill | Location | Source |
|---|---|---|
| `find-skills` | `.agents/skills/` only | `vercel-labs/skills` |
| `prototype` | `.agents/skills/` only | `mattpocock/skills` |
| `setup-matt-pocock-skills` | `.agents/skills/` only | `mattpocock/skills` |
| `teach` | `.agents/skills/` only | `mattpocock/skills` |
| `triage` | `.agents/skills/` only | `mattpocock/skills` |
| `write-a-skill` | `.agents/skills/` only | `mattpocock/skills` |

---

## 2. Custom Skills — Must Copy Into Harness

These skills were written by hand for opencode-harness and live in
`opencode-harness/global/skills/`. The rest of section 1a came in from
external skill collections — historically the superpowers repository, though
that is no longer a blanket statement: the planning cluster was superseded
rather than re-vendored (B-DEC-1), and skills have been added from other
sources since.

| Skill | Files | Total size | Notes |
|---|---|---|---|
| `code-reviewer` | 1 file: `SKILL.md` (1.2K) | 4K | Review rules; stack-agnostic, English only (verified — no client literals, no Cyrillic) |
| `security` | 6 files: `SKILL.md` (3.1K), 5 sub-docs (40K total) | 60K | Multi-doc security checklist for Nuxt 4 + Directus 11 + PostgreSQL |
| `startup` | 1 file: `SKILL.md` (2.2K) | 4K | Session Start ritual with edge cases — step list lives in `global/AGENTS.md`, never counted here |
| `session-end` | 1 file: `SKILL.md` (2.1K) | 4K | Session end protocol with troubleshooting |
| `dod` | 1 file: `SKILL.md` (3.1K) | 4K | Definition of Done with per-step checklists |
| `frontend` | 1 file: `SKILL.md` (942B) | 2K | CSS/Layout + Design System rules |
| `documentation` | 1 file: `SKILL.md` (1.4K) | 2K | Documentation session triggers and script |

### codebase-health-check — Origin Unclear

`codebase-health-check` has:
- 6 files: `SKILL.md` (2.3K) + 5 sub-docs (22.7K total) = **40K total**
- No YAML frontmatter (unlike superpowers skills)
- No project-specific references (unlike custom skills)
- Not in `.agents/skills/`

**Recommendation:** Check if it's useful and either keep as custom or remove.

---

## 3. Install Commands for Fresh Setup

### By order of execution:
```bash
# 1. Install OpenCode (via npm)
npm install -g opencode-ai

# 2. Clone harness and run setup
git clone https://github.com/Dimas53/opencode-harness.git
cd opencode-harness
make setup
# This copies all skills from global/skills/ to ~/.config/opencode/skills/

# 3. Install find-skills ecosystem (installed on demand)
# Triggered by opening a project and running find-skills
# Sources: mattpocock/skills, antfu/skills, vercel-labs/skills
```

**Note:** All skills are vendored in `global/skills/`. No external plugin or skill download needed — `make setup` handles everything.

---

## 4. MCP Server Inventory (from opencode.jsonc)

| MCP Server | Purpose | Install command |
|---|---|---|
| `@modelcontextprotocol/server-filesystem` | Read/write project files | `npm install -g @modelcontextprotocol/server-filesystem` |
| `@modelcontextprotocol/server-git` | Git operations | `npm install -g @modelcontextprotocol/server-git` |
| `context7` | Live framework docs | Built-in to opencode |
| `sequential-thinking` | Complex reasoning | Built-in to opencode |
| `@playwright/mcp` | Browser automation / E2E tests | `npm install -g @playwright/mcp` + `npx playwright install` |
| `fetch` | External HTTP requests | Built-in to opencode |

---

## 5. Overlap Notes

- All harness skills are vendored in `global/skills/` and copied to `~/.config/opencode/skills/` during `make setup`
- `.agents/skills/` is maintained by the `find-skills` ecosystem — installed on-demand
- OpenCode looks at `.config/opencode/skills/` first
