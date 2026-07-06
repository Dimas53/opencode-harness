# 03 — Prioritisation

**Goal:** Stack-rank all extraction candidates so the agent works on the highest-value items first and doesn't waste cycles on low-leverage refactors.

---

## Scoring formula

```
Priority = (Impact × Frequency) ÷ Risk
```

### Impact (1–3)
How much does extracting this improve the codebase?

| Score | Meaning |
|-------|---------|
| 3 | Removes a source of bugs (business logic duplicated, N+1 queries) |
| 2 | Removes significant boilerplate, makes files meaningfully shorter |
| 1 | Cosmetic — reduces lines but doesn't change comprehension |

### Frequency (copies count)
- Use the actual number of copies found in Step 2
- Weight: number of callers that would simplify after extraction

### Risk (1–3)
How likely is this extraction to break something?

| Score | Meaning |
|-------|---------|
| 1 | Pure utility: no side effects, no reactive state, no template coupling |
| 2 | Stateful composable: reactive refs, lifecycle hooks, or touch/event handlers |
| 3 | Template-coupled: the template directly references the inline state (state machine, conditional rendering that spans script + template tightly) |

---

## Tier classification

After scoring, sort candidates into tiers:

**🔥 Trivial (do first, <10 min each)**
- Pure utility functions (Type 1) with 3+ copies
- Dead code removal (commented blocks, stale console.log)
- Auto-imports already exported from a util that files aren't using

**⚡ Easy (15–20 min each)**
- UI patterns (Type 2) that are fully self-contained
- Shared components for repeated template blocks
- Fetch+transform composables with low coupling

**🧩 Medium (20–30 min each)**
- Business logic composables (Type 4)
- Extending existing composables with new capabilities
- N+1 query fixes (require careful batch logic)

**🏗️ Hard (30+ min, plan carefully)**
- Large page decompositions (the file must be fully understood before splitting)
- State machine extraction (tight template coupling)
- Anything that changes the public interface of an existing composable

---

## Defer criteria

Do NOT extract when:

1. **Single caller today** — N=1. Even if the code looks extractable, wait for a second caller to emerge naturally. Premature extraction creates abstractions nobody asked for.

2. **Template-coupled state machine** — The logic and template are so intertwined that extracting the logic would require rewriting the template too. The complexity moves, not reduces.

3. **The target module is already deep** — A well-written 200-line composable that does one thing doesn't need to be split just because it could be. Depth is good.

4. **Planned for deletion** — If a file is going to be replaced by a new implementation, don't refactor it first.

---

## Priority table format

| Priority | Step | What | Type | Impact | Frequency | Risk | Score | Time |
|----------|------|------|------|--------|-----------|------|-------|------|
| 1 | `utils/dates.ts` — fix all auto-imports | Trivial | 2 | 5 copies | 1 | 10 | 5 min |
| 2 | `formatUserName` utility | Trivial | 2 | 13 copies | 1 | 26 | 10 min |
| 3 | `ActionBlockedModal.vue` component | Easy | 2 | 4 copies | 1 | 8 | 15 min |
| 4 | `useSlider.ts` | Easy | 3 | 4 copies | 2 | 6 | 20 min |
| 5 | `useDeduction.ts` + N+1 fix | Medium | 3 | 1 copy | 2 | 1.5 | 30 min |
| 6 | `useRecipeServings.ts` | Medium | 2 | 1 copy | 2 | 1 | 25 min |
| 7 | Extend `useParticipants` | Easy | 2 | 2 copies | 1 | 4 | 15 min |
| — | `useRecipeForm.ts` | Defer | — | 1 copy | — | — | — |

---

## Output: Numbered extraction list

After filling the table, produce a clean ordered list:

```
Phase 1 — Cross-cutting utilities (zero coupling risk, do first)
  1. Extract formatDateISO + MONTH_NAMES to utils/dates.ts (or fix missing auto-imports)
  2. Extract formatUserName to utils/strings.ts
  3. Remove dead code: index.vue:47-72, stale console.logs
  4. Extract ActionBlockedModal.vue

Phase 2 — UI patterns and composables
  5. useSlider.ts — replace 4 independent implementations
  6. Extend useParticipants.ts with getFullList()
  7. useCookQueueStatus() — shared startCooking / markReady

Phase 3 — Business logic
  8. useDeduction.ts — fix N+1 + extract from cook.vue
  9. useRecipeServings.ts
  10. useShoppingListCleanup.ts

Phase 4 — Optional / deferred
  11. useRecipeForm.ts — defer until AI Recipe page needs it
  12. useRecipeShare.ts — defer until second caller
```
