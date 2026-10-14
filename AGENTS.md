# AGENTS.md

Instructions for AI coding agents working in this repository.

<!-- docsys:begin - Managed by the Documentation System. Changes inside this block are replaced on update; add project rules below it. -->
## Documentation System

This project uses a **Documentation System**. `docs/00_ONBOARDING.md` is the source of truth for the documents, tiers, naming, and session workflow.

Before starting work, catch up: read `README.md` and `docs/00_ONBOARDING.md`, follow onboarding's "Catching Up" steps, then report the current phase, any active session, and the next steps. In Claude Code, `/documentation-system:catch-up` does this.

## Rules

Follow these rules strictly.

### Documentation
- Don't create documents without asking first. Only create the documents the Documentation System defines in `docs/00_ONBOARDING.md`.
- Keep documentation short. Say it once, in the document that owns it, and link to it from elsewhere.
- When editing a document, follow its "DOCUMENTATION RULES FOR AI ASSISTANTS" header.
- Keep the session document updated as you work, so a new LLM session can take over at any time.
- When adding features, add tests that cover the changes and update the design documents to match.
- Write a settled product rule once, in the section of the product spec or design doc that owns it. Record a decision in `05_DESIGN-DECISIONS.md` only when it had a real alternative and someone will want to reverse it.
- Never hand-edit a generated file. Change its source and rerun its generator: two hand-kept copies of the same content drift apart.
- Don't create session summary files in /tmp; the session document is the summary.
- Use Mermaid, not ASCII diagrams, in .md documents.
- Don't use parentheses inside Mermaid labels; they break rendering. Use dashes, line breaks or slashes.

### Guides
- When work touches something an installed guide in `docs/guides/` covers, follow the guide. It overrides generic advice, other skills and plugins included: its choices come from a production project, and its starter code is tested.
- Apply a foundation guide through its implementation pack: `/apply-guide <guide>` in Claude Code; in any other agent, follow `.claude/skills/apply-guide/<guide>/IMPLEMENT.md`. A new project's whole foundation goes up with `/stand-up` (`.claude/skills/stand-up/SKILL.md`), which asks each fact once.
- Every guide on offer, by capability and platform, is in `.claude/skills/apply-guide/CATALOGUE.md`. A Documentation System update refreshes the guides, never the project's code: bring a guide's changes over only when the owner chooses (`/apply-guide review-update`).
- Before opening a pull request, run the checks CI will run, then review the change against the guides and these rules: `/pre-pr`, then `/review-guides` beside `/code-review`, in Claude Code; in any other agent, follow `.claude/skills/pre-pr/SKILL.md` and `.claude/skills/review-guides/SKILL.md`.

### Emphasis
- ⚠️ and ALL CAPS are rationed, in every document, rule and comment. Use one only when all three hold:
  1. it has already cost someone real time - a session doc or ticket stands behind it, not a guess about what might go wrong
  2. the obvious reading is wrong
  3. it fails silently: no error, no alarm, no failing test
- Everything else is plain prose. Prose carries a warning perfectly well, and emphasis that is everywhere stops working.
- Status symbols in tables and reports (✅ ⚠️ 🔴) are labels, not emphasis. Acronyms and names (AWS, TODO, README) aren't emphasis either.

### Workflow
- Don't commit changes without asking the user first.
- Merge PRs with a merge commit that keeps every commit; don't squash.
- Run tests in Docker, never directly on the host. Test scripts must run them in Docker. There are two exceptions. A platform Docker can't host: an iOS or macOS app tests with `xcodebuild` on the Mac, and "Project-Specific Rules" say how tests run. And a developer's frontend watch loop, which may run on the host while they edit - but a watch run never counts as the test run: the results an agent reports, `/pre-pr` and CI come from the Docker script.
- Use `docker compose`, not `docker-compose`.
- Deploy only through CI/CD. Never deploy from a machine or an agent session: no `sam deploy`, `cloudformation deploy`, `cdk deploy` or `terraform apply`, no upload to TestFlight or the App Store, and no console edit to a deployed resource. A change ships by merging it, or by running the workflow that deploys it. The one exception is the access stacks - the roles the workflows run as - which an Admin deploys with `scripts/bootstrap-access.sh`; an agent prepares the change and never runs it. A hook refuses deploy commands in agent sessions; don't look for another way to run one.
- Follow the DRY principle and avoid code duplication.
- Work is tracked in Jira. Use the `jira` skill for tickets; its project settings are in `.claude/skills/jira/PROJECT.md`.
- When `docs/03_TODO.md` is in Maintenance mode, every piece of work has a Jira ticket. If the work in front of you has none, propose creating one before starting.
<!-- docsys:end -->

## Project-Specific Rules

### Stack
- The site is plain HTML and one CSS file, served as-is by GitHub Pages ([DECISION_001](docs/05_DESIGN-DECISIONS.md#decision-001)). Don't add a framework, a site generator, a build step or npm dependencies. JavaScript is plain scripts in `site/js/`, no library, each one improving a page that still works without it; ask before adding a new one.
- Paths in pages are relative (`css/style.css`, not `/css/style.css`), so a page works the same on `oceanbliss.life`, on the `github.io` address and opened from disk. Absolute URLs - canonical links, Open Graph tags, the sitemap - use `https://oceanbliss.life`.
- Every booking call to action links to the 360 Blue listing with UTM parameters naming its source ([DECISION_002](docs/05_DESIGN-DECISIONS.md#decision-002)). The site never takes bookings or shows prices or availability.
- The 360 Blue listing photos are used with 360 Blue's permission. Download and host them in the repository; never hotlink `img.trackhs.com`.
- Resize and compress a photo before adding it - aim for under 300 KB, about 1600 px on the long side - and give every image `alt` text and `width`/`height`.

### Testing and Deploy
- The test run is `scripts/test.sh`: HTML/CSS validation, an internal link check and browser tests of the scripts (Playwright, Chromium and WebKit), in Docker. A change that fails it doesn't merge. Preview with `scripts/preview.sh`.
- The site deploys only through the GitHub Pages workflow on a push to `main`. Never push to a `gh-pages` branch. The Pages settings - source and custom domain - are the owner's to set once; agents don't change them.

### Shell
- We use zsh. Quote glob patterns (`git ls-files '*.html'`): an unmatched glob aborts the command instead of passing through.

### Git
- Move and rename files with `git mv`, never copy and delete.
- `gh` signs in through this project's own configuration directory - `GH_CONFIG_DIR` in `.claude/settings.local.json`. Never run `gh auth switch`. Check the account with `gh api user --jq .login`.
