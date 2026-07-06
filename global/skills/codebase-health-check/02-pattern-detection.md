# 02 — Pattern Detection

**Goal:** Find all code that appears in more than one place. Apply the deletion test to every candidate before recommending extraction.

---

## The Deletion Test

For every candidate pattern, ask:

> "If I delete all N copies of this and replace with one shared module, does the codebase get simpler?"

- **Strong signal:** N ≥ 3 callers, or the shared version would be materially simpler than all copies combined.
- **Moderate signal:** N = 2 callers, both would simplify noticeably.
- **Weak signal:** N = 2, but callers would need adaptation logic that offsets the savings.
- **No signal:** N = 1. Never extract for a single caller unless a second is imminent.

Record the deletion test result explicitly in your findings. Do not recommend extraction without it.

---

## Pattern types to look for

### Type 1: Pure utility duplication
Functions that are redefined verbatim in multiple files. No dependencies, no side effects.

Common examples:
- Date formatters: `formatDateISO`, `formatDateStr`, `parseISODate`, `MONTH_NAMES`
- String helpers: `formatUserName`, `truncate`, `capitalize`
- Number formatters: `formatCurrency`, `formatPercent`
- Type guards: `isNullish`, `parseJsonField`

**Extraction target:** `utils/` (auto-importable, zero coupling risk)

Detection:
```bash
# Find function definitions repeated across files
grep -rn "function formatDate" src/
grep -rn "const formatDate" src/
```

---

### Type 2: UI interaction patterns
Stateful logic that manages a piece of UI — no business logic, no API calls.

Common examples:
- Scroll/slider logic (offset, visible count, touch handlers)
- Toggle/expand/collapse state
- Modal open/close with confirm/cancel
- Tab switching
- Form validation state

**Extraction target:** `composables/useXxx.ts` (returns reactive state + handlers)

Detection: look for blocks of refs + methods that appear in multiple component `<script setup>` sections with the same shape.

---

### Type 3: Data-fetch + transform patterns
API call followed by the same mapping/transform.

Common examples:
- Fetch a list, then build a lookup map by ID
- Batch-fetch counts (likes, views) for a set of IDs
- Fetch user → format display name
- Fetch related record → set local ref

**Extraction target:** composable that owns the fetch + returns the derived state

Detection:
```bash
# Look for the same endpoint called in multiple files
grep -rn "/items/cook_queue" src/pages/
grep -rn "request.*get.*balances" src/
```

---

### Type 4: Business logic duplication
The same domain operation implemented twice.

Common examples:
- Deducting a balance (fetch current → patch delta → record transaction)
- Cancelling an entity (patch status + delete related records)
- Fork-on-copy pattern for owned resources
- Permission checks repeated in multiple components

**Extraction target:** composable with clear domain name (`useDeduction`, `useCancellation`)

This is the highest-value extraction type because errors here are domain errors, and fixing one copy leaves the other broken.

---

### Type 5: Template structure duplication
The same HTML/JSX structure repeated with minor variation in props or content.

Common examples:
- List + "show more" / "show all" toggle appearing in multiple pages
- Action-blocked modal with same layout but different message
- Status badge with same styling but different icon/color

**Extraction target:** shared component (`.vue`, `.jsx`, or equivalent)

---

## Findings table format

For each candidate:

| # | Pattern | Files | Copies | Lines each | Type | Deletion test | Risk |
|---|---------|-------|--------|------------|------|----------------|------|
| 1 | `formatDateISO` | cook.vue, kitchen.vue, finance.vue, index.vue | 4 | ~4 each | Pure utility | **Strong** — extract to utils/dates.ts | Low |
| 2 | Vertical slider | cook.vue, finance.vue ×2, recipe/[id].vue | 4 | 50–80 each | UI pattern | **Strong** — useSlider.ts | Medium (touch handlers) |
| 3 | `fetchParticipants` | cook.vue, recipe/[id].vue | 2 | ~15 each | Fetch+transform | **Moderate** — extend existing composable | Low |
| 4 | `confirmDeduction` + balance update | cook.vue | 1 | 92 lines | Business logic | **Weak** for extraction, **Strong** for N+1 fix | Medium |

---

## N+1 query detection

Separately from duplication, look for sequential loops over API calls:

```
// Bad: N round-trips
for (const participant of participants) {
  await request('post', '/items/transactions', ...)    // N calls
  const bal = await request('get', '/items/balances?filter[user]=...')  // N calls
  await request('patch', '/items/balances/' + bal.id, ...)  // N calls
}
```

These are high-value fixes even when the code isn't duplicated — they cause real latency in production.

Pattern to search for:
```bash
grep -n "await request" src/pages/cook.vue | head -30
# Look for awaits inside for/forEach loops
```

Correct pattern: batch the reads (filter `_in` for multiple IDs), then parallel-write with `Promise.all`.
