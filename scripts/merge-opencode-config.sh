#!/bin/bash
# scripts/merge-opencode-config.sh TEMPLATE TARGET
# Shared JSONC merge logic for ~/.config/opencode/opencode.jsonc, used by
# both install.sh (fresh/existing install) and update.sh (T-G-U2). Adds
# missing top-level `mcp` server entries and the `permission` block from
# TEMPLATE into TARGET — never overwrites a key the user already has.
# Extracted out of install.sh so update.sh doesn't duplicate (and drift
# from) the same merge logic.
set -euo pipefail

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

  if (added.length > 0) {
    fs.writeFileSync(cfgPath, JSON.stringify(existing, null, 2) + "\n");
    console.log("  ✓ Added: " + added.join(", "));
  } else {
    console.log("  ✓ All harness config keys already present");
  }
' "$TEMPLATE" "$TARGET"
