# Test Workflows

> Overview of all test-related agent skills: what they do, how they chain together,
> and what finding prefixes mean.

## Finding Prefix Reference

| Prefix | Source | What it means | Verify gate |
|--------|--------|---------------|-------------|
| [L] | `analyze-logic` | Uncovered business logic — code is correct, needs a test | UNIT_TEST_REDGREEN |
| [U] | `analyze-ui` | UI behavior issue — button, form, nav, modal, auth | Static or Playwright |
| [U-pw] | `analyze-ui` | UI issue requiring browser-level verification | Playwright |
| [C] | `analyze` | Security Critical — must fix before deploy | curl or UNIT_TEST_REDGREEN |
| [B] | `analyze` | Senior Review Blocker — architectural problem | curl or UNIT_TEST_REDGREEN |
| [H] | `analyze` | Security High or Senior Review Major | curl or grep |
| [M] | `analyze` | Security Medium or Senior Review Medium | grep |

## Workflow Chains

### 1. Coverage: analyze-logic → fix-logic

Finds business logic without tests, generates test cases, then writes them.

```
analyze-logic
  └─ finds pure functions, composables, server routes
  └─ checks existing test coverage
  └─ generates [L1], [L2]... with concrete test cases
  └─ saves to docs/audits/logic-YYYY-MM-DD.md

fix-logic
  └─ reads latest logic report
  └─ for each [L] finding: writes test, runs it (should pass), verifies
  └─ no source code modification — code is correct, just needs coverage
```

**Commands:**
- `analyze-logic` — full project scan
- `analyze-logic composables/` — scan specific directory or file
- `fix-logic` — fix all L-findings from latest report
- `fix-logic L1` — fix a specific finding by ID

**Supported test runners:** vitest, jest, pytest, phpunit, go test.
Runner is auto-detected from project files (package.json, pyproject.toml, composer.json, go.mod).
Installation requires user confirmation.

### 2. UI Behavior: analyze-ui → fix-ui

Finds UI problems (forms, buttons, navigation, states, accessibility) and fixes them.

```
analyze-ui
  └─ scans components for form validation, button states, loading/error/empty
  └─ checks modals, navigation guards, auth visibility
  └─ generates [U1], [U2]... findings
  └─ saves to docs/audits/ui-YYYY-MM-DD.md

fix-ui
  └─ reads latest UI report
  └─ static findings → fix and grep-verify
  └─ Playwright findings → write e2e test + verify via agent-e2e
```

**Commands:**
- `analyze-ui` — full UI scan
- `analyze-ui pages/Login.vue` — specific component
- `fix-ui` — fix all U-findings
- `fix-ui U1` — fix specific finding
- `fix-ui U2-pw` — fix + write Playwright test

### 3. Bug/Security: analyze → fix

Read-only audit that finds bugs, vulnerabilities, and architectural problems.

```
analyze
  └─ architecture review, code health, security audit, risk premortem
  └─ generates [C], [B], [H], [M] findings
  └─ saves to docs/audits/YYYY-MM-DD-analysis.md

fix
  └─ Phase 1: Critical + Blocker → red-green unit test cycle (test FAILS first, then fix, then PASS)
  └─ Phase 2: High + Major → fix + verify
  └─ Phase 3: Medium → fix + grep
```

**Commands:**
- `analyze` — full project audit
- `analyze server/api/` — specific path
- `fix` — fix all findings from latest report
- `fix C1` — fix specific finding by ID

## How It All Fits Together

```
analyze        → [C] [B] [H] [M]  →  fix        (bug fixing)
analyze-ui     → [U] [U-pw]       →  fix-ui     (UI behavior)
analyze-logic  → [L]              →  fix-logic  (test coverage)
```

Each chain follows the same pattern:
1. **analyze** — scans, finds problems, generates findings, saves report
2. **fix** — reads report, applies fixes, verifies each finding

`fix-logic` is coverage-only: code is correct, no source modification.
`fix` and `fix-ui` may modify source code to fix bugs or UI issues.
