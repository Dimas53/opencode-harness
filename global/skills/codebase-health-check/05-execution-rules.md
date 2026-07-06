# 05 — Execution Rules

**Goal:** Rules for safely extracting code without breaking the working app. These rules apply regardless of project, stack, or phase.

---

## The cardinal rules

### Rule 1: One extraction per session
Do not extract multiple patterns in the same agent session unless they are trivially small (pure utility functions, <5 lines each). Larger extractions require verification between steps.

### Rule 2: Read before writing
Before creating a new composable or utility, always read:
- The file you are extracting from (full context)
- Any existing composable that the new one might extend or conflict with
- The existing `utils/` or `composables/` index (to avoid name collisions)

### Rule 3: No dead code left behind
After migrating all callers to the new module, the original inline code must be deleted. Never leave commented-out copies "just in case". The version control history is the backup.

### Rule 4: Verify in browser after every step
Do not move to the next step until you have confirmed (or the user has confirmed) that the affected feature still works. "It compiles" is not sufficient for UI features.

### Rule 5: Never rename and move in the same step
If a function needs to be renamed AND moved to a new file, do it in two commits:
1. Rename in place (callers break → fix callers → commit)
2. Move to new file (update imports → commit)

Doing both at once makes git diff unreadable and rollback harder.

---

## Extraction checklist

For each extraction:

**Before starting:**
- [ ] Read the source file fully — understand all the code that surrounds the block you're extracting
- [ ] Identify all callers (grep for the function name)
- [ ] Confirm no caller has a local override that differs from the others
- [ ] Check if a similar composable/util already exists

**Creating the new module:**
- [ ] New file goes in the correct layer (`utils/` for pure functions, `composables/` for stateful)
- [ ] Export the function/composable with the agreed name
- [ ] TypeScript types match what callers expect
- [ ] If Nuxt: composable uses `useState` for shared state, not module-level vars
- [ ] No circular imports (new module must not import from the files it's being extracted into)

**Migrating callers:**
- [ ] Update imports in caller 1 → verify app works → move to caller 2
- [ ] Do not update all callers at once if there are 3+
- [ ] Remove the inline copy from each caller as you go

**After all callers migrated:**
- [ ] Zero remaining inline copies of the extracted code (grep to confirm)
- [ ] TypeScript: no errors
- [ ] App: affected features work in browser
- [ ] Commit

---

## What not to do

**Don't extract to "make it testable someday"**
Extract when there's a concrete second caller or a concrete bug. "This would be easier to test if it were a composable" is not enough — it creates abstraction debt.

**Don't combine extraction with bug fixes**
If you notice a bug while extracting, note it but don't fix it in the same commit. Fix it separately after the extraction is committed. Otherwise it's impossible to tell what caused what.

**Don't touch the composable's public interface mid-migration**
If you start migrating callers and realise the interface needs to change, stop. Roll back to before the first caller migration. Update the interface. Then restart the migration. Partial migrations with an unstable interface cause subtle breakage.

**Don't extract template-coupled state**
If the `<script setup>` state is directly referenced in 20+ places in `<template>`, do not attempt to move that state to a composable in one step. The template would need to be rewritten simultaneously. Instead, introduce the composable alongside the inline state, migrate logic gradually, then remove the inline state last.

---

## Risk signals — stop and ask the user

Stop and ask before proceeding if:

1. The code you're extracting has **different behaviour** in different callers (not just different parameters — actually different logic)
2. The extraction would change **timing** (e.g., moving an API call from `onMounted` to `setup()` changes when it fires)
3. The new composable would need to be **a singleton** (shared state across all component instances) and you're not sure if that's intended
4. Any caller uses the **surrounding context** (closures over local refs) that won't transfer to the new module
5. The extraction touches **authentication, permissions, or financial calculations** — these need extra verification

---

## Stack-specific notes

### Nuxt 4 / Vue 3
- `useXxx()` composables must be called at component setup level, not inside async handlers (Nuxt SSR constraint — even in SPA mode, keep this rule)
- `useState('key', init)` for shared cross-component state; `ref()` for composable-local state
- Auto-imports work for `composables/` and `utils/` — new files in these dirs are available without import statements
- After adding a new `utils/` file, restart the dev server once to ensure auto-import registration

### Directus / REST API patterns
- Batch reads: use `filter[field][_in]=id1,id2,id3` instead of looping `filter[field][_eq]`
- Parallel writes: `Promise.all([...])` instead of sequential `await` in a loop
- Never call `request()` outside of composables/pages — keep API calls in one layer

### General
- After extracting to a new file, run `grep -rn "OLD_FUNCTION_NAME" src/` to confirm no copies remain
- Line count before/after: `wc -l filename.vue` is your quick health metric
