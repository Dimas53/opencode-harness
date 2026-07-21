# HARNESS.md — Project Context for AI Agents

> This file gives every new agent session instant context about this project.
> Read this first before looking at any other documentation.

## Entry Point

- **Framework:** [e.g., Nuxt 4, Directus 11, PostgreSQL]
- **Dev server:** `npm run dev` / `docker compose up`
- **Tests:** `npm run test` / `vitest run`
- **Lint:** `npm run lint`
- **Deploy:** [e.g., `docker compose -f docker-compose.prod.yml up -d`]
- **Architecture:** `docs/architecture/`

## Product Contract — What Must Never Break

<!-- List of things that MUST NOT break under any circumstances.
     Examples: auth, payments, data isolation between clients.
     Fill after the first working session once critical paths become clear. -->
- [ ] ...

## Risk Levels

| Risk | Examples |
|------|----------|
| **High** (stop + confirm) | DB migrations, auth, billing, permissions, env changes |
| **Medium** (review after code) | API routes, business logic, collection schema, server routes |
| **Low** (safe to proceed) | UI, copy, styles, component refactors, non-critical bug fixes |

## Decisions to Inherit

<!-- Architectural decisions that future agents must know and not re-ask.
     Examples: "use JWT not sessions", "no API Platform — manual controllers only",
     "multi-tenant via global scope not separate DBs".
     Fill once you've made an important technical decision. -->
- ...

---

## Risk Check

Before any significant change, ask:
1. Is this High, Medium, or Low risk?
2. Do I have all the context I need?
3. Is there an ADR or decision record for this?
