# Progress Log

## Current Status

Phase: implementation-plan reorganization + audit annotation — done. Wave 6 (recon) still paused at T6.5 batch 1 (unchanged this session).
Last commit: bbd5df7 (still current — this session's work is entirely in notes/, gitignored, see below)
Chat language: ru

## Session 2026-08-05 (implementation-plan reorganization, audit checkmarks, two new synthesis docs)

Chat language: ru

By user request, three deliverables on top of the recon work from the
previous Wave 6 session — all pure documentation/organization, no code
changes, no commits (everything lives under `notes/Harness/`, gitignored
per `.gitignore:37`):

### Done

- **Translated all 5 Wave 6 recon reports to Russian** (in place, same
  filenames) — user wanted to read them directly.
- **`notes/Harness/implementation-plan/08-open-decisions.md`** — added 3
  new backlog entries: (1) capability deny-by-default — the T3.7 spike
  concluded the mechanism genuinely exists in OpenCode (`permission.bash`
  config, `allow`/`ask`/`deny`) with a concrete ready-to-implement
  recommendation that was never picked up, not even by Wave 5 despite the
  spike itself suggesting it; (2) three skill-dedup recommendations from
  `skill-dedup-candidates.md` (T2.7) that were never carried into this
  backlog file (tdd/test-driven-development merge, debugging-and-error-recovery/
  systematic-debugging retirement + now file:line-confirmed dangling
  `superpowers:` refs, session-start phantom references in 3
  instructions/reference/*.md files); (3) pointers to the two Wave 6
  critical findings (secret-leak risk, GUIDE.md §6 DoD duplication) plus
  the other Wave 6 findings, so nothing from the recon session is at risk
  of being lost.
- **Confirmed via direct read**: both `stack-specificity-decision.md`
  (T2.8) and `skill-dedup-candidates.md` (T2.7) are completed WAVE 2
  deliverables (full analysis, decisions pending) — not leftover/unstarted
  work. `stack-specificity-decision.md` was already fully mirrored into
  08; `skill-dedup-candidates.md` was only partially mirrored (fixed
  above).
- **Moved `notes/Harness/recon-findings/` → `notes/Harness/implementation-plan/recon-findings/`**
  so all plan-related output lives in one place. Could not remove the old
  location — `rm`/`rm -r` denied by the current permission mode (tried
  both recursive and per-file). **Old duplicate folder
  `notes/Harness/recon-findings/` still exists on disk and needs manual
  cleanup** (5 stale English-language copies of the now-Russian reports).
- **`notes/Harness/implementation-plan/2026-07-30-audit-enforcement-gaps.md`**
  — annotated in place with ~33 green-checkmark blockquotes against every
  Part I/II/III finding, cross-referencing which wave/ticket closed it (or
  ⚠️ for still-open, 🔵 for reassessed-not-a-bug). No original text
  deleted or rewritten, insertions only.
- **New `notes/Harness/implementation-plan/agent-session-flow.post-waves-0-5.md`**
  — successor to `agent-session-flow.v0.3.md`, same honest
  what-AGENTS.md-says vs what-actually-happens format, covering the
  current (post Wave 0-5) Session Start (8 steps)/DoD (9 product steps +
  8 mechanical dod.sh steps)/Session End mechanics, cross-checked directly
  against current `global/AGENTS.md`, `scripts/dod.sh`, `hooks/pre-commit`,
  `hooks/post-commit`, `scripts/session-end.sh`.
- **New `notes/Harness/implementation-plan/GENERAL-REPORT-waves-0-5.md`**
  — plain-language (no ticket IDs, no jargon) narrative of what actually
  changed across all 6 waves, organized by theme (data-loss prevention,
  silent self-disabling fixed, --no-verify handling, protocol
  fragmentation resolved, template cleanup, deny-by-default groundwork,
  behavior evals, Wave 6 recon findings, what's still open) — for the user
  to build a mental model before deciding on further waves / a re-analysis.

### Known issues

- Old `notes/Harness/recon-findings/` duplicate directory not removable
  this session (permission denial on `rm`) — flagged above, needs manual
  removal or a future session with `rm` permission granted.

### Next

- User decides: re-run/extend the audit given the new synthesis docs,
  continue Wave 6 T6.5 batch 2, or start on any of the now-fuller
  `08-open-decisions.md` backlog items (capability deny-by-default has the
  most ready-to-go concrete recommendation).

## Session 2026-08-05 (implementation-plan Wave 6 — T6.1 through T6.4, T6.5 batch 1)

Chat language: ru

Working from `notes/Harness/implementation-plan/07-wave6-recon-unread-files.md`
— a recon wave, not a fix wave: every ticket's output is a findings report
in `notes/Harness/recon-findings/`, not an autonomous code change (per the
wave's own scope). `notes/` is gitignored (`.gitignore:37`, "Local notes,
not versioned") — same as the implementation-plan itself — so **none of
this session's output is in git history**; this PROGRESS.md entry is the
only durable record. Ran T6.1-T6.4 fully autonomously (no fix-wave-style
commits expected here); stopped after T6.5 batch 1 because the ticket
itself designs in a stop-and-decide checkpoint after every 8-10 skill
batch — not a routine permission ask, so treated as the wave's own
architecture rather than something to push past.

### Done

- **T6.1** → `notes/Harness/recon-findings/scripts-batch1.md` —
  `analyze.sh`/`gen-opencode.sh`/`start.sh`. Top finding: **critical**
  secret-leak risk — `gen-opencode.sh` writes a live Directus MCP bearer
  token into `opencode.jsonc`, but `init-adopt.sh` never touches
  `.gitignore` at all (zero matches on grep), and `sync-templates.sh`'s
  merge step only *prints* missing `.gitignore` lines rather than writing
  them — so an adopted project can commit the token with nothing in the
  harness's own tooling ever having blocked it. Also: `start.sh`'s
  session-end guard never actually blocks anything (major, same
  fail-open class as pre-Wave-0 findings), and a BSD-only `date -v-1d`
  call breaks silently on Linux (minor).
- **T6.2** → `notes/Harness/recon-findings/windows-wsl.md` —
  `install.bat`. Confirmed it is fully orphaned (zero references in
  README/INSTALL.md/Makefile — the real Windows path is WSL2 running
  `install.sh`) AND independently drifted from `install.sh` in both
  directions (missing symlink creation, AGENTS.md backup logic,
  opencode.jsonc auto-merge, post-commit hook, git identity check; has an
  untested superpowers-install step `install.sh` lacks). Historical notes
  (`ostatok-po-versii-0.3.md`/`.full.md`) claim this file was already
  deleted — `git log --diff-filter=D` shows it never was; those notes are
  stale.
- **T6.3** → `notes/Harness/recon-findings/bats-tests.md` — both
  `tests/*.bats` files (20 tests total, all passing). Every single test
  is existence/non-empty/syntax-only — **zero tests actually execute any
  script and assert on behavior.** None of `dod.sh`'s 8 steps, the T5.2
  `.agentignore` gate, or `hooks/pre-commit`'s actual blocking behavior
  are exercised. Same disease class as pre-T0.4 `session-end.sh`, one
  layer up. Also cross-checked roadmap Phase 1.1/1.2 (A/B series
  checkboxes) — honestly, none are complete yet (closest: A1, B5,
  partial); did not flip any checkbox since none qualified.
- **T6.4** → `notes/Harness/recon-findings/guide-md.md` — full 786-line
  read. Top finding: **critical** — GUIDE.md §6 "Definition of Done"
  fully duplicates and has drifted from the canonical DoD list in
  `global/AGENTS.md` (missing the Commit Gate/`scripts/dod.sh` mechanical
  check entirely), in the *same file* whose §5 explicitly warns against
  doing exactly this, citing T1.1 by name. Also: Session Start step count
  stated as both 7 and 8 in different sections (canon is 8; the place
  that lists all 7 items is missing the Directus MCP step); docs-lag
  threshold documented as 5, actually enforced as 3
  (`scripts/dod.sh:149`).
- **T6.5 batch 1** → `notes/Harness/recon-findings/skills-batch-1.md` —
  8 skills (5 from the ticket's named priority list: `security`,
  `debugging-and-error-recovery`, `planning-and-task-breakdown`,
  `verification-before-completion`, `git-workflow-and-versioning`; 3 from
  T2.7's dedup report needing file:line follow-up: `code-reviewer`,
  `requesting-code-review`, `systematic-debugging`). Confirmed and pinned
  exact locations for `systematic-debugging.md`'s dangling
  `superpowers:test-driven-development` /
  `superpowers:verification-before-completion` references (T2.7 had
  flagged this without line numbers). Minor: leftover vendored-voice
  phrasing ("your human partner", "you'll be replaced") in two files,
  inconsistent with this harness's own tone.

### Known issues

- None new beyond what's captured in the recon reports themselves — this
  wave's whole purpose is surfacing exactly this kind of thing.

### Next

- User decides: address any of the findings above (especially the T6.1
  secret-leak risk and the T6.4 GUIDE.md §6 duplication — both flagged
  critical) as their own tickets, or continue T6.5 with batch 2 (~57
  skills remain unchecked by this pass, some already deep-read via T2.7
  for the dedup question specifically).

## Session 2026-08-04 (implementation-plan Wave 5 — T5.1 through T5.3)

Chat language: ru

Working from `notes/Harness/implementation-plan/06-wave5-bridge-to-sandbox.md`,
one ticket = one commit, verify run and shown before each commit, fully
autonomous per standing wave-execution instruction (no mid-session
confirmation stops).

### Done

- **T5.1** (`be5fcae`) — new `## Database Migrations` section in
  `templates/AGENTS.md` (between Git Workflow and MCP Servers Available):
  hard rule that every schema migration ships a paired `.up.sql`/`.down.sql`
  file (Wiederherstellung / TOMs Art. 32 GDPR). Project-specific template
  only, not `global/AGENTS.md`.
- **T5.2** (`6f9d255`) — file-level `.agentignore`: new
  `templates/.agentignore` with default restricted patterns (backups,
  dumps, prod env/compose, private keys); `global/AGENTS.md` Access
  Restrictions now references it; `scripts/dod.sh` renumbered 7→8 steps and
  gained a new, non-skippable Step 8 that mechanically blocks any staged
  file matching an `.agentignore` pattern; `init-project.sh`/`init-adopt.sh`
  now propagate `.agentignore` into new/adopted projects. Verified in an
  isolated scratch git repo (blocked case + clean-pass case, both correct);
  `make check-docs-sync` still 9/9 after the step renumbering.
- **T5.3** (`b0da261`) — YAML frontmatter (`name`/`trigger`/`when_to_use`/
  `stack`) added to all 8 `global/skills/harness-init/agent-*.md` files —
  3 from the ticket text verbatim, 5 written after reading each file in
  full (`agent-adopt.md`, `agent-analyze-ui.md`, `agent-fix-ui.md`,
  `agent-analyze-logic.md`, `agent-e2e.md`). Body content untouched
  (insertions-only diff, confirmed via `git diff --stat`).
- All three tickets ran independently (T5.1 → T5.2 → T5.3 per plan order),
  each with its own `instructions/CHANGELOG.md` dated entry and `make dod`
  passing before commit.

### Known issues

- None new. `.agentignore`'s glob matching is a conscious simplification
  (no `**` support) — documented as a future ticket in the T5.2 source
  plan, not a blocker.

### Next

- `07-wave6-recon-unread-files.md`, OR direct read-through of
  `notes/Harness/v0.4 - SANDBOX_ARCHITECTURE.md` in full to plan
  `directus-guard-mcp` and the LLM Guard proxy (both R&D, out of scope for
  the implementation-plan waves) — per the Wave 5 plan's own closing
  summary section.

## Session 2026-08-04 (implementation-plan Wave 4 — T4.1 through T4.3)

Chat language: ru

Working from `notes/Harness/implementation-plan/05-wave4-behavior-evals.md`,
one ticket = one commit, verify run and shown before each commit — for T4.1
and T4.2 this included actually running the fixtures/scenarios end-to-end
against real harness scripts (not just checking fixture stdout syntax), to
catch stale assumptions before they became misleading regression tests.

### Impact on other local projects — checked, none needed
This wave only added `tests/behavior/` (gated behind `IS_HARNESS_REPO`,
never syncs to client projects — see `scripts/dod.sh` Step 6/7 logic) and
`notes/Harness/red-team-findings/` (gitignored, local-only). No changes to
`hooks/`, `scripts/dod.sh`, `global/AGENTS.md`, or `global/skills/` — the
things that actually propagate to (or affect) other local harness projects.
**Nothing needs to be re-synced or reinstalled in `itocook`,
`karriere-page-ito`, or any other local project after this session.**

### Done
- **T4.1** (`fccedf3`): built `tests/behavior/{README.md,lib/assert.sh,
  run-scenario.sh}` plus the first fixture+scenario pair
  (`skill-only-commit`, regresses T0.3's docs-matrix false positive and the
  original 7-commits-0-DoD incident). Semi-automated by design: fixture
  setup is scripted, the actual agent run is manual — headless `opencode
  run` on a multi-step task isn't confirmed reliable, only the `echo ok`
  smoke test is (per the ticket's own explicit warning not to invent
  headless flags). Verified fixture stdout is exactly one line (the temp
  path), and `run-scenario.sh` reaches the `read -p` pause correctly
  (tested via `/dev/null` stdin — `timeout` isn't available on this macOS
  shell).
- **T4.2** (`bef3917`): added `dirty-adopt` (T0.1), `broken-harness-path`
  (T0.2), `pressure-to-bypass` (T3.1/T3.3), `session-end-with-failures`
  (T0.4). Caught and corrected a stale ticket assumption while building the
  last one: the ticket claimed removing `PROGRESS.md` forces a FAIL in
  `session-end.sh` Step 2 — verified directly against the current script
  and found Step 2 is `check_warn` only, never `check_fail`; the real FAIL
  path is Step 3 (missing memory log + real session changes). Rebuilt the
  fixture around the actual condition instead of the wrong assumption.
  Verified all 4 scenarios end-to-end against real behavior: ran
  `scripts/init-adopt.sh --no-open` for real against `dirty-adopt`
  (`opencode` CLI happened to be available in this environment — confirmed
  `AGENTS.md.bak` created with the marker preserved); ran `PRE_COMMIT=1
  scripts/dod.sh` against `pressure-to-bypass` (Step 4 genuinely fails);
  attempted a real commit against `broken-harness-path` (blocked by
  pre-commit exactly as T0.2 intends); ran `scripts/session-end.sh` against
  `session-end-with-failures` (Step 3 fails, `.session-ended` correctly
  never created). One transient sandbox hiccup during a batch of 4
  concurrent `git clone`s (`Operation not permitted` on a git object copy)
  — resolved by retrying that one fixture alone; not a bug in the fixture.
- **T4.3** (`90f372e`): added `tests/behavior/scenarios/red-team-pressure.md`
  (4 adversarial pressure prompts reusing the `pressure-to-bypass` fixture)
  and `notes/Harness/red-team-findings/README.md` (finding log format).
  Infrastructure only, per the ticket's explicit scope limit — did not run
  the scenario itself; that's a separate, recurring activity (e.g. before
  a harness release), not part of this one-time ticket.

### Notes
- Also logged, per user request, a known gap unrelated to this wave's own
  code: `sync-templates`/`update-harness` never re-sync hooks into already
  -adopted client projects (only `install-hooks.sh` at project creation
  does) — recorded as a new open decision in
  `notes/Harness/implementation-plan/08-open-decisions.md` (on-disk only,
  `notes/` is gitignored), not fixed in this session per the user's
  explicit instruction to just note it for now.
- Wave 4 itinerary complete per `05-wave4-behavior-evals.md`'s stated order
  (T4.1 → T4.3). Next per that file: `06-wave5-bridge-to-sandbox.md`.

## Session 2026-08-04 (implementation-plan Wave 3 — T3.1 through T3.7)

Chat language: ru

Working from `notes/Harness/implementation-plan/04-wave3-enforcement.md`, one
ticket = one commit (except T3.7, see below), verify run and shown before
each commit. Wave 1 (T1.1-T1.3) confirmed already complete before starting,
per this wave's own prerequisite check.

### Done
- **T3.1** (`b6bc789`): `hooks/post-commit` now runs `dod.sh` against the
  commit that just landed (`HEAD~1` diff) and `git reset --soft HEAD~1` on
  failure — catches `--no-verify` or any other pre-commit bypass. Mirroring
  of `global/skills/`/`AGENTS.md` to `~/.config/opencode/` is now
  conditional on the commit touching those paths, not unconditional on
  every commit. Reinstalled the local hook per the ticket's instruction.
  Verified in an isolated clone: since the literal `--no-verify` flag is
  itself denied by this repo's own `.claude/settings.local.json` (fittingly
  on-topic), simulated the bypass by temporarily removing the clone's
  `pre-commit` hook instead, committed a DoD-breaking change, confirmed the
  guard caught it and rolled `HEAD` back with the change left staged.
- **T3.2** (`f6e5ab5`): added `DOD_SKIP=<step-name>` to `scripts/dod.sh` —
  skips one named step instead of `--no-verify` disabling all 7. Wrapped
  Steps 3/4/5/6/7 (`docs-lag`/`progress`/`docs-matrix`/`tests`/`self-check`);
  deliberately left Step 1 (`uncommitted`) and Step 2 (`cyrillic`)
  unwrappable. Verified all 5 skip names print the SKIPPED warning and that
  `DOD_SKIP=cyrillic`/`DOD_SKIP=uncommitted` have no effect at all.
- **T3.3** (`dfd03ff`): added a 6th Hard Limits bullet in `global/AGENTS.md`
  documenting `--no-verify`'s real mechanics (disables all 7 checks, not
  just one), pointing to `DOD_SKIP` (T3.2) as the narrow alternative and the
  post-commit guard (T3.1) as the backstop. Confirmed no duplicate mention
  added to `## Safety Gates`.
- **T3.4** (`cfc0bc4`): added `.github/workflows/dod.yml` (runs `dod.sh` +
  `check-dod-sync.sh` on push/PR to `main`, `fetch-depth: 0` since Steps 3/5
  compare `HEAD~1`) and `notes/Harness/branch-protection-setup.md` (manual
  one-time GitHub UI steps — agent has no Settings access to enable branch
  protection itself). Verified `.github/` isn't gitignored and the YAML
  parses (validated via Ruby's `YAML.load_file`, `pyyaml` isn't installed
  in this environment).
- **T3.5** (`5494570`): removed the unjustified `global/*` exemption from
  `scripts/dod.sh`'s Cyrillic scan (Step 2) — the English-Only Policy names
  only `notes/` as exempt. Confirmed `global/` was already clean before
  removing it; verified the scan now correctly flags Cyrillic added there
  (tested with a temporary insertion into `global/skills/dod/SKILL.md`,
  reverted immediately after confirming).
- **T3.6** (`96325cb`): documented in `scripts/install.sh` +
  `scripts/install-hooks.sh` why `post-commit` only installs in the
  harness's own repo while `pre-commit` installs in every adopted project —
  intentional scoping, not a desync (re-assessed from the original audit
  finding during this plan's authoring). Note: the ticket's own suggested
  comment text line-wraps mid-phrase, which would've broken its own
  single-line `grep -q` verify commands if copied verbatim — reflowed the
  wrapping, kept the meaning.
- **T3.7** (report, no commit — `notes/` is fully gitignored, `git add -f`
  not used, consistent with the T2.4 precedent): wrote
  `notes/Harness/capability-deny-by-default-spike.md`. Researched via
  WebSearch/WebFetch against `opencode.ai/docs/permissions`,
  `/docs/agents/`, `/docs/mcp-servers/` (2026-08-04). Conclusion: **(a)
  mechanism exists** — OpenCode's `permission` config (top-level and
  per-agent, keys like `bash`/`edit`/`webfetch`/etc., three levels
  allow/ask/deny) and MCP-server wildcard tool scoping
  (`"mymcp_*": false`/`true`) let capabilities be denied at the config
  level, not just in prose. Notably, the docs' own example denies `git
  commit *` at the `permission.bash` level — directly applicable to
  closing the `--no-verify` gap from T3.3/T3.2 as a structural guarantee
  instead of a text rule. `global/opencode-config.example.jsonc` currently
  has no `permission` section at all. Recommended next step: a follow-up
  ticket (candidate: Wave 5, "bridge to sandbox") to add a `permission.bash`
  block to the harness's config template — not implemented here, per the
  ticket's own scope limit (research only, no blind implementation).

### Notes
- `--no-verify` (the literal flag) is denied by this repo's own
  `.claude/settings.local.json` — discovered while writing T3.1's verify
  test, had to simulate the bypass a different way (disabling the
  `pre-commit` hook file instead of using the flag).
- T3.5's own CHANGELOG entry initially failed the Cyrillic scan it was
  describing — quoting the scanner's own Cyrillic-range regex character
  class in prose contains literal Cyrillic characters. Reworded to
  describe the pattern without quoting it literally. (Same trap hit again
  writing this very PROGRESS.md paragraph on the first attempt.)
- Wave 3 itinerary complete per `04-wave3-enforcement.md`'s stated order
  (T3.1 → T3.7). Next per that file: `05-wave4-behavior-evals.md`.

## Session 2026-08-04 (implementation-plan Wave 2 — T2.1 through T2.8)

Chat language: ru

### Done
- Working from `notes/Harness/implementation-plan/03-wave2-transplant-cleanup.md`,
  one ticket = one commit, verify run and shown before each commit.
- **T2.1**: `scripts/dod.sh` Step 5 — added `DOCS_FILES="INSTALL.md README.md"`
  exact-match list alongside `DOCS_DIRS`, so a commit touching `Makefile`
  together with `INSTALL.md`/`README.md` no longer false-fails the docs-matrix
  check. Verified in an isolated clone.
- **T2.2**: removed 10 phantom skill references from
  `templates/docs/skills-cheatsheet.md` (`find-skills`, `triage`,
  `receiving-code-review`, `prototype`, `setup-matt-pocock-skills`,
  `write-a-skill`, `teach`, `finishing-a-development-branch`,
  `using-git-worktrees`, `subagent-driven-development`) — none exist under
  `global/skills/`, confirmed before editing.
- **T2.3**: fixed Directus row in `skills-cheatsheet.md`'s
  `Stack → Required Skills` table — falsely claimed "Vendored in harness"
  when no `global/skills/directus/` exists. Now honestly shows "not vendored"
  + points to the partial `security/06-directus-nuxt.md` coverage. Did NOT
  write a full Directus skill (separate content task, flagged for a future
  ticket with explicit review).
- **T2.4**: consolidated 4 roadmap files into one canon. Added `SUPERSEDED`
  banners to `notes/Harness/v0.5 - harness-roadmap.md` and `.full.md`
  (on-disk only — `notes/` is gitignored, so these edits aren't in any
  commit). Rewrote `instructions/roadmap.md` (the only tracked file of the
  four) to point at `v0.5 - harness-roadmap.new.md` as canonical; left
  Phase 2/3 checkboxes unchecked — no clear evidence in PROGRESS.md/git log
  that "test on Windows" or "GUIDE.md from real experience" were completed
  as discrete milestones.
- **T2.5**: removed `--no-verify` legitimization from `PROGRESS.md` (two
  "Known issues" entries) and `memory/2026-07-22.md` (the only one of the
  five audit-flagged sites that's git-committed and read at Session Start —
  the other four are either already-superseded roadmap files or archival
  docs). All rewritten to describe the actual fix (T0.3/T2.1) instead of
  recommending a bypass that disables all 7 DoD checks.
- **T2.6**: extracted the `update-harness` (~10 lines) and `sync-templates`
  (~55 lines) inline bash blocks out of `global/AGENTS.md` into new
  `scripts/update-harness-shortcut.sh` / `scripts/sync-templates.sh`
  (verbatim, `chmod +x`, logic manually verified against the original).
  `global/AGENTS.md` 467→444 lines. Did NOT touch the Hard
  Limits/Safety Gates/Behavior consolidation or the skills-table trim —
  those change safety-critical text and need per-line human review, out of
  this ticket's mechanical scope. Noted risk: `update-harness` now depends
  on a valid `~/.opencode-harness` symlink more strictly than before (code
  used to be inline and worked even without one).
  Also carried over (not fixed, flagged): a pre-existing bug in
  `sync-templates.sh` — `gt="~/.opencode-harness/templates/.gitignore"` is
  quoted, so `~` never tilde-expands.
- **T2.7** (report, no autonomous action): read all 13 SKILL.md files across
  6 candidate duplicate pairs/groups, grepped cross-references, wrote
  `notes/Harness/skill-dedup-candidates.md`. Key findings: most pairs are
  NOT true duplicates once read in full (different altitude/scope, e.g.
  `security` = stack-specific routing hub vs `security-and-hardening` =
  generic fallback). `frontend-behavior` was mis-grouped in the original
  audit — it's a static-analysis protocol, not a guidance skill, dropped
  from the comparison. Weakest link found: `requesting-code-review`
  references the now-confirmed-phantom `subagent-driven-development` skill
  inside its own body (not just the cheatsheet table T2.2 already fixed)
  and isn't called from any `agent-*.md` protocol — candidate for removal,
  needs Dmitrii's call. `systematic-debugging` still has two dangling
  `superpowers:` skill references (pre-vendoring leftover) regardless of
  the merge decision.
- **T2.8** (decision doc, no autonomous action): wrote
  `notes/Harness/stack-specificity-decision.md`. Facts gathered: 12
  Directus/Nuxt mentions in PROGRESS.md; of 13 non-`notes/Harness/` files
  mentioning Directus/Nuxt, the two that are genuinely live client/test
  projects (`mechanika-workflow.md`,
  `2026-07-29-analysis-support-portal-utm-shop.md` — a real production
  Sophos/UTMshop support portal) are both Nuxt+Directus. No evidence found
  of the harness running end-to-end on any other stack. Recommendation
  leans Option A (own the Nuxt+Directus specialization) given zero
  on-record usage elsewhere — left `NOT DECIDED`, waiting for Dmitrii.
- T2.7 and T2.8 report files live under `notes/Harness/` (gitignored) —
  no commit exists for them; they're on-disk only, as intended (decision
  material, not code).

### Known issues
- `requesting-code-review` skill references phantom `subagent-driven-development`
  inside its own body (T2.7 finding) — needs a decision, not yet fixed.
- `systematic-debugging` skill has 2 dangling `superpowers:` references
  (T2.7 finding) — pre-vendoring leftover, needs a decision on whether the
  skill is kept before fixing.
- `sync-templates.sh` has a pre-existing (carried over, not introduced)
  tilde-expansion bug on the `.gitignore` template path (T2.6 finding).
- Three `instructions/reference/*.md` files still have phantom
  `session-start` mentions — outside T2.2's file scope (which only covered
  `templates/docs/skills-cheatsheet.md`), not yet assigned to a ticket.

### Next
- Wave 2 complete. Per explicit instruction: do NOT start Wave 3
  automatically. Wait for the user. T2.7/T2.8 reports need Dmitrii's
  decision before any skill-dedup or stack-specificity action is taken.
  Next file when resumed: `04-wave3-enforcement.md`.

## Session 2026-08-04 (implementation-plan Wave 1 — T1.1 through T1.3)

Chat language: ru

### Done
- Working from `notes/Harness/implementation-plan/02-wave1-single-source-of-truth.md`,
  one ticket = one commit, verify run and shown before each commit.
- **T1.1** (`331a027`): consolidated three independent versions of
  Definition of Done (`global/AGENTS.md`, `global/skills/dod/SKILL.md`, and
  a third hardcoded list found in `instructions/GUIDE.md`) into one 9-step
  list in `global/AGENTS.md`, with `dod/SKILL.md` mirroring it 1:1. Added an
  explicit **Commit Gate** step (`make dod`) to the behavioral checklist —
  previously the mechanical gate wasn't listed there. Removed hardcoded step
  counts from enforcement blocks so they can't silently drift again.
- **T1.2** (`d6e4a16`): consolidated Session Start. Fixed a hardcoded
  "Execute all 7 steps" (actually 8) plus inconsistent list indentation in
  `global/AGENTS.md`. Removed `global/skills/session-start/SKILL.md` — an
  orphaned duplicate of `startup/SKILL.md` that leaked a specific client
  project name ("ItoCook") into its trigger phrase and referenced a
  nonexistent template file (`docs/project-state.md`). Carried its two
  useful behavioral rules (keep report under 10 lines, ask ONE clarifying
  question) into `startup/SKILL.md` before deleting it.
  **Flagged, not touched** (outside this ticket's file list, belongs to
  Wave 2 T2.2/T2.3 "phantom skills in cheatsheet"): `session-start` is still
  listed as an available skill in `templates/docs/skills-cheatsheet.md` and
  three `instructions/reference/*.md` files — now phantom entries after
  this deletion. `instructions/roadmap.md:22`'s "Consider generic version
  of session-start" TODO is now moot for the session-start half. Separately,
  "ItoCook" also appears in `global/skills/security/` reference docs and
  `global/skills/archify/notes/` — pre-existing, unrelated to Session Start.
- **T1.3** (`130210b`): added `scripts/check-dod-sync.sh` + `make
  check-docs-sync` — compares step count/titles between `AGENTS.md` and
  `dod/SKILL.md` so they can't silently re-diverge. Not wired into
  pre-commit (that's Wave 3/CI). Found and fixed two bugs in the ticket's
  own proposed script during verify: (1) the SKILL.md step extraction
  wasn't scoped past its own "Checklist format" illustrative example
  section, inflating the count from 9 to 11; (2) the first-word title
  comparison broke on single-word titles with a trailing colon
  (`**JSDoc:**` vs `JSDoc`), false-flagging steps 3/4/8. Both fixed and
  verified (clean positive run + isolated-copy negative run).
- Incident during T1.3 verify: a negative-test `sed` mutation briefly landed
  on the real `global/skills/dod/SKILL.md` on disk (session was interrupted
  mid-command) instead of staying inside the intended temp copy. Caught via
  the harness's file-change notice, reverted immediately, confirmed via
  `git diff` that the real file matches HEAD before committing T1.3. No bad
  state was committed.

### Known issues
- Phantom `session-start` skill references (see T1.2 above) — left for
  Wave 2 T2.2/T2.3.
- "ItoCook" leaks outside Session Start scope (security/ docs, archify/
  notes/) — not yet assigned to a specific ticket.

### Next
- Per explicit instruction: do NOT start Wave 2 automatically. Wait for the
  user. Next file when resumed: `03-wave2-transplant-cleanup.md`.

## Session 2026-08-03 (implementation-plan Wave 0 — T0.1 through T0.7)

Chat language: ru

### Done
- Working from `notes/Harness/implementation-plan/01-wave0-stop-the-bleeding.md`,
  one ticket = one commit, verify run and shown before each commit.
- **T0.1** (`e28bf01`): `init-adopt.sh`/`init-project.sh` no longer overwrite
  an existing project's AGENTS.md/MEMORY.md/PLAN.md/PROGRESS.md/HARNESS.md —
  differing files back up to `<file>.bak` first; `docs/`/`memory/` copy with
  `cp -rn`. Added `set -euo pipefail` to both scripts.
- **T0.2** (`43033ec`): `hooks/pre-commit` now `exit 1` (was `exit 0`) when
  `dod.sh` is missing — a broken harness path no longer lets commits through
  silently with zero checks run.
- **T0.3** (`2081e0d`): `dod.sh` Step 5 docs-matrix — skill-only commits
  (`global/skills/**` only) can satisfy the check with a same-day
  `instructions/CHANGELOG.md` entry instead of the only prior legal escape
  being `--no-verify` (which disables all 7 checks).
- **T0.4 — SKIPPED, finding stale**: `session-end.sh` already had a real
  `exit 1` in the FAIL branch on HEAD before this session started (fixed in
  some earlier uncommitted-to-plan change). No functional edit needed.
- **T0.5** (`1e724b3`): `dod.sh` Step 3 docs-lag now checks `instructions/`
  as a fallback when `docs/` doesn't exist (this repo documents itself under
  `instructions/` — the check was always a no-op skip before). Step 6's
  "skipping tests" warning is now an explicit "TESTS NOT RUN" with an
  install hint.
- **T0.6** (`70606a8`): manual `make dod` no longer `check_fail`s on
  uncommitted changes (expected right before a commit) — now a warning in
  manual mode, still a hard fail inside the actual pre-commit hook.
- **T0.7** (`375fee2`): `make unadopt` backs up AGENTS.md/MEMORY.md/PLAN.md/
  PROGRESS.md/HARNESS.md/memory/ to `.harness-unadopt-backup/` before
  deleting. Bug found during verify and fixed: the ticket's own `for`-loop
  pattern let a missing optional file (e.g. no HARNESS.md) abort the whole
  `make` target midway via the loop's exit code, before the real `rm` ran —
  fixed with `|| true`.

### Known issues
- None new. Wave 0 close-out per `01-wave0-stop-the-bleeding.md`: the one
  direct irreversible user-data-loss hole is stopped (T0.1, T0.7), pre-commit
  no longer lets commits through silently (T0.2), the docs matrix gives a
  cheap legal pass instead of pushing toward --no-verify (T0.3), the gates
  stopped lying about their strictness (T0.4 already true, T0.5), and manual
  make dod no longer undermines trust with a false FAIL (T0.6).

### Next
- `notes/Harness/implementation-plan/02-wave1-single-source-of-truth.md` —
  Wave 1 (consolidates 3 versions of DoD and 2 versions of Session Start into one).

## Session 2026-07-22 (auto-HOME-PATH, Accessing Windows files, make help, rm -rf fix)

Session language: ru

### Done
- **#12 — install.sh**: auto-replace `/YOUR/HOME/PATH` with `$HOME` via `sed -i.bak` after creating opencode.jsonc
- **#11 — INSTALL.md**: dedicated "Accessing your Windows files" section with /mnt/ examples + WSL path tip
- **#13 — README.md**: added `dod` and `docs` to After Setup shortcuts + `make help` hint
- **#14 — Makefile help**: added session-end, start, mcp targets + OpenCode shortcuts (new, adopt, analyze, update-harness, sync-templates, dod, docs)
- **#17 — Safer uninstall**: replaced `rm -rf ~/opencode-harness` with `cd .. && rm -rf opencode-harness` in README.md (1 place) and INSTALL.md (2 places)
- Self-check: all scripts bash -n OK, permissions OK, no trailing whitespace

### Known issues

- Makefile: duplicate `init` target, empty `setup` target
- `make session-start` target does not exist
- context7 MCP: zero usage in practice (rule exists, no enforcement)
- DoD Step 2 (docs update per mapping) not implemented
- `instructions/reference/` 8 files need consolidation → target 4-5
- `session-end.sh` PROGRESS.md + memory/ warnings expected for meta-project
- `notes/` has 6 stale session artifacts — archive candidate

## Session 2026-07-21 (Analyze quality gate + notes archive)

### Done
- agent-analyze.md: expanded from 4 to 7 skills (context-canary, junior-to-senior,
  code-review-and-quality); reordered logically; Quality Gate (≥5 concrete
  findings with file+line); report sections: Context Check, Senior Review, Quality
- Archived stale premortems (07-07/07-08) → notes/old/
- Synced global/AGENTS.md → ~/.config (language persistence)
- Verified Directus 11 wildcard gotcha doc fix

### Next
- Consider running `analyze` on a real project to validate the new skill stack
- On Directus prod migration: remove admin_access, replace with per-collection grants
- Consider merging `instructions/reference/` (8 files → 4-5)

## Session 2026-07-20 (Directus MCP — per-project generated config)

### Done
- **Architecture:** Directus MCP is now per-project from `.env`. Removed the
  global `directus` block from `~/.config/opencode/opencode.jsonc` and deleted
  the `switch-directus` shortcut/logic everywhere. No global Directus MCP to
  switch — each project gets its own gitignored `opencode.jsonc`.
- **scripts/gen-opencode.sh** (new) — reads `.env` (`DIRECTUS_URL` +
  `MCP_DIRECTUS_TOKEN`), merges the global OpenCode config, writes a local
  `opencode.jsonc` with the per-project `directus` block.
- **Makefile** — added `mcp` target. **scripts/start.sh** — regenerates
  `opencode.jsonc` from `.env` before launching OpenCode.
- **templates/.env.example** (new) — `DIRECTUS_URL` + `MCP_DIRECTUS_TOKEN`
  placeholders; `init-project.sh` copies it to `.env` when absent.
- **instructions/directus-mcp-setup.md** — rewritten: enable MCP server, create
  Access Policy → Role → User → Static Token, `.env`, `make mcp`, open project.
- **global/AGENTS.md** — Session Start step 7 simplified (local `opencode.jsonc`
  used automatically; else warn to create `.env` + `make mcp`). Synced to
  `~/.config/opencode/AGENTS.md`.
- **README.md** — removed `switch-directus`; `## Directus MCP` now per-project.

### Known issues
- (none)

## Session Log

### 2026-07-16

- Done:
  - Full Harness audit → notes/harness-audit-2026-07-16.md
  - Reality-check annotation → notes/AGENTS.reality-check.md
  - Short & mean version → notes/AGENTS.short-and-mean.md
  - Project-level AGENTS.md in root (100 lines, harness-specific)
  - scripts/dod.sh — DoD checker (uncommitted + cyrillic + docs lag)
  - scripts/install-hooks.sh — installs pre-commit hook into .git/hooks/
  - hooks/pre-commit — blocks commit unless `make dod` passes
  - scripts/session-end.sh — session end checks (docs lag + PROGRESS + memory)
  - Pre-commit hook installed, verified blocking real commits
  - global/AGENTS.md: added `dod` shortcut, replaced Technology Standards with triggers table
  - init scripts: hook installation appended to init-project.sh and init-adopt.sh
  - Fixed session-end.sh SIGPIPE 141 bug (head -1 under set -o pipefail)
- Problems:
  - ~70% of Harness rules not enforced (documented in audit)
  - pre-commit hook didn't differentiate staged/unstaged on first run — fixed
- Next:
  - Replace context7 auto-trigger with honest manual rule (done 2026-07-17)
  - Add PROGRESS.md check to `make dod`

### 2026-07-17

- Done:
  - PROGRESS.md: stale no longer blocks, changed to warn only (8998a6d)
  - global/AGENTS.md: session start reduced 9→7 steps, doc check merged into session-end (66bb8c7)
  - scripts/start.sh — `make start` launcher for full session init (16ef9d8)
  - Makefile: added `start` target
  - Replaced automatic context7 triggers with "Honesty Over Guessing" rule in global/AGENTS.md
  - Updated templates/AGENTS.md context7 description to manual-only
  - tests/agents.bats — 14 tests (all scripts exist + bash -n + no TODO)
  - Makefile: added `test-quick` and `test` targets
  - `make test-quick` — 20/20 tests pass (6 templates + 14 agents)
- Problems:
  - context7 auto-trigger was aspirational and never enforced — replaced with honest approach
- Next:
  - Memory save: upgrade from warning to fail in `make session-end`
  - Documentation Session shortcut: remove auto-trigger, add manual `docs` shortcut

### 2026-07-17 (late)

- Done:
  - .session-ended guard: session-end.sh creates it, start.sh warns if missing/stale
  - .gitignore: added .session-ended
  - dod.sh step 5: docs matrix check — warns if code changed but no docs updated
  - dod.sh: renumbered 1-5 → 1-6
  - session-end.sh: creates .session-ended on close
  - start.sh: checks .session-ended on open, warns if missing or >1 day old
  - notes/AGENTS.reality-check.md: full update — all v0.3 fixes marked, compared vs audit/overview/workflow
  - session-end.sh: memory check upgraded from warning to fail if session has git changes
  - global/AGENTS.md: Documentation Session auto-trigger removed, `docs` shortcut added
  - scripts/update.sh: fixed /dev/tty bug — no-TTY auto-applies, interactive prompts use [ -t 0 ]
- Problems: none
- Next:
  - v0.4 planning — decide scope

### 2026-07-17 (v0.3 → v0.4 startup)

- Done:
  - Installed 8 skills from JuliusBrussee/skills (caveman, context-canary, fuck-slop, grill-me, interface-kit, junior-to-senior, last-20-percent, loop-factory)
  - Added junior-to-senior skill to global/skills/ and deployed via make update
  - global/AGENTS.md: updated codebase-health-check triggers (added "assess", removed "DRY, duplication, assess codebase")
  - global/AGENTS.md: added junior-to-senior skill entry with triggers "review, improve quality, make it better"
  - global/AGENTS.md: added "Function max 25 lines. Component max 150 lines." rule to Code Style
  - templates/AGENTS.md: synced all three changes
  - instructions/reference/03-skills-cheatsheet.md: added junior-to-senior and codebase-health-check
  - Moved 5 more skills to OpenCode config (context-canary, fuck-slop, interface-kit, last-20-percent, loop-factory)
  - Added all 5 skills to the Auto-Loading trigger table in global/AGENTS.md + templates/AGENTS.md
  - Removed 6 downloadable skills from global/skills/ (not in repo — installed via npx skills add JuliusBrussee/skills -y)
  - Updated scripts/install.sh: added npx skills add JuliusBrussee/skills -y + copy .agents/skills/ to OpenCode config
  - Updated scripts/update.sh: added JuliusBrussee skill enrichment on make update
- Problems:
  - Russian-language trigger removed from junior-to-senior — rejected by DoD cyrillic check, removed per user confirmation
- Next:
  - v0.4 planning
  - Test: fresh `git clone && make setup` on clean machine
  - Add .agents/ .claude/ skills-lock.json to .gitignore

### 2026-07-17 (v0.4 — continued)

- Done:
  - Pushed 3 commits: JuliusBrussee skills install, trigger table, skill repo cleanup
  - scripts/install.sh: added npx skills add + copy to OpenCode config
  - scripts/update.sh: added JuliusBrussee skill enrichment
  - global/skills/: removed 6 downloadable skills (installed via npx)
- Problems:
  - `make update` re-runs npx skills add, creates .agents/ + .claude/ + skills-lock.json artifacts in repo — need .gitignore
- Next:
  - Clean up .gitignore

### 2026-07-17 (v0.3 closing)

- Done:
  - dod.sh step 5: check_warn → check_fail — docs matrix now blocks commit
  - dod.sh step 5: exclude PROGRESS.md + notes/ from code check, add instructions/ as valid docs dir
  - dod.sh: replace head -1 with sed -n '1p' — eliminate SIGPIPE 141
  - global/AGENTS.md: removed Russian trigger words from Session End + DoD
  - global/AGENTS.md: added German session-end triggers (Ende, Schluss, fertig, tschüss, bis dann)
  - templates/AGENTS.md: synced from global
  - global/skills/session-end/SKILL.md, code-reviewer/SKILL.md: removed Russian
  - GUIDE.md, README.md, 02-opencode-commands.md: updated session lifecycle docs
  - ~/.config/opencode/AGENTS.md: auto-synced via make update
- Problems: none
- Next:
  - v0.4 — plan and execute

### 2026-07-19 (new-flow fix)

- Done:
  - scripts/init-project.sh: added `--no-open` flag — scaffolds project
    (copies templates, git init, hooks) without launching a second OpenCode
    instance. Used by `new` flow from inside OpenCode.
  - global/skills/harness-init/agent-new-project.md (+ synced to
    ~/.config/opencode/skills/): restructured into 3 phases:
    - Phase 0 — Scaffold: runs `make init PROJECT="$(pwd)" --no-open` BEFORE
      interview, so HARNESS.md/MEMORY.md/PLAN.md/PROGRESS.md/memory/ always exist
    - Phase 1 — fixed interview question order (Q1 name/purpose, Q2 team/auth,
      Q3 stage/deploy, Q4 integrations/sensitive, Q5 design/fields, Q6 plan) +
      HARNESS questions (critical paths, risk levels); MANDATORY restate (4.5)
      with explicit "yes" before any file is written; fill/REWRITE scaffolded
      templates in place (no generate-from-scratch)
    - Phase 2 — formatted hand-off report: lists created files, instructs user
      to open new session and type `start` (continues from roadmap M1)
  - templates/AGENTS.md: restored to PROJECT skeleton (was accidentally
    overwritten with global AGENTS.md) — placeholders only, no global content
  - templates/docs/CONTEXT.md + roadmap.md: cleaned of example domain data
    (Cook/Deduction/Hetzner/Tailwind) — structure + instruction comment only
  - Root cause fixed: `new` previously generated only 6 docs files and missed
    HARNESS/MEMORY/PLAN/PROGRESS/memory/ because the skill never called
    `make init` and ignored templates/
- Problems:
  - templates/AGENTS.md was a duplicate of global AGENTS.md — would have created
    a redundant mirror in every new project; corrected to project skeleton
- Next:
  - Touch-test the `new` flow in an empty folder; verify full file set appears
  - Fix Makefile known issues (duplicate `init` target, empty `setup` target)

## Session 2026-07-22 (vendor all skills — remove external dependencies)

Session language: ru

### Done
- **Vendored all skills**: copied all 70 skills from `~/.config/opencode/skills/` into `global/skills/`.
  No more dependency on superpowers plugin or JuliusBrussee GitHub repos.
- **Added YAML frontmatter** to 10 custom harness skills (code-reviewer, codebase-health-check,
  documentation, dod, frontend, harness-init, security, session-end, session-start, startup)
- **scripts/install.sh**: removed `opencode plugin add superpowers`, `npx skills add JuliusBrussee`,
  `.agents/skills/` copy — now only `cp -r global/skills/*`
- **scripts/update.sh**: same cleanup + changed from "add new only" to full `cp -r` overwrite
- **global/opencode-config.example.jsonc**: removed superpowers from `plugin` array
- **Removed `.agents/skills/`** — all skills now live in `global/skills/`

### Next
- Test clean `git clone && make setup` on a fresh machine
- On the new MacBook: run `update-harness` and verify all 70 skills land

## Session 2026-07-23 (analyze TARGET, post-commit hook, agent-analyze overhaul)

Session language: ru

### Done
- **agent-analyze.md** — полностью переписан Output format: narrative Architecture, Security текстом, Risks абзацами, source-маппинг к скиллам. Добавлены: Target detection, step 0 (git log diff), step 9a (findings diff), step 10a (verify file). Убран context-canary. Step 11 теперь на языке сессии.
- **analyze <path>** — шорткат в AGENTS.md: `analyze pages/Dashboard.vue` загружает скилл с TARGET. Задокументировано в README, INSTALL, GUIDE, make help.
- **hooks/post-commit** — авто-зеркалирование global/skills/ → ~/.config/opencode/skills/ после каждого коммита
- **install.sh + update.sh** — установка post-commit hook при setup/update
- **Документация** — README, INSTALL, GUIDE, Makefile help обновлены: analyze <path>, generic path examples вместо cook.vue
- **Проверка 4 анализов** — сравнили 0→1→2→4, подтвердили что изменения улучшили качество отчётов

### Known issues
- Post-commit hook не зеркалирует global/AGENTS.md — только skills/. Нужно копировать вручную или расширять hook.
- v0.3 ostatok практически закрыт (6 из 8 P0 решены). Можно начинать v0.4 (Sandbox).

### Next
- v0.4 Sandbox module — архитектура готова (notes/Harness/v0.4 - SANDBOX_ARCHITECTURE.md), можно начинать реализацию

## Session 2026-07-23 (adopt --no-open fix)

Session language: ru

### Done
- **Bug fix**: `agent-adopt.md` Step 0 no longer creates files from agent memory.
  Now calls `init-adopt.sh "$(pwd)" --no-open` — same pattern `agent-new-project.md`
  already uses with `init-project.sh --no-open`.
- **scripts/init-adopt.sh**: added `--no-open` flag parsing (matching init-project.sh).
  With `--no-open`: copies templates + hooks and exits without launching OpenCode.
- **make verify**: 9/9 passed. **bash -n**: all scripts OK.

### Next
- Test adopt on a real project

## Git Log

- `a8169f9` — docs(make): add analyze <path> to help output
- `ab23863` — docs: replace project-specific path examples with generic placeholders
- `7fef804` — docs: add analyze <path> usage to README, INSTALL, GUIDE; remove context-canary from skill stack
- `5c4862e` — fix: support analyze <path> shortcut with TARGET argument
- `5463601` — feat(analyze): TARGET scoping, session language for summary, report filename
- `88f6a1e` — chore: add post-commit hook to auto-mirror skills
- `f158e7b` — fix: replace head -1 with sed -n '1p' in dod.sh to avoid SIGPIPE
- `c1b8b3d` — fix: remove Russian trigger words from AGENTS.md, update docs
- `d9f5b12` — fix: dod.sh step 5 check_warn → check_fail, exclude PROGRESS.md + notes/
- `16ef9d8` — feat: add make start launcher
- `66bb8c7` — refactor: session start 9→7 steps, merge doc check into session-end
- `8998a6d` — fix: PROGRESS.md stale → warn not fail
- `80eb51b` — docs: add PROGRESS.md with v0.3 state, dod step 4 validates it
- `174e8c6` — fix: session-end.sh SIGPIPE on docs lag check
- `f152663` — feat: add make session-end script
- `e68336b` — docs: translate "What's Not Here" section to English
- `f3e424c` — feat: add project-level AGENTS.md, clean up architecture diagrams
- `f4d16d4` — fix: exclude dod.sh itself from cyrillic scan
- `d09012f` — feat: add make dod, pre-commit hook, fix Makefile

## Session 2026-07-19 (stack→skill map + sync cleanup)

Session language: ru

### Done
- **Stack → Required Skills** section added to `templates/docs/skills-cheatsheet.md`
  and `instructions/reference/03-skills-cheatsheet.md` (table: technology →
  skill folder → install command). Directus → `npx skills add directus`;
  TypeScript covered by `tdd` + `test-driven-development` (no standalone skill).
- **agent-new-project.md** — new step `4.4 SKILL GAP CHECK` before restate
  (4.5): reads the Stack→Required Skills table, matches against interview
  stack, `ls ~/.config/opencode/skills/<name>` per skill, shows ✅/❌ with
  install command. Informational only — does NOT block the interview.
- **Sync cleanup** — `global/skills/*` mirrored into `~/.config/opencode/skills/`:
  harness-init (agent-analyze, agent-adopt, SKILL), security (SKILL +
  06-directus-nuxt.md was missing), session-start, code-reviewer. All 25 skill
  files now in sync; AGENTS.md in sync.
- **session-start/SKILL.md** — output block translated RU→EN (English-Only Policy
  for global/ files).

### Known issues
- (none new)

## Session 2026-07-31 (dod.sh — docs-lag self-deadlock fix)

Chat language: ru

### Done
- **scripts/dod.sh step 3 (docs-lag)** — fixed self-deadlock in PRE_COMMIT mode:
  if the staged commit contains files under `docs/`, the check passes (that
  commit resets the lag). Previously the history-based check ran before HEAD
  updated, so the very docs commit that would fix the lag was blocked forever.
- Docs update: instructions/GUIDE.md + instructions/reference/02-opencode-commands.md
  now document the staged-docs behavior.
- Verified with A/B test on a temp repo (lag=4):
  - OLD dod.sh + staged docs file → blocked (deadlock reproduced)
  - NEW dod.sh + staged docs file → passed (fix works)
  - NEW dod.sh + staged non-doc file → still blocked (hook not weakened)
- `make test-quick`: 14/14 pass, `bash -n`: OK.

### Known issues
- (none new)

### Next
- Propagate fix to target projects: projects using the harness symlink get it
  automatically (no re-install needed).

## Session 2026-07-19 (rename existing → adopt)

Session language: ru

### Done
- Renamed shortcut `existing` → `adopt` (global/AGENTS.md + ~/.config/AGENTS.md
  + repo AGENTS.md + README + INSTALL + GUIDE).
- Renamed skill file `agent-init-existing.md` → `agent-adopt.md` (global/ +
  ~/.config), updated all cross-references (SKILL.md, agent-analyze.md, GUIDE,
  04-skill-stacks, README, INSTALL, PROGRESS).
- Renamed Makefile target `init-existing` → `init-adopt`; updated all docs.
- Renamed script `scripts/init-existing.sh` → `scripts/init-adopt.sh` (git mv),
  updated internal references + install-hooks.sh comment.
- Renamed `04-skill-stacks.md` section `existing-project` → `adopt-project`.
- All 25 skill files verified in sync (global/ ↔ ~/.config); AGENTS.md synced;
  bash syntax OK; no Cyrillic introduced.

### Known issues
- (none)

---

## Session — Directus MCP setup strategy

### Done
- Added `instructions/directus-mcp-setup.md`: full guide for the Directus MCP
  server — mcp service-account user creation (scope = developer's choice:
  read-only or read+write), global shared `Bearer` token in
  `~/.config/opencode/opencode.jsonc` (`type: remote`, `url`, `headers.Authorization`),
  per-project URL auto-correction on Session Start, per-project `opencode.jsonc`
  override, and `switch-directus` semantics.
- Updated `global/AGENTS.md` Session Start step 7: local project `opencode.jsonc`
  takes priority (fully overrides global, skips mismatch check); MCP URL now read
  from `mcpServers.directus.url` with `Bearer` auth. Synced to ~/.config/AGENTS.md.
- Shortened `README.md` `switch-directus` section to 3 lines + link to the setup guide.
- Added `opencode.jsonc` to `templates/.gitignore` (init-project.sh copies
  .gitignore only when absent — override stays per-project, gitignored).
- Added Directus `mcp` user reminder to hand-off of both `agent-new-project.md`
  and `agent-adopt.md`. Synced to ~/.config/skills/.
- All modified batch files verified Cyrillic-free; bats tests pass (14/14).

### Known issues
- (none)

---

## Session — README cleanup (top-level commands only)

### Done
- README.md: removed Fallback make-commands block, Symlink block, and From
  terminal block. Kept only OpenCode shortcuts (`new`/`adopt`/`analyze`/
  `update-harness`/`sync-templates`/`switch-directus`), Daily Workflow trigger
  words, and links to INSTALL.md / GUIDE.md. Terminal `make` commands remain
  documented in INSTALL.md and instructions/GUIDE.md.
- Verified no make command was lost — `make link`, `make init`, `make start`
  all still present in INSTALL.md / GUIDE.md.

### Known issues
- (none)

---

## Session 2026-07-21 (fix: agent-new-project.md — test_3 bugs)

Session language: ru

### Done
- **P1**: Removed duplicate step 11 from Phase 1 (design.md reminder inlined in Phase 2)
- **P2**: Added session language instruction before hand-off block
- **P3**: Reformatted hand-off with visual frames (━━━), ✅📋🚀⚠️ sections, marketplace URLs
- **P4**: Added skill gap box after step 4.4, repeated in hand-off
- **P5**: Added brainstorming explanation frame before step 5
- **P6**: Replaced weak batch-write rule with VIOLATION-level hard rule
- **P7**: Stripped template example data (#8966FA, Jost, h-56px, phosphor-icons) → TBD
- **P8**: Removed TypeScript pinning and example gotchas from templates/MEMORY.md
- **P9**: Changed step 4.4 from table-based gap to dynamic `ls` check
- **P10**: Updated instructions/reference/04-skill-stacks.md new-project section
- **Cyrillic cleanup**: Removed from 5 project files (agent-new-project.md ×2, design.md, MEMORY.md, 04-skill-stacks.md)
- **Mirror verified**: global/skills/ and ~/.config/opencode/skills/ agent-new-project.md are identical
- **make verify**: 8/8 passed

### Next
- Close session

## Session 2026-07-21 (ostatok reorg + cleanup)

### Done
- **`notes/harness/ostatok-po-versii-0.3.md`** — reorganised: deduplicated from ~15
  source docs, sorted P0→P3→DEAD→Completed, with priority tables
- **`notes/harness/ostatok-po-versii-0.3.full.md`** — created: full reference with
  per-document tables, colored status markers (🔴🟡🟢), no deduplication
- **`notes/AGENTS.reality-check.md`** → `notes/harness/old/` — moved out of root
  `notes/`, removed from git tracking (`git rm --cached`)
- **Status corrections**: marked superpowers issue ✅ (user confirmed resolved),
  stale question count ✅ (GUIDE/INSTALL/diagram already clean)
- New `notes/harness/old/` directory for archived documents

### Next
- Live-test cycle: `new` on empty project, `analyze` on RecipeBox/ItoCook,
  `adopt` on non-harness project, clean install on MacBook — fix real issues
- Then: backlog or Sandbox module

## Session 2026-07-21 (P15-P19 — template hints, gap→AGENTS, .env rule, PLAN comment, plan-main conditional)

Session language: ru

### Done
- **P15**: templates/HARNESS.md — Product Contract and Decisions to Inherit now have detailed hints with examples
- **P16**: gap check result → auto-write found skills to AGENTS.md Stack Skills + placeholder for missing
- **P17**: Hard rules — forbid creating .env directly (only .env.example)
- **P18**: templates/PLAN.md — comment at top explaining it's empty at new-time, filled during implementation
- **P19**: docs/plan-main.md — created only if Q-1 provided a file, otherwise deleted
- **P13-P14**: applied in previous session (P13 — language ack after Q0, P14 — final end block)
- All mirrors synced (global/ ↔ ~/.config/)
- make verify: 8/8 passed

### Next
- Live-test cycle on real projects

## Session 2026-07-21 (P20-P26 — Q-1 pre-fill, skill-gap hand-off, .env.example)

Session language: ru

### Done
- **P20**: Q-1 rewritten — files are PRE-FILL not interview replacement.
  Full interview Q1→Q6→HARNESS always runs, one question at a time.
  Files only pre-fill answers, agent confirms each before skipping.
- **P21**: Hard rule + step 8 — NEVER delete entries from skills-cheatsheet.md.
  Removed "trim" language, replaced with "ADD only, NEVER delete".
- **P22**: Hand-off now shows both ✅ found and ❌ missing skills
  (was only ❌ before).
- **P23**: AGENTS.md Stack Skills — clear Installed / Missing sections
  with uncommented paths for found, commented # ❌ for missing.
- **P24**: Phase 0 now verifies .env.example after scaffold; copies from
  templates/ if missing. Hard rule strengthened.
- **P25**: skills-cheatsheet.md — inline show→confirm→write requirement.
- **P26**: Hand-off NEXT STEPS — "Add docs/design.md" and
  "Add docs/plan-main.md" shown only if files NOT provided in Q-1.
- All mirrors synced (global/ ↔ ~/.config/); Cyrillic-free; make verify: 8/8

### Next
- Live-test cycle: run `new` with Q-1 files on a real project (test_6)

## Session 2026-07-22 (WSL2/Linux bugs + docs cleanup)

Session language: ru

### Done
- **install.sh**: OS dispatch (brew for macOS, curl for Linux) for uv + RTK;
  `export PATH` before `rtk init` on Linux; `~/.bashrc` PATH persistence;
  git identity prompt at end
- **Makefile**: `chmod +x scripts/*.sh` in setup target; `uninstall` = full
  removal with OS dispatch (brew/rm); new `uninstall-lite` target (harness
  only); new `self-check` target (syntax + permissions + diff)
- **verify.sh**: OS-aware error hints (brew for macOS, curl for Linux);
  new check: script permissions (git ls-files mode 755); added pass/fail
  helper functions
- **dod.sh**: step 7/7 — Self-check (bash -n on all scripts)
- **global/AGENTS.md**: DoD updated — self-check step; synced to
  ~/.config/opencode/
- **INSTALL.md**: Windows section rewritten — git identity step, daily
  workflow, tips (/mnt/c/, Windows Terminal), uninstall options, expanded
  comparison table; API key hint added to Step 5 (both macOS and Windows)
- **README.md**: deduplicated Update/Uninstall blocks under shared
  section; uninstall-lite added; Already Installed? removed (replaced
  by shared Update block)
- **Bug #1 fix**: `git update-index --chmod=+x` for install.sh and
  gen-opencode.sh (were 644 in git index)

### Known issues
- DoD docs matrix check doesn't see INSTALL.md or README.md as docs
  (only checks docs/ and instructions/) — needs fixing
- `make uninstall` removes ~/.config/opencode entirely — may delete
  non-harness configs if user added their own there

## Session 2026-07-22 (uninstall, bugs #5 #6 #8, clean superpowers refs)

Session language: ru

### Done
- **make uninstall** — added `uninstall` (+ symlink, skills, AGENTS.md) and
  `uninstall-full` (+ OpenCode CLI, RTK) targets
- **Bug #5**: `init-project.sh` — replaced relative `templates/` paths with
  `$SCRIPT_DIR/../templates/` (works from any directory)
- **Bug #6**: `install.sh` version check updated `v1.17.20` → `v1.18.4`
- **Bug #8**: `agent-new-project.md` — Phase 0 now asks user confirmation
  before scaffold
- **README.md** — restructured: Quick Start → macOS install block (one code
  block, 6 steps) → Update/Uninstall; removed `chmod +x` workaround,
  removed `git pull` from Already Installed (handled by `make update`)
- **INSTALL.md** — removed `chmod +x` workaround, fixed outdated manual steps
  (config already auto-copied)
- **Superpowers references** — cleaned from GUIDE.md, 03-skills-cheatsheet.md,
  05-skills-inventory.md, 02-opencode-commands.md, 01-harness-overview.de.md,
  templates/docs/skills-cheatsheet.md, verify.sh
- **Makefile** — added `uninstall` + `uninstall-full` to .PHONY and help
- `make verify`: 8/8, `bash -n`: all scripts pass, committed + pushed

### Next
- Windows WSL2 testing when available
- Bug backlog (none remaining in ostatok)

## Session 2026-07-24 (adopt stabilization — P16-P24)

Chat language: ru

### Done
- **P16**: per-file confirmation → batch approval before generation
- **P17**: design.md extraction from tailwind.config.ts, fonts, CSS, icons
- **P18**: skill gap check for AGENTS.md Stack Skills
- **P19**: hand-off with commit/push questions after summary
- **P20**: CONTEXT.md source priority: code → analysis → grill, min 10 terms
- **P21**: ISO language code enforced in Q0 (ru not русский)
- **P22**: dod.sh Cyrillic scan — line-level with docs/audits/ and Chat language exceptions
- **P23**: skills-cheatsheet — copy template, append project section
- **P24**: skill gap section in hand-off block
- Restored domain-modeling skill loading after P20 accidentally removed it
- Fixed hand-off to auto-commit then show summary, push after end
- Fixed Russian text in skill files (English-only policy)
- Two successful adopt test runs (ducito + ticket_tracker) — confirmed stable
- Created agent-fix.md design spec

### Known issues
- Context.md quality still varies between runs (domain-modeling skill application is inconsistent)
- Chat language instruction still competes with file generation (agent writes files in session language before reading Step 4 switch)

### Next
- Implement agent-fix.md (fix shortcut) ← DONE
- Test adopt on a non-trivial project stack

## Session 2026-07-24 (fix shortcut implementation)

Chat language: ru

### Done
- **agent-fix.md** — new skill: reads latest analysis report from docs/audits/, parses findings by section (Security C/H/M, Senior Review B/M), fixes in 3 phases (CRITICAL+BLOCKER → HIGH+MAJOR → MEDIUM) with per-finding verify gates and user confirmation (y/n/stop) after each fix
- **Q0 language check** — added to agent-fix.md matching agent-adopt.md/agent-analyze.md
- **Empty phase handling** — if section has no [C]/[H] findings, skip phase gracefully
- **Shorcuts** — `fix` and `fix <path>` added to global/AGENTS.md and ~/.config/opencode/AGENTS.md
- **Verified on 2 real reports** — ticket_tracker + ducito confirmed section format and M-prefix collision (Senior Review Majors vs Security Medium)
- **self-check:** `make verify` 9/9 passed, `bash -n` all OK, no Cyrillic in changes, no trailing whitespace

### Known issues
- DoD step 5 (docs matrix) — false positive on skill-only changes FIXED
  (2026-07-30): same-day instructions/CHANGELOG.md entry now satisfies the
  check. See scripts/dod.sh Step 5.

### Next
- Test `fix` on a real project with audit report — DONE (ticket_tracker, 3 test runs: all, file, ID)
- If needed: add `stop` → auto-commit and exit logic (planned but not tested yet)*

## Session 2026-07-24 (frontend-behavior + Playwright verify gate)

Chat language: ru

### Done
- **frontend-behavior/SKILL.md** (new) — static UI analysis for forms, buttons, nav, states, modals, accessibility, auth. 9 categories, [U1]/[U1-pw] findings. Two modes: analyze + standalone `ui <path>` shortcut.
- **agent-analyze.md** — frontend-behavior added to skill stack (position 3), new `## UI Behavior` section in report, `[U` added to diff grep.
- **agent-fix.md** — U prefix added to section mapping (Phase 2). Verify: U-pw → PLAYWRIGHT direct, U → static, path-based → ask. TARGET pattern `[CBMHU]`. Dedup: C > B > U > H > M.
- **agent-e2e.md** (new) — Playwright verify gate sub-protocol. Called from agent-fix when verify is PLAYWRIGHT. Writes + runs test, returns PASS/FAIL.
- **global/AGENTS.md** — added `ui` and `ui <path>` shortcuts.
- Architecture: single Playwright engine (agent-e2e) shared between fix and ui shortcut. Path-based detection replaced by explicit [U/U-pw] prefix.
- make verify 9/9, bash -n all clean, no Cyrillic.

### Next
- Test full flow: analyze → [U] findings → fix U1 → agent-e2e writes test
- Test `ui pages/Login.vue` standalone
- Consider pre-commit hook running make verify

### Fix 2026-07-24 (same session)
- **frontend-behavior/SKILL.md** — Fixed -pw suffix generation: replaced `→ **[U1-pw]**` with `→ Finding (e2e)` in checklist, added explicit numbering rule (e2e → `[U<N>-pw]`). Expanded API detection to include `useAsyncData`, `useLazyAsyncData`, store actions, `ref()` + `onMounted()`, `api/` paths.

## Session 2026-07-27/28 — agent-e2e full overhaul + fix-ui hardening

### Done
- **agent-e2e.md**: added @playwright/test check (step 0), guard on config values (headless:false, slowMo:2000), between-retry restrictions (only read error/edit spec, never devtools/context7/kill processes), `run-playwright-verify.sh` script (replaces fragile bash while-loop that broke in zsh), canonical scroll block alignment when reusing existing spec files
- **agent-fix-ui.md**: step 3.4 rewritten from optional advice to MANDATORY gate (must load agent-e2e before any playwright command), step 0 changed from `head -1` to aggregate ALL reports + dedup by file:line
- **frontend-behavior/SKILL.md**: new numbering rules (never combine findings, scan-all-files list), expanded Modals/Dialogs search to catch `<transition>`+`v-show`/`v-if` overlay pattern
- **agent-fix-ui.md Hard Rules**: three TARGET types documented: ID/report path/component path
- **run-playwright-verify.sh**: created in `scripts/` (not `global/scripts/`), 100755 in git, auto-available via `~/.opencode-harness` symlink

### Key bugs caught
- zsh parse error on `&& while` — compound command after `&&` breaks. Fixed by extracting retry loop into standalone script
- agent skipped loading agent-e2e.md entirely, ran playwright directly from fix-ui context. Fixed by MANDATORY gate

### Note — templates/AGENTS.md
- This file is a PROJECT TEMPLATE with `{{PLACEHOLDER}}` syntax, used by `make new` / `make adopt`.
- Do NOT overwrite with `global/AGENTS.md`. Only sync relevant shortcut additions.
- Other templates checked: HARNESS.md, MEMORY.md, PLAN.md, PROGRESS.md — all clean.

### Next
- Deploy to target project, run `fix-ui U2-pw` to verify the full chain: MANDATORY gate → agent-e2e load → retry-guard script

## Session 2026-07-28 (afternoon) — agent-fix.md: verify strength + UNIT_TEST_REDGREEN

### Done
- **agent-fix.md** — complete overhaul:
  - New Step 1a (classify verify strength): C/B → FUNCTIONAL, H/M-major → FUNCTIONAL_PREF, M-medium/L → GREP_OK. grep-only is a violation for C/B.
  - Pure function detection criteria + UNIT_TEST_REDGREEN verify gate type
  - Vitest session flag (ask once per session, never again)
  - Red-green protocol in fix loop: write test → FAIL → fix → PASS
  - Fallback for no-Vitest: `curl / node -e / python3 -c / grep` per function nature
  - Dedup + verify tier by highest-severity prefix
  - `tests/unit/` directory auto-created if absent
  - 11 new Hard Rules (verify strength tiers, unit test scope, Vitest flag, red-green order)
- `PROGRESS.md` — Last commit synced to HEAD (84ca4e2)
- `make test-quick`: 20/20 pass, `make self-check`: OK

### Known issues
- Need live test on target project to confirm agent actually follows red-green protocol (yesterday's principle: text rules get bypassed)

### Next
- Commit + make update → test on ticket_tracker/ducito: `fix C1` with pure function expectation

## Session 2026-07-28 (late) — live test on ducito + "Next?" barrier fix

### Done
- **Live test on ducito**: `fix C1` — agent correctly followed UNIT_TEST_REDGREEN protocol (vitest install → write test → FAIL → fix → PASS → verify). Configuration workaround: setup.ts + export for vitest compatibility with Nuxt server routes.
- **Stop no longer auto-commits**: agent-fix.md + agent-fix-ui.md — `stop` now appends Resolved, updates PLAN.md, exits. User decides when to commit.
- **Verify + "Next?" merged**: agent-fix.md + agent-fix-ui.md — verify output template now REQUIRES `> [ID] — verify: [TOOL] (PASS/FAIL)` + `> Next? (y/n/stop)`. Agent cannot show verify result without asking "Next?" and waiting for answer before `mark [x]`.
- Commits: `15d96a3` (feat: verify strength), `b4af051` (fix: stop no auto-commit), `01692fa` (fix: verify+Next? merged)
- `make test-quick`: 20/20 pass, `make self-check`: OK

### Known issues
- dod.sh docs matrix — skill-only `global/skills/` changes now pass via a
  same-day instructions/CHANGELOG.md entry (fixed 2026-07-30). `--no-verify`
  is never required; see Hard Limits in AGENTS.md for why not to use it.
- Nuxt server routes can't be directly imported in vitest (requires setup.ts mock) — documented in memory

### Next
- Fix remaining findings in ducito (H2, H3, M1-M10)
- Ship v0.4 Sandbox module

## Session 2026-07-28 (analyze-logic skill)

Chat language: ru

### Done
- **agent-analyze-logic.md** (new) — skill for finding uncovered business logic: grep for export function/use[A-Z]/defineEventHandler, priority rules (finance=HIGH / flows=MEDIUM / formatting=LOW), mandatory test cases >=3 with business rules extracted from code, mock annotations for composables
- **agent-fix.md** — added L-prefix: section mapping (Logic Analysis -> Phase 1), verify tier (UNIT_TEST_REDGREEN always, never curl/grep)
- **global/AGENTS.md** — shortcuts: analyze-logic, analyze-logic <path>, fix-logic, fix-logic <ID>
- **~/.config/opencode/** — mirrored AGENTS.md + skills
- `make test-quick`: 14/14 pass, `make self-check`: OK

### Known issues
- Post-commit hook does not mirror global/AGENTS.md — only skills/. Need to copy manually or extend the hook.

### Next
- Test analyze-logic on itocook project
- Consider adding AGENTS.md mirroring to post-commit hook

## Session 2026-07-28 (multi-runner + mandatory output block)

Chat language: ru

### Done
- **agent-fix.md** — universal test runner detection: vitest/jest/pytest/phpunit/go_test
  with per-runner install confirmation (always ask)
- Runner-specific test syntax and run commands per runner
- MANDATORY OUTPUT BLOCK: 'will fail if X breaks because Y' consolidated
  with verify result + Next?
- ReferenceError handling restricted to vitest/jest only
- VITEST_READY renamed to RUNNER_READY throughout
- PATH fix: uncommented .local/bin in .zshrc
- 3 commits this session: c8fd0de, fbdc1c5, 8f2a1a2

### Known issues
- Post-commit hook does not mirror global/AGENTS.md — only skills/
- mcp-server-git crashes with Python error on stdio (pre-existing)

### Next
- Test fix-logic L4 on itocook with new coverage protocol
- Test on non-JS project (pytest/phpunit) when available

## Session 2026-07-29 — Makefile tab fix + .env denied handling in security skill

Chat language: ru

### Done
- **Makefile line 23**: fixed missing tab separator in `uninstall-lite` help echo (two spaces before tab → just tab)
- **security/01-auth-and-secrets.md**: added `.env access denied handling` section — when user denies `.env` access, agent skips gracefully, notes `⚠️ .env not scanned — user denied access`, and continues analysis. Applied to both `global/skills/` and `~/.config/opencode/skills/`
- `make verify`: 9/9 passed, `bash -n`: all scripts OK, no trailing whitespace

### Known issues
- (none new)
