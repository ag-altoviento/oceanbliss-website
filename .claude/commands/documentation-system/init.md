---
description: Check the Documentation System setup and walk through fixing what's missing - docs, hooks, permissions, Jira, testing, running locally, access
---

# Init Documentation System

Check that the Documentation System is set up in this project, then help the user finish whatever is missing. **`docs/00_ONBOARDING.md` is the single source of truth** for the documents, tiers, session naming and session workflow. Read it first and check the project against it. Don't restate or redefine its rules here.

## How to Run

1. **Check** every area below. Checking is read-only.
2. **Report** one line per area: ✅ when it's in place, ⚠️ with what's missing.
3. **Fix, one area at a time**, in the order below: explain what's missing and how to fix it, offer to do it, and wait for the user's OK before changing anything. Skip anything the user declines.

## 1. Documents

- **Structure** - Every document and folder in onboarding's "Documentation Structure" table exists.
- **Headers** - Each core document (01-05, 10) has its "DOCUMENTATION RULES FOR AI ASSISTANTS" header, and its **Document Type** tier matches onboarding's "Documentation Tiers" table.
- **Headers are current** - The core documents are installed once and never updated, so their headers fall behind the template's. Compare each one with the template's current copy: `gh docsys status` prints the latest version, and `gh api 'repos/agarcian/documentation-system-template/contents/docs/<file>?ref=v<latest>' -H 'Accept: application/vnd.github.raw'` fetches the file (use `$DOCSYS_REPO` instead, if it's set). The header block is the blockquote from "DOCUMENTATION RULES FOR AI ASSISTANTS" to its last `>` line. Where they differ, show the difference and offer to replace the header block only - the rest of the document is the project's. If `gh` can't reach the template, say so and skip this check.
- **Placeholders** - List documents still containing `[PLACEHOLDER_...]` or `[PROJECT_NAME]` (expected on a fresh project). Offer to fill them in with the user, starting with `01_PRD.md` and `02_ARCHITECTURE.md`. If the project already had docs covering the same ground, offer to merge them in.
- **Sessions** - Files in `docs/sessions/` follow onboarding's "Session Document Naming", end in `-active`, and name an **Owner**. No file in `docs/archive/sessions/` ends in `-active`.
- **TODO** - `docs/03_TODO.md` states its **Mode** (Build or Maintenance). Every row in "Active Sessions" (Build) or "Now" (Maintenance) links to a session document that exists. In Maintenance mode, every active session names a Jira ticket.
- **Design docs** - Each file in `docs/design/` covers one component, not a ticket or a bug, and is linked from the Components table in `02_ARCHITECTURE.md` or "Details" in `04_INFRASTRUCTURE.md`. Offer to add missing links, and to fold ticket- or bug-named docs into their component's doc. The product spec (`docs/design/PRODUCT-DESIGN.md`) and the scenarios under `docs/design/product/` are the exception: they cover the whole product, not one component.
- **Product spec** - Optional. If the PRD's Key Features describe behaviour that needs rules - a user interface, or what an agent does - and `docs/design/PRODUCT-DESIGN.md` doesn't exist, offer to start it from `docs/templates/PRODUCT-DESIGN.md`.

## 2. Agent Entry Points

- **AGENTS.md** - Exists at the root, has exactly one `<!-- docsys:begin` / `<!-- docsys:end -->` managed block, and its "Project-Specific Rules" section (below the block) is filled in. If not, offer to fill it in: ask about the stack, cloud accounts, deployment and generated code, and copy matching sections from `docs/templates/AGENT-RULES-LIBRARY.md`.
- **CLAUDE.md** - If it exists here (or in a parent directory), it imports `@AGENTS.md`. Otherwise Claude Code loads `CLAUDE.md` and never sees `AGENTS.md`.

## 3. Hooks

- **Registered** - The markdown guard `.claude/hooks/block-wrong-markdown.sh` is registered:
  - Claude Code: `.claude/settings.json`, a `PreToolUse` entry with matcher `Write|Edit|MultiEdit` and command `$CLAUDE_PROJECT_DIR/.claude/hooks/block-wrong-markdown.sh`.
  - Cursor: `.cursor/hooks.json`, a `preToolUse` entry with matcher `Write` and command `.claude/hooks/block-wrong-markdown.sh`.

  Fix: `gh docsys update` registers both and keeps any other hooks. Or add the entries by hand, merging into existing settings.
- **Session hooks** - registered for Claude Code and Cursor, so the docs keep themselves current. `gh docsys update` registers them; each can be switched off in `.claude/hooks/docsys.conf`:
  - `.claude/hooks/session-briefing.sh` - Claude Code `SessionStart` (no matcher), Cursor `sessionStart`: a short briefing at every session start
  - `.claude/hooks/session-update-check.sh` - Claude Code `Stop`, Cursor `stop`: asks the agent to update the session doc when code changed after it
  - `.claude/hooks/session-missing-check.sh` - Claude Code `PostToolUse` (matcher `Write|Edit|MultiEdit`), Cursor `postToolUse` (matcher `Write`): asks the agent to create a session doc when code changes on a branch that has none
  - `.claude/hooks/shell-markdown-check.sh` - Claude Code `PostToolUse` (matcher `Bash`), Cursor `postToolUse` (matcher `Shell`): tells the agent when a shell command wrote Markdown outside the allowed places
  - `.claude/hooks/ticket-prompt.sh` - Claude Code `PostToolUse` (matcher `Bash`), Cursor `postToolUse` (matcher `Shell`): on a commit or an archived session, asks the agent to offer moving the ticket to the final status
  - `.claude/hooks/block-manual-deploy.sh` - Claude Code `PreToolUse` (matcher `Bash`), Cursor `preToolUse` (matcher `Shell`): refuses a shell command that deploys - `sam deploy`, `cloudformation deploy`, an app upload - since the project deploys only through CI/CD. Switching it off (`deploy_guard=off`) is the user's decision, never the agent's
- **jq installed** - `jq --version`. The hook needs `jq`; without it the hook lets every write through. Fix: `brew install jq` (macOS) or the system package manager.
- **Allowed Markdown** - Show the entries in `.claude/hooks/allowed-markdown.txt` and ask whether agents need to write Markdown anywhere else (changelogs, API docs, package READMEs). Add what the user confirms.

## 4. Permissions (Claude Code)

Offer to pre-approve the **read-only** commands the Documentation System uses, so agents don't ask every time. Add them to `permissions.allow` in `.claude/settings.json` (shared with the team) or `.claude/settings.local.json` (just this user) - ask which. Merge with existing entries; don't remove any.

```json
{
  "permissions": {
    "allow": [
      "Bash(git status:*)",
      "Bash(git diff:*)",
      "Bash(git log:*)",
      "Bash(git branch:*)",
      "Bash(acli jira workitem search:*)",
      "Bash(acli jira workitem view:*)",
      "Bash(acli jira auth status:*)",
      "Bash(gh docsys status:*)"
    ]
  }
}
```

**Never pre-approve commands that change things** - `git commit`, `git push`, `acli jira workitem create/edit/transition/delete`, `gh docsys install/update`. Those always need the user's OK.

In Cursor, approve these commands when first prompted.

## 5. Jira

- **acli** - `acli --version` and `acli jira auth status`. Fix: follow "Install and Sign In" in the `jira` skill.
- **Project settings** - `.claude/skills/jira/PROJECT.md` has no `[PLACEHOLDER_...]` left. Fix: run the `jira` skill's setup (`/jira setup`).

## 6. Testing

- **How tests run** - Find how this project runs its tests: README, `docs/guides/TESTING-GUIDE.md`, test scripts. Per `AGENTS.md`, tests always run in Docker - flag test commands that run on the host, other than a developer's frontend watch loop. An iOS or macOS app is the exception: its tests run with `xcodebuild` on the Mac, and "Project-Specific Rules" in `AGENTS.md` should say so.
- **Fix, if nothing is documented** - Suggest `gh docsys update --guides testing` to add the Testing Guide and its starter files (`--guides ios-testing` for an iOS app). Then apply it with the user - `/apply-guide testing` (or `ios-testing`), which follows its implementation pack - and record the commands in the README.

## 7. Running Locally

- **How the app runs locally** - Find how this project starts locally: README "Run Locally", start scripts, `docker-compose*.yml`. Skip this area when there's a single service or no backend.
- **Fix, for a backend of several services** (an API plus Lambda or Fargate workers) with no single start script - Suggest `gh docsys update --guides local-backend` to add the Local Backend Guide and its starter files. Then apply it with the user - `/apply-guide local-backend` - and record the start commands in the README's "Run Locally".

## 8. Access

- **The check** - If `scripts/check-access.sh` exists, run it and report what it prints: tools at the versions `.tool-versions` pins, gh signed in as an account that sees the repository, acli signed in, each environment's AWS profiles in the right account, the OIDC provider and deploy role trust, each GitHub environment's branch and reviewers, and every variable and secret the deploy workflow reads. It changes nothing; offer each fix it prints for the user to run, and never run a fix yourself - they sign in, deploy stacks or set secrets.
- **Fix, if there's no check** - On the python-angular-aws stack, suggest `gh docsys update --guides toolchain-access`, then `/apply-guide toolchain-access`. Otherwise skip this area.
- **The project's GitHub account** - Ask whether this machine has more than one GitHub account. If it does and `.claude/settings.local.json` sets no `GH_CONFIG_DIR`, offer the Git Identities guide's [gh setup](../../../docs/guides/MULTI-IDENTITY-GIT-SSH-SETUP-GUIDE.md#7-the-github-cli-one-account-per-project): first confirm `git check-ignore .claude/settings.local.json` matches - if not, offer to add the file to `.gitignore` - then, with the user's OK, write `{"env": {"GH_CONFIG_DIR": "<home>/.config/gh-<account>"}}` into it, merged with what's there. The user runs `gh auth login --insecure-storage` from the project once - a plain login replaces the keychain token every configuration shares - and confirms with `gh api user --jq .login`; never run `gh auth switch`.

## Rules

- Don't create or modify any files without the user's OK.
- If everything is in place, say so in one line.
