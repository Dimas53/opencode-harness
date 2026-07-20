# Directus MCP Setup

How to connect the OpenCode Directus MCP server to your projects — securely,
for both solo and team workflows.

## TL;DR

- One global MCP server in `~/.config/opencode/opencode.jsonc`.
- One shared `mcp` user (service account, minimal rights) per Directus instance.
- The token lives in the global config once.
- The project URL comes from the project's `.env` (`DIRECTUS_URL`).
- `switch-directus` changes only the URL — never the token.

---

## 1. Create a dedicated `mcp` user in Directus

Do NOT use an admin token. Create a scoped service account instead.

1. Open your Directus admin panel.
2. **Settings → Access Policies → New Policy** (or "Roles"):
   - Name: `mcp` (or `mcp-readonly`).
   - **Scope is the developer's choice.** The `mcp` user only needs enough
     rights for what the agent actually does. Examples:
     - **Read-only** — grant read access to `directus_collections`,
       `directus_fields`, `directus_relations` (schema introspection only).
       Use this if the agent only inspects the project.
     - **Read + write** — also allow create/update/delete on the collections
       the agent manages (e.g. the agent scaffolds content models, seeds
       data, or runs migrations). This is common when the agent builds the
       project, not just reads it.
   - Avoid the `Administrator` role unless you explicitly want full access.
     Prefer the narrowest policy that covers the agent's real workload.
3. **User Directory → New User**:
   - Email: `mcp@local` (or any placeholder).
   - Assign the `mcp` policy you created.
   - Generate a **static access token** (user → token field). Copy it.
4. Repeat steps 1-3 in **each** Directus instance you work with.

> The same token value can be reused across instances (you set it manually),
> so the global MCP config needs only one token. If an instance already has
> its own token, see Override below.

---

## 2. Put the token in the global config

Edit `~/.config/opencode/opencode.jsonc`. The Directus MCP server is a
**remote** server authenticated with a `Bearer` token in the request headers:

```jsonc
{
  "mcpServers": {
    "directus": {
      "type": "remote",
      "url": "http://localhost:8055/mcp",
      "headers": {
        "Authorization": "Bearer dkIHulcJZ18e3ZuENS943XlY8K_S3nMZ"
      }
    }
  }
}
```

- Set `url` to any of your instances (including the `/mcp` path) — it will
  be auto-corrected per project on Session Start (see below).
- The token after `Bearer ` is the `mcp` user's static access token. It is
  set **once** and shared by all projects that use the same `mcp` user token.

---

## 3. Automatic URL switching on Session Start

Every session, the agent reads the project's `.env`:

```env
DIRECTUS_URL=http://localhost:8056
```

Then it compares that URL with the one in the global MCP config.

- **Match** → nothing happens, the agent proceeds.
- **Mismatch** → the agent asks: "MCP points at a different instance
  (<mcp-url>), switch to <expected-url>?" — you reply `yes` and it updates
  the global config.

This means in normal work you never think about `switch-directus`: open the
project, the agent fixes the address itself.

---

## 4. Override — per-project `opencode.jsonc`

For projects that need a **different token** (separate service account,
production instance, etc.), put a local config in the project root:

```jsonc
// opencode.jsonc  (in your project root)
{
  "mcpServers": {
    "directus": {
      "type": "remote",
      "url": "https://shop.directus.app/mcp",
      "headers": {
        "Authorization": "Bearer project-specific-token"
      }
    }
  }
}
```

A project-level `opencode.jsonc` **overrides** the global one for that session.
The agent uses it and does not touch the global config.

**IMPORTANT — never commit this file:**

```gitignore
opencode.jsonc
```

(Already included in the harness `.gitignore` template.)

---

## 5. `switch-directus` (manual lever)

Use it only when you want to switch without restarting the session, or when
auto-switch did not fire.

```
switch-directus            # reads DIRECTUS_URL from .env
switch-directus <url>      # explicit URL
```

What it does:
- Reads `DIRECTUS_URL` from the project's `.env` (or uses the explicit URL).
- If a local `opencode.jsonc` exists in the project → it does **not** modify
  the global config; it reports "using project config".
- If no local config → it updates only the `url` (the `/mcp` endpoint) in the
  global `~/.config/opencode/opencode.jsonc`. The `headers.Authorization`
  (Bearer token) is left untouched.

It always asks for confirmation before writing.

---

## Decision summary

| Case | What to do |
|------|-----------|
| Default (99%) | One `mcp` user + one token in global config; URL from `.env` |
| Auto URL fix | Nothing — Session Start handles it |
| Manual switch | `switch-directus` |
| Special token / instance | Project-level `opencode.jsonc` (gitignored) |
