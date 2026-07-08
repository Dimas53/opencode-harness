# Harness-Übersicht — Selbstdiagnose des Agent-Systems

> **Datum:** 2026-07-01
> **Agent:** OpenCode (deepseek-v4-flash-free)
> **Projekt:** ItoCook
> **Ziel:** Vollständiges Bild des Harness um das LLM — welche Werkzeuge und Fähigkeiten verfügbar sind, wie Entscheidungen getroffen werden und was vor Fehlern schützt.

---

## 1. Harness-Konzept

**Harness** — mehrschichtige Infrastruktur zwischen Entwickler und rohem LLM. Sie verwandelt ein Modell, das nur Text generieren kann, in einen Engineering-Agenten, der Dateien liest, Code schreibt, in die Datenbank geht, im Browser debuggt und Ergebnisse dokumentiert.

Im Projekt ItoCook ist ein **9-schichtige Struktur** implementiert:

```
1. INSTRUCTION  — AGENTS.md, Regeln, Verbote
2. CONTEXT      — progress.md, roadmap.md, design.md (was das Modell sieht)
3. TOOLS        — MCP-Server (filesystem, git, Directus, Chrome DevTools, Playwright)
4. LOOP         — Think → Do → Verify (Ausführungsdisziplin)
5. MEMORY       — progress.md, architecture.md, docs/specs/, git log
6. SUBAGENTS    — context7, sequential-thinking, task (Kind-Agenten)
7. VERIFICATION — TypeScript, DevTools, Code-Review
8. SANDBOX      — was erlaubt und was verboten ist
9. SKILLS       — 52 Fähigkeiten, bei Bedarf geladen
```

Das Schichtdiagramm ist visualisiert in `notes/Harness/harness-diagram.html`.

---

## 2. AGENTS.md — Das Gehirn des Systems

Der Agent hat **zwei Instruktionsebenen**:

### 2.1 Globales AGENTS.md (`~/.config/opencode/AGENTS.md`)

Definiert:
- **Verhalten:** Plan vor großen Änderungen, Bestätigung vor Commit, niemals ohne Erlaubnis pushen
- **Verbote ohne Erlaubnis:** `.env`, `nuxt.config.ts`, `docker-compose.yml`, DB-Migrationen
- **English-Only Policy:** Russisch verboten in Code, Kommentaren, Dokumentation (außer `notes/`)
- **CSS/Layout:** Tailwind, flexbox/grid, keine inline-Styles, px für Mobilgeräte
- **Skills Auto-Loading Regeln:** 52 Fähigkeiten, geladen per Trigger (security → auth/nginx, debugging → Bugs, UI → frontend usw.)
- **Working in External / Client Projects:** reduzierter Aktivitätsmodus — keine Kommentare, Doku, Refactoring, neue Abhängigkeiten
- **Design System (Global Default):** `docs/design.md` vor UI-Code lesen, Farb-Tokens, Phosphor Icons, `<script setup lang="ts">`

### 2.2 Projekt-AGENTS.md (`/Users/DSAITO/Documents/BackEnd/itocook/AGENTS.md`)

Definiert:
- **9-Schritt Session-Start:** (1) `using-agent-skills` laden, (2) 4 Stack-Skills laden, (3) git log, (4) progress.md, (5) Sync-Check, (6) roadmap.md, (7) task-spezifischer Kontext, (8) task-spezifische Skills, (9) Session-Bericht ausgeben
- **Definition of Done:** Checkliste vor "fertig" — progress.md aktualisiert, JSDoc hinzugefügt, roadmap.md geprüft, Safety-Check bestanden
- **Documentation Session:** automatische Prüfung ob docs hinter HEAD zurückliegen (>5 Commits oder >1 Woche) → Vorschlag docs zu aktualisieren
- **Nuxt 4 Struktur:** alle Ordner innerhalb von `app/`
- **MCP-Server:** 8 Server: filesystem, git, context7, directus, chrome-devtools, fetch, sequential-thinking, playwright
- **Directus Permissions Checkliste:** Rechte vor neuen Kollektionen prüfen
- **Vue 3 / Nuxt Gotchas:** `useDirectus` auf oberster Ebene, `reactive()` für plain-object Composables, DELETE 204 Crash, `generateSW`-Strategie
- **Betriebshinweise:** Directus Flows nicht in git, CRON erfordert Restart, `docs/specs/` für Projektspezifikationen

### Was erfordert menschliche Bestätigung

| Aktion | Grund |
|--------|-------|
| Änderung an `docker-compose.yml` | Kann gesamte Infrastruktur zerstören |
| Änderung an `.env` | Enthält Secrets, Passwörter, Tokens |
| Löschung von Directus-Kollektionen | Datenverlust unwiderruflich |
| `git push` | Impliziter Deployment |
| Löschung von Dateien aus `docs/` oder `notes/` | Dokumentationsverlust |
| Änderung von Directus-Berechtigungen | Risiko der horizontalen Eskalation |

---

## 3. Skills — Wissen auf Abruf

Insgesamt installiert: **52 Fähigkeiten** in `~/.config/opencode/skills/`. Alle Verzeichnisse enthalten aktuelle `SKILL.md`. Leere Ordner wurden entfernt. Der Agent lädt sie vor jeder Aufgabe.

### 3.1 Benutzerdefinierte Skills (spezifisch für ItoCook erstellt)

| Skill | Zweck |
|-------|-------|
| `security/` (5 Dateien) | Sicherheit: Auth, API, Frontend, Stack, Release-Checkliste |
| `session-start/` | Boot-Sequenz: docs lesen, Zusammenfassung ausgeben |
| `code-reviewer/` | Checkliste vor "fertig": TS, Vue, Directus, Design |
| `code-review-and-quality/` | 5-achsiges Code-Review mit Quality Gates |

> **Security-Audit 2026-06-28** durchgeführt mit `security/`-Skill. Gefunden: 3 CRITICAL (einschließlich unrestricted `directus_users` read), 2 HIGH, 2 MEDIUM. Alle behoben. Vollständiger Bericht: `docs/audits/security-audit.md`.

### 3.2 Superpowers-Skills (via `npx superpowers`)

| Skill | Verwendung | Gelöstes Problem |
|-------|-----------|-----------------|
| `brainstorming/` | Vor neuer Funktion | Präzisiert Anforderungen vor Code |
| `spec-driven-development/` | Neue Funktion ohne Spec | Formaliert Anforderungen |
| `planning-and-task-breakdown/` | Große Aufgabe | Zerlegt in Schritte |
| `incremental-implementation/` | Jede Implementierung | Kleine Schritte, jeder geprüft |
| `debugging-and-error-recovery/` | Bugs | Reproduzieren → Lokalisieren → Fixen |
| `diagnose/` | Bugs | Zyklus: reproduce → minimise → hypothesis → fix |
| `codebase-health-check/` | Architektur-Audit | Bewertung der Codebasis, Refactoring-Möglichkeiten |
| `code-review-and-quality/` | Code-Review | 5 Prüfachsen |
| `test-driven-development/` | Tests | Red → Green → Refactor |
| `git-workflow-and-versioning/` | Commits/Branches | Saubere Historie |
| `documentation-and-adrs/` | Dokumentation | ADR, Glossar, JSDoc |
| `handoff/` | Lange Session | Kontextpaket für nächste Session |
| `interview-me/` | Unklare Anforderungen | Extrahiert was wirklich gebraucht wird |
| `grill-me/` | Stresstest für Pläne | Verhör bis zur kristallklaren Klarheit |
| `grill-with-docs/` | Stresstest mit Doku-Update | Verhör + CONTEXT.md-Update |
| `zoom-out/` | Unbekannter Code | Erklärung im Systemkontext |
| `improve-codebase-architecture/` | Refactoring | Architektur-Verbesserungen finden |
| `idea-refine/` | Roh-Idee | Divergentes + konvergentes Denken |
| `source-driven-development/` | Code mit Framework | Prüfung an offizieller Dokumentation |
| `doubt-driven-development/` | Unbekannter/wichtiger Code | Adversarial Review jeder Entscheidung |
| `context-engineering/` | Kontext-Optimierung | Richtiger Kontext zur richtigen Zeit |
| `finishing-a-development-branch/` | Branch-Abschluss | Sauberer Merge/PR |
| `executing-plans/` | Plan vorhanden | Ausführung mit Kontrollpunkten |
| `triage/` | Bug-Priorisierung | Issues nach Gewicht ordnen |
| `prototype/` | Schneller Prototyp | Throwaway-Prototyp zur Ideenprüfung |
| `teach/` | Lernen | Schrittweise Konzepterklärung |
| `write-a-skill/` | Skill-Erstellung | SKILL.md-Struktur mit gebündelten Ressourcen |
| `writing-skills/` | Skill-Erstellung (superpowers) | Erstellen, Bearbeiten, Verifizieren |
| `receiving-code-review/` | Review erhalten | Technische Verifikation von Feedback |
| `requesting-code-review/` | Review anfordern | Prüfung vor Merge |
| `using-superpowers/` | Meta-Skill | (bereits zu Sessionsbeginn geladen) |
| `using-git-worktrees/` | Isolation | Arbeit via git worktree |
| `subagent-driven-development/` | Unteraufgaben | Ausführung durch Kind-Agenten |
| `setup-matt-pocock-skills/` | Ersteinrichtung | Repository-Konfiguration |
| `caveman/` | Token-Sparmodus | Ultra-kurzer Kommunikationsmodus |

### 3.3 Stack-Skills (Nuxt / Vue / Tailwind / Directus)

| Skill | Verwendung |
|-------|-----------|
| `nuxt/` | Jede Nuxt-Arbeit |
| `nuxt-ui/` | Nutzung von Nuxt UI Komponenten |
| `vue/` | Vue 3, Composition API, Composables |
| `tailwind-design-system/` | Tailwind-Tokens, Design-System |
| `docker-expert/` | Docker, docker-compose Probleme |
| `frontend-ui-engineering/` | Produktions-UI Entwicklung |
| `api-and-interface-design/` | API-Design |
| `make-interfaces-feel-better/` | UI-Politur (Schatten, Animationen, Typografie) |
| `performance-optimization/` | Leistungsoptimierung |
| `ci-cd-and-automation/` | CI/CD-Pipelines |
| `shipping-and-launch/` | Produktions-Deployment-Checkliste |
| `deprecation-and-migration/` | Entfernung alter Systeme |
| `browser-testing-with-devtools/` | DevTools MCP Tests |
| `dispatching-parallel-agents/` | Parallele unabhängige Aufgaben |
| `code-simplification/` | Code-Vereinfachung ohne Verhaltensänderung |
| `to-prd/` | Gespräch in PRD konvertieren |
| `to-issues/` | PRD in Aufgaben aufteilen |
| `find-skills/` | Passenden Skill finden |
| `verification-before-completion/` | Prüfung vor "fertig" |
| `customize-opencode/` | OpenCode selbst konfigurieren |
| `writing-plans/` | Schritt-für-Schritt-Plan erstellen |
| `security-and-hardening/` | Code-Härtung gegen Schwachstellen |
| `tdd/` | Test-driven Development (rot-grün-refaktor) |

**Gesamt: 52 installierte Skills.**

---

## 4. MCP-Server — Was der Agent tun kann

### 4.1 Dateisystem (filesystem MCP)

- Lesen/Schreiben aller Projektdateien
- Suche nach Mustern (glob) und Inhalten (grep)
- **Beispiel:** `filesystem_read_file("app/pages/cook.vue")` — Quelle lesen

### 4.2 Git (git MCP)

- Status, Commits, Logs, Diffs
- **Beispiel:** `git_git_log({"repo_path": project, "max_count": 5})` — letzte Commits
- **Beispiel:** `git_git_commit({"repo_path": project, "message": "fix(auth): ..."})`

### 4.3 Web Fetch (fetch MCP + websearch)

- Seiten per URL herunterladen
- **Beispiel:** `fetch_fetch({"url": "https://nuxt.com/docs/..."})` — aktuelle Dokumentation
- **Beispiel:** `websearch({"query": "nuxt 4 middleware ..."})` — Google-Suche

### 4.4 Directus MCP (`http://localhost:8055/mcp`)

- Vollständiges CRUD für Kollektionen, Felder, Beziehungen
- Erstellung von Flows und Operations
- Schema-Lesen vor der Arbeit
- **Beispiel:** `directus_collections({"action": "read"})` — alle Kollektionen anzeigen
- **Beispiel:** `directus_flows({"action": "create", "data": {...}})` — Automatisierung

### 4.5 context7 (Framework-Dokumentation)

- Live-Dokumentation für Nuxt, Directus, Vue, Tailwind
- Immer aktuelle APIs, nicht aus Trainingsdaten
- **Beispiel:** `context7_query-docs({"libraryId": "/nuxt/nuxt", "query": "server routes"})`

### 4.6 Chrome DevTools (Browser-Debugging)

- Console.log und Fehler lesen
- Network Requests (Status, CORS)
- Screenshots, Lighthouse-Audit
- Performance-Trace
- **Beispiel:** `chrome-devtools_list_console_messages()` — JS-Fehler
- **Beispiel:** `chrome-devtools_list_network_requests()` — 4xx/5xx

### 4.7 Playwright (E2E-Tests)

- Vollständiger Browser-Test-Runner
- Navigation, Klicks, Formularausfüllung, Screenshots
- Console-Message-Erfassung
- **Beispiel:** `playwright_browser_navigate({"url": "http://localhost:3000"})`
- **Beispiel:** `playwright_browser_snapshot()` — a11y-Baum der Seite

### 4.8 Sequential Thinking

- Erzwungene schrittweise Argumentation
- Für komplexe Architekturentscheidungen
- **Beispiel:** `sequential-thinking_sequentialthinking({"thought": "...", "nextThoughtNeeded": true})`

---

## 5. Speichersystem

Der Agent hat kein Langzeitgedächtnis zwischen Sitzungen. Speicher ist implementiert als **trigger-basierte Dokumentation**:

| Datei | Wann aktualisiert | Inhalt |
|-------|-------------------|--------|
| `docs/progress.md` | Nach jeder Änderung | Status, bekannte Probleme, Plan für nächste Session, git log |
| `docs/roadmap.md` | Bei Phasenabschluss | High-Level Roadmap, Checkboxen, Abschlussdaten |
| `docs/ARCHITECTURE.md` | Neues Composable/Route/Pattern | Struktur, Core-Layer-Dokumentation |
| `docs/architecture/*.md` | Neue Funktion | 8 Dateien: cook-queue, recipe-system, finance, duty, shopping-list, auth-flow, notifications, deployment-pwa |
| `docs/CONTEXT.md` | Interview mit Entwickler | Glossar der Domänenbegriffe (40+ Begriffe) |
| `docs/specs/` | Neue Funktion ohne Spec | Feature-Spezifikationen: Zweck, Ein-/Ausgaben, Edge Cases |
| `docs/audits/*.md` | Nach Audit | Security-Audit, UI-Polish-Audit, Refactoring-Plan |
| `docs/design.md` | Bei Design-Änderung | Farben, Tokens, Schriftarten, UI-Regeln |
| `docs/skills-cheatsheet.md` | Neuer Skill | Skill-Tabelle für Entwickler |
| `docs-site/` | VitePress-Dokumentation | 20+ Seiten: Architektur, Features, Screens, Design-System, Roadmap |

**Prinzip:** Dokumente werden nur bei Ereignissen aktualisiert (Phasenabschluss, neuer Bug, neue Funktion), nicht nach Zeitplan. Git-Log dient als durchsuchbare Entscheidungshistorie.

**.planning/** — entfernt. Ersetzt durch `docs/specs/` für Projektspezifikationen.

---

## 6. Arbeitszyklus

Der Prozess ist ein **Dreieck** aus drei Beteiligten:

```
┌─────────┐     schreibt Prompts     ┌──────────┐     führt aus        ┌──────────┐
│ Claude  │ ────────────────────→  │ Dmitrii  │ ────────────────→ │ OpenCode │
│ (Stratege│ ←──────────────────── │ (PO/QA)  │ ←──────────────── │ (Ausführer)│
│ + Diagn.)│   Ergebnisse+Screens   │           │   Bericht+Code     │           │
└─────────┘                        └──────────┘                   └──────────┘
```

1. **Claude** (extern, im Browser) — Stratege und Diagnostiker. Schreibt Prompts auf Englisch, analysiert Ergebnisse, entwickelt Lösungen.
2. **Dmitrii** (Mensch) — Product Owner. Startet Prompts im Terminal via OpenCode. Genehmigt Änderungen. Führt visuelles QA durch.
3. **OpenCode** (Agent, aktuell) — Ausführer. Liest Dateien, schreibt Code, greift auf Directus zu, debuggt im Browser, aktualisiert docs.

**Warum Prompts auf Englisch?** Weil Code, Dokumentation, Kommentare — alles auf Englisch ist (English-Only Policy). Claude schreibt Prompts in derselben Sprache wie der Code, um Sprachmischung zu vermeiden.

**"One change at a time"** — Regel hinzugefügt, nachdem gleichzeitige Infrastrukturänderungen zu einem eintägigen Rollback führten.

---

## 7. Safety Gates & Sandbox

### Harte Gates (ohne Bestätigung — kein Schritt)

| Gate | Grund |
|------|-------|
| **nginx-Konfiguration** | Konfigurationsfehler → kompletter day-long Outage |
| **Service Worker-Strategie** | Wechsel von `injectManifest` zu `generateSW` zerstörte PWA-Build; `navigateFallback: null` ist kritisch |
| **Docker Compose** | Kann gesamte Produktionsinfrastruktur zerstören |
| **.env-Dateien** | Passwörter, Tokens, VAPID-Keys |
| **Directus-Berechtigungen** | Risiko horizontaler Eskalation (CRITICAL-Fund: `directus_users` unrestricted read) |
| **git push** | Deployment auf Produktion ohne Bestätigung |
| **Löschung von Kollektionen/Dokumenten** | Unwiderruflicher Verlust |

### Autonome Aktionen (ohne Nachfrage)

- Erstellen/Bearbeiten von Vue/TS-Komponenten
- Nuxt Server Routes
- Neue Dateien in `docs/`
- Aktualisierung von `progress.md` und `roadmap.md`
- Neue Directus-Kollektionen (ohne Löschung bestehender)
- Lesen beliebiger Projektdateien

---

## 8. Gelernte Lektionen

Regeln, die hinzugefügt wurden, nachdem etwas schiefgelaufen ist:

| Problem | Was passierte | Hinzugefügte Regel |
|---------|--------------|-------------------|
| **Multiple Infra-Änderungen** | Gleichzeitige Änderung von nginx + Directus + Docker führte zu eintägigem Rollback | "One change at a time" |
| **Composable plain object refs** | `useParticipantsModal()` gab plain object zurück → `v-if="pm.loading"` immer true (Ref object truthy) | `reactive()` wrappen oder `readonly(reactive({}))` zurückgeben |
| **useDirectus() in async** | Composables mit useRuntimeConfig innerhalb setTimeout verloren Nuxt-Kontext | useDirectus auf oberster Ebene aufrufen, nicht innerhalb async |
| **Horizontale Eskalation** | User Policy hatte create/update auf `balances`/`transactions` ohne `$CURRENT_USER`-Filter | Admin-Proxy-Muster + Security-Audit |
| **Directus-Benutzer offengelegt** | `directus_users` read permission gab alle Felder zurück (inkl. Email, Tokens) | Field-level Restriction + Audit |
| **DELETE 204 Crash** | DELETE von Directus gibt 204 No Content → `res.json()` stürzt ab | `res.text()` + bedingtes `JSON.parse` |
| **Calendar today highlight** | Ausgewählter Tag und heute kollidierten visuell | `bg-purple-100 text-purple-700` für today separat |
| **PWA swSrc/swDest-Konflikt** | `injectManifest` scheiterte in Nuxt 4 wegen same-file Conflict in `app/public/` | Umstellung auf `generateSW` |
| **Fork-Pattern erforderlich** | Geteiltes `recipes.cook` PATCH verletzte Urheberrechte | Fork-on-cook: Kopie mit `forked_from`, owned by cook |
| **Naming Collision im Composable** | `fetch()` in useTotalUsers rief sich selbst auf | Interne Funktion umbenannt in `fetchCount` |
| **CRON-Änderungen erfordern Neustart** | CRON-Änderung in UI wurde nicht übernommen | `docker compose restart directus` nach CRON-Änderungen |
| **Directus Flows nicht in git** | Flows in DB, nicht in git; Production-Sync ging verloren | Hinweis: Flows nicht version-controlled, manueller Sync nötig |

---

## 9. Tests

Vollständiger Testplan — `notes/tests-promt.md` (10 Prompts, Reihenfolge: Units → API → E2E → CI/CD).

### Unit-Tests (Vitest)

| # | Datei | Testet |
|---|-------|--------|
| 1 | `dedupRecipes.test.ts` | Rezept-Deduplizierung nach `dish_name` — reine Funktion, 7 Fälle |
| 2 | `useBalanceCheck.test.ts` | Balance-Gate (−30€ Grenze) — 7 Fälle, inkl. safe fallback |
| 3 | `deduction.test.ts` | Kostenaufteilung — `computePastaCost` + Pro-Kopf-Anteil, 10 Fälle |
| 4 | `security.test.ts` | Sicherheitsregression — update-me whitelist, Balance-Grenzen, department field |

### API-Tests (Vitest — Server-Routen)

| # | Datei | Testet |
|---|-------|--------|
| 5 | `auth-routes.test.ts` | Autorisierung auf Server-Routen — 401 ohne Token, 403 für normalen User |
| 6 | `validation.test.ts` | Eingabevalidierung — 400 auf Müll-Daten, Feld-Whitelist |
| 7 | `permissions.test.ts` | Directus-Berechtigungsgrenzen — fremde balances/transactions/users unzugänglich |

### E2E-Tests (Playwright)

| # | Datei | Testet |
|---|-------|--------|
| 8 | `auth.spec.ts` | Login/Logout — gültige Daten leiten weiter, ungültige zeigen Fehler |
| 9 | `cook-flow.spec.ts` | Become Cook + Cook-Panel Dish-Eingabe |
| 10 | `join-flow.spec.ts` | Join Meal, Teilnehmerzähler, BalanceWidget |

### CI/CD

| # | Datei | Testet |
|---|-------|--------|
| 11 | `.github/workflows/test.yml` | GitHub Actions — automatischer Teststart bei Push/PR |

### Ausführung

- Unit: `cd frontend && npx vitest run tests/unit/`
- API: `cd frontend && npx vitest run tests/api/`
- E2E: `cd frontend && npx playwright test tests/e2e/`

---

## Zusammenfassung

Dieser Harness verwandelt ein rohes LLM in einen Engineering-Agenten, der ohne ständige Aufsicht an einem Produktionsprojekt arbeiten kann. 9 Schichten (von Instruktionen bis Sandbox), 52 Skills für verschiedene Aufgaben, 8 MCP-Werkzeuge für Dateien, Git, DB, Browser, E2E-Tests und Dokumentation, trigger-basiertes Speichersystem und Safety Gates, die vor katastrophalen Fehlern schützen.

Ohne dieses Harness könnte das Modell nur Text generieren. Mit ihm liest und schreibt es Code, verwaltet das Directus-Schema, debuggt in Chrome DevTools und Playwright, nutzt Live-Framework-Dokumentation, erstellt Flows und Automationen und führt E2E-Tests in echten Browsern aus.

**Harness — der Unterschied zwischen einem "AI-Plappermaul" und einem "AI-Ingenieur".**
