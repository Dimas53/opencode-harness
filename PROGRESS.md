# Progress Log

> Older sessions: [docs/progress-archive/](docs/progress-archive/)

## Current Status

> ### START HERE NEXT SESSION — 4 confirmed gaps found on a live project (2026-08-07)
>
> A real session in the user's Nuxt project exposed 4 design gaps in what
> this harness ships. All verified against code, not memory — and NOT a
> stale-project problem (`~/.config/opencode/AGENTS.md` is byte-identical
> to `global/AGENTS.md`, so the agent read exactly the current text):
>
> - **A. `session-end.sh` is unreachable from the "end" trigger.**
>   `global/AGENTS.md` `## Session End` describes 6 manual steps and never
>   mentions the script or the `docs` shortcut. So everything added to it
>   on 2026-08-06 (T-G2 docs-completeness Step 4, T-F4 audit-trail
>   auto-append, Retro nudge) never fires in a real session. Root cause,
>   honestly: the mechanism was verified on a fixture, but nothing ever
>   checked whether anything *invokes* it in the live flow.
> - **B. `.dod-run.log` is documented nowhere agent-facing** — an agent saw
>   the unfamiliar file and deleted it as junk, silently killing the audit
>   trail. Only mentioned in CHANGELOG and inside the scripts.
> - **C. DoD product steps 6/7/8 (Safety check, Skill feedback, Cleanup)
>   get lost behind `dod.sh`'s 8-step output** — the gate's output becomes
>   the de-facto checklist and those three aren't in it.
> - **D. `## Session End` step 2 ("git add and git commit if uncommitted")
>   contradicts `## Behavior` ("NEVER commit without explicit user
>   confirmation")** in the same file. The live agent followed Behavior,
>   i.e. it chose better than the written protocol.
>
> - **E. Stale skills are live on this machine and no update command
>   removes them.** A live agent report listed `session-start` under
>   "Skills loaded" — that skill was deleted from the repo on 2026-08-03
>   (`d6e4a16`). Confirmed by `ls`: `~/.config/opencode/skills/` still
>   holds `session-start` and `requesting-code-review`, neither of which
>   exists in `global/skills/`. Counterintuitive part, verified in code:
>   `update-project` never touches skills at all (grep: 0 hits), and
>   `update-harness` only *prints* the stale list (C-DEC-mirror =
>   warn-only, never delete). So "the update command will clean it up" is
>   wrong — it needs a manual `rm`, or a deliberate revisit of
>   C-DEC-mirror. Also re-check hooks/.agentignore/templates in each known
>   project via `update-project` (the still-deferred T-H6 step 3).
> - **F. Nothing verifies the shortcut list stays complete.** Both
>   `update-harness` and `update-project` are present today (21 shortcuts,
>   checked) — but no mechanical check ties a shortcut to an existing
>   target, or a new script to the list. Same class as A: the mechanism
>   exists and nothing points at it. Worth a check in
>   check-propagation.sh.
>
> Full write-up with fix directions:
> `notes/Harness/implementation-plan-2/GENERAL-REPORT.md`, top block,
> the red "must verify next session" section (it's in Russian there,
> like the rest of that file).

Phase: implementation-plan-2 is essentially complete. The 2026-08-06
second session went through all 20 open decisions in
06-open-decisions.md with the user (one left explicitly deferred:
F-DEC-2, eval-gate CI vs local), ran both A2 technical investigations
for real, then executed every ticket those decisions unblocked (Wave C
tail, Wave B tail, Wave E, Wave G Block 1, Wave F Block 1/2, M1's cheap
subset — 15 commits). A follow-up audit against GENERAL-REPORT.md
(2026-08-07) found 3 tickets whose DECISION had been recorded but whose
CODE was never written (T-H1 step 1, T-H3 Problem B, T-H5 step 5) — all
three closed same-day, 4 more commits, each verified end-to-end
(behavioral bats tests / real client-fixture runs), not just read.
Only remaining known gaps: **F-DEC-2** (user deferred), **T-F5's actual
stack-conventions.md feature** (M1 unblocked it but the feature itself is
new, substantial work not built), **M1's heavy content** (ARCHITECTURE.md
generic skeleton, Symfony/Python skills-cheatsheet rows), **T-F4 part 3
(retry-limit-escalation)** (scenario written, not calibrated/run),
**`verify.sh` not checking MCP servers respond** (never had a ticket),
**Safety Gates** (12 of 13 rows still text-only, permission.bash covered
1), and **real `update-project` run against karriere-page-ito/itocook**
(user said not yet). Full breakdown with ✅/⚠️/🟡/🔵 per finding:
`notes/Harness/implementation-plan-2/GENERAL-REPORT.md` (top block +
inline annotations). Per-ticket detail: 2026-08-06/07 session entries
below and `06-open-decisions.md`.
Last commit: (this session, see below)
Chat language: ru

## Session 2026-08-07 (report audit + 3 closed gaps)

Chat language: ru

User asked for a report: go through GENERAL-REPORT.md, mark every
finding done/not-done with the ticket that closed it, and put
not-yet-done items in one block at the top. While annotating, cross-
checked each "decision resolved" claim from the prior session against
actual code (not memory) — found 3 tickets where the DECISION had been
recorded in `06-open-decisions.md` but the corresponding CODE was never
written: **T-H1 step 1**, **T-H3 Problem B**, **T-H5 step 5**. Reported
this honestly instead of glossing over it. User asked to close all
three now, then fix the report afterward.

### Done
- **T-H1 step 1**: `scripts/dod.sh` Step 5 (docs-matrix) now branches by
  `IS_HARNESS_REPO` — harness repo keeps its `CODE_DIRS` list, client
  projects get a new `is_doc_file()` inversion (H-DEC-1). `fail` if code
  changed and no doc at all was touched; `warn` if only `PROGRESS.md`
  was touched. Surfaced and fixed a real bug in `check-propagation.sh`
  Rule 3 (its awk heuristic matched `if [ "$IS_HARNESS_REPO" = "1" ]`
  regardless of indentation, mispairing the new nested `if` with an
  unrelated `fi` — narrowed to `elif`, which is what the pre-existing
  Steps 6/7 actually use). Verified with 3 real `PRE_COMMIT=1` runs on a
  client fixture (fail/warn/pass) + 2 new bats cases; fixed an existing
  bats fixture (skill-only-fallback tests) that wasn't marked as the
  harness profile and started exercising the wrong branch once profile
  branching existed. 35/35 bats green.
- **T-H3 Problem B**: `global/AGENTS.md`'s "Working in External / Client
  Projects" renamed to "Working in Non-Harness Projects (guest mode)"
  with an explicit boundary line (H-DEC-3 = a: applies only without
  `HARNESS.md`/`memory/`). Removed the two bullets that contradicted DoD
  in adopted projects; kept the rest (never in conflict). German
  overview doc's summary line updated to match.
- **T-H5 step 5**: new `templates/ci/github-actions-dod.yml` +
  `gitlab-ci-dod.yml` (H-DEC-4 = a) — both clone `opencode-harness`
  fresh into the CI runner and invoke `dod.sh` against the client
  project's checkout (safe: `dod.sh` never references its own script
  location, only CWD-relative paths). Installation is opt-in — new Q-CI
  interview question in `agent-adopt.md`/`agent-new-project.md`, asked
  once, right after the language question, never installed silently.
  Extended `check-propagation.sh` Rule 2 with the same `propagation-ok:`
  marker Rule 3 already used, for the `.github/workflows` path being
  *created* inside the client project (not a stale reference).
- **`GENERAL-REPORT.md`** fully annotated: new top block listing what's
  genuinely not done (now updated post-fix — only the items in Current
  Status above remain), plus inline ✅/⚠️/🟡/🔵 verdicts with ticket IDs
  under every finding in the original report.

3 commits (`feat(H1)`, `feat(H3)`, `feat(H5)`), each with DoD passing,
each independently verified (not just "ticket says decision resolved,
assume done").

## Session 2026-08-06 (second session — all 22 decisions resolved, waves executed)

Chat language: ru

User came back after the previous overnight session (below) had stopped
on 22 open decisions. Went through `06-open-decisions.md`'s full list
with the user in batches (via AskUserQuestion, mini-comment per question
so the user could decide informed), then executed every ticket the
decisions unblocked, in the recommended order (A4 in
`11-open-questions-and-blocked.md`: C → B → E → G → F). Full per-ticket
detail is in `instructions/CHANGELOG.md`'s 2026-08-06 entries (14 new
commits); this is the cross-cutting summary.

### Decisions
All 20 decisions in `06-open-decisions.md` resolved except one
explicitly deferred by the user: **F-DEC-2** (eval-gate: CI-job vs local
pre-merge) — user leans CI-job but wants to think about it more, marked
"deferred" not "decided," T-F2 stays unbuilt. Also ran the two A2
technical investigations for real (not just "confirmed a mechanism
exists on paper"):
- **Headless agent run:** `opencode run --auto --format json "<prompt>"`
  genuinely executes multi-step tasks (real file writes, real shell
  commands) and returns a structured, parseable JSON event stream — a
  real multi-step task, not just `echo ok`. Unblocks T-F2/T-F3 technically
  (F-DEC-2 itself is still the user's call).
- **OpenCode message hook (for a code-level skill-router):** confirmed via
  cross-checked docs + a GitHub issue that no hook sees the user's message
  text before that turn's system prompt is built —
  `experimental.chat.system.transform` gets `{sessionID, model}` only;
  `chat.message` sees the text but a turn too late. Same-turn
  deterministic routing isn't buildable with the current plugin API.

### Wave C tail (T-C3, T-C4)
`hooks/post-commit`/`install.sh`/`update.sh` now print (not auto-delete)
skills present locally but absent from the repo, after every mirror
(C-DEC-mirror = warn-only). `start.sh`'s session-not-closed messages
reworded from `⚠`/coercive phrasing to honest `ℹ` informational text
(C-DEC-startguard). `install.bat` removed (D-DEC-1 — confirmed zero doc
references, WSL2+install.sh is the only documented Windows path).

### Wave B tail (T-B2/B3/B4, T-B5) + new finding
B-DEC-1 = supersede: `executing-plans`/`writing-plans` get a SUPERSEDED
banner pointing to `planning-and-task-breakdown` +
`incremental-implementation`, body left untouched.
`brainstorming/SKILL.md`'s terminal handoff redirected off the now-
superseded `writing-plans` (5 places) — otherwise the supersede would've
been incomplete, brainstorming was the only path in. Also fixed a
branded-path leak the original grep missed (`docs/superpowers/specs/` →
`docs/specs/`). B-DEC-2 = anonymize: ItoCook's real domain/container
names/DB creds in `security/03,04,05.md` replaced with placeholders.
New finding resolved: `brainstorming/scripts/server.cjs` (vendored
companion server) unconditionally loaded a remote brand image from
primeradiant.com on every page render — removed the whole
telemetry/branding apparatus, no remote calls left in that file.

### Wave E — capability deny-by-default (T-E1, T-E2)
`global/opencode-config.example.jsonc` gets a `permission.bash` block:
`git commit --no-verify*` = `deny` (physically blocked by OpenCode, not
just discouraged in text), `push --force`/`push`/`reset --hard`/`rm -rf`
= `ask`, everything else `allow` (E-DEC-1 hybrid). Checking propagation
(E-DEC-2) found a real bug: `gen-opencode.sh` used strict `json.load()`
on the global config, which would've crashed on the first `//` comment
the new permission block introduces — fixed with the same JSONC-safe
stripper `merge-opencode-config.sh` already has (T-G-U2), verified
end-to-end in a scratch project.

### Wave G Block 1 (T-G1-G4, T-G-U6)
DoD table rows for `schema.md`/`flows.md` now explicitly stack-conditional
(DB/Directus-only, not universal). New Step 4 in `session-end.sh` warns
on stale doc placeholders after 4+ sessions (real bug found+fixed while
testing: `grep -c`'s "0 + exit 1" behavior was corrupting a count via
`|| echo 0`). `init-adopt.sh` skips `docs/design.md` for non-UI projects
(no package.json), never touching a pre-existing file. `agent-analyze.md`
gets honest stack detection with a generic-pass fallback instead of
silently assuming Nuxt. `templates/AGENTS.md`'s 4 pure-harness-text
sections wrapped in `HARNESS-MANAGED` markers + new
`update-project.sh --refresh-agents` to pull harness rule improvements
into already-adopted projects without touching filled-in project content
— found and fixed a `set -e`/`pipefail` bug in the same pass. All
verified end-to-end on real client-project fixtures, not just read.

### Wave F Block 1 (T-F1, T-F3, T-F4 — T-F2 stays deferred)
`global/rules/dod.yaml` is now the canonical DoD step list; new
`gen-rules.sh --check` verifies both `AGENTS.md` and `dod/SKILL.md`
against it (stronger than the old cross-file-only check). Skill-router
degraded to a mandatory Auto-Loading text scan per the A2 finding — new
`skill-router-auth` eval scenario (+ new `run-scenario-headless.sh`, using
the now-confirmed headless mode) **honestly FAILED in both real runs** —
left as a real baseline, not tuned to pass. `dod.sh` now logs every run
to a local `.dod-run.log`; `session-end.sh` mechanizes the audit-trail
section it already documented (T-H5) into `memory/YYYY-MM-DD.md`, plus a
non-blocking nudge for a missing `## Retro` section.

### Wave F Block 2 (T-F7)
`requesting-code-review` skill removed entirely (M2). `tdd/` turned out
not to exist in the tree at all (M3, nothing to merge). Ported
`systematic-debugging`'s "3+ fix attempts → stop" rule into
`debugging-and-error-recovery` (which lacked it), added pointers to its 3
still-useful companion technique files, marked
`systematic-debugging/SKILL.md` SUPERSEDED.

### M1 (cheap subset only)
Auto-Loading's UI/Frontend row no longer hardcodes nuxt/vue for every UI
project; `.env.example` marked explicitly Directus-only/optional;
`HARNESS.md`'s Framework example broadened past Nuxt+Directus. Heavy
content (ARCHITECTURE.md generic skeleton, Symfony/Python
skills-cheatsheet rows) stays deferred — M1's own scoping, hours of
authored content, not this pass.

### Explicitly NOT done this session (by user instruction or genuine scope)
- **F-DEC-2** — deferred by the user, not decided.
- **T-F5's actual feature** (stack-conventions.md freshness gate via
  fetch MCP) — M1 unblocked it, but building it is separate substantial
  new work, not a quick fix; not started.
- **Real `update-project` run against `karriere-page-ito`/`itocook`** —
  user explicitly said not yet this session, wants to try it himself
  later. All the fixes accumulated over both 2026-08-06 sessions
  (hooks, `.agentignore`, HARNESS-MANAGED markers, everything) are still
  sitting undelivered to those two real projects until that run happens.
- **retry-limit-escalation scenario** — written as infrastructure/
  description only (same precedent as T4.3's red-team-pressure), not
  actually run — calibrating a fixture that reliably needs 3+ attempts
  is its own effort, better spent once T-F2 exists to consume it.

## Session 2026-08-06 (autonomous — implementation-plan-2 Wave H+)

Working the order H0 → H1 → H2 → H3 → C → B → A → D → E → G → H4 → F → H5 →
H6/H7 per user's overnight instructions. Details of what's done/skipped are in
notes/Harness/implementation-plan-2/11-open-questions-and-blocked.md (not
versioned — see .gitignore). Summary of commits this session:

- T-H0: `unadopt` now removes both git hooks (was leaving `post-commit`
  behind, which rolled back every future commit in a project after the
  harness was removed from it). Logic moved to `scripts/unadopt.sh`.
- T-H1 (partial — steps 3-4 only, steps 1-2 blocked by H-DEC-1/H-DEC-2):
  `dod.sh` steps 7-8 no longer print `✓` for checks that never ran in a
  client project.
- T-H2: fixed 12 unreachable commands/paths in `global/AGENTS.md`,
  `harness-init/SKILL.md`, `agent-adopt.md`, `templates/AGENTS.md`,
  `templates/.agentignore`, `templates/.env.example` — all now resolve from
  any client project.
- T-H3 (partial — Problem A only, Problem B blocked by H-DEC-3): the
  "harness project?" detector in `global/AGENTS.md` now checks for
  client-project artifacts (`HARNESS.md`/`memory/`) instead of meta-repo
  properties, so JSDoc requirement no longer contradicts DoD step 3.
- Wave C (T-C1..C4): fixed Directus token leak on `init-adopt` (fail-closed
  `gen-opencode.sh` + `.gitignore` merge), tilde bug crashing
  `sync-templates.sh`, BSD-only `date -v` in `start.sh` (T-C3 partial —
  step 2 blocked by C-DEC-startguard), and `.bak` files leaking into the
  skill mirror (T-C4 partial — step 1 blocked by tooling permission, step 3
  by C-DEC-mirror).
- Wave B (T-B1, T-B2 partial, T-B3 partial, T-B4, T-B6 done; T-B5 skipped
  — blocked entirely by B-DEC-2): purged/marked `superpowers:` phantom
  refs, de-branded the plan-output path, fixed non-harness voice
  ("human partner", "you'll be replaced"), removed `--no-verify` as a
  presented option in `agent-adopt.md`. New out-of-scope finding logged:
  `brainstorming/scripts/server.cjs` vendored telemetry + remote brand
  fetch — see 11-open-questions-and-blocked.md.
- Wave A (T-A1..A5, all done, no decisions blocking): GUIDE.md DoD
  duplicate removed (pointer to canon), 12 phantom skills removed from
  `instructions/reference/03-skills-cheatsheet.md` (incl. `directus`
  falsely claimed "Vendored in harness") + same phantoms found and fixed
  in the K3 template `templates/docs/skills-cheatsheet.md`, skills-inventory
  count corrected (62 claimed → 70 real, table marked non-current instead
  of re-hardcoding), German overview `session-start` → `startup`. New
  `scripts/check-docs-refs.sh` (`make check-docs-refs`) is a mechanical
  backstop against this class of drift recurring.
- Wave D: T-D2 done — new `tests/dod.bats` (9 real behavioral cases,
  verified they catch injected regressions), found+fixed a real
  `init-adopt.sh` bug along the way (BSD `cp -n` exit-1-on-skip crashes a
  second adopt run under `set -e`). T-D1 skipped entirely — blocked on
  D-DEC-1, the ticket itself forbids committing without the user's choice.
- Wave E: both tickets skipped entirely — T-E1 depends on E-DEC-1 for the
  whole config shape (rollout scope), T-E2 explicitly gated on E1 landing.
- Wave G (T-G5 done, T-G1..G4 skipped — each depends on an open decision
  with no safe subset): `templates/MEMORY.md`/`docs/CONTEXT.md` Gotchas
  canon separated (cross-project vs per-project), `PLAN.md`/
  `docs/plan-main.md` headers cross-reference each other.
- T-G-U3 (⚠ flagged for human review, see CHANGELOG — wave header asks for
  line-by-line review of Block 2): `scripts/sync-templates.sh` renamed to
  `scripts/update-project.sh`, extended to check the whole `templates/docs/`
  subtree (not just root `*.md`) and to detect+reinstall drifted/missing
  git hooks. Never overwrites existing files. Tested on scratch projects
  (fresh adopt = up to date; incomplete manual project = detects and fixes
  everything, then idempotent on rerun).
- T-G-U1: `global/AGENTS.md` wrapped in `HARNESS-MANAGED START/END`
  markers; `update.sh` now surgically replaces only that region instead of
  overwriting `~/.config/opencode/AGENTS.md` wholesale (was auto-applying
  on no-TTY with zero confirmation). No markers found (old install) → backs
  up + shows diff + requires explicit `y`, never auto-applies. Verified on
  a fixture with custom content before/after the block — both survive.
- T-G-U2: `update.sh` now also merges `opencode.jsonc` (new MCP servers +
  future `permission` block), via a new shared
  `scripts/merge-opencode-config.sh` also used by `install.sh` (dedup, was
  two copies of the same node script). Found+fixed a real pre-existing bug
  while at it: the JSONC comment-stripper corrupted any config containing
  `"$schema": "https://..."` (which all of them do) by treating the `//`
  inside the URL as a comment start.
- T-G-U4: swept remaining live `sync-templates` mentions to `update-project`
  in `README.md`/`GUIDE.md`/`INSTALL.md`; added the "two commands, two
  scopes, this order" bridge explanation to `INSTALL.md` that previously
  existed nowhere.
- T-G-U5: already fully covered by Wave C T-C4 — verified, no new code.
- T-G-U6 (partial): verified `update.sh` never touches a project's
  `AGENTS.md` and `update-project` never touches an existing one (both
  true via T-G-U1/T-G-U3). Did NOT retrofit HARNESS-MANAGED markers into
  `templates/AGENTS.md` for structural-section propagation — that template
  interleaves harness text and interview-filled project content with no
  clear boundary today; needs its own design pass, not an autonomous
  guess. See 11-open-questions-and-blocked.md.
- T-H6 (partial): new `instructions/PROPAGATION-BACKFILL.md` (artifact →
  check → delivery table for pre-`update-project` adopted projects).
  Writing it found a real gap: `.agentignore` was never checked by
  `update-project`/old `sync-templates.sh` (root loop only globs `*.md`) —
  fixed, verified on scratch project. Migration rule + phantom
  skills-cheatsheet entries in a project's own files stay manual by
  design (documented why). Not run against a real project — out of scope
  for this session (nothing outside opencode-harness touched).
- T-H5 (partial): new `tests/behavior/fixtures/_lib/make-client-project.sh`
  shared base; `pressure-to-bypass`/`session-end-with-failures` rewritten
  to use it (re-verified both still trigger their target failure);
  `dirty-adopt` left as-is (pre-adopt state, incompatible with the lib);
  `skill-only-commit`/`broken-harness-path` correctly stay harness-profile.
  New scenario `adopted-project-jsdoc` (T-H3 regression) + new
  `tests/unadopt.bats` (T-H0 regression, deterministic). Audit-trail/retro
  section format documented in `session-end/SKILL.md` (docs only, no new
  mechanism — that's Wave F T-F4). Step 5 (CI templates) blocked H-DEC-4.
- Wave F: skipped almost entirely. T-F1-F4 (Block 1) need either a
  technical investigation this session didn't run (headless agent
  execution, OpenCode message hooks) or T-H5 landing first, and the wave's
  own header requires human line-review for Block 1, not autonomous
  execution. T-F5/T-F7 blocked on M1/M2/M3. T-F6 already fully satisfied
  by T-G-U3 (hook drift detection) — verified, nothing new needed.
- T-H4: new `scripts/check-propagation.sh` (`make check-propagation`, in
  CI) — mechanical backstop scanning delivered files for unreachable
  `make X` commands, unprefixed harness-repo-only paths, and dishonest
  `check_pass` in `dod.sh`'s client-profile branches. Running it against
  the real tree found and fixed 2 previously-unknown instances
  (`global/skills/dod/SKILL.md:90` missing prefix; `templates/AGENTS.md:7`
  naming Makefile targets that don't exist). **Correction to T-H1:** Rule
  3 caught that step 6 (tests) was over-blocked on H-DEC-2 — the ticket's
  own safe default (honest `⚠` naming the HARNESS.md test command, no
  auto-run) doesn't need that decision. Implemented, 2 new bats cases
  added; T-H7 case 3 now covered too. Only T-H1 step 1 (docs-matrix
  severity, genuinely gated by H-DEC-1) remains blocked.
