#!/usr/bin/env bash
# scripts/gen-opencode.sh — generate a project-local opencode.jsonc from .env
#
# Why: OpenCode's project-level opencode.jsonc FULLY OVERRIDES the global
# config. To keep Directus MCP per-project (each project points at its own
# Directus instance) without losing the other MCP servers, we merge the
# global config and inject the per-project directus block from .env.
#
# The generated opencode.jsonc is gitignored — it must never be committed,
# because it embeds the MCP token.
#
# Usage: bash scripts/gen-opencode.sh [PROJECT_DIR]
set -euo pipefail

PROJECT_DIR="${1:-$(pwd)}"
ENV_FILE="$PROJECT_DIR/.env"
OUT_FILE="$PROJECT_DIR/opencode.jsonc"
GLOBAL_CONFIG="${OPENCODE_GLOBAL_CONFIG:-$HOME/.config/opencode/opencode.jsonc}"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "✗ .env not found in $PROJECT_DIR" >&2
  echo "  Create it with DIRECTUS_URL and MCP_DIRECTUS_TOKEN (see directus-mcp-setup.md)" >&2
  exit 1
fi

DIRECTUS_URL=""
MCP_DIRECTUS_TOKEN=""
while IFS='=' read -r key value; do
  [[ -z "${key:-}" || "$key" == \#* ]] && continue
  k="$(echo "$key" | xargs)"
  v="$(echo "$value" | xargs)"
  [[ "$k" == "DIRECTUS_URL" ]] && DIRECTUS_URL="$v"
  [[ "$k" == "MCP_DIRECTUS_TOKEN" ]] && MCP_DIRECTUS_TOKEN="$v"
done < "$ENV_FILE"

if [[ -z "$DIRECTUS_URL" || -z "$MCP_DIRECTUS_TOKEN" ]]; then
  echo "✗ DIRECTUS_URL and MCP_DIRECTUS_TOKEN must be set in .env" >&2
  exit 1
fi

url="${DIRECTUS_URL%/}/mcp"

python3 - "$GLOBAL_CONFIG" "$OUT_FILE" "$url" "$MCP_DIRECTUS_TOKEN" <<'PY'
import json, sys, os

global_path, out_path, url, token = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
config = {}
if os.path.exists(global_path):
    with open(global_path) as f:
        config = json.load(f)

mcp = config.setdefault("mcp", {})
mcp["directus"] = {
    "type": "remote",
    "url": url,
    "headers": {"Authorization": f"Bearer {token}"},
}
config["mcp"] = mcp

with open(out_path, "w") as f:
    json.dump(config, f, indent=2)
    f.write("\n")
PY

echo "✓ Wrote $OUT_FILE (directus MCP → $url)"
