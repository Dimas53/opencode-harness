# Directus MCP Setup

How to let OpenCode talk to a project's Directus instance via the Model Context
Protocol (MCP) server.

## When do you need this?

If you want OpenCode to read your collections/fields, create items, or run flows
in **this project's** Directus instance, you must set up the Directus MCP.
Without it OpenCode has no Directus access at all.

> You only do this once per Directus project. Other projects repeat the same
> steps against their own instance.

## Architecture (per-project, no global config)

- Directus MCP is configured **per project** in a local `opencode.jsonc`
  generated from the project's `.env`.
- The global `~/.config/opencode/opencode.jsonc` contains **no** `directus`
  block — there is nothing to switch between projects.
- Each project gets its **own** `mcp` user + role inside its own Directus instance.
- The generated `opencode.jsonc` is **gitignored** (it embeds the token) — never commit it.
- Open each project in its own OpenCode window. Three projects = three
  independent MCP connections, each pointed at its own instance.

## Prerequisites

- Directus **v11.12+** (MCP server requires it). Check the version:
  ```bash
  docker exec <directus-container> node -e "console.log(require('/directus/package.json').version)"
  ```
- The project's Directus instance is running and reachable (e.g. `http://localhost:8055`).

## Step 1 — Enable the MCP server in Directus

1. Open your Directus admin panel.
2. Go to **Settings → AI → Model Context Protocol**.
3. Set **MCP Server: Enabled**, then **Save**.

The MCP endpoint is now available at `<DIRECTUS_URL>/mcp`.

## Step 2 — Create a scoped access policy, role, user, and token

Do **not** use an admin token. Create a scoped, least-privilege identity.
Follow these sub-steps in order.

### 2a — Create the Access Policy (permissions)

1. **Settings → Access Policies → Create Policy**.
2. **Name:** `mcp`
3. Enable **App Access** (this lets the user authenticate via token).
4. Under **Collection Permissions**, grant the following. The rights depend on
   what the agent should be allowed to do. If you want the agent to be able to
   do everything (read the schema, create collections, run flows, upload files)
   — grant full CRUD on all the system collections below. If you want to
   restrict it — that is your responsibility. Start with Read on the schema
   collections and add more as needed.

   | Collection           | Permission |
   |----------------------|------------|
   | `directus_collections` | CRUD     |
   | `directus_fields`      | CRUD     |
   | `directus_relations`   | CRUD     |
   | `directus_flows`       | CRUD     |
   | `directus_operations`  | CRUD     |
   | `directus_files`       | CRUD     |
   | `directus_folders`     | CRUD     |

    (Running flows is covered by the permission on `directus_flows`; uploading
    files by the permission on `directus_files`.)

    > ⚠️ Want the agent to reach **all** your collections without listing them
    > one by one? Do **not** use the **All Collections (`*`)** option — it does
    > not reliably apply to existing collections in Directus 11 (verified). For
    > a local dev machine, enable **Admin Access** on this policy (see
    > "Granting access to your own collections" below). For production, grant
    > each collection explicitly.

5. **Save** the policy.

### 2b — Create the Role and assign the policy

1. **Settings → Roles → Create Role**.
2. **Name:** `mcp`
3. Assign the **Access Policy:** `mcp` (the one from 2a).
4. **Save** the role.

### 2c — Create the User and assign the role

1. **Settings → User Directory → Create User** (or **Settings → Users**).
2. **Name:** `MCP User`
3. **Role:** `mcp` (the one from 2b).
4. **Save** the user.

### 2d — Generate the Static Token

1. Open the **MCP User** card you just created.
2. Find the **Token** field and click **Generate** (Static Token).
3. **Copy** the generated token — you will paste it into `.env` in Step 3.

## Step 3 — Put the credentials in the project `.env`

Edit the project's `.env` (created from `templates/.env.example` by `make init`):

```env
# DIRECTUS_URL e.g. http://localhost:8055 or http://localhost:8056
DIRECTUS_URL=http://localhost:8055
MCP_DIRECTUS_TOKEN=<paste the token from Step 2d>
```

`.env` is gitignored, so the token never leaves your machine via git.

## Step 4 — Generate `opencode.jsonc`

From the project root run:

```bash
make mcp
```

This runs `scripts/gen-opencode.sh`, which reads `.env`, merges your global
OpenCode config, and writes a local `opencode.jsonc` containing the `directus`
MCP block (`url = <DIRECTUS_URL>/mcp`, `Authorization: Bearer <token>`).

You can also run it manually: `bash scripts/gen-opencode.sh`.

## Step 5 — Open the project

```bash
make start
```

`make start` regenerates `opencode.jsonc` from `.env` (if `.env` has
`DIRECTUS_URL`) and then launches OpenCode. The Directus MCP connects to
**your** instance on launch. No switching, no restart.

## Adding more collections later

When you need OpenCode to touch one of your own collections, grant the `mcp`
policy **Read** (and **Create/Update** as needed) on that collection in
**Settings → Access Policies → mcp**. No config change is required.

### Granting access to your own (user) collections

After Step 2a the `mcp` policy can only see system collections. To let the agent
**create and read your own** collections, the policy needs rights on them. Two
supported approaches:

- **Local / dev machine — Admin Access:** in **Settings → Access Policies →
  mcp**, enable **Admin Access** (`admin_access: true`). The agent gets full
  access to everything, including collections not yet created — no
  per-collection setup, and the chicken-and-egg problem disappears. Use this on
  your own machine; **do NOT** use it on shared / production instances.
- **Production / shared instance — explicit grants:** in **Settings → Access
  Policies → mcp → Collection Permissions**, click **+ Add Collection** and pick
  the **specific** collection, then grant the needed rights. Repeat for every
  collection the agent should touch.

> ⚠️ The **All Collections (`*`)** option does **not** reliably apply to existing
> collections in Directus 11. Verified: a `*` CRUD grant was created but did not
> take effect, while an explicit grant on the same collection worked
> immediately. Do not rely on `*` as a "give everything" shortcut — use Admin
> Access for dev or explicit per-collection grants for production.

The token itself is never changed — only the policy's permissions in Directus.

## Setting this up for additional projects

Repeat Steps 1–4 in each project. Each project has its own `.env` and its own
`opencode.jsonc` pointing at its own Directus instance. Open them in separate
OpenCode windows — they run completely independently.

## Troubleshooting

- **MCP not connecting / "directus" missing:** run `make mcp` — `opencode.jsonc`
  was not generated (or `.env` is missing `DIRECTUS_URL` / `MCP_DIRECTUS_TOKEN`).
- **401 Unauthorized:** token invalid/expired, or user has no role / no
  App Access. Re-check Steps 2b–2d.
- **403 on writes:** grant the `mcp` policy the needed permission on that
  collection (Step 2a / "Adding more collections later").
- **Endpoint not found:** MCP Server not Enabled (Step 1), or Directus < v11.12.
