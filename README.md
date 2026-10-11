# Ocean Bliss

The marketing website for Ocean Bliss, a 6-bedroom beach house in North Cape San Blas, Florida. It brings in guests from the owner's own ads and promotions, and sends them to the house's [360 Blue listing](https://www.360blue.com/destinations/the-forgotten-coast/gulf-county/properties/north-cape-san-blas-ocean-bliss-189-westwind-dr-631) to book.

Plain HTML and CSS, published on GitHub Pages at **https://oceanbliss.life**.

---

<!-- docsys:begin - Managed by the Documentation System. Changes inside this block are replaced on update. -->
## 🤖 Documentation System

This project uses a **Documentation System** designed for spec-driven development with LLMs. The system provides extensive documentation that gives AI assistants (and humans) the context they need to work effectively.

**New to this system?** Read the [Documentation System Manual](DOCUMENTATION-SYSTEM-MANUAL.md) to understand how it works and why it exists, or type `/helpme` in Claude Code for a tour of this project and its commands - and ask it anything, as in `/helpme where do decisions go?`.

### Getting Started with Documentation System

**Start here → [docs/00_ONBOARDING.md](docs/00_ONBOARDING.md)**

The Onboarding Guide defines the complete Documentation System including:
- All documentation files and their purposes
- The AI Assistant Session Workflow (starting, during, finalizing sessions)
- Work scenarios (new feature, resume work, hotfix, etc.)

Then check current status:
```bash
head -40 docs/03_TODO.md      # See current phase and active work
ls docs/sessions/             # See active work sessions
```

### Foundation Guides

Opinionated guides for building the parts every product needs - sign-in, database, deploy, email, AI calls, teams and more - each with tested starter code. The [guide catalogue](.claude/skills/apply-guide/CATALOGUE.md) lists them all by capability and platform (web, iOS), with what's planned.

- `/stand-up` builds a new project's foundation in one pass: it asks each fact once, applies every chosen guide, verifies in Docker, deploys dev through CI, and leaves what's deferred on the roadmap with its trigger. `/apply-guide add <part>` brings a deferred part in when its trigger comes.
- `/apply-guide` in Claude Code shows the catalogue with what this project has applied; `/apply-guide <guide>` applies one. Other agents follow the guide's `.claude/skills/apply-guide/<guide>/IMPLEMENT.md`.
- `gh docsys update --guides <name>` installs a guide; `--stacks <stack>` installs a whole stack.
- An update refreshes the guides, never your code: `/apply-guide review-update` says what changed in the guides you applied, and you choose what to bring over.

### Developer Skills

- `/pre-pr` runs the checks the pull request will run, locally and in Docker, and says READY or NOT READY; `/fix-build` fixes a red check without silencing it.
- `/review-guides` reviews a change against the installed guides and `AGENTS.md`, beside Claude Code's `/code-review`.
- `/refactoring` restructures code the way Martin Fowler's *Refactoring* teaches: one hat at a time, small steps, tests green after each.
- Projects with the Frontend Shell guide also get `angular-developer`, the Angular team's reference skill adapted to the guides.
- Every project gets its own Claude Code status line - context used, folder, branch, session name, model, cost - in `.claude/statusline.sh`, yours to change; an update never replaces it (`gh docsys update --guides statusline` for how).
<!-- docsys:end -->

---

## 🚀 Quick Start

### Prerequisites
- Docker
- Git

### Run Locally

The site and its preview and check scripts come in Phase 1 - see [docs/03_TODO.md](docs/03_TODO.md). Until then there is nothing to run.

---

## 🌿 Git Workflow

Content and code changes go on a branch and merge to `main` through a pull request; the merge publishes the site. Docs-only changes may go straight to `main`.

**See:** [Onboarding § Work Scenarios](docs/00_ONBOARDING.md#-work-scenarios)

---

## 📦 Technology Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Pages** | HTML5 | Site content |
| **Styling** | CSS | Layout and look |
| **Hosting** | GitHub Pages | Serves the site |
| **Deploy** | GitHub Actions | Publishes on merge to `main` |
| **Measurement** | Google tag | Analytics and Google Ads conversions |

Details: [docs/02_ARCHITECTURE.md](docs/02_ARCHITECTURE.md) · [docs/04_INFRASTRUCTURE.md](docs/04_INFRASTRUCTURE.md)
