# 04 — Phased Plan

**Goal:** Sequence the extraction work into phases where each phase is independently committable and leaves the app working after every step.

---

## Phase structure

### Phase 1: Cross-cutting utilities
**Constraint:** Zero coupling risk. These extractions cannot break anything.
**Characteristic:** Pure functions with no imports, no reactive state, no side effects.
**Rule:** Every step in Phase 1 must be completable in under 10 minutes. If it takes longer, it's not Phase 1.

Typical Phase 1 items:
- Date/string/number utility functions extracted to `utils/`
- Dead code removal (commented blocks, unused vars, stale console.log)
- Fixing cases where a utility already exists but callers aren't importing it

**After Phase 1:** All files are the same size minus the duplicated utility blocks. No behaviour has changed.

---

### Phase 2: UI interaction patterns
**Constraint:** Reactive state but no business logic. The composable's interface must be stable before callers are updated.
**Characteristic:** Returns refs + handlers. No API calls. No domain knowledge.
**Rule:** Write the composable first, verify its interface, then migrate callers one by one. Each migrated caller is a separate commit.

Typical Phase 2 items:
- `useSlider(options)` — scroll state, touch handlers, offset computation
- `useModal()` — open/close, confirm/cancel pattern
- `useTabSwitch()` — active tab, switch handler
- Shared UI components (`ActionBlockedModal`, `ExpandableList`)

**After Phase 2:** The UI interaction logic is centralised. Page files are shorter but their business logic is unchanged.

---

### Phase 3: Business logic composables
**Constraint:** These touch API calls and domain state. Test each one in isolation before migrating callers.
**Characteristic:** May own reactive state. Makes API requests. Knows domain terms (participant, cook queue, deduction, balance).
**Rule:** Write the composable, verify it works in a scratch call, then replace one caller at a time. Do not migrate multiple callers in the same commit.

Typical Phase 3 items:
- `useDeduction()` — cost splitting, balance updates
- `useRecipeServings()` — scaling logic, save-back
- `useShoppingListCleanup()` — delete related items on cancel/complete
- Extending existing composables with new methods

**N+1 fixes belong in Phase 3**, not Phase 2, because they change the number and sequencing of API calls — a behaviour change even if the end result is the same.

**After Phase 3:** Page files are significantly shorter. Business logic is testable in isolation. N+1 queries are eliminated.

---

### Phase 4: Optional polish
**Constraint:** Only do these if a second caller emerges or the IHK presentation needs it.
**Rule:** Do not implement Phase 4 items speculatively.

Typical Phase 4 items:
- Composables extracted for a single caller that a new feature will reuse
- Template decomposition that requires rewriting the template structure
- Performance optimisations beyond N+1 fixes

---

## Plan document format

Produce a plan with this shape:

```markdown
## Refactoring Plan — [Project Name]
Generated: [date]
Scope: [files analysed]

### Phase 1: Cross-cutting utilities (~X min total)
- [ ] Step 1: [what] — [why] — [estimated lines saved]
- [ ] Step 2: ...

### Phase 2: UI patterns (~X min total)
- [ ] Step 3: [what] — [new file: composables/useXxx.ts] — [callers: A.vue, B.vue]

### Phase 3: Business logic (~X min total)  
- [ ] Step 4: [what] — [risk: medium — test after each caller migration]

### Phase 4: Deferred
- Step N: [what] — [waiting for: second caller / new feature / post-IHK]

### Target line counts after all phases
| File | Current | After Phase 1 | After Phase 3 | Target |
|------|---------|---------------|----------------|--------|
| cook.vue | 1202 | 1150 | 900 | ~800 |
```

---

## Commit strategy

Each step in the plan = one commit. Commit message format:
```
refactor(scope): [what was extracted] → [new location]

Examples:
refactor(utils): extract formatDateISO to utils/dates.ts (5 callers)
refactor(composables): add useSlider — replaces 4 independent implementations  
refactor(cook): migrate confirmDeduction to useDeduction composable
```

Never mix extractions across phases in one commit. If Phase 1 and Phase 2 items are both small, still commit separately — it makes bisect and rollback trivial.

---

## Completion check per step

Before marking a step done:
1. ✅ New module created with the extracted code
2. ✅ All callers updated to import from new location
3. ✅ Old inline code removed (no copy left behind)
4. ✅ App runs and the affected feature works in browser
5. ✅ No TypeScript errors (`tsc --noEmit` or equivalent)
6. ✅ Committed
