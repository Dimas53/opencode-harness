# Security Skill — Entry Point

> Read this file at the start of every session.
> Then load additional files based on the task context (see routing below).

---

## What This Skill Is

A practical, opinionated security baseline for AI-assisted development.
Not enterprise compliance. Not a one-time audit.
A living set of rules the agent follows on every task — from first commit to production.

Covers: authentication, secrets, API design, frontend, infrastructure, and release.
Stack-specific guidance for Nuxt 4 + Directus 11 + PostgreSQL + nginx + Docker is in `04-stack-specific.md`.

---

## When to Load Which File

| Task type | Files to read |
|---|---|
| Auth, login, tokens, cookies, signup | `01-auth-and-secrets.md` |
| API routes, server routes, DB queries, permissions | `02-api-and-data.md` |
| Vue components, nginx config, Docker, CSP, CORS | `03-frontend-and-infra.md` |
| Nuxt / Directus / PostgreSQL specific work | `04-stack-specific.md` |
| Pre-release review, PR review, deploy | `05-release-checklist.md` |
| Any task touching secrets, .env, credentials | `01-auth-and-secrets.md` always |

When in doubt — load `01` and `02`. They cover the most common vulnerabilities.

---

## 5 Questions Before Every Change

Ask these before writing or modifying any code:

1. **Does this expose a secret?**
   Could any value from `.env`, admin token, or internal key end up in client-side code, logs, or API response?

2. **Does this trust client input?**
   Is any value coming from the request body, query params, or headers used without validation on the server?

3. **Does this return more than needed?**
   Does the API response include fields the client doesn't actually need? (passwords, tokens, internal IDs, other users' data)

4. **Does this require auth?**
   Is the route or action protected? Could an unauthenticated or lower-privilege user reach it?

5. **Does this break the principle of least privilege?**
   Is the permission scope as narrow as possible for this specific action?

If the answer to any question is "yes" or "not sure" — stop and fix before proceeding.

---

## Non-Negotiable Rules

These apply to every task, no exceptions:

- **Never put secrets in client-side code.** If it runs in the browser, assume it's public.
- **Never trust client input.** Validate and sanitize on the server, always.
- **Never return raw internal errors to the user.** Log details server-side, show neutral messages client-side.
- **Never use wildcard permissions when a scoped permission exists.**
- **Never commit `.env` files or real credentials to git.**
- **Always use `requireAuth()` on server routes.**

---

## Skill File Index

```
security/
├── SKILL.md                  ← this file (read first)
├── 01-auth-and-secrets.md    ← tokens, cookies, API keys, secrets management
├── 02-api-and-data.md        ← server routes, permissions, input validation, OWASP
├── 03-frontend-and-infra.md  ← Vue XSS, CSP, CORS, nginx, Docker
├── 04-stack-specific.md      ← Nuxt 4, Directus 11, PostgreSQL, nginx patterns
└── 05-release-checklist.md   ← pre-release audit, incident response, code review
```
