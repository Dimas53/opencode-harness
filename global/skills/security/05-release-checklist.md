# 05 — Release Checklist & Incident Response

> Load this file before any production deploy, PR review of security-sensitive
> changes, or when something has already gone wrong.

---

## 1. Pre-Release Security Checklist

Run through every section before deploying to production.
Check each box only after actually verifying — not by assumption.

---

### 🔐 Auth & Secrets

```
□ .env is in .gitignore — verify with: git check-ignore -v .env
□ No secrets in git history:
    git log --all --full-history -p -- .env | grep -E "password|token|secret|key"
□ No secrets in client bundle:
    npm run build && grep -r "YOUR_SECRET_VALUE" .output/public/
□ All cookies have httpOnly + secure + sameSite flags
□ Access tokens have explicit expiry set
□ Admin credentials changed from defaults (Directus default: admin/admin)
□ Rate limiting active on /auth/login and /auth/signup routes
□ Signup route requires server-side validation (not just client)
```

---

### 🛡️ API & Permissions

```
□ Every server route has auth check as the first operation
□ No server route returns raw DB objects — only explicitly picked fields
□ No server route returns raw error messages to the client
□ All Directus collections have permissions explicitly set (no accidental wildcards)
□ Sensitive fields excluded from User policy reads:
    directus_users: password, token, auth_data, tfa_secret
    transactions: only own records (filter by $CURRENT_USER)
    balances: only own records (filter by $CURRENT_USER)
□ Admin token used only in server routes — never in composables or pages
□ All new collections created since last deploy have permissions checklist run
```

---

### 🌐 Frontend & Infrastructure

```
□ No v-html rendering unescaped user-generated content
□ All ?returnTo= and redirect params validated against internal paths only
□ nginx security headers present (verify with curl -I https://yourdomain):
    Strict-Transport-Security ✓
    X-Frame-Options ✓
    X-Content-Type-Options ✓
    Referrer-Policy ✓
    Content-Security-Policy ✓
□ server_tokens off in nginx config
□ CORS restricted to own domain — no wildcard *
□ Directus CORS_ORIGIN set to exact domain (not *)
□ PostgreSQL port NOT exposed outside Docker network
□ All Docker images pinned to specific versions (no :latest)
□ npm audit clean: run npm audit --audit-level=high
```

---

### 🔍 Auth Edge Cases — Manual Testing

Run through these before every release. These catch most auth bugs:

```
□ Wrong password 5 times → rate limiting kicks in, not a crash
□ Wrong email + wrong password → same generic error message for both
    ("Invalid credentials" — not "Email not found" or "Wrong password")
□ Signup with already-registered email → generic message, doesn't confirm email exists
□ Login with valid email, wrong password → no timing difference hint
□ Expired token → clean redirect to login, not a white screen or raw error
□ Manually cleared cookie → middleware redirects to /auth correctly
□ Accessing protected route without token → redirected, not 500
□ Accessing admin route as regular user → 403, not data leak
```

---

### 📋 Legal & Data (Internal Apps)

Even for internal apps, check these before adding real employee data:

```
□ Do you know where employee data is stored? (server location, backups)
□ Has IT/management been informed that this tool stores employee data?
□ Is there a process for deleting a user's data if they leave the company?
□ Are you logging anything that could be considered personal data?
    (IP addresses, activity logs, balance history)
□ If yes — is there a retention policy? (how long kept, who can access)
```

> Note: if the app is internal-only, full GDPR compliance may not apply —
> confirm scope with the client. But these questions are worth answering
> before going live with real users.

---

## 2. Code Review Checklist — Security-Sensitive PRs

Use when reviewing any PR that touches: auth, server routes, permissions,
env config, nginx, Docker, or user data.

```
□ Does this PR introduce any new server routes?
    → Is requireAuth() the first line?
    → Is the response stripped of sensitive fields?

□ Does this PR change permissions in Directus?
    → Is the change scoped (not widened to wildcard)?
    → Was it tested with a non-admin user token?

□ Does this PR add new environment variables?
    → Are secrets in private runtimeConfig (not public)?
    → Is .env.example updated with a placeholder?

□ Does this PR add or update npm packages?
    → Was npm audit run after the change?
    → Is package-lock.json committed?

□ Does this PR change nginx config?
    → Was nginx -t run to validate syntax?
    → Were security headers verified with curl -I after deploy?

□ Does this PR render user-generated content?
    → Is v-html avoided or sanitized with DOMPurify?
    → Are URLs validated before v-bind:href?

□ Does this PR use redirect parameters?
    → Is the returnTo/redirect value validated as internal path?
```

---

## 3. Monitoring & Logging

What to log and where to look when something seems wrong.

**Log these events server-side (not to client):**
```ts
// Auth failures — detect brute force
console.error(`[AUTH] Failed login attempt for email: ${email} from IP: ${ip}`)

// Permission denials — detect probing
console.error(`[AUTHZ] Forbidden: user ${userId} tried to access ${resource}`)

// Rate limit hits — detect automated attacks
console.error(`[RATE] Rate limit hit: ${key} at ${new Date().toISOString()}`)

// Admin operations — audit trail
console.info(`[ADMIN] User ${adminId} topped up balance for ${targetUserId}: +${amount}`)
```

**What NOT to log:**
```ts
// ❌ Never log tokens, passwords, or full request bodies:
console.log('Request body:', JSON.stringify(body))   // may contain password
console.log('Auth token:', token)                    // credentials in logs
console.log('Admin token:', config.directusAdminToken) // secret in logs
```

**On the server — where to look:**
```bash
# Nuxt / Docker container logs:
docker logs app-frontend-1 --tail=100 -f

# nginx access log — see all requests:
tail -f /var/log/nginx/access.log

# nginx error log — see 4xx/5xx:
tail -f /var/log/nginx/error.log

# Directus logs:
docker logs app-directus-1 --tail=100 -f
```

**Signs of active attack to watch for:**
- Many failed login attempts from same IP in short window
- Requests to paths that don't exist (scanner probing)
- Sudden spike in 429 responses (rate limit being hit)
- Requests with unusual user agents or no user agent
- Auth attempts at unusual hours (if users are in one timezone)

---

## 4. Incident Response

Something went wrong. Stay calm. Follow this order.

### Step 1 — Contain
Stop the bleeding before investigating.

```
If a secret was exposed:
→ Rotate it immediately (generate new, invalidate old)
→ Don't wait to investigate first — rotate first

If an account was compromised:
→ Invalidate all sessions for that user
→ Reset their credentials
→ Check what they accessed in logs

If the server is under active attack:
→ Block the attacking IP in nginx or firewall
→ Enable stricter rate limiting temporarily
→ Don't take the service down unless data is actively being exfiltrated
```

### Step 2 — Assess
What actually happened?

```
□ What was exposed or accessed?
□ When did it start? (check logs for earliest suspicious activity)
□ How did it happen? (which vulnerability, which endpoint)
□ Who is affected? (which users, which data)
□ Is the attack ongoing or stopped?
```

### Step 3 — Fix
Address the root cause, not just the symptom.

```
□ Deploy the fix to production
□ Verify the fix actually closes the vulnerability
□ Run the full pre-release checklist before redeploying
□ Check for similar vulnerabilities in adjacent code
```

### Step 4 — Notify
Who needs to know?

```
Internal app:
□ Notify management/IT immediately if employee data was accessed
□ Inform affected users what data was exposed and what you've done
□ Document the incident: what happened, when, what was done

If personal data was involved:
□ Check if GDPR notification is required (72 hours from discovery)
□ Even for internal tools — HR and legal should be informed
```

### Step 5 — Post-Mortem
Prevent it from happening again.

```
□ Write a brief incident report (even 1 page):
    - What happened
    - Root cause
    - What was done to fix it
    - What will prevent recurrence

□ Add a test or check that would have caught this
□ Update this checklist if a step was missing
□ Share findings with the team — not to blame, to prevent
```

---

## 5. Useful Commands — Quick Reference

```bash
# Check if .env is gitignored:
git check-ignore -v .env

# Search git history for secrets:
git log --all -p | grep -E "password|secret|token|api_key" | head -20

# Check what's in the client bundle:
npm run build && ls -la .output/public/_nuxt/

# Verify nginx config:
nginx -t

# Check live security headers:
curl -I https://your-app.example.com

# Run security audit on dependencies:
npm audit --audit-level=high

# Check open ports on server:
ss -tlnp

# See which Docker containers are running and their exposed ports:
docker ps --format "table {{.Names}}\t{{.Ports}}"

# Tail all Docker logs at once:
docker compose logs -f --tail=50

# Check Directus permissions for a collection via API:
curl -H "Authorization: Bearer ADMIN_TOKEN" \
  "https://your-app.example.com/cms/permissions?filter[collection][_eq]=orders"
```
