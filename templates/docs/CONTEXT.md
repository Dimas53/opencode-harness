<!--
EXAMPLE FILE — based on a real project's domain glossary.
DO NOT copy domain terms as-is — they are project-specific.
When generating this file for a new project:
  1. Keep all section headers (Domain Terms, Patterns, Gotchas)
  2. Fill Domain Terms with concepts a future developer would need to know
  3. Patterns = architectural decisions that repeat across the codebase
  4. Gotchas = things that caused bugs or confusion — most valuable section
  Add new entries as they are discovered during development.
  NEVER delete existing entries — only append.
-->

# Context — Domain Glossary

## Domain Terms

| Term | Definition |
|------|-----------|
| Cook | User assigned to prepare meals for the office on a given day |
| Deduction | Automatic balance reduction after cook confirms meal completion |
| Duty | Cleaning assignment, separate from cooking rotation |
| Participant | User who signed up for today's lunch |
| Admin token | Server-side Directus admin credential used for privileged operations |

## Patterns

- **Admin-proxy** — browser never calls Directus with admin credentials;
  all privileged ops go through `server/api/` routes
- **Composable-per-domain** — each feature has its own composable
  (`useAuth`, `useDeduction`, `useNotifications`)
- **useState for global state** — Nuxt's `useState` instead of Pinia
  for cross-component state (simpler, SSR-compatible)

## Gotchas

- Directus 11 filter syntax: `{ field: { _eq: value } }` not `field=value`
- `useCookie` token must be `httpOnly: false` — client needs to read it
  for Authorization headers
- Tailwind CSS v3 requires `tailwind.config.ts` — v4 is CSS-first (no config file)
- Push notifications require HTTPS even on localhost (use ngrok for testing)
