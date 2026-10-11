---
name: stand-up
description: Stand up a new project's foundation in one pass - interview the owner once with the stand-up questions, plan, assemble every chosen implementation pack with the optional parts left out, adapt them in parallel, verify in Docker, deploy dev through CI, and hand over a roadmap with what's deferred. Use when a new project wants its foundation built, when asked to "stand up", "bootstrap" or "set up the whole stack", or when the user types /stand-up. For one guide at a time use /apply-guide.
argument-hint: "[resume]"
user-invocable: true
---

# /stand-up - The Foundation in One Pass

A stand-up turns an empty project with the Documentation System installed into a working "app that does nothing": sign-in, workspaces, the web app, the API, email, alarms - deployed to dev and smoke-checked - with a roadmap that holds what was left for later. It applies the stack's foundation guides together, so each fact is asked once and the packs are assembled the way the template's CI tests them.

Arguments passed: `$ARGUMENTS` - `resume` picks up from the stand-up's session document.

The session document, `docs/sessions/YYYY-MM-DD-standup-active.md`, is the record from the first question on: every answer, the plan, each phase's result. Keep it current, so a new session can resume at any phase.

## 1. Interview

Ask the questions in [`STANDUP.md`](../apply-guide/STANDUP.md), one group at a time - Identity, Addresses, Scope, Product Shape - with each default named, so "the default" is an answer. Use AskUserQuestion where the answers are a few choices. Record each answer, with its key, in the session document.

For Scope, say what each Later costs: nothing now, one `/apply-guide add` when its trigger comes. Lean to Later for anything not needed to learn whether the product works.

## 2. Plan

Show the plan and wait for approval:

- the template version - `.docsys/VERSION` - and the parts left out;
- the guides to apply, in the stack guide's [Phase 0 order](../../../docs/guides/PYTHON-ANGULAR-AWS-STACK.md#4-build-order);
- what the people do meanwhile, as a checklist with an owner each: whatever of STANDUP.md's [Before the Stand-up](../apply-guide/STANDUP.md#before-the-stand-up) is still open, then the Slack app and the Sentry project if they're wanted;
- the checks in STANDUP.md's "Checked, Not Asked", and when each runs - the GitHub plan's before this plan is shown, so an upgrade it needs is on the checklist rather than found at the access run;
- with `jira` answered: `/jira setup` now, so `PROJECT.md` holds the key, workflow and final status before any ticket is written.

## 3. Assemble

On a new branch, never `main`:

1. Create the Angular workspace as [Frontend Shell](../apply-guide/frontend-shell/IMPLEMENT.md)'s Steps say, and with the Public Site, set its `angular.json` as [Public Site](../apply-guide/public-site/IMPLEMENT.md)'s do.
2. `python .claude/skills/apply-guide/assemble.py . --without <every Later and Never part>` - every pack's starter files where their tables put them, the requirements merged, the parts left out and their markers stripped. The template's CI assembles the stack this way for every part, so what lands is a tested whole.
3. Commit the assembly alone, before any adapting, so each later change reads as a diff against the starters.

## 4. Adapt

Fan out one subagent per Phase 0 group, in parallel where the order allows: each applies its group's guides with `/apply-guide <guide>` from Ask First on, taking every STANDUP.md key from the session document - it asks the owner nothing those answers cover. Each one:

- sets the `CUSTOMIZE` values its answers decide, and leaves the starter's example where STANDUP.md says the feature decides later;
- writes the design doc its guide names, with the project's values;
- reports what it changed, what it left, and any question that truly needs the owner.

Collect the reports into the session document. Ask the owner the leftover questions together, once.

## 5. Verify

In Docker, never on the host:

1. The project's full test suite, the migrations up, down and up, the templates' and workflows' lints - `/pre-pr all`.
2. The checks from "Checked, Not Asked", and `scripts/check-access.sh` once the access stacks exist.
3. `/review-guides` on the whole change.

Fix with `/fix-build` until everything passes. Never skip a check to get there.

## 6. Deploy Dev

Only through CI - never from this session. Ask before each step:

1. `main` is on GitHub - push it first in a new repository: with `REVIEW_GATE=branch` the access run gives it a ruleset, and from then on it takes changes only through pull requests.
2. An Admin runs `scripts/bootstrap-access.sh` for the access stacks - the roles the workflows run as. Prepare `access.conf` from the answers; never run it yourself.
3. Commit, push, and open the pull request; merge it when CI is green and the owner agrees.
4. The infrastructure workflow creates the retained stacks - user pool, database - behind its reviewer, for `auth` and then `data`. The merge's own dev deploy runs before them and stops at its first step, saying so; once Infra has run, run Deploy dev again.
5. Smoke-check what the deploy verified and a person can see: sign up, the confirmation email, sign in, a workspace, the alarm email subscription confirmed.

## 7. Hand Over

- `03_TODO.md`: Phase 0 ticked; Phase 1 from the PRD's first features; "Later - Waiting for a Trigger" with every Later part, every planned guide the owner named, and each trigger. Each STANDUP.md "Asked With the Feature" item goes under the first feature that needs it.
- With Jira: the jira skill's [Write the Roadmap](../jira/SKILL.md#write-the-roadmap) - an epic per phase, a story per item, a Backlog story per Later row - once the owner agrees to the list, each key written back into `03_TODO.md`.
- `05_DESIGN-DECISIONS.md`: each Never, and each answer that departs from a default for a reason someone will question.
- `04_INFRASTRUCTURE.md`: the accounts, environments and stacks, as Deploy and Toolchain & Access say.
- The session document finalised and archived, as onboarding says.

Then tell the owner what works, what's deferred and on what trigger, and what's theirs to do next.
