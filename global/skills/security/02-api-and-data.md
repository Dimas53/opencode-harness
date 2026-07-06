# 02 — API & Data Security

> Load this file for any task involving: server routes, API endpoints,
> database queries, permissions, input validation, error handling, data responses.

---

## 1. Server Route Discipline

Every server route is a contract. Before writing any route, define:
- Who can call it (auth required? which role?)
- What it receives (validate everything)
- What it returns (only what the client actually needs)

**The minimum structure of every server route:**

```ts
// server/api/example.post.ts
export default defineEventHandler(async (event) => {
  // 1. Auth check — always first
  const user = await requireAuth(event)

  // 2. Input validation — never trust the client
  const body = await readBody(event)
  if (!body.amount || typeof body.amount !== 'number') {
    throw createError({ statusCode: 400, message: 'Invalid amount' })
  }

  // 3. Business logic
  const result = await doSomething(body.amount, user.id)

  // 4. Return only what the client needs — strip everything else
  return {
    id: result.id,
    amount: result.amount,
    // ❌ never: return result (full DB object with internal fields)
  }
})
```

**What to strip before returning to client:**
- Password hashes, tokens, refresh tokens
- Internal IDs used for admin operations
- Other users' private data
- System fields (created_by internal metadata, audit fields)
- Full user objects — pick only needed fields explicitly

---

## 2. Never Trust Client Input

The client can send anything. Validation on the frontend is UX, not security.
The server must validate independently, always.

**What to validate on every request:**

```ts
// Types — is it the right type?
if (typeof body.amount !== 'number') throw createError(400, 'amount must be a number')

// Range — is the value within acceptable bounds?
if (body.amount <= 0 || body.amount > 10000) throw createError(400, 'amount out of range')

// Presence — are required fields there?
if (!body.userId || !body.amount) throw createError(400, 'Missing required fields')

// Format — does it match expected pattern?
if (!/^[a-zA-Z0-9_-]+$/.test(body.slug)) throw createError(400, 'Invalid slug format')

// Ownership — does this user own what they're trying to modify?
const resource = await getResource(body.resourceId)
if (resource.user_id !== currentUser.id) throw createError(403, 'Forbidden')
```

**Never pass raw client input directly to:**
- Database queries (use parameterized queries or ORM)
- File system paths (`path.join` with user input = path traversal)
- Shell commands (command injection)
- External API calls without sanitization

---

## 3. Input Sanitization

Sanitization removes dangerous content before storing or processing.
Different from validation (which rejects bad input entirely).

**For text fields stored in DB:**
```ts
// Trim whitespace
const name = body.name.trim()

// Limit length — prevent DB overflow and DoS
const description = body.description.slice(0, 2000)

// Strip HTML if plain text is expected (use a library like DOMPurify on client,
// but also strip server-side for stored content)
```

**For IDs and references:**
```ts
// Never use client-provided IDs directly in queries without ownership check
// ❌ Wrong:
const item = await getItem(body.id)  // attacker provides someone else's ID

// ✅ Correct:
const item = await getItem(body.id)
if (item.user_id !== currentUser.id) throw createError(403, 'Forbidden')
```

**For numeric values:**
```ts
// Always parse and validate — never trust string-to-number coercion
const amount = parseFloat(body.amount)
if (isNaN(amount) || amount < 0) throw createError(400, 'Invalid amount')
```

---

## 4. Error Handling — Never Leak Internals

Raw error messages reveal your stack, DB schema, and logic to attackers.

```ts
// ❌ Wrong — exposes internal details:
throw new Error(`SELECT * FROM users WHERE id = ${id} failed: column "pasword" does not exist`)

// ✅ Correct — neutral message to client, details in server log:
console.error('DB query failed:', error)  // server log only
throw createError({ statusCode: 500, message: 'Something went wrong. Please try again.' })
```

**Error response rules:**
- `400` — bad input (tell the user what field is wrong, but not internals)
- `401` — not authenticated (redirect to login)
- `403` — authenticated but not allowed (just "Forbidden", no details)
- `404` — not found (don't reveal whether the resource exists or is just forbidden)
- `429` — rate limited (tell them to try later)
- `500` — server error (neutral message, full details in server logs only)

**Never include in error responses:**
- Stack traces
- SQL queries or DB error messages
- File paths
- Internal IDs or schema details
- Whether a specific email/username exists (use generic messages)

---

## 5. Principle of Least Privilege

Every permission should be as narrow as possible for the specific action.

**For API design:**
- A user endpoint should only ever return that user's own data
- A list endpoint should filter by current user automatically, not rely on the client to pass their own ID
- Admin actions must explicitly check for admin role, not just "authenticated"

**For DB queries:**
- Use scoped queries: `WHERE user_id = $currentUserId` — never fetch all and filter in code
- Never give the frontend a query builder — always define query shape on the server

**The IDOR pattern (Insecure Direct Object Reference) — most common mistake:**
```ts
// ❌ Wrong — attacker changes the ID in the request to access other users' data:
GET /api/orders/12345   // what stops them from trying /api/orders/12346 ?

// ✅ Correct — always scope by current user:
const order = await db.orders.findOne({
  where: { id: params.id, user_id: currentUser.id }  // ownership enforced
})
if (!order) throw createError(404, 'Not found')  // same message whether missing or forbidden
```

---

## 6. OWASP Top 10:2025 — Applied to Our Stack

The OWASP Top 10:2025 was released in January 2026 and introduced two new categories. Here's the full list applied practically:

| # | Category | What it means for us |
|---|---|---|
| A01 | Broken Access Control | IDOR in API routes, missing `requireAuth()`, users accessing other users' data |
| A02 | Security Misconfiguration | Default Directus credentials, open ports, debug mode in prod, wildcard CORS |
| A03 | Software Supply Chain Failures | Unaudited npm packages, unpinned Docker images, compromised dependencies |
| A04 | Cryptographic Failures | Plain HTTP, weak JWT secrets, passwords not hashed, sensitive data in logs |
| A05 | Injection | SQL injection via raw queries, XSS via unescaped output, command injection |
| A06 | Insecure Design | No rate limiting, no ownership checks designed in, trust-the-client patterns |
| A07 | Auth & Identity Failures | Weak passwords, missing token expiry, session not invalidated on logout |
| A08 | Data Integrity Failures | Unsigned data accepted, deserialization of untrusted input |
| A09 | Security Logging Failures | No logging of auth failures, no alerting on suspicious patterns |
| A10 | Mishandling of Exceptional Conditions | Raw errors returned to client, unhandled exceptions crash the server |

**Most likely to hit us (priority order):**
1. A01 — missing ownership checks in API routes
2. A02 — misconfiguration (Directus defaults, CORS, ports)
3. A10 — raw errors leaking to client
4. A05 — injection via unsanitized input
5. A09 — no logging of auth failures

---

## 7. Directus-Specific Rules

**Permissions — always scope to current user:**
```
❌ Wildcard: read all records → anyone reads everyone's data
✅ Scoped: filter[user_created][_eq]=$CURRENT_USER → user sees only their own
```

**When to use `permissions: "$full"`:**
- Only in server routes that run with admin token
- Never for regular user operations
- If you add `$full` to fix a 403 — stop and fix the actual permission instead

**Fields never to expose via Directus API to regular users:**
- `directus_users.password`
- `directus_users.token`
- `directus_users.auth_data`
- Any internal system fields prefixed with `directus_`
- Balance or transaction data of other users

**Admin token in server routes:**
```ts
// ✅ Correct — admin token only on server, never logged
const config = useRuntimeConfig()
const res = await fetch(`${config.directusUrl}/items/collection`, {
  headers: { 'Authorization': `Bearer ${config.directusAdminToken}` }
})

// ❌ Never:
console.log('Making request with token:', config.directusAdminToken)  // token in logs
```

**Flows and automations:**
- Flows run with system privileges — validate trigger payload before using it
- Never use user-supplied data from Flow trigger directly in Create Data without sanitization
- Condition filters: use nested objects, not dot notation (dot notation is unreliable)

**Permissions checklist after creating any new collection or field:**
- [ ] Who can read? (scoped to user or admin only?)
- [ ] Who can create? (authenticated users or admin only?)
- [ ] Who can update? (owner only via `$CURRENT_USER` or admin?)
- [ ] Who can delete? (admin only in most cases)
- [ ] Are sensitive fields excluded from the default field list?
