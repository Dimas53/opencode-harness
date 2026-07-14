# Useful Resources

## Core Tools
| Tool | URL | What it is |
|------|-----|-----------|
| OpenCode | https://opencode.ai/ | AI agent CLI — the foundation |
| OpenRouter | https://openrouter.ai/ | API gateway for 100+ LLM models |
| RTK | https://www.rtk-ai.app/ | Token optimizer for OpenCode |

## Skills
| Resource | URL | What it is |
|----------|-----|-----------|
| Superpowers | https://github.com/obra/superpowers | Main skills package (47 skills) |
| Agent Skills | https://github.com/addyosmani/agent-skills | Curated skill collection |
| Skills.sh | https://www.skills.sh/ | Skills marketplace |
| MCP Market Skills | https://mcpmarket.com/tools/skills | More skills |

## MCP Servers
| Resource | URL | What it is |
|----------|-----|-----------|
| Official MCP servers | https://github.com/modelcontextprotocol/servers | Official registry |
| MCP.so | https://mcp.so | MCP server catalog |
| Awesome MCP | https://github.com/punkpeye/awesome-mcp-servers | Curated MCP list |
| Context7 | https://context7.com | Live docs MCP (already configured) |

## Design References
| Resource | URL | What it is |
|----------|-----|-----------|
| Refero Design | https://styles.refero.design/ | Design system references |
| DesignMD | https://designmd.me/ | Design documentation |


---

# Agent Resource Kit

A curated list of tools and libraries to supply to the agent for fast, high-quality UI development.

---

## 🧱 Components & Blocks

| Tool | What it provides | Nuxt-friendly |
|---|---|---|
| [shadcn-vue.com](https://shadcn-vue.com) | Copy-paste components that live inside your project (`components/ui/`) | ✅ |
| [ui.nuxt.com](https://ui.nuxt.com) | Official Nuxt component library, first-class Nuxt integration | ✅ |
| [hyperui.dev](https://hyperui.dev) | Free Tailwind HTML blocks, no dependencies | ✅ |
| [v0.dev](https://v0.dev) | AI block generator (React/shadcn — ask agent to port to Vue) | ⚠️ |
| [ui.aceternity.com](https://ui.aceternity.com) | Animated UI blocks (Vue port available) | ⚠️ |
| [magicui.design](https://magicui.design) | Eye-catching animated blocks | ⚠️ React only |

---

## 🎨 Icons

| Tool | Notes |
|---|---|
| [lucide.dev](https://lucide.dev) | Default icon set for shadcn, SVG, fully tree-shakeable |
| [phosphoricons.com](https://phosphoricons.com) | Flexible weight system, great for UI |
| [icones.js.org](https://icones.js.org) | Search across all icon sets at once — useful for agent queries |
| [icon-sets.iconify.design](https://icon-sets.iconify.design) | Iconify — universal icon provider, native Nuxt support |

---

## 🎨 Colors & Theming

| Tool | Notes |
|---|---|
| [uicolors.app](https://uicolors.app) | Generate a full Tailwind color palette from one hex |
| [realtime-colors.com](https://realtime-colors.com) | Preview color choices on a real UI layout |
| [tweakcn.com](https://tweakcn.com) | Visual shadcn theme customizer — exports ready-to-use CSS variables |
| [coolors.co](https://coolors.co) | Quick palette generation |

---

## 🖼️ Images & Illustrations

| Tool | Notes |
|---|---|
| [unsplash.com](https://unsplash.com) | Free high-quality photos |
| [undraw.co](https://undraw.co) | SVG illustrations with customizable brand color |
| [storyset.com](https://storyset.com) | Animated illustrations, free with attribution |

---

## 📐 Typography & Fonts

| Tool | Notes |
|---|---|
| [fonts.google.com](https://fonts.google.com) | Standard font source |
| [fontpair.co](https://fontpair.co) | Curated font pairings ready to use |

---

## 🤖 Agent Feeding Strategy

The agent performs best when given **concrete references**, not abstract instructions.

**Always provide:**
- `design.md` — brand colors, fonts, spacing rules, tone (one file, every session)
- Full component documentation as text (not a URL — the agent does not browse)
- Actual component code from `components/ui/` — the agent reads and adapts it
- Real examples from `templates/docs/examples/` — the agent reuses patterns, not reinvents them

**Core principle:**
> Give the agent an **exemplar** — a specific component, real documentation, a concrete example. Never just "make it look good."