# 01 — Authentication & Secrets

> Load this file for any task involving: login, signup, tokens, cookies,
> API keys, .env files, credentials, session management.

---

## 1. Cookies

When storing auth tokens in cookies, always set all three flags:

```ts
setCookie(event, 'auth_token', token, {
  httpOnly: true,   // JS cannot read this cookie — blocks XSS token theft
  secure: true,     // HTTPS only — never sent over plain HTTP
  sameSite: 'lax',  // blocks CSRF from cross-site requests
  maxAge: 60 * 60 * 24 * 7, // explicit expiry — never leave it session-only in prod
  path: '/',
})
```

**Why each flag matters:**
- Missing `httpOnly` → XSS attack can steal the token via `document.cookie`
- Missing `secure` → token travels over HTTP, visible in network sniffing
- Missing `sameSite` → CSRF attacks can send authenticated requests from other sites

**Never store tokens in:**
- `localStorage` — readable by any JS on the page, persists after tab close
- `sessionStorage` — slightly safer but still JS-readable, XSS risk
- URL query params — ends up in server logs, browser history, referrer headers

---

## 2. Token Lifecycle

**Expiry:**
- Access tokens: short-lived (15 min to 1 hour)
- Refresh tokens: longer (7–30 days), store separately with stricter cookie scope
- Never issue tokens without expiry (`exp` claim must be set)

**Rotation:**
- Rotate refresh tokens on every use (invalidate old one, issue new one)
- On logout: invalidate token server-side, clear cookie immediately

**Validation:**
- Always verify token signature and expiry on the server
- Never trust token payload without verification
- Handle expired tokens gracefully — redirect to login, not a crash

**Concurrent sessions:**
- Decide policy upfront: allow multiple sessions or single session per user
- If single session: store token hash in DB, invalidate old on new login
- Always allow "logout all devices" action

---

## 3. Secrets Management

**The golden rule:** if it's not meant for the browser, it must never reach the browser.

```
.env file
  ├── PUBLIC values  → runtimeConfig.public  → visible in client bundle ⚠️
  └── PRIVATE values → runtimeConfig          → server only ✅
```

**What goes where in Nuxt 4:**

```ts
// nuxt.config.ts
runtimeConfig: {
  // PRIVATE — server only (DB passwords, admin tokens, API secret keys)
  directusAdminToken: '',
  openRouterApiKey: '',
  databaseUrl: '',

  public: {
    // PUBLIC — safe to expose (base URLs, feature flags, public keys)
    directusUrl: 'http://localhost:8055',
    appVersion: '1.0.0',
  }
}
```

**Never put in `runtimeConfig.public`:**
- Admin credentials
- Secret API keys (OpenRouter, Stripe, SendGrid)
- Database connection strings
- JWT secrets

**Git safety:**
- `.env` must be in `.gitignore` — verify this on every new project
- Use `.env.example` with placeholder values for documentation
- Audit git history if a secret was accidentally committed:
  ```bash
  git log --all --full-history -- .env
  # If found — rotate the secret immediately, then clean history
  ```
- Use `git-secrets` or similar tool to block accidental commits

---

## 4. API Keys

**Rule:** if an API key hits the browser, it's compromised. Period.

```
❌ Wrong — key in client-side code:
const response = await fetch('https://api.openrouter.ai/...', {
  headers: { 'Authorization': `Bearer ${config.public.openRouterKey}` }
})

✅ Correct — key only in server route:
// server/api/ai/generate.post.ts
const config = useRuntimeConfig()
const response = await fetch('https://api.openrouter.ai/...', {
  headers: { 'Authorization': `Bearer ${config.openRouterKey}` } // private
})
```

**Rate limiting on API key endpoints:**
- Any endpoint calling a paid external API must have rate limiting
- Implement per-user limits, not just per-IP (authenticated users can bypass IP limits via VPN)
- Log and alert on unusual usage spikes

---

## 5. Rate Limiting

Without rate limiting, a single user (or bot) can:
- Spam your auth endpoint → enumerate valid emails, brute-force passwords
- Hammer a paid API endpoint → run up your bill overnight
- Flood signup → fill your DB with fake accounts

**What to rate limit — minimum:**

| Endpoint | Limit (example) |
|---|---|
| POST /auth/login | 5 attempts per 15 min per IP |
| POST /auth/signup | 3 per hour per IP |
| POST /api/ai/* | 20 per hour per user |
| POST /api/*/reset-password | 3 per hour per email |

**In Nuxt server routes — basic implementation:**

```ts
// Simple in-memory rate limiter (use Redis in production)
const attempts = new Map<string, { count: number; resetAt: number }>()

function checkRateLimit(key: string, max: number, windowMs: number): boolean {
  const now = Date.now()
  const record = attempts.get(key)
  if (!record || now > record.resetAt) {
    attempts.set(key, { count: 1, resetAt: now + windowMs })
    return true
  }
  if (record.count >= max) return false
  record.count++
  return true
}

// Usage in server route:
const ip = getRequestIP(event) ?? 'unknown'
if (!checkRateLimit(`login:${ip}`, 5, 15 * 60 * 1000)) {
  throw createError({ statusCode: 429, message: 'Too many attempts. Try again later.' })
}
```

---

## 6. Edge Cases in Auth

These are the scenarios most often skipped during development:

**Expired token:**
- Must redirect to login cleanly, not crash or show raw error
- Refresh token flow: try refresh silently first, only redirect if refresh also fails

**Wrong credentials:**
- Return the same error for wrong email AND wrong password: `"Invalid credentials"`
- Never say `"Email not found"` — that confirms which emails are registered (user enumeration)

**Signup with existing email:**
- Same rule: don't confirm the email exists
- Either: silent success + send email, or generic: `"If this email is available, you'll receive a confirmation"`

**Password reset link:**
- Must expire (15–60 minutes)
- Must be single-use — invalidate after first click
- Must not leak whether the email exists

**Concurrent logins:**
- If user logs in on device B while device A has active session — define behavior explicitly
- Don't silently invalidate device A without warning

---

## 7. What If a Secret Is Compromised

If a secret, token, or API key is exposed (committed to git, logged, visible in client bundle):

1. **Rotate immediately** — generate a new secret, invalidate the old one
2. **Assume it was used** — check logs for unusual activity in the window it was exposed
3. **Clean git history** if committed — `git filter-branch` or BFG Repo Cleaner, then force push
4. **Notify affected users** if their data may have been accessed
5. **Post-mortem** — add a check or tool to prevent this specific leak from happening again

The worst response is to hope nobody noticed. Rotate first, investigate second.
