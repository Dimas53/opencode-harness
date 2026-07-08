<!--
EXAMPLE FILE — based on a real mobile PWA design system.
Fill this file BEFORE writing any UI code.
The agent reads this file before every UI task.
When generating for a new project:
  1. Keep all section headers
  2. Fill Colors with actual brand tokens — even 3-4 colors is enough to start
  3. Typography: pick one font, define 4 sizes (heading/title/body/caption)
  4. Components: describe the most common UI patterns for this project type
  5. If no design system exists yet — write "TBD" and fill as decisions are made
-->

# Design System

## Colors

| Name | HEX | Usage |
|------|-----|-------|
| Primary | `#8966FA` | Buttons, active states, accents |
| Primary Light | `#D2C5FF` | Card backgrounds, section fills |
| Background | `#F5F5F8` | Screen background |
| Black | `#0A0116` | Main text, dark elements |
| Muted | `#6B7280` | Secondary text, labels |

## Typography

**Font:** Jost (Google Fonts) — geometric grotesque

| Role | Size | Weight |
|------|------|--------|
| Heading | 36px | Bold |
| Title | 20px | Semibold |
| Body | 14px | Regular |
| Caption | 12px | Regular |

## Components

- **Button primary:** h-56px, rounded-2xl, bg-primary, text-white
- **Input:** h-48px, rounded-xl, border-gray-200, focus:border-primary
- **Card:** rounded-2xl, shadow-sm, overflow-hidden
- **Bottom nav:** blur background, rounded-3xl, 5 tabs

## Icons

**Package:** `@phosphor-icons/vue`
- Navigation: `regular` → `fill` when active, size-6
- Inline: `regular`, size-4
