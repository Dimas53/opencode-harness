# 04 — Stack-Specific Security Patterns

> Load this file for any task involving Nuxt 4 server routes, Directus 11
> permissions/policies/flows, PostgreSQL, or nginx reverse proxy config.
>
> This is the only file in the skill that changes per project.
> Replace this file when switching stacks — keep 01–03 and 05 as-is.

---

## 1. Nuxt 4 — runtimeConfig Security Model

Nuxt 4 has two config scopes. Getting them wrong leaks secrets to the browser.

```
runtimeConfig
├── private keys (no prefix)  → server only, never in client bundle
└── public: {}                → exposed in browser, treat as public
```

```ts
// nuxt.config.ts
runtimeConfig: {
  // ✅ PRIVATE — only available in server/ routes and plugins
  directusAdminToken: '',       // from NUXT_DIRECTUS_ADMIN_TOKEN in .env
  directusAdminEmail: '',
  directusAdminPassword: '',
  openRouterApiKey: '',
  databaseUrl: '',

  public: {
    // ✅ PUBLIC — safe to expose, appears in client JS bundle
    directusUrl: 'http://localhost:8055',  // base URL only, no credentials
    appName: 'ItoCook',
  }
}
```

**How to check if a secret leaked to the client:**
```bash
# Build the app and grep the output bundle
npm run build
grep -r "your_secret_value" .output/public/
# If found — it leaked. Move it to private runtimeConfig.
```

**Server routes are the only safe place for admin operations:**
```
browser → Nuxt server route (server/api/) → Directus (with admin token)
                                          ↑
                              admin token never leaves here
```

Never call Directus admin endpoints directly from the browser or from
`composables/`, `pages/`, or `components/`. Those run on the client.

---

## 2. Nuxt 4 — Server Route Security Checklist

Every server route must follow this pattern:

```ts
// server/api/example.post.ts
export default defineEventHandler(async (event) => {
  // ─── 1. Authentication ──────────────────────────────────────────
  // Always verify the user token first — before reading anything else
  const token = getCookie(event, 'directus_token')
  if (!token) {
    throw createError({ statusCode: 401, message: 'Unauthorized' })
  }

  // Validate token with Directus
  const config = useRuntimeConfig()
  const userRes = await fetch(`${config.public.directusUrl}/users/me`, {
    headers: { Authorization: `Bearer ${token}` }
  })
  if (!userRes.ok) {
    throw createError({ statusCode: 401, message: 'Invalid or expired token' })
  }
  const { data: currentUser } = await userRes.json()

  // ─── 2. Authorization ───────────────────────────────────────────
  // Check role if admin-only action
  // Note: compare role UUID, not role name (names can change)
  const ADMIN_ROLE_UUID = process.env.DIRECTUS_ADMIN_ROLE_UUID
  if (currentUser.role !== ADMIN_ROLE_UUID) {
    throw createError({ statusCode: 403, message: 'Forbidden' })
  }

  // ─── 3. Input validation ────────────────────────────────────────
  const body = await readBody(event)
  if (!body.amount || typeof body.amount !== 'number' || body.amount <= 0) {
    throw createError({ statusCode: 400, message: 'Invalid amount' })
  }

  // ─── 4. Admin action via admin token ────────────────────────────
  const result = await fetch(`${config.public.directusUrl}/items/transactions`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      // Admin token from private runtimeConfig — never logged, never returned
      'Authorization': `Bearer ${config.directusAdminToken}`
    },
    body: JSON.stringify({ amount: body.amount, user: body.userId })
  })

  // ─── 5. Sanitized response ──────────────────────────────────────
  const data = await result.json()
  // Return only what the client needs — not the full Directus response
  return { id: data.data.id, amount: data.data.amount }
})
```

---

## 3. Directus 11 — Permissions Architecture

In Directus 11, policies are sets of rules that can be attached to users or roles. Permissions are additive — a user gets the combined permissions of all policies applied to them through their role and direct assignments.

**The hierarchy:**
```
User
 ├── Role (one per user)
 │    └── Policies (many per role) ← permissions live here
 └── Direct Policies (assigned to user specifically)

Effective permissions = union of ALL policies from all paths
```

**Key difference from Directus 10:**
- D10: permissions attached directly to roles
- D11: permissions live in policies, roles just group policies
- When you create a policy, all permissions are turned off by default — you explicitly grant what's needed.

**Getting the policy UUID (not the role UUID):**
```ts
// ❌ Wrong — role UUID ≠ policy UUID
const roleId = user.role  // this is the role, not the policy

// ✅ Correct — fetch the policy from the role
GET /roles/{role_id}?fields=policies.policy.id
// policies[0].policy is the policy UUID you need for directus_permissions
```

---

## 4. Directus 11 — Permission Rules

**Always scope reads to current user:**
```
Collection: orders
Action: read
Filter: { "user_created": { "_eq": "$CURRENT_USER" } }
```

**Never use wildcard where scoped permission exists:**
```
❌ read: all records (no filter)   → any user reads everyone's data
✅ read: filter by $CURRENT_USER   → user sees only their own records
```

**`permissions: "$full"` — use only in server routes with admin token:**
```ts
// ✅ OK — running as admin via server route, explicit and intentional
headers: { Authorization: `Bearer ${config.directusAdminToken}` }

// ❌ Wrong — passing $full to user-facing operations
// If you added $full to fix a 403, stop and fix the actual policy instead
```

**Fields to always exclude from User policy reads:**

| Collection | Fields to block |
|---|---|
| `directus_users` | `password`, `token`, `auth_data`, `tfa_secret` |
| `directus_sessions` | entire collection |
| `transactions` | other users' records (scope by user) |
| `balances` | other users' records (scope by user) |

**Permissions checklist — run after creating any new collection or field:**
```
□ Read   — scoped to $CURRENT_USER or admin-only?
□ Create — authenticated users or admin only?
□ Update — owner only ($CURRENT_USER) or admin?
□ Delete — admin only in most cases
□ Fields — are sensitive fields excluded from the readable field list?
□ Test   — verify with a non-admin user token in Directus API explorer
```

---

## 5. Directus 11 — Flows Security

Flows run with system-level privileges. Treat them carefully.

**Trigger payload validation:**
```
Never use $trigger.payload.* values directly in Create Data operations
without a preceding Run Script step that validates the payload.
```

```
❌ Unsafe Flow:
Trigger → Create Data (uses $trigger.payload.user_id directly)

✅ Safe Flow:
Trigger → Run Script (validate payload, extract safe fields)
        → Create Data (uses $last.validated_user_id)
```

**Condition filter syntax — nested objects only:**
```json
// ✅ Correct — nested object syntax
{
  "$trigger": {
    "payload": {
      "status": { "_eq": "ready" }
    }
  }
}

// ❌ Wrong — dot notation is unreliable in Flow conditions
{
  "$trigger.payload.status": { "_eq": "ready" }
}
```

**Flow logging:**
- Never log full payload objects that may contain tokens or passwords
- In Run Script steps: `console.log(data.userId)` not `console.log(JSON.stringify(data))`

---

## 6. PostgreSQL — Exposure Rules

PostgreSQL should never be directly reachable from outside Docker network.

```yaml
# docker-compose.yml

services:
  postgres:
    image: postgres:15.6   # pin version, never use latest
    # ✅ Correct — only expose within Docker network:
    expose:
      - "5432"
    # ❌ Wrong — this makes DB accessible from host machine:
    # ports:
    #   - "5432:5432"

  directus:
    # Directus reaches postgres via Docker DNS: postgres:5432
    environment:
      DB_HOST: "postgres"
      DB_PORT: "5432"
```

**If you need to connect to DB for debugging:**
```bash
# ✅ Use docker exec — no port exposure needed:
docker exec -it itocook-postgres-1 psql -U itouser -d itocook_db

# Or SSH tunnel on the server:
ssh -L 5433:localhost:5432 user@your-server
# Then connect locally to localhost:5433
```

---

## 7. nginx — Reverse Proxy Security Patterns

**The /cms/ routing bug pattern (learned the hard way):**

When nginx has a catch-all static file rule, Directus `/cms/` admin JS
can get routed through Nuxt (port 3000), causing MIME type errors.
Always scope static file location blocks to exclude `/cms/`:

```nginx
# ❌ Wrong — catches everything including /cms/ assets:
location ~* \.(js|css|png|jpg)$ {
    root /path/to/nuxt/output;
}

# ✅ Correct — excludes /cms/ from the static rule:
location ~* ^(?!/cms/).*\.(js|css|png|jpg)$ {
    root /path/to/nuxt/output;
}

# Directus admin gets its own block:
location /cms/ {
    proxy_pass http://directus:8055/;
}
```

**Hide server information:**
```nginx
server_tokens off;   # removes nginx version from headers and error pages
```

**Proxy headers — pass real client IP to app:**
```nginx
location / {
    proxy_pass http://localhost:3000;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

**Verify headers after any nginx config change:**
```bash
# Test config before reloading:
nginx -t

# Reload without downtime:
nginx -s reload

# Verify security headers are present:
curl -I https://itocook.duckdns.org | grep -E "Strict-Transport|X-Frame|X-Content-Type|Content-Security"
```
