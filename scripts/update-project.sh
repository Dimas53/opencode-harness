#!/bin/bash
# scripts/update-project.sh
# Body of the `update-project` AGENTS.md shortcut (renamed from
# sync-templates — T-G-U3/T-G-U4, implementation-plan-2 Wave G). Brings an
# already-adopted project up to date with the current harness: missing
# template files/doc structure, .gitignore entries, and git hooks. Never
# overwrites a file that already exists and differs — this is deliberately
# conservative (G-DEC-4 default: "only new + structural additions"), not a
# full re-sync. Invoked by OpenCode when the user types `update-project`.
# See global/AGENTS.md "Harness Shortcuts".
set -euo pipefail

# See T-I25: report the missing interpreter by name rather than letting the
# shell surface it from inside a heredoc.
command -v python3 >/dev/null 2>&1 || {
  echo "✗ python3 is required to refresh HARNESS-MANAGED regions in AGENTS.md." >&2
  exit 1
}

# Same override the git hooks already honour (hooks/pre-commit:12) — the
# default is unchanged, but a test (or a second checkout) can point this at
# another harness copy instead of the installed one.
HARNESS_PATH="${OPENCODE_HARNESS_PATH:-$HOME/.opencode-harness}"

# ── Non-interactive answers, for when an agent runs this on the user's behalf.
#    The script asks questions; an agent cannot forward the user's keystrokes
#    into a subprocess, and it is forbidden from answering for them
#    (global/AGENTS.md, Harness Shortcuts). Without a way to pass a decision
#    the user actually made, the script simply ran, hit EOF and did nothing —
#    which is what happened on the first live run in a client project.
#
#    So: --dry-run prints the plan and exits; --yes and --ci=<...> carry an
#    answer the user gave in the chat. The rule stays intact — the agent still
#    must not decide, it now has a way to REPORT a decision.
DRY_RUN=0
ASSUME_YES=0
CI_ANSWER=""
ARGS=()
for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=1 ;;
    --yes|-y)  ASSUME_YES=1 ;;
    --ci=*)    CI_ANSWER="${arg#--ci=}" ;;
    *)         ARGS+=("$arg") ;;
  esac
done
set -- "${ARGS[@]+"${ARGS[@]}"}"
TEMPLATES="$HARNESS_PATH/templates"
# pwd -P, not pwd: macOS is case-insensitive, so `cd ~/documents/backend/itoCook`
# succeeds and every path printed afterwards carries that spelling — including
# the ones written into files. -P resolves to the real name on disk.
PROJECT="$(pwd -P)"

# ── Is this actually a project root? (T-J17.1)
#    PROJECT is wherever the caller happened to be standing, and this script
#    creates files. Run from a parent directory by mistake, it scaffolds a
#    whole project — AGENTS.md, PROGRESS.md, docs/, .gitignore — into a folder
#    that merely contains projects. That happened on 2026-08-20: a scratch
#    directory got a full template set, and the error message from
#    --refresh-agents named a path two levels above the real project, which
#    an agent then read as "this project was never adopted, run adopt".
#
#    A root looks like one of: a git repo root, or a directory already
#    carrying the harness's own files. Anything else asks first — and in a
#    non-interactive run (agent, CI) refuses rather than guessing, because
#    the failure mode is silent file creation in the wrong place.
if [ ! -d "$PROJECT/.git" ] && [ ! -f "$PROJECT/AGENTS.md" ] && [ ! -f "$PROJECT/PROGRESS.md" ]; then
  echo "⚠ $PROJECT does not look like a project root:"
  echo "  no .git/, no AGENTS.md, no PROGRESS.md."
  echo "  Running here would create a new project structure in this directory."
  if [ "$ASSUME_YES" = "1" ]; then
    echo "  Continuing anyway (--yes)."
  elif [ "$DRY_RUN" = "1" ]; then
    echo "  (dry run — nothing would be written without confirmation)"
  else
    printf "Continue anyway? (y/n): "
    if ! read -r root_answer; then
      echo ""
      echo "✗ No answer received (stdin closed). If you meant to run here, pass --yes."
      exit 2
    fi
    case "$root_answer" in
      y|Y|yes|YES) echo "  Continuing." ;;
      *) echo "✗ Stopped. cd into the project root and run again."; exit 1 ;;
    esac
  fi
fi

# ── --refresh-agents — on-request pull of harness-authored rule updates
#    into an ALREADY-FILLED project AGENTS.md (G-DEC-4 addition, T-G-U6).
#    The normal sync above never touches an existing AGENTS.md — templates
#    are meant to be filled per-project, so blind overwrite would destroy
#    that. But some sections of templates/AGENTS.md are pure harness text
#    with no {{...}} placeholders (Git Workflow, Database Migrations,
#    Docs Update Matrix, the DoD Hard Rules block) — those ARE safe to
#    refresh, and are wrapped in HARNESS-MANAGED START/END markers (same
#    convention as global/AGENTS.md, T-G-U1). This flag replaces ONLY
#    those marked regions in the project's AGENTS.md with the current
#    template's version, matched positionally in file order — everything
#    outside a marked region (your filled-in Stack Skills, File Map,
#    Gotchas, etc.) is untouched. Run manually when you know a harness
#    rule improved and want it in this project, not automatically.
# ── --seed-markers — put HARNESS-MANAGED markers into a project AGENTS.md
#    that predates them (T-J17.3). Done by hand three times (itocook,
#    karriere-page-ito, a sandbox copy) before it was worth automating; the
#    procedure never varied, which is the definition of a job for a script.
#
#    --refresh-agents matches regions POSITIONALLY: the i-th marked region in
#    the target is replaced by the i-th in the template, headings unchecked.
#    So the count and order have to match the template exactly, and wrapping
#    the wrong block would let the next refresh overwrite project content with
#    placeholder text. Hence: anchor on the heading that opens each template
#    region, wrap the target's own copy of that section, and where the section
#    does not exist at all, insert an EMPTY marker pair in the right position —
#    refresh then fills it from the template (verified: that is how a project
#    with no Database Migrations section acquired one).
if [ "${1:-}" = "--seed-markers" ]; then
  TARGET="$PROJECT/AGENTS.md"
  TEMPLATE="$TEMPLATES/AGENTS.md"

  [ -f "$TARGET" ] || { echo "✗ $TARGET not found — nothing to seed"; exit 1; }
  [ -f "$TEMPLATE" ] || { echo "✗ $TEMPLATE not found"; exit 1; }

  if grep -qF "# === HARNESS-MANAGED START" "$TARGET"; then
    echo "✓ $TARGET already has HARNESS-MANAGED markers — nothing to seed."
    echo "  To pull current harness text into them: bash \"$0\" --refresh-agents"
    exit 0
  fi

  SEEDED=$(python3 - "$TARGET" "$TEMPLATE" <<'PY'
import re, sys

target_path, template_path = sys.argv[1], sys.argv[2]
START = "# === HARNESS-MANAGED START"
END = "# === HARNESS-MANAGED END ==="

template = open(template_path).read().split("\n")
target = open(target_path).read().split("\n")

# Anchors: the first markdown heading inside each template region, in order.
anchors, start_line = [], None
for i, line in enumerate(template):
    if line.startswith(START):
        start_line = template[i]
        heading = None
    elif line.strip() == END:
        anchors.append((heading, start_line))
        heading = None
    elif start_line is not None and heading is None and line.startswith("#"):
        heading = line.strip()

def heading_level(line):
    m = re.match(r"^(#+)\s", line)
    return len(m.group(1)) if m else None

def find_section(lines, heading):
    """Return (start, end) of the target's own copy of `heading`, or None.
    Matches on the heading text, not the exact string — a project may have
    edited the wording ("### After every commit — update progress.md")."""
    key = re.sub(r"[^a-z0-9]+", " ", heading.lower()).strip()
    key_head = " ".join(key.split()[:3])
    for i, line in enumerate(lines):
        if heading_level(line) is None:
            continue
        norm = re.sub(r"[^a-z0-9]+", " ", line.lower()).strip()
        if not norm.startswith(key_head):
            continue
        level = heading_level(line)
        for j in range(i + 1, len(lines)):
            lv = heading_level(lines[j])
            if lv is not None and lv <= level:
                end = j
                break
        else:
            end = len(lines)
        # trailing --- and blank lines belong outside the region
        while end > i and lines[end - 1].strip() in ("", "---"):
            end -= 1
        return (i, end)
    return None

placements, report = [], []
for heading, start_marker in anchors:
    found = find_section(target, heading) if heading else None
    placements.append((found, start_marker, heading))

# Insert from the bottom up so earlier indices stay valid. Sections that were
# not found are seeded empty, immediately after the previous region's end (or
# at end of file for the first one) so template order is preserved.
out = list(target)
last_end = len(out)
for found, start_marker, heading in reversed(placements):
    if found:
        s, e = found
        out.insert(e, END)
        out.insert(e, "")
        out.insert(s, "")
        out.insert(s, start_marker)
        last_end = s
        report.append(f"wrapped   {heading}")
    else:
        pos = last_end
        out[pos:pos] = ["", start_marker, END, ""]
        report.append(f"seeded    {heading}  (section absent — refresh will fill it)")

sys.stderr.write("\n".join(reversed(report)) + "\n")
print("\n".join(out))
PY
) || { echo "✗ Could not seed markers — target structure not recognised."; exit 1; }

  if [ "$DRY_RUN" = "1" ]; then
    echo "(dry run — nothing written)"
    echo "To apply: bash \"$0\" --seed-markers --yes"
    exit 0
  fi

  printf '%s\n' "$SEEDED" > "$TARGET"
  MARKER_COUNT=$(grep -cF "# === HARNESS-MANAGED START" "$TARGET" || true)
  echo "✓ $TARGET seeded with $MARKER_COUNT HARNESS-MANAGED region(s)"
  echo "  Next: bash \"$0\" --refresh-agents   (fills them from the template)"
  exit 0
fi

if [ "${1:-}" = "--refresh-agents" ]; then
  TARGET="$PROJECT/AGENTS.md"
  TEMPLATE="$TEMPLATES/AGENTS.md"
  MARK_START="# === HARNESS-MANAGED START"
  MARK_END="# === HARNESS-MANAGED END ==="

  [ -f "$TARGET" ] || { echo "✗ $TARGET not found — nothing to refresh"; exit 1; }
  [ -f "$TEMPLATE" ] || { echo "✗ $TEMPLATE not found"; exit 1; }

  if ! grep -qF "$MARK_START" "$TARGET"; then
    echo "⚠ $TARGET has no HARNESS-MANAGED markers — it predates T-G-U6."
    echo "  Automatic region refresh isn't safe without them. Diff manually:"
    diff "$TARGET" "$TEMPLATE" || true
    exit 1
  fi

  MERGED=$(python3 - "$TARGET" "$TEMPLATE" <<'PY'
import sys

target_path, template_path = sys.argv[1], sys.argv[2]
START = "# === HARNESS-MANAGED START"
END = "# === HARNESS-MANAGED END ==="

def split_regions(text):
    segments = []  # (is_managed, lines)
    cur = []
    in_region = False
    for line in text.split("\n"):
        if not in_region and line.startswith(START):
            segments.append((False, cur))
            cur = [line]
            in_region = True
        elif in_region and line.strip() == END:
            cur.append(line)
            segments.append((True, cur))
            cur = []
            in_region = False
        else:
            cur.append(line)
    segments.append((False, cur))
    return segments

target_segs = split_regions(open(target_path).read())
template_segs = split_regions(open(template_path).read())
template_managed = [s for m, s in template_segs if m]

if len([s for m, s in target_segs if m]) != len(template_managed):
    sys.stderr.write("REGION_COUNT_MISMATCH\n")
    sys.exit(2)

out = []
ti = 0
for is_managed, seg in target_segs:
    if is_managed:
        out.append(template_managed[ti])
        ti += 1
    else:
        out.append(seg)

for seg in out:
    for line in seg:
        print(line)
PY
) || {
    if [ "$?" = "2" ]; then
      echo "✗ $TARGET has a different number of HARNESS-MANAGED regions than the"
      echo "  current template — structure has drifted too far for a positional"
      echo "  merge. Diff manually:"
      diff "$TARGET" "$TEMPLATE" || true
    fi
    exit 1
  }

  TMP=$(mktemp)
  printf '%s\n' "$MERGED" > "$TMP"
  if diff -q "$TARGET" "$TMP" >/dev/null 2>&1; then
    echo "✓ AGENTS.md HARNESS-MANAGED regions already up to date"
    rm -f "$TMP"
    exit 0
  fi

  echo "HARNESS-MANAGED regions in $TARGET differ from the current template:"
  # T-J17.2: the cut used to be silent. With four managed regions, forty lines
  # can show the first one and stop — and the user then approves a refresh
  # having seen a quarter of it. Say how much was hidden and how to see it.
  DIFF_FILE=$(mktemp)
  diff "$TARGET" "$TMP" > "$DIFF_FILE" || true
  DIFF_LINES=$(wc -l < "$DIFF_FILE" | tr -d ' ')
  head -40 "$DIFF_FILE"
  if [ "$DIFF_LINES" -gt 40 ]; then
    echo ""
    echo "  … showing 40 of $DIFF_LINES diff lines."
    echo "  Full diff: diff \"$TARGET\" \"$TMP\""
  fi
  rm -f "$DIFF_FILE"
  echo ""
  if [ "$DRY_RUN" = "1" ]; then
    echo "(dry run — nothing applied)"
    echo "To apply after the user decides: bash \"$0\" --refresh-agents --yes"
    rm -f "$TMP"
    exit 0
  fi
  if [ "$ASSUME_YES" = "1" ]; then
    answer="y"
    echo "Apply this refresh? (y/n): y   [--yes]"
  else
    printf "Apply this refresh? Only marked regions change, your own content is untouched. (y/n): "
    if ! read -r answer; then
      echo ""
      echo "✗ No answer received (stdin closed)."
      echo "  Show the diff above to the user, ask, then re-run:"
      echo "    bash \"$0\" --refresh-agents --yes"
      rm -f "$TMP"
      exit 2
    fi
  fi
  if [ "$answer" != "y" ]; then
    echo "Skipped — no changes made."
    rm -f "$TMP"
    exit 0
  fi
  mv "$TMP" "$TARGET"
  echo "✓ AGENTS.md HARNESS-MANAGED regions refreshed"
  exit 0
fi

missing=0
to_copy=()

# ── Root template files (AGENTS.md excluded — project-authored, never
#    silently replaced) ─────────────────────────────────────────────────
for f in "$TEMPLATES"/*.md; do
  fname=$(basename "$f")
  [ "$fname" = "AGENTS.md" ] && continue
  if [ ! -f "$PROJECT/$fname" ]; then
    echo "  + $fname — not in project"
    missing=1
    to_copy+=("$fname")
  fi
done

[ ! -d "$PROJECT/memory" ] && echo "  + memory/ — directory not in project" && missing=1

# ── .agentignore — the file-level access backstop (T5.2). Missed by the
#    *.md glob above (T-H6 backfill finding); dod.sh step 8 warns
#    "backstop is INACTIVE" when this is absent, which is exactly the
#    delta this ticket exists to close for pre-T5.2 adopted projects. ────
if [ ! -f "$PROJECT/.agentignore" ]; then
  echo "  + .agentignore — not in project (dod.sh step 8 backstop is inactive without it)"
  missing=1
  to_copy+=(".agentignore")
fi

# ── docs/ subtree — new doc types added to the harness since this project
#    was adopted (the gap sync-templates never checked: only root *.md) ──
if [ -d "$TEMPLATES/docs" ]; then
  while IFS= read -r -d '' f; do
    rel="${f#"$TEMPLATES"/}"
    if [ ! -f "$PROJECT/$rel" ]; then
      echo "  + $rel — not in project"
      missing=1
      to_copy+=("$rel")
    fi
  done < <(find "$TEMPLATES/docs" -type f -print0)
fi

# ── .gitignore — merge, never overwrite (keep project's existing entries) ─
gt="$TEMPLATES/.gitignore"
if [ ! -f "$PROJECT/.gitignore" ]; then
  echo "  + .gitignore — not in project"
  missing=1
else
  gt_missing=0
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    grep -qxF "$line" "$PROJECT/.gitignore" || gt_missing=1
  done < "$gt"
  if [ "$gt_missing" = "1" ]; then
    echo "  ~ .gitignore — missing entries (will be appended):"
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      grep -qxF "$line" "$PROJECT/.gitignore" || echo "    + $line"
    done < "$gt"
    missing=1
  fi
fi

# ── Git hooks — compare installed hook to the harness's current one.
#    install-hooks.sh bakes HARNESS_PATH into the copy, so a byte diff can
#    be either a real drift or just a different HARNESS_PATH; either way,
#    reinstalling is the correct fix and is itself idempotent/safe (it
#    backs up any hook it doesn't recognize as its own to *.bak). ────────
hooks_stale=0
for h in pre-commit post-commit; do
  installed="$PROJECT/.git/hooks/$h"
  current="$HARNESS_PATH/hooks/$h"
  if [ -d "$PROJECT/.git" ] && [ -f "$current" ]; then
    if [ ! -f "$installed" ]; then
      echo "  ~ .git/hooks/$h — not installed"
      hooks_stale=1
    elif ! diff -q <(sed 's/OPENCODE_HARNESS_PATH:-[^}]*/OPENCODE_HARNESS_PATH:-X/' "$installed") \
                    <(sed "s|OPENCODE_HARNESS_PATH:-\$HOME/.opencode-harness|OPENCODE_HARNESS_PATH:-X|" "$current") \
                    >/dev/null 2>&1; then
      echo "  ~ .git/hooks/$h — differs from the harness's current version"
      hooks_stale=1
    fi
  fi
done

# ── Optional CI gate (T-I14 step 3). The gate was only ever offered by
#    `new`/`adopt` (Q-CI in harness-init/agent-adopt.md), so every project
#    adopted before 2026-08-07 has no way to hear about it — the one update
#    path that exists never mentioned templates/ci/ at all.
#    Listed here, but NOT covered by the bulk y/n below: H-DEC-4 says the CI
#    gate is "never installed silently", and folding it into a prompt whose
#    subject is "missing template files" would install it as a side effect of
#    agreeing to something else. It gets its own question, with the same
#    three choices Q-CI offers. ────────────────────────────────────────────
ci_missing=0
ci_hint=""
if [ -d "$PROJECT/.git" ] && [ -d "$TEMPLATES/ci" ]; then
  gitlab_has_dod=0
  if [ -f "$PROJECT/.gitlab-ci.yml" ] && grep -qE '^dod:' "$PROJECT/.gitlab-ci.yml"; then
    gitlab_has_dod=1
  fi
  if [ ! -f "$PROJECT/.github/workflows/dod.yml" ] && [ "$gitlab_has_dod" = "0" ]; then
    ci_missing=1
    # Only a hint for the default answer — the remote is where CI would run,
    # but the user may host elsewhere, so the question still offers both.
    ci_remote="$(git -C "$PROJECT" config --get remote.origin.url 2>/dev/null || true)"
    case "$ci_remote" in
      *gitlab*) ci_hint="gitlab" ;;
      *github*) ci_hint="github" ;;
    esac
    echo "  + CI gate — not installed (optional, asked separately below)"
  fi
fi

if [ "$missing" = "0" ] && [ "$hooks_stale" = "0" ] && [ "$ci_missing" = "0" ]; then
  echo "✓ Nothing to update — project is up to date"
  exit 0
fi

if [ "$DRY_RUN" = "1" ]; then
  echo ""
  echo "(dry run — nothing applied)"
  echo "To apply after the user decides:"
  echo "  bash \"$0\" --yes --ci=none|github|gitlab"
  exit 0
fi

answer="n"
if [ "$missing" = "1" ] || [ "$hooks_stale" = "1" ]; then
  if [ "$ASSUME_YES" = "1" ]; then
    answer="y"
    echo "Apply the updates above? (y/n): y   [--yes]"
  else
    printf "Apply the updates above? (y/n): "
    # Reaching EOF means nobody is there to answer. Treating that as "no" made
    # the run indistinguishable from "already up to date" — which is exactly
    # how the first live run in a client project looked to the user. Say so
    # and name the flag instead.
    if ! read -r answer; then
      echo ""
      echo "✗ No answer received (stdin closed)."
      echo "  Do NOT answer on the user's behalf. Show them the list above, ask,"
      echo "  then re-run with their decision:"
      echo "    bash \"$0\" --yes --ci=none|github|gitlab"
      exit 2
    fi
  fi
  if [ "$answer" != "y" ]; then
    echo "Skipped — no changes made."
  fi
fi

if [ "$answer" = "y" ]; then

for rel in "${to_copy[@]+"${to_copy[@]}"}"; do
  mkdir -p "$PROJECT/$(dirname "$rel")"
  cp "$TEMPLATES/$rel" "$PROJECT/$rel" && echo "✓ Copied $rel"
done
[ ! -d "$PROJECT/memory" ] && mkdir -p "$PROJECT/memory" && echo "✓ Created memory/"
if [ ! -f "$PROJECT/.gitignore" ]; then
  cp "$TEMPLATES/.gitignore" "$PROJECT/.gitignore" && echo "✓ Copied .gitignore"
elif [ "${gt_missing:-0}" = "1" ]; then
  # Printing "merge manually" and stopping there meant a template fix never
  # actually reached an existing project — the entries stayed missing until
  # someone did it by hand, which nobody did (T-I11). Appended, not merged in
  # place: a line the user deliberately deleted will come back, which is
  # acceptable and stated — this command's model is additions only.
  {
    echo ""
    echo "# --- added by update-project ---"
    while IFS= read -r line; do
      [ -z "$line" ] && continue
      grep -qxF "$line" "$PROJECT/.gitignore" || echo "$line"
    done < "$TEMPLATES/.gitignore"
  } >> "$PROJECT/.gitignore"
  echo "✓ .gitignore — appended missing entries"
fi
if [ "$hooks_stale" = "1" ]; then
  bash "$HARNESS_PATH/scripts/install-hooks.sh" "$PROJECT"
fi

fi  # end of the bulk "apply the updates above" block

if [ "$ci_missing" = "1" ]; then
  echo ""
  echo "Optional — CI gate. Runs the same DoD checks on push/PR, where a local"
  echo "  hook bypass cannot reach them. Requires no setup in your project; the"
  echo "  workflow checks out the harness in the runner (see the template header"
  echo "  if the harness repo is private)."
  [ -n "$ci_hint" ] && echo "  Your origin remote looks like $ci_hint."
  if [ -n "$CI_ANSWER" ]; then
    ci_answer="$CI_ANSWER"
    echo "Install a CI gate? [none / github / gitlab]: $ci_answer   [--ci]"
  else
    printf "Install a CI gate? [none / github / gitlab] (default: none): "
    if ! read -r ci_answer; then
      echo ""
      echo "✗ No answer received for the CI question (stdin closed)."
      echo "  Re-run with the user's choice: --ci=none | --ci=github | --ci=gitlab"
      exit 2
    fi
  fi
  case "$ci_answer" in
    github)
      mkdir -p "$PROJECT/.github/workflows"
      if [ -f "$PROJECT/.github/workflows/dod.yml" ]; then
        echo "⚠ .github/workflows/dod.yml already exists — left as is"
      else
        cp "$TEMPLATES/ci/github-actions-dod.yml" "$PROJECT/.github/workflows/dod.yml"
        echo "✓ Installed .github/workflows/dod.yml"
      fi
      ;;
    gitlab)
      # Never overwrite an existing pipeline definition: it is the project's
      # whole CI, and clobbering it to add one job is not a trade this command
      # gets to make. Same rule Q-CI states for `adopt`.
      if [ -f "$PROJECT/.gitlab-ci.yml" ]; then
        echo "⚠ .gitlab-ci.yml already exists — not overwritten."
        echo "  Merge the dod job in manually from:"
        echo "  $TEMPLATES/ci/gitlab-ci-dod.yml"
      else
        cp "$TEMPLATES/ci/gitlab-ci-dod.yml" "$PROJECT/.gitlab-ci.yml"
        echo "✓ Installed .gitlab-ci.yml"
      fi
      ;;
    *)
      echo "Skipped — no CI gate installed."
      ;;
  esac
fi
