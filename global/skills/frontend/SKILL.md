# Frontend UI Rules

Loaded when doing UI/frontend work. Triggers: component, page, layout, form, styles, Tailwind, Nuxt UI, Vue, design, CSS.

## CSS / Layout Rules

- Never use absolute positioning except overlapping hero images or floating badges
- Always prefer flexbox or grid for layout
- All sizes in fixed px for mobile screens (not rem)
- No hover effects — use tap feedback (`active:scale-[0.98]` or equivalent)
- Follow the project's CSS framework conventions (Tailwind, SCSS, etc.)

## Design System (Global Default)

- Always read `docs/design.md` before writing any UI code
- Use only color tokens and typography defined in `docs/design.md`
- Follow the icon library and component conventions defined in the project AGENTS.md

## Nuxt UI

- Use @nuxt/ui v4 components when available — 125+ accessible components
- Customize theme in `app/app.config.ts` using Tailwind CSS v4
- See `nuxt/SKILL.md` for Nuxt-specific patterns
