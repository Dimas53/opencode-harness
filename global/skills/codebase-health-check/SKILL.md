# Codebase Health Check

**Purpose:** Analyse a codebase holistically, identify what to refactor and in what order, with risk assessment and a phased plan that doesn't break what works.

**Triggers — apply this skill when the user says:**
- "refactor", "refactoring", "clean up the code", "tidy up"
- "find duplication", "find repeated code", "DRY this"
- "assess the codebase", "code health", "what's worth fixing"
- "where should I start with refactoring"
- "the code is getting messy"
- "this file is too big / too long"

**Does NOT replace:**
- `code-review-and-quality` → use for reviewing a specific PR or file
- `code-simplification` → use when the task is already scoped to one function/file
- `improve-codebase-architecture` → use for structural rewrites or pattern migrations
- `deprecation-and-migration` → use when the goal is removing a deprecated API or framework

**Use this skill when the scope is: the whole project or a set of files, the goal is to prioritise and phase the work, and "don't break what works" is a constraint.**

---

## Workflow

**Step 1 — Map the system** (`01-system-mapping.md`)
Understand the project structure before touching anything. Identify layers, boundaries, and the call graph.

**Step 2 — Find cross-cutting patterns** (`02-pattern-detection.md`)
Run the deletion test on every repeated pattern. Score by leverage (how many callers) and risk (how tightly template-coupled).

**Step 3 — Score and prioritise** (`03-prioritisation.md`)
Stack-rank all candidates by: impact × frequency ÷ risk. Output a numbered extraction list.

**Step 4 — Build the phased plan** (`04-phased-plan.md`)
Sequence the work into phases. Phase 1 = cross-cutting utilities (zero coupling risk). Phase 2 = business logic composables. Phase 3 = optional polish.

**Step 5 — Execute one step at a time** (`05-execution-rules.md`)
Rules for safe, incremental extraction without breaking the working app.

---

## Output format

Always produce:

1. **System map** — a text diagram of layers and which files live in each
2. **Findings table** — each candidate with: file, lines, pattern type, deletion-test result, risk
3. **Phased plan** — numbered steps grouped into phases, with estimated lines saved per step
4. **File size targets** — current vs target line counts for affected modules
