---
name: review-guides
description: Review a change against this project's own guides and rules - each installed guide the change touches gets a reviewer that checks the diff against that guide's choices, traps, tasks and Done When list, beside three more that look for silent failures, tests that can't fail and broken AGENTS.md rules. Read-only; it reports findings, each citing the rule it breaks. Use before opening a pull request, when asked to check a change against the guides or the project's rules, or when the user types /review-guides. Complements /code-review, which looks for generic bugs.
argument-hint: "[PR number | branch | path]"
user-invocable: true
---

# /review-guides - Review a Change Against the Guides

`/code-review` finds bugs any reviewer would. This finds what only this project knows is wrong: the choices its guides made, the traps they record, the rules in `AGENTS.md`. Each reviewer is a file beside this one, so a guide added later is reviewed with nothing to keep in step.

Arguments passed: `$ARGUMENTS`

## 1. Get the Change

| Argument | The change |
|----------|-----------|
| None | The branch against `main` plus uncommitted work: `git diff main...HEAD` and `git diff HEAD` |
| A PR number | `gh pr diff <n>` |
| A branch | `git diff main...<branch>` |
| A path | That path's diff against `main` |

An empty change: say so and stop.

## 2. Find the Guides It Touches

A guide counts when it is installed - in `docs/guides/` - and either:

- **owns a changed file**: the file sits where a Starter Files table in `.claude/skills/apply-guide/<guide>/IMPLEMENT.md` copies to, or
- **covers what the change does**: its header's **Use when** row matches - a new migration is the Database guide's, a new event consumer the Event Bus guide's, a bundle change Angular Performance's. Guides with no pack are found this way only.

List each guide with the changed files that brought it in. A file no guide covers is still reviewed by the reviewers that always run.

## 3. Run the Reviewers

Run every reviewer at once, each as its own subagent where the agent supports them, otherwise one after another. Give each the change, its files, and its instructions file:

| Reviewer | Runs | Instructions |
|----------|------|--------------|
| Guide | Once per guide from step 2 | [reviewers/guide.md](reviewers/guide.md), with the guide's name |
| Silent failures | Always, on code | [reviewers/silent-failures.md](reviewers/silent-failures.md) |
| Tests that can't fail | Always, on code and tests | [reviewers/test-gaps.md](reviewers/test-gaps.md) |
| Project rules | Always | [reviewers/project-rules.md](reviewers/project-rules.md) |

Reviewers read and report. None edits a file, runs a deploy, or runs tests outside Docker.

## 4. Report

Each finding has the same parts:

- **Severity** - *blocking*: breaks a choice or rule, or repeats a recorded trap; *should fix*: risks one; *note*: worth a look
- **Where** - `file:line` in the change
- **Rule** - what it breaks, cited: `DATABASE-GUIDE.md` choice 4, its trap "Columns are missing...", a Done When item, an `AGENTS.md` rule
- **Why** - what goes wrong, in a sentence
- **Fix** - the smallest change that satisfies the rule

Before reporting, drop a finding that cites no rule or names no line in the change, and merge duplicates - two reviewers often reach the same line. A choice the project changed, recorded in the guide's design doc or `05_DESIGN-DECISIONS.md`, is the project's: not a finding.

Report blocking findings first, then by file. End with what was reviewed - the guides and reviewers that ran - and a line for each Done When item the change completes or leaves open. Then offer to fix the findings; fix only what the user picks.
