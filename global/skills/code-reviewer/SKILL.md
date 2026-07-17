# Code Reviewer

Activate after completing any code changes before reporting "done".

## Trigger

After finishing implementation, before saying "done", "finished".

## Checklist

Run through this checklist mentally:

**TypeScript**
- [ ] No TypeScript errors (check imports, types, props)
- [ ] No `any` types added without comment
- [ ] Composables initialized at component level, not inside async handlers

**Vue / Nuxt**
- [ ] No `console.log` left in production code
- [ ] useDirectus() called at composable level (not inside onMounted)
- [ ] New pages have `definePageMeta({ layout: 'app' })`
- [ ] Phosphor icons use Ph prefix: PhHouse not House

**Directus**
- [ ] New collections have permissions added for User policy
- [ ] New fields are accessible via API (check field permissions)

**Design**
- [ ] Colors from design.md tokens only (no hardcoded hex)
- [ ] Font sizes from design.md scale
- [ ] Mobile safe areas respected (pt-[60px], pb-[100px])

## Output format

If all clear:
> ✅ Code review passed. [brief summary of what was done]

If issues found:
> ⚠️ Found [N] issues before marking done: [list]. Fixing now.

Then fix issues before reporting to user.
