# Directus + Nuxt Security Patterns

Stack-specific rules for Nuxt 4 + Directus 11 projects. Extends `04-stack-specific.md`.

---

## 1. Role Check: Always Positive (Never Negative)

**Wrong:**
```ts
if (role !== 'admin') throw new Error('Forbidden')
```
A newly created role (e.g., `editor`, `manager`) passes this check — it's not `admin`. But is it supposed to?

**Right:**
```ts
const ALLOWED_ROLES = ['admin', 'editor']
if (!ALLOWED_ROLES.includes(role)) throw new Error('Forbidden')
```
Explicit allowlist. Any unknown role is automatically rejected.

---

## 2. Role UUIDs Only in Constants File

**Wrong:** UUID strings scattered in components, server routes, and composables.
```ts
if (user.role === 'b3f1a2c4-...') // what role is this? why? when was it added?
```

**Right:** Single constants file `app/constants/roles.ts`:
```ts
export const ROLES = {
  ADMIN: 'b3f1a2c4-...',
  EDITOR: 'd5e6f7a8-...',
  VIEWER: 'e9f0a1b2-...'
} as const
```

Then use everywhere: `user.role === ROLES.ADMIN`

**Why:** When Directus is reset or migrated, role UUIDs change. One file to update, not 20.

---

## 3. Admin Token Routes Must Check Caller Role

**Problem:** Server routes using `getAdminToken()` bypass Directus permissions entirely.

```ts
// WRONG — no caller check
export default defineEventHandler(async (event) => {
  const adminToken = await getAdminToken()
  const result = await directus.request(withToken(adminToken, readItems('secrets')))
  return result
})
```

**Right:**
```ts
export default defineEventHandler(async (event) => {
  const { role } = await getUserFromEvent(event)
  if (role !== ROLES.ADMIN) throw createError({ statusCode: 403 })

  const adminToken = await getAdminToken()
  const result = await directus.request(withToken(adminToken, readItems('secrets')))
  return result
})
```

Directus permissions don't apply when using admin token. You must manually check the caller.

---

## 4. Copying a Role Requires Full Permission Audit

When you copy a role in Directus Admin:
1. The new role starts with EXACTLY the same permissions as the source
2. You MUST review every permission before saving
3. Common misses: `unpublish` access, `read` on admin collections, `share` permissions
4. Document the audit in a comment or PR description

**Automation:** Check for copied roles in the Directus activity log before any release.

---

## 5. `app_access` Defaults to `false` via API

When creating roles through the Directus API (flows or scripts):

```ts
// This creates a role with app_access: false by default
const role = await directus.request(withToken(adminToken, createRole({
  name: 'Editor',
  // app_access is omitted — defaults to false
})))
```

If the role needs the Directus App — explicitly set `app_access: true`.
If not — leave it `false`. The default is secure but surprising.

---

## 6. Frontend-Only Protection Is Insufficient with Admin Token

**Wrong:** Protecting a server route only on the client:
```ts
// client-side only — worthless if someone calls the API directly
if (user.role !== ROLES.ADMIN) return
await $fetch('/api/admin/export')
```

**Right:** Both client AND server protection:
```ts
// server
export default defineEventHandler(async (event) => {
  const { role } = await getUserFromEvent(event)
  if (role !== ROLES.ADMIN) throw createError({ statusCode: 403 })
  // ... actual logic
})
```

**Rule of thumb:** If a server route uses admin token, it must check the caller's role. Frontend checks are UX, not security.
