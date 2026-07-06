# 01 — System Mapping

**Goal:** Understand the full project structure before evaluating anything. Never start analysis without this step.

---

## What to collect

### 1. Layer diagram
Identify the layers of the application and which files belong to each:

```
┌────────────────────────────────────────┐
│            Page / Screen Layer          │  ← pages/, screens/, routes/
├────────────────────────────────────────┤
│         Business Logic Layer            │  ← composables/, hooks/, services/
├────────────────────────────────────────┤
│           Utility Layer                 │  ← utils/, helpers/, lib/
├────────────────────────────────────────┤
│        External API / Data Layer        │  ← API clients, SDKs, ORM models
└────────────────────────────────────────┘
```

Adapt the names to the actual stack. In Nuxt 4 these are: pages/ → composables/ → utils/ → Directus REST API.

### 2. File inventory
For each file in scope, collect:
- Path and name
- Line count: `wc -l` or equivalent
- Primary responsibility (one sentence)
- Which layer it belongs to
- Which other files it imports from

```bash
# Fast line count for all source files
find . -name "*.vue" -o -name "*.ts" | grep -v node_modules | grep -v .nuxt | xargs wc -l | sort -rn
```

### 3. Hotspot list
Files that are candidates for extraction usually share these traits:
- **Large** — line count well above the project median
- **Shallow** — the file's internal logic is as complex as its public interface
- **High fan-in** — many other files import from it (but it's still monolithic)
- **Mixed responsibilities** — does data fetching AND business logic AND UI state at the same seam

### 4. Dependency graph (lightweight)
For each file in scope, list:
- What it imports (outgoing)
- What imports it (incoming — use `grep -r "from.*filename"`)

You don't need a full AST graph. A text list is enough to spot which patterns are truly shared vs which only appear in one file.

---

## Questions to answer before moving to Step 2

1. What is the largest file? What is it doing?
2. Are there shared patterns (slider, date helpers, fetch + transform) that appear in 2+ files?
3. Is there already a composable/utility layer, and is it being used consistently?
4. Which files are read-only (stable, no extraction needed) and which are the refactoring targets?
5. What's the existing test coverage? (Untested files = higher extraction risk)

---

## Output: System map

Produce a diagram like this before proceeding:

```
Pages (shallowest — most likely to need extraction):
  cook.vue          1202 lines  [state machine, 7 inline concerns]
  recipe/[id].vue   1153 lines  [recipe detail, 6 inline concerns]
  finance.vue        630 lines  [admin panel, slider duplication ×2]
  kitchen.vue        475 lines  [date helpers duplicated, otherwise OK]
  recipe/create.vue  395 lines  [well-balanced, defer]

Composables (existing, evaluate for extension):
  useAuth.ts         [auth, token, user state]
  useDirectus.ts     [HTTP client — do not touch]
  useParticipants.ts [count only — candidate for extension]
  ...

Utils (existing):
  dates.ts           [exists but not being imported everywhere]
  ingredientIcons.ts [stable]
```
