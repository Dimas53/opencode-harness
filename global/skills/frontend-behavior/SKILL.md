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
4. API detection — a component is considered API-connected if it uses any of:
   `useFetch`, `$fetch`, `fetch()`, `useAsyncData`, `useLazyAsyncData`,
   store actions (Pinia/Vuex), or has `ref()` + `onMounted()` together.
   Also flag any component that references an `api/` or `/api/` path.
   If API-connected → ALWAYS check error/loading/empty state.
   Missing state = finding.

**Numbering rule (read this BEFORE running the checklist):**
- Each checklist item is marked as either `→ static` or `→ e2e`.
- When enumerating findings, number them sequentially: U1, U2, U3...
- For `→ e2e` items → output with `-pw` suffix: `[U1-pw]`, `[U2-pw]`
- For `→ static` items → output without suffix: `[U1]`, `[U2]`
- Always include file:line when possible.
- Each `[U-pw]` finding MUST include a `Test:` line with step-by-step Playwright criteria.
- Never combine findings. If one element has multiple failed checklist items (e.g. a button missing both disabled state AND loading state) — each failed item is a SEPARATE [U<N>], even if same file:line.
- Before writing the report — scan every file under scope (components/, pages/, layouts/) and print: "Scanned: file1.vue ✓, file2.vue ✓, ..." for ALL files, not just ones with findings. If a file exists in scope but is missing from this list, it's a violation.

## Checklist

### Forms and Inputs

For each form element found (search: `<form`, `useForm`, `vee-validate`, `zod`, `ref` with submit):

- **Validation:** Client-side validation exists (required, pattern, minlength, zod schema, vee-validate rules)
  If missing → static
- **Error display:** Validation or API error shown to user (not just console.log)
  If error response ignored → e2e
- **Submit disabled:** Submit button has `:disabled` when form invalid or loading
  If no disabled binding → e2e
- **Form reset:** Form clears or redirects after successful submit
  If neither reset nor redirect → static
- **Labels:** Every `<input>`/`<select>`/`<textarea>` has a `<label>` (not just placeholder)
  If placeholder-only → static

### Buttons

For each button with a side effect (search: `@click` with API call, delete, remove, save, submit):

- **Loading state:** Button text/content changes during request (spinner, "Saving...")
  If button text stays same during loading → e2e
- **Double-click guard:** Button disabled while request in progress
  If no `:disabled="loading"` → static
- **Destructive confirmation:** Delete/remove action has confirmation dialog or undo
  If delete fires immediately → e2e

### Navigation

- **Broken links:** Router-link `to` paths corresponding to existing route files
  If `to="/unknown"` and no matching route → static
- **Active state:** Navbar item highlights for current route
  If nuxt-link without active class → static
- **Auth guard:** Protected pages check auth before render
  If page has sensitive data but no `useAuth()` or middleware → e2e

### Component States

For each component that loads data via API (search: `useFetch`, `$fetch`, `fetch()`, `useAsyncData`, `useLazyAsyncData`, `onMounted` + API call, api/ in any fetch, store action):

- **Loading state:** Template shows spinner/skeleton/placeholder while data loads
  If no conditional `loading` in template → e2e
- **Empty state:** User sees meaningful message when list is empty
  If no `v-if="items.length === 0"` → e2e
- **Error state:** User sees error message when request fails
  If no `v-if="error"` → e2e

### Modals and Dialogs

Search for components matching any of:
- Named `<Modal>`/`<Dialog>`/`<Drawer>` components
- `<transition>` wrapping a `v-show`/`v-if` toggle with fixed/absolute positioning + high z-index
- Common overlay/dropdown classes: `fixed`, `overlay`, `backdrop`, `menu-overlay`

All matched elements are checked against the same criteria below.

- **Escape close:** Modal closes on Escape key
  If no `@keydown.escape` → static
- **Outside click:** Modal closes on click outside content area
  If no backdrop click handler → static
- **Scroll lock:** Body scroll blocked while modal is open
  If no `overflow: hidden` on body → static

### Dropdowns and Selects

- **Close on select:** Dropdown closes after selecting an option
  If `open` stays `true` after select → static
- **Selection display:** Currently selected value visible in trigger
  If button shows placeholder text after selection → static

### Tables and Lists

- **Live update:** List refreshes after CREATE/UPDATE/DELETE without page reload
  If API call returns 200 but list doesn't re-render → e2e
- **Pagination:** Pagination or infinite scroll for large datasets
  If all items fetched at once without limit → static

### Accessibility (basic)

- **Image alt:** Every `<img>` has non-empty `alt` attribute
  If `<img src="..." >` without alt → static
- **Icon labels:** Icon-only buttons/links have `aria-label`
  If `<button><Icon/></button>` without aria-label → static

### Authentication

- **Login redirect:** Unauthenticated user redirected to /login
  If no middleware/guard on protected routes → e2e
- **Dashboard redirect:** Already-authenticated user on /login sent to /
  If login page loads without checking existing session → e2e
- **Logout cleanup:** Token/session data cleared on logout
  If `clear()` or `removeItem()` not called → static

## Finding output format

```
**[U<N>] Title** — `file:line`
Short description of what is missing and why it matters.

**[U<N>-pw] Title** — `file:line`
Description. Test: <step-by-step Playwright acceptance criteria>
```

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
