---
name: helpme
description: Explain the Documentation System to someone new to it - what it is, the documents and where each thing is written, the daily loop, and every command and skill this project has - and answer questions about it, pointing to the file that owns each answer and the command that does the job. Read-only. Use when the user types /helpme, is new to the project or the Documentation System, asks "how does this work", "what can I do here", "what commands are there", "where does X go", "how do I add Y", or seems unsure which command or document fits what they want to do.
argument-hint: "[a question | commands]"
user-invocable: true
---

# /helpme - Find Your Way Around

Answer from this project's files, read now, never from memory: the system changes with each update, and a project may have changed its copy. Every answer names the file it came from, so the reader learns where to look next time.

Arguments passed: `$ARGUMENTS`

## 1. Read the Sources

Read only what the request needs; for the tour, all of these.

| Source | What it gives |
|--------|---------------|
| `DOCUMENTATION-SYSTEM-MANUAL.md` | Why the system exists, the document tiers, the workflow |
| `docs/00_ONBOARDING.md` | Every document, what goes where, the session workflow |
| `AGENTS.md` | The rules every agent follows, and the project's own |
| `README.md` | The project, and the system's commands and skills in brief |
| `docs/03_TODO.md` | The **Mode** - Build or Maintenance - and where work stands |
| `.claude/commands/documentation-system/*.md` | The system's commands: each file's `description` |
| `.claude/skills/*/SKILL.md` | The project's skills: each file's `description` and `argument-hint`; `user-invocable: true` means it can be typed |
| `.claude/skills/apply-guide/CATALOGUE.md`, `docs/guides/` | Every guide on offer, and which are installed |

A guide is *applied* when the design doc its header's **Creates** row names exists - the rule `/apply-guide` uses.

## 2. Answer

| Argument | Answer with |
|----------|-------------|
| None | The tour, section 3 |
| `commands`, or "what can I do" | The capability map, section 4 |
| A question | Section 5 |

## 3. The Tour

Short enough to read in a minute - about 30 lines:

1. **What it is**, in three lines, from the manual's opening: the documents are the project's memory, so any session - any person or AI agent - can pick up where the last one stopped.
2. **Where things are written**: the document tiers, and a few of the most-asked "what goes where" rows from onboarding's "During a Session" table.
3. **The daily loop**, as commands: catch up, work and keep the session doc current, status update; before a pull request, `/pre-pr`, then `/review-guides` beside `/code-review`.
4. **Where this project stands**: its Mode; whether its foundation is up (any guide applied) or `/stand-up` is the next step; how many guides are installed and applied.
5. **Three questions to try next**, picked for where the project stands - "how do I add sign-in?" on a new project, "where do decisions go?" on any.

## 4. The Capability Map

Every command and skill found in section 1, grouped by what the reader wants to do - one line each, the command then what it does:

- **Start and keep context**: catch-up, reminders, status-update
- **Build the foundation or a feature a guide covers**: stand-up, apply-guide, and the guides installed but not applied
- **Keep the docs healthy**: audit, init
- **Get a change ready**: pre-pr, review-guides, fix-build, refactoring
- **Track work**: jira
- **Anything left**: a skill that fits no group above

Name each command the way the reader's tool types it: Claude Code writes the system's commands `/documentation-system:catch-up`, Cursor `/documentation-system-catch-up`. Claude Code's own commands - `/code-review`, `/help` - are Claude Code's, not the project's; say so when they come up.

## 5. A Question

1. Find the file that owns the answer - usually onboarding's tables, a rule in `AGENTS.md`, a guide's header, or a skill's description. A question about one command or skill - what it does, what it asks, how it differs from another - gets that command's whole file read, and any file it points to, not just its description.
2. Answer in a few lines, then cite it: `docs/00_ONBOARDING.md` "During a Session", `AGENTS.md` "Workflow".
3. When a command does the job, end with it: "Run `/apply-guide auth`."
4. When the system doesn't cover it, say so, and say what the project's own docs say instead - never invent a command or a rule.

Change nothing. When the reader wants something done, name the command that does it and offer to run it.
