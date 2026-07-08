<!--
EXAMPLE FILE — based on a real Nuxt 4 + Directus production project.
DO NOT copy this content as-is. Use it as structural reference only.
When generating this file for a new project:
  1. Keep all section headers (Overview, Stack, Structure, Key Decisions)
  2. Replace every value with the actual project's tech stack and decisions
  3. The "Key Decisions" section is most important — explain WHY, not just WHAT
-->

# Architecture

## Overview

PWA for office lunch management. Users order meals, cooks manage prep,
admins handle finances. Mobile-first, Nuxt 4 frontend consuming Directus CMS
via REST API. Deployed on Hetzner VPS via Docker Compose.

## Stack

| Layer | Technology | Role |
|-------|-----------|------|
| Frontend | Nuxt 4 (Vue 3) | PWA, mobile-first SPA |
| Styling | Tailwind CSS v3 | Utility-first, custom tokens |
| Icons | @phosphor-icons/vue | Icon set |
| CMS / Backend | Directus 11 | Data layer, permissions, REST API |
| Database | PostgreSQL 16 | Primary data store |
| Background jobs | FastAPI (Python) | Push notifications, scheduled tasks |
| CI/CD | GitHub Actions | Build, test, deploy |
| Container | Docker + Compose | Consistent deployment |
| Hosting | Hetzner VPS | Production server |

## Structure

```
frontend/app/
├── pages/           ← file-based routing
├── components/      ← auto-imported Vue components
├── composables/     ← reusable state & logic
├── layouts/         ← page layouts
├── middleware/      ← route guards
├── server/          ← Nuxt server routes (admin proxy)
└── assets/css/      ← global styles + Tailwind tokens
```

## Key Decisions

- **Directus as backend** — avoids writing custom API; permissions and
  schema managed via UI; REST API auto-generated from collections
- **Admin-proxy pattern** — sensitive operations go through Nuxt server
  routes to avoid exposing admin credentials in browser
- **FastAPI for background jobs** — Python better suited for scheduled
  tasks and push notification delivery than Nuxt server routes
- **Docker Compose** — dev/prod parity; single `docker compose up` on VPS
