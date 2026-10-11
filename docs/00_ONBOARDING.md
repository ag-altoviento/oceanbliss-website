# Onboarding Guide

> **🔒 LOCKED DOCUMENT** - Do not modify without explicit user approval.
> This defines the Documentation System workflow. Read it carefully.

---

## 📖 What is the Documentation System?

This project uses a **Documentation System** - a structured approach that provides extensive documentation and necessary context for AI assistant sessions. The system ensures:

- **Context is preserved**: New LLMs (or humans) can pick up work instantly
- **Work is tracked**: Every session is documented in real-time
- **Knowledge isn't lost**: Design decisions and guides are kept permanently

---

## 📁 Documentation Structure

| # | Document | Purpose |
|---|----------|---------|
| 1 | **README.md** | Project overview, how to run the project and tests |
| 2 | **AGENTS.md** | Agent entry point and rules - loaded automatically each session. System rules sit in a managed block; project rules go below it |
| 3 | **CLAUDE.md** | Imports `AGENTS.md` so Claude Code always loads it |
| 4 | **docs/00_ONBOARDING.md** | This document - Documentation System reference |
| 5 | **docs/01_PRD.md** | Product requirements - what and why: problem, concepts, scope (in v1 / later / not building), success criteria |
| 6 | **docs/02_ARCHITECTURE.md** | System design and technical stack |
| 7 | **docs/03_TODO.md** | Current status: phases and milestones in Build mode, a short index of Jira work in Maintenance mode |
| 8 | **docs/04_INFRASTRUCTURE.md** | Environments and deployment |
| 9 | **docs/05_DESIGN-DECISIONS.md** | Key decisions only - choices with a real alternative that someone will want to reverse, each in its final form. Product rules go in the product spec, setup facts in 02/04 |
| 10 | **docs/10_TROUBLESHOOTING.md** | Common issues and solutions |
| 11 | **docs/design/** | Design documents, one per component, linked from 02/04 |
| 12 | **docs/design/PRODUCT-DESIGN.md** | Optional. The product spec - how the product behaves, as current truth; one numbered section per area, each rule stated once |
| 13 | **docs/design/product/** | Optional. Scenarios that test the spec (any filename, e.g. `SCENARIOS.md`), and any view generated from them |
| 14 | **docs/sessions/** | Active work sessions (in progress) |
| 15 | **docs/guides/** | Opinionated reference guides for the technologies we use most. A stack's foundation guides say what to build and why, their implementation packs in `.claude/skills/apply-guide/` carry the steps and starter code, and its stack guide gives the build order |
| 16 | **docs/templates/** | Templates to copy from: `SESSION.md`, `DESIGN.md`, `PRODUCT-DESIGN.md`, `FOUNDATION-GUIDE.md`, `TODO-MAINTENANCE.md`, `AGENT-RULES-LIBRARY.md` |
| 17 | **docs/archive/** | Archived documents no longer active |
| 18 | **docs/archive/sessions/** | Completed sessions (moved from docs/sessions/) |
| 19 | **.docsys/** | System version and manifest - do not edit |

### Design Documents

- `docs/design/` holds **one document per component** or feature surface, created from `docs/templates/DESIGN.md`.
- A ticket, a bug or a mechanism is a section in its component's document, not a new file.
- `02_ARCHITECTURE.md` and `04_INFRASTRUCTURE.md` are thin hubs: a row per component or area, linking its design doc.
- One exception: the product spec, `docs/design/PRODUCT-DESIGN.md` from `docs/templates/PRODUCT-DESIGN.md`, describes the whole product's behaviour. Component design docs implement its sections and link to them.
- A generated file (an `.html` page, any rendered view) is never edited by hand. Its source's header names the script that renders it, and that script has a `--check` that fails when the view is out of date.

---

## 📚 Documentation Tiers

| Tier | Documents | Archive Policy |
|------|-----------|----------------|
| **Tier 1: Core** | README, AGENTS.md, CLAUDE.md, 00-05 docs | Never archive - except 05's running log at a phase reset (see [Resetting the Decision Log](#resetting-the-decision-log)) |
| **Tier 2: Reference** | 10_TROUBLESHOOTING, guides/, design/ (the product spec and scenarios included), templates/ | Rarely changes; a generated view follows its source |
| **Tier 3: Working** | sessions/ (with `-active` suffix) | Archive when complete |
| **Tier 4: Archive** | archive/, archive/sessions/ | Historical reference |

---

## 🤖 AI Assistant Session Workflow

### Catching Up (Start of Every Session)

1. **Read core docs** to understand the project:
   - `docs/01_PRD.md` - What we're building
   - `docs/02_ARCHITECTURE.md` - How it's built
   - `docs/design/PRODUCT-DESIGN.md`, if it exists - How the product behaves (the sections the task touches, plus Open questions)
   - `docs/05_DESIGN-DECISIONS.md` index - The key choices not to reopen casually

2. **Check current status**:
   - `docs/03_TODO.md` - Its **Mode**, then the current phase (Build) or the "Now" table (Maintenance)
   - `ls docs/sessions/` - Active work in progress; yours are the ones whose **Owner** is you

3. **If active session exists**, read it to understand ongoing work

4. **Start working** with the user on the current or next task

### During a Session

| If you... | Update this document |
|-----------|---------------------|
| Settle how the product behaves | The section of `docs/design/PRODUCT-DESIGN.md` that owns it, as current truth |
| Make a choice with a real alternative that someone will want to reverse | A key decision in `docs/05_DESIGN-DECISIONS.md`, cited from the section it shapes |
| Leave something unsettled | The spec's Open questions |
| Change a rule a scenario shows | The scenario in the same change, then regenerate its view with its script |
| Need a rendered view of a document | Generate it from the Markdown with a script that has `--check`; never keep two hand-written copies |
| Make progress on your work | Your row in `docs/03_TODO.md` ("Active Sessions" in Build mode, "Now" in Maintenance mode) |
| Troubleshoot repeatable issues | `docs/10_TROUBLESHOOTING.md` |
| Change environment/architecture | `docs/02_ARCHITECTURE.md` or `docs/04_INFRASTRUCTURE.md` |
| Make progress on current work | Active session in `docs/sessions/` |
| Change how a component works | That component's design doc in `docs/design/` - never a new file |
| Add a new component | A new `docs/design/<COMPONENT>-DESIGN.md` from `docs/templates/DESIGN.md`, and a row in `02_ARCHITECTURE.md`'s Components table |
| Build a component a foundation guide covers | `/apply-guide <guide>`: read the guide, follow its implementation pack, and record the project's values in the design doc it names |
| Find new work to do | A Jira ticket - propose it, and create it once the user confirms |

### Finalizing a Session

1. Finalize the session document in `docs/sessions/`
2. Move it to `docs/archive/sessions/` (remove `-active` suffix)
3. Update `docs/03_TODO.md` per its Mode - Build: mark items complete, update current/next phase; Maintenance: move your row from "Now" to "Recently Done"

---

## 🔄 Work Scenarios

| Scenario | What to Do |
|----------|------------|
| **New feature** | Create branch `feature/[work-id]-[description]`, create session doc from `docs/templates/SESSION.md`, start coding |
| **Maintenance work** | Start from the Jira ticket: branch `feature/[ticket-key]-[description]`, a session doc, and your row in the TODO's "Now" table |
| **Batch of small fixes** | One session with a short batch name (e.g. `bugfix-sweep`) that lists its tickets |
| **Resume active work** | Read session doc in `docs/sessions/`, checkout the branch, continue |
| **New LLM picking up work** | Read session doc, `git fetch && git checkout` the branch it names, continue |
| **Multiple tasks active** | Each task has its own session doc and branch |
| **Docs-only changes** | Commit directly to main (no branch needed) |
| **Design phase ends** | Reset the decision log - see [Resetting the Decision Log](#resetting-the-decision-log) |

### Updating docs/03_TODO.md

| When... | Build mode | Maintenance mode |
|---------|------------|------------------|
| **Starting work** | Add your row to "Active Sessions"; set the current phase | Add your row to "Now" |
| **Making progress** | Check off `[x]` completed tasks | Nothing - progress lives in the session doc |
| **Finishing work** | Remove your row; collapse finished milestones into "Completed Work" | Move your row to "Recently Done" |
| **Planned phases done** | Switch to Maintenance mode - `status-update` offers it, and first saves the whole TODO to `docs/archive/03_TODO-build-YYYY-MM-DD.md` | - |

### Session Document Naming

```
docs/sessions/YYYY-MM-DD-[work-id]-[description]-active.md
```

- **work-id**: `phase-X.Y` (phase X, milestone Y in `docs/03_TODO.md`), a ticket key in lowercase (e.g. `proj-191`), several keys (`proj-191-proj-192`), or a short batch name (`bugfix-sweep`) whose tickets the session lists
- **Owner**: every session names its owner; each person updates only their own sessions and TODO rows
- **Maintenance mode**: every session lists at least one Jira ticket
- **description**: a few lowercase words, hyphenated
- **Branch**: `feature/[work-id]-[description]` (same work-id and description)
- **Example**: `docs/sessions/2026-01-15-phase-2.1-user-auth-active.md` on branch `feature/phase-2.1-user-auth`

Create it from `docs/templates/SESSION.md`. When complete, move to `docs/archive/sessions/` and remove the `-active` suffix. Only session docs are archived - completed phases stay in `docs/03_TODO.md` under "Completed Work".

### Resetting the Decision Log

The design-phase counterpart of the TODO's switch to Maintenance mode. `status-update` and `audit` offer it; ask the user before starting.

1. **When** - at the end of a design phase, or when the log has revision chains and more entries than anyone reads (about 30 active entries).
2. **Archive unchanged** - `git mv docs/05_DESIGN-DECISIONS.md docs/archive/05_DESIGN-DECISIONS-<PHASE>.md`. Its numbers stay as they were.
3. **Sort every entry into one destination:**
   - a key decision - a real alternative was rejected, and someone will want to reverse it - goes to the new log, in its final form
   - a product rule goes to its section of the product spec, or to the PRD
   - a setup fact goes to 02/04 or a design doc
   - a superseded or revised entry goes nowhere: the archive keeps it
4. **Write the new log** - renumber from 001; each entry closes with the old numbers it replaces ("Replaces 012, 027."). The header notes that it holds key decisions only, where rules live, the reset date, and links the archive.
5. **Repoint citations** - grep for `DECISION_` in the spec, design docs, `AGENTS.md` and code comments, and update them to the new numbers. Keep the old-to-new mapping in the session doc, not in 05.
6. **Close** - record the reset as one line in the TODO's completed work.

---

## 📋 Core Principles

- **One branch per feature** - Tied to TODO milestones
- **Session docs** - Archive when complete
- **Design docs** - One per component; never archive (keep in `docs/design/`)
- **One source per fact** - A rendered or derived copy is generated, never hand-kept
- **Spec before log** - A rule is written into the spec; the log keeps only the choices someone will want to reverse
- **Always test in Docker** - never run tests locally, unless the platform can't run in Docker (iOS, macOS) and `AGENTS.md` says how tests run instead. A developer's frontend watch loop may run on the host; it never counts as the test run
- **Always update docs** as you work

---

**Last Updated**: 2026-10-04
