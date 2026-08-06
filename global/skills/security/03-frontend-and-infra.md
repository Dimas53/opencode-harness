# 03 — Frontend & Infrastructure Security

> Load this file for any task involving: Vue components, nginx config,
> Docker setup, CORS, CSP headers, dependency management, Open Redirect.

---

## 1. XSS in Vue — v-html Is Dangerous

`v-html` renders raw HTML. If the content comes from user input or an API,
an attacker can inject `<script>` tags or event handlers.

```vue
<!-- ❌ Wrong — if content is user-generated, this is XSS: -->
<div v-html="recipe.description" />

<!-- ✅ Option 1 — render as plain text: -->
<p>{{ recipe.description }}</p>

<!-- ✅ Option 2 — if HTML is required, sanitize first: -->
<div v-html="sanitized(recipe.description)" />
```

```ts
// Sanitize with DOMPurify before rendering HTML from untrusted sources
import DOMPurify from 'dompurify'

function sanitized(html: string): string {
  return DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p', 'br', 'ul', 'li'],
    ALLOWED_ATTR: [],  // no attributes — blocks event handlers
  })
}
```

**Rule:** treat every string from the DB, API, or user input as untrusted.
Even if your own server wrote it — it might have been injected at write time.

**Other Vue XSS vectors to watch:**
- `v-bind` with `href` — validate URLs, block `javascript:` scheme
- Dynamic component names from user input
- `eval()` or `new Function()` with user content — never do this

```vue
<!-- ❌ Wrong — user-supplied URL, could be javascript:alert(1) -->
<a :href="user.website">Visit</a>

<!-- ✅ Correct — validate URL scheme before binding -->
<a :href="safeUrl(user.website)">Visit</a>
```

```ts
function safeUrl(url: string): string {
  try {
    const parsed = new URL(url)
    if (!['http:', 'https:'].includes(parsed.protocol)) return '#'
    return url
  } catch {
    return '#'
  }
}
```

---

## 2. Open Redirect — Validate returnTo Parameters

Open redirect lets attackers craft URLs like:
`https://yourapp.com/auth?returnTo=https://evil.com`

After login, the app blindly redirects to the attacker's site.

```ts
// ❌ Wrong — redirect to whatever the URL says:
const returnTo = route.query.returnTo as string
router.push(returnTo)

// ✅ Correct — only allow internal paths:
function safeRedirect(returnTo: string | undefined): string {
  if (!returnTo) return '/'
  // Must start with / and not be a protocol-relative URL (//evil.com)
  if (returnTo.startsWith('/') && !returnTo.startsWith('//')) {
    return returnTo
  }
  return '/'
}

router.push(safeRedirect(route.query.returnTo as string))
```

**Where to check for this pattern in the codebase:**
- Auth login redirect (`?returnTo=`, `?redirect=`, `?next=`)
- Any `router.push()` or `navigateTo()` that uses query params
- Server routes that return redirect responses based on input

---

## 3. Content Security Policy (CSP)

CSP tells the browser which sources it's allowed to load resources from.
Even if XSS succeeds, a strict CSP prevents the injected script from executing.

**Baseline CSP for Nuxt 4 SPA with Directus:**

```nginx
# nginx — in server block
add_header Content-Security-Policy "
  default-src 'self';
  script-src 'self';
  style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
  img-src 'self' data: https:;
  font-src 'self' https://fonts.gstatic.com;
  connect-src 'self' https://your-directus-domain.com;
  frame-ancestors 'none';
  base-uri 'self';
  form-action 'self';
" always;
```

**What each directive does:**
- `default-src 'self'` — baseline: only load from same origin
- `script-src 'self'` — no inline scripts, no external scripts
- `style-src 'unsafe-inline'` — needed for Tailwind/scoped styles (unavoidable in most SPAs)
- `img-src data:` — allows base64 images (avatar uploads)
- `connect-src` — allows fetch/XHR to Directus API
- `frame-ancestors 'none'` — nobody can embed your app in an iframe (clickjacking)
- `form-action 'self'` — forms can only submit to your own domain

**⚠️ Important:** `'unsafe-inline'` in `script-src` defeats most XSS protection.
Avoid it. If Nuxt inlines scripts — use nonces instead (Nuxt has built-in nonce support).

**Roll out safely — use Report-Only mode first:**
```nginx
# Test without blocking — logs violations to console:
add_header Content-Security-Policy-Report-Only "default-src 'self'; ..." always;
# Switch to enforcing only after confirming no legitimate violations
```

---

## 4. nginx Security Headers — Full Baseline

All headers must use `always` so they apply to error responses (4xx, 5xx) too, not just successful ones.

```nginx
# /etc/nginx/sites-available/your-app.conf
server {
    listen 443 ssl;
    server_name your-app.example.com;

    # ── Security Headers ────────────────────────────────────────────

    # Force HTTPS for 1 year — only add preload if ready for HSTS preload list
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Prevent clickjacking — nobody can iframe your app
    add_header X-Frame-Options "DENY" always;

    # Prevent MIME sniffing — browser must respect declared Content-Type
    add_header X-Content-Type-Options "nosniff" always;

    # Control referrer info sent to other sites
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Disable browser APIs you don't use
    add_header Permissions-Policy "accelerometer=(), camera=(), geolocation=(), gyroscope=(), microphone=(), payment=(), usb=()" always;

    # CSP — customize connect-src for your Directus URL
    add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: https:; font-src 'self' https://fonts.gstatic.com; connect-src 'self'; frame-ancestors 'none'; base-uri 'self';" always;

    # Hide nginx version from response headers
    server_tokens off;

    # ── CORS ────────────────────────────────────────────────────────
    # Restrict to your own domain only — never use wildcard *
    add_header Access-Control-Allow-Origin "https://your-app.example.com" always;
    add_header Access-Control-Allow-Methods "GET, POST, PATCH, DELETE, OPTIONS" always;
    add_header Access-Control-Allow-Headers "Content-Type, Authorization" always;

    # ── Rest of config ──────────────────────────────────────────────
    location / {
        proxy_pass http://localhost:3000;
        # Note: add_header in nested location blocks REPLACES parent headers
        # Repeat security headers here if needed, or use include
    }
}
```

**⚠️ nginx `add_header` gotcha:** when you use `add_header` in a nested `location` block, it replaces all headers from the parent block. Either repeat headers in each location or use an include file:

```nginx
# /etc/nginx/snippets/security-headers.conf
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;

# Then in each location:
location /api/ {
    include snippets/security-headers.conf;
    proxy_pass http://localhost:3000;
}
```

**Verify headers are live:**
```bash
curl -I https://your-app.example.com
# Check: Strict-Transport-Security, X-Frame-Options, X-Content-Type-Options all present
```

---

## 5. CORS — Never Use Wildcard

CORS controls which origins can make requests to your API.

```
❌ Wildcard — any website can call your API:
Access-Control-Allow-Origin: *

✅ Scoped — only your own frontend:
Access-Control-Allow-Origin: https://your-app.example.com
```

**In Directus config (docker-compose.yml):**
```yaml
directus:
  environment:
    CORS_ENABLED: "true"
    CORS_ORIGIN: "https://your-app.example.com"  # exact domain, no wildcard
    CORS_METHODS: "GET,POST,PATCH,DELETE"
    CORS_ALLOWED_HEADERS: "Content-Type,Authorization"
```

**Dynamic CORS in Nuxt server routes (if needed):**
```ts
const allowedOrigins = ['https://your-app.example.com']
const origin = getHeader(event, 'origin') ?? ''

if (!allowedOrigins.includes(origin)) {
  throw createError({ statusCode: 403, message: 'CORS: origin not allowed' })
}
setHeader(event, 'Access-Control-Allow-Origin', origin)
```

---

## 6. Docker Security

**Don't run as root:**
```dockerfile
# ❌ Wrong — default is root:
FROM node:20-alpine

# ✅ Correct — create non-root user:
FROM node:20-alpine
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
```

**Pin image versions — never use `latest`:**
```yaml
# ❌ Wrong — latest can change without warning, introduces unknown vulnerabilities:
image: directus/directus:latest
image: node:latest

# ✅ Correct — pin to specific version:
image: directus/directus:11.3.5
image: node:20.18-alpine
```

**Don't expose ports that don't need to be public:**
```yaml
services:
  postgres:
    # ❌ Wrong — exposes DB to the host network:
    ports:
      - "5432:5432"
    # ✅ Correct — only accessible within Docker network:
    expose:
      - "5432"

  directus:
    # Only expose if you need direct access — behind nginx it's not needed:
    # ports:
    #   - "8055:8055"
```

**Secrets in Docker — don't hardcode in docker-compose.yml:**
```yaml
# ❌ Wrong — credentials visible in compose file:
environment:
  POSTGRES_PASSWORD: "mypassword123"

# ✅ Correct — reference from .env:
environment:
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
# And keep .env out of git
```

---

## 7. Dependency Security

**npm audit — run regularly:**
```bash
# Check for known vulnerabilities:
npm audit

# Fix automatically where safe:
npm audit fix

# See full report:
npm audit --json
```

**When to run:**
- Before every deploy to production
- After adding any new package
- Weekly as a habit (add to GitHub Actions)

**Lock files must be in git:**
```bash
# ✅ These must be committed:
package-lock.json   # npm
yarn.lock           # yarn
pnpm-lock.yaml      # pnpm

# They ensure reproducible installs — without them, a package could
# silently update to a compromised version
```

**Evaluate packages before installing:**
- Check download count and last publish date on npmjs.com
- Avoid packages with a single maintainer and no recent activity
- Prefer packages with >1M weekly downloads for critical functionality
- Check what the package actually does — typosquatting is real (`lodash` vs `1odash`)

**GitHub Actions — add audit step:**
```yaml
- name: Security audit
  run: npm audit --audit-level=high
  # Fails the build if high or critical vulnerabilities found
```
