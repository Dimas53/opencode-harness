# frontend-behavior — Static UI Analysis

> Analyses frontend code for UI behavior problems: forms, buttons, navigation,
> states, modals, accessibility, auth. Static analysis only — no browser needed.
> Called from agent-analyze.md (analysis mode) or standalone via `ui` shortcut.

## Modes

This skill has two modes. The caller determines which mode applies:

- **Analysis mode** (called from agent-analyze.md): run checklist, output findings, stop.
- **Standalone mode** (called from `ui <path>` shortcut): run checklist, output findings,
  then ask about Playwright tests (see After Analysis section below).

## Input

- TARGET (optional) — if set, scope analysis to this file/directory only.
- If TARGET is empty — scan full project frontend.

## Skip check

If TARGET is empty:
  ```bash
  ls pages/ components/ layouts/ app.vue 2>/dev/null | head -1
  ```
  If no frontend files found — print "SKIP: No frontend files found (pages/, components/, layouts/, app.vue)" and exit immediately.

If TARGET is set — skip the skip check (user explicitly asked to analyze a file).

## Analysis logic

For each category below:
1. Find all elements of that type in the code (forms, buttons, navigations, etc.)
2. If no elements found — skip category entirely
3. For each element found — run all checklist items for that category
4. Exception: if element connects to an API (form submit, fetch in onMounted),
   ALWAYS check error/loading/empty state — even if they look missing.
   Missing state = finding.

## Checklist

### Forms and Inputs

For each form element found (search: `<form`, `useForm`, `vee-validate`, `zod`, `ref` with submit):

- **Validation:** Client-side validation exists (required, pattern, minlength, zod schema, vee-validate rules)
  If missing → **[U1]**
- **Error display:** Validation or API error shown to user (not just console.log)
  If error response ignored → **[U1-pw]**
- **Submit disabled:** Submit button has `:disabled` when form invalid or loading
  If no disabled binding → **[U1-pw]**
- **Form reset:** Form clears or redirects after successful submit
  If neither reset nor redirect → **[U1]**
- **Labels:** Every `<input>`/`<select>`/`<textarea>` has a `<label>` (not just placeholder)
  If placeholder-only → **[U1]**

### Buttons

For each button with a side effect (search: `@click` with API call, delete, remove, save, submit):

- **Loading state:** Button text/content changes during request (spinner, "Saving...")
  If button text stays same during loading → **[U1-pw]**
- **Double-click guard:** Button disabled while request in progress
  If no `:disabled="loading"` → **[U1]**
- **Destructive confirmation:** Delete/remove action has confirmation dialog or undo
  If delete fires immediately → **[U1-pw]**

### Navigation

- **Broken links:** Router-link `to` paths corresponding to existing route files
  If `to="/unknown"` and no matching route → **[U1]**
- **Active state:** Navbar item highlights for current route
  If nuxt-link without active class → **[U1]**
- **Auth guard:** Protected pages check auth before render
  If page has sensitive data but no `useAuth()` or middleware → **[U1-pw]**

### Component States

For each component that loads data via API (search: `useFetch`, `$fetch`, `fetch()`, `onMounted` + API call):

- **Loading state:** Template shows spinner/skeleton/placeholder while data loads
  If no conditional `loading` in template → **[U1-pw]**
- **Empty state:** User sees meaningful message when list is empty
  If no `v-if="items.length === 0"` → **[U1-pw]**
- **Error state:** User sees error message when request fails
  If no `v-if="error"` → **[U1-pw]**

### Modals and Dialogs

- **Escape close:** Modal closes on Escape key
  If no `@keydown.escape` → **[U1]**
- **Outside click:** Modal closes on click outside content area
  If no backdrop click handler → **[U1]**
- **Scroll lock:** Body scroll blocked while modal is open
  If no `overflow: hidden` on body → **[U1]**

### Dropdowns and Selects

- **Close on select:** Dropdown closes after selecting an option
  If `open` stays `true` after select → **[U1]**
- **Selection display:** Currently selected value visible in trigger
  If button shows placeholder text after selection → **[U1]**

### Tables and Lists

- **Live update:** List refreshes after CREATE/UPDATE/DELETE without page reload
  If API call returns 200 but list doesn't re-render → **[U1-pw]**
- **Pagination:** Pagination or infinite scroll for large datasets
  If all items fetched at once without limit → **[U1]**

### Accessibility (basic)

- **Image alt:** Every `<img>` has non-empty `alt` attribute
  If `<img src="..." >` without alt → **[U1]**
- **Icon labels:** Icon-only buttons/links have `aria-label`
  If `<button><Icon/></button>` without aria-label → **[U1]**

### Authentication

- **Login redirect:** Unauthenticated user redirected to /login
  If no middleware/guard on protected routes → **[U1-pw]**
- **Dashboard redirect:** Already-authenticated user on /login sent to /
  If login page loads without checking existing session → **[U1-pw]**
- **Logout cleanup:** Token/session data cleared on logout
  If `clear()` or `removeItem()` not called → **[U1]**

## Finding output format

```
**[U<N>] Title** — `file:line`
Short description of what is missing and why it matters.

**[U<N>-pw] Title** — `file:line`
Description. Test: <step-by-step Playwright acceptance criteria>
```

- `[U1]`, `[U2]` — static only, no Playwright test needed
- `[U1-pw]`, `[U2-pw]` — Playwright-testable, includes `Test:` line
- Number sequentially per finding type (U1, U2, U3...)
- Always include file:line when possible

## After Analysis (standalone mode only)

If this skill was called in standalone mode (not from agent-analyze.md):

1. Present all findings.
2. If any findings with `[U-pw]` suffix exist:
   → ask "Run Playwright tests on [N] UI findings? (y/n)"
   If y → load ~/.config/opencode/skills/harness-init/agent-e2e.md
          pass: all [U-pw] findings with file:line and Test: criteria
   If n → done.
3. If no [U-pw] findings:
   → "All findings are static-only. No Playwright tests needed."

## Hard Rules

| Rule | Value |
|------|-------|
| Skip condition | No .vue/.jsx/.tsx in project → skip entirely |
| TARGET scope | If set — only check files under TARGET path |
| No browser | Static analysis only — never launch Playwright here |
| Finding prefix | `[U<N>]` for static, `[U<N>-pw]` for e2e-testable |
| No file modification | Read-only. Never create or edit files. |
