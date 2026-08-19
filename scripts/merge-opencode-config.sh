#!/bin/bash
# scripts/merge-opencode-config.sh TEMPLATE TARGET
# Shared JSONC merge logic for ~/.config/opencode/opencode.jsonc, used by
# both install.sh (fresh/existing install) and update.sh (T-G-U2). Adds
# missing top-level `mcp` server entries and the `permission` block from
# TEMPLATE into TARGET — never overwrites a key the user already has.
# Extracted out of install.sh so update.sh doesn't duplicate (and drift
# from) the same merge logic.
set -euo pipefail

# Fail with a harness message, not `node: command not found` from somewhere
# deep in a pipeline. Neither this script nor gen-opencode.sh checked, so a
# machine without the interpreter got a raw shell error and no hint about
# which tool was missing or why (T-I25).
command -v node >/dev/null 2>&1 || {
  echo "✗ node is required to merge opencode.jsonc (JSONC parsing)." >&2
  echo "  Install Node.js — the harness already needs it for OpenCode itself." >&2
  exit 1
}

# --list-mcp CONFIG: print one line per MCP server as
# "name|type|command-or-url". verify.sh uses this to check the servers are
# reachable (T-I24) — the point of putting it here rather than in verify.sh is
# that the JSONC stripper below is subtle enough to have been fixed twice
# already (T-G-U2); a third copy would drift the same way.
if [ "${1:-}" = "--list-mcp" ]; then
  CONFIG="${2:-$HOME/.config/opencode/opencode.jsonc}"
  [ -f "$CONFIG" ] || { echo "✗ config not found: $CONFIG" >&2; exit 1; }
  node -e '
    const fs = require("fs");
    const raw = fs.readFileSync(process.argv[1], "utf8");
    const clean = raw.replace(/(^|[^:])\/\/.*$/gm, "$1").replace(/,\s*([}\]])/g, "$1");
    const cfg = JSON.parse(clean);
    for (const [name, def] of Object.entries(cfg.mcp || {})) {
      const type = def.type || "local";
      const what = type === "remote" ? (def.url || "") : ((def.command || [])[0] || "");
      console.log(`${name}|${type}|${what}`);
    }
  ' "$CONFIG"
  exit 0
fi

TEMPLATE="$1"
TARGET="$2"

node -e '
  const fs = require("fs");
  const tplPath = process.argv[1];
  const cfgPath = process.argv[2];

  function parseJSONC(filePath) {
    const raw = fs.readFileSync(filePath, "utf8");
    // Strip `//` comments, but not a `//` inside a string value like
    // "https://..." — a `//` immediately preceded by `:` is treated as
    // part of a URL, not a comment start. (Pre-existing bug found while
    // building this shared script: the old regex corrupted any JSONC
    // containing "$schema": "https://..." — see T-G-U2.)
    const clean = raw.replace(/(^|[^:])\/\/.*$/gm, "$1").replace(/,\s*([}\]])/g, "$1");
    return JSON.parse(clean);
  }

  const existing = parseJSONC(cfgPath);
  const template = parseJSONC(tplPath);
  const added = [];

  existing.mcp = existing.mcp || {};
  for (const [key, value] of Object.entries(template.mcp || {})) {
    if (!existing.mcp[key]) {
      existing.mcp[key] = value;
      added.push("mcp." + key);
    }
  }

  // permission block: only add sub-keys the user does not already have —
  // never overwrite an existing permission choice (e.g. a user-tightened
  // "ask" the harness template would otherwise leave alone anyway, since
  // we only fill gaps, not replace values).
  if (template.permission) {
    existing.permission = existing.permission || {};
    for (const [scope, rules] of Object.entries(template.permission)) {
      existing.permission[scope] = existing.permission[scope] || {};
      for (const [pattern, verdict] of Object.entries(rules)) {
        if (existing.permission[scope][pattern] === undefined) {
          existing.permission[scope][pattern] = verdict;
          added.push("permission." + scope + "." + pattern);
        }
      }
    }
  }

  // Superseded permission patterns (T-I4 step 4). Filling gaps is safe for
  // MCP servers, but it silently loses a *widened* rule: a machine that
  // already has the old narrow "git push" keeps it, gets the new "git push*"
  // added beside it, and now carries two rules for the same command with an
  // untested precedence between them. Overwriting is not the answer either —
  // we cannot tell a superseded harness pattern from a deliberate user rule.
  // So: say it out loud and name the line to delete.
  //
  // "wider" here means every literal segment of the new pattern still occurs,
  // in order, inside the old one with its wildcards stripped:
  //   "git push*"               ⊃ "git push"
  //   "git commit*--no-verify*" ⊃ "git commit --no-verify*"
  // The bare "*" is excluded — with no literal segments it would claim to
  // supersede every rule in the file.
  function supersedes(newPat, oldPat) {
    if (newPat === oldPat) return false;
    const segments = newPat.split("*").filter(s => s.length > 0);
    if (segments.length === 0) return false;
    const oldLiteral = oldPat.split("*").join("");
    let cursor = 0;
    for (const segment of segments) {
      const at = oldLiteral.indexOf(segment, cursor);
      if (at === -1) return false;
      cursor = at + segment.length;
    }
    return true;
  }

  const superseded = [];
  if (template.permission) {
    for (const [scope, rules] of Object.entries(existing.permission || {})) {
      const templateRules = (template.permission || {})[scope] || {};
      for (const oldPattern of Object.keys(rules)) {
        if (templateRules[oldPattern] !== undefined) continue; // still current
        for (const newPattern of Object.keys(templateRules)) {
          if (supersedes(newPattern, oldPattern)) {
            superseded.push({ scope, oldPattern, newPattern });
            break;
          }
        }
      }
    }
  }

  if (added.length > 0) {
    fs.writeFileSync(cfgPath, JSON.stringify(existing, null, 2) + "\n");
    console.log("  ✓ Added: " + added.join(", "));
  } else {
    console.log("  ✓ All harness config keys already present");
  }

  for (const { scope, oldPattern, newPattern } of superseded) {
    console.log("  ⚠ permission." + scope + ": \"" + oldPattern + "\" is narrower than");
    console.log("    the harness pattern \"" + newPattern + "\", which was just added beside it.");
    console.log("    Merging only fills gaps, so the old rule stays until you remove it.");
    console.log("    Delete the old line from " + cfgPath + " unless you set it on purpose.");
  }
' "$TEMPLATE" "$TARGET"
