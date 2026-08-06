# Propagation Backfill — delta for projects adopted before a given fix

**Source:** T-H6, `notes/Harness/implementation-plan-2/10-waveH-propagation.md`.
**Why this exists:** `templates/` (K3) only reaches a project once, at
`init`/`adopt` time (see `09-propagation-audit.md` §0-§3). A project
adopted before a fix landed does not get it automatically. `update-project`
(T-G-U3) closes most of this gap going forward — this file is the concrete
list of what to check for in a project that predates it, and whether
`update-project` actually fixes it or the fix needs a manual step.

**Run `update-project` first** (`bash ~/.opencode-harness/scripts/update-project.sh`
in the project root) — it now handles rows marked "update-project" below.
Everything marked "manual" still needs a human to look at the file, because
`update-project` deliberately never modifies a file that already exists
(see its own header comment — that's the G-DEC-4 default, not a bug).

| Artifact | How to check | Delivery |
|---|---|---|
| `.agentignore` (T5.2) | `test -f .agentignore` | **update-project** (added this backfill, T-H6) |
| Both git hooks present and current (T3.1, T-H0) | `test -f .git/hooks/pre-commit .git/hooks/post-commit`; compare against `~/.opencode-harness/hooks/` | **update-project** (T-G-U3) |
| New `docs/` subtree files added to `templates/docs/` since adopt | `diff <(cd ~/.opencode-harness/templates/docs && find . -type f) <(cd docs && find . -type f)` | **update-project** (T-G-U3) |
| New root template files (`HARNESS.md`, `MEMORY.md`, `PLAN.md`, `PROGRESS.md`) | `test -f <file>` | **update-project** |
| `opencode.jsonc` / `AGENTS.md` on the machine (not per-project) | — | **update-harness** (T-G-U1/U2), not per-project |
| UP/DOWN migration rule in project `AGENTS.md` (T5.1) | `grep -q "Database Migrations" AGENTS.md` | **manual** — `update-project` never touches an existing project `AGENTS.md` (T-G-U6, by design: it interleaves harness text with interview-filled content with no safe boundary to diff yet). Add the section from `templates/AGENTS.md` "Database Migrations" by hand. |
| Phantom skill names in project `docs/skills-cheatsheet.md` (T2.2/T2.3) | `grep -iE "directus|session-start" docs/skills-cheatsheet.md` | **manual** — same reason: the file already exists in the project, so `update-project` skips it as "present" even though its content is stale. Diff against `templates/docs/skills-cheatsheet.md` by hand, keep the project's own stack-relevant rows. |

## Known gap this file doesn't close

`update-project` treats "file exists" as "up to date" for anything outside
`docs/` (root templates + `AGENTS.md`). It cannot tell a project-customized
`HARNESS.md`/`PROGRESS.md` apart from a stale pre-fix one — the two manual
rows above are the two cases in this backfill sweep where that distinction
actually matters. A future upgrade (see T-G-U6 in
`08-waveG-doc-stack-and-update-mechanism.md`) could apply the same
HARNESS-MANAGED-marker approach `update-harness`/T-G-U1 uses for the
global `AGENTS.md`, once someone designs the harness-vs-project-content
boundary for the project-level file. Not attempted here — see
`11-open-questions-and-blocked.md`.

## Applying this to a real project

Not run against any real project in this session — the operating
constraints for this pass explicitly excluded modifying anything outside
`opencode-harness` itself. Known adopted projects to check when someone
runs this by hand: `karriere-page-ito`, `itocook` (see the remediation scan
in `11-open-questions-and-blocked.md` for what was already checked
read-only against these two).
