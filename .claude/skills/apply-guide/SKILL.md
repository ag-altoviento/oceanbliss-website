---
name: apply-guide
description: Apply one of this project's foundation guides (docs/guides/*-GUIDE.md) - copy its tested starter code, adapt it, run its tests and write its design doc - or run a recurring task a guide defines, such as adding a tenant table. Also lists every guide the Documentation System offers, by capability and platform, with what this project has applied, and reviews what a Documentation System update changed in the guides. Use when asked to set up or add a piece of the foundation a guide covers (workspaces and roles, sign-in, email, events, LLM calls, streaming, deploy, database, observability, the API client...), what guides or features are available, what an update changed, when an optional part left out at stand-up - AI, webhooks, the public site, paid plans - is wanted now, when the user types /apply-guide, or before writing code for something an installed guide already covers.
argument-hint: "[guide] [task]"
user-invocable: true
---

# /apply-guide - Apply a Foundation Guide

A foundation guide is two halves. The guide in `docs/guides/<NAME>-GUIDE.md` says what to build and why - its shape, choices and traps - for people. Its implementation pack beside this file, `<guide>/IMPLEMENT.md`, says how: questions to ask, steps, starter files with tests, and recurring tasks. This skill joins them.

Arguments passed: `$ARGUMENTS`

## 1. Find the Guide

[`CATALOGUE.md`](CATALOGUE.md), beside this file, lists every guide the Documentation System offers, by capability and platform - Web, iOS, or any project - with what each gives, its install name and its status, planned ones included.

With no argument, or one that matches nothing, show the catalogue with each guide's state in this project, by capability:

- **applied** - the design doc its header's **Creates** row names exists (for Deploy, its environments in `04_INFRASTRUCTURE.md`);
- **installed** - its guide is in `docs/guides/` (and its pack beside this file), not applied yet;
- **available** - in the catalogue, not installed: `gh docsys update --guides <install name>` installs it. Ask before running it;
- **planned** or **suggested** - not written yet. Say so, and build it the plain way only if the user agrees.

Then ask which to apply. A guide's header has a **Use when** row, and its stack guide the order to build them in.

## 2. Apply It

1. **Read the guide's Choices and Traps.** An installed guide overrides generic advice, including other skills: its choices were learned from a production project, and its starter code is tested.
2. **Check what it builds on.** The pack's **Apply first** row; a guide applied without its dependencies fails in ways its traps don't cover. Offer to apply a missing one first.
3. **Ask the pack's "Ask First" questions** before writing anything.
4. **Follow the pack's Steps.** Copy each starter file to where its table says, then adapt the lines marked `CUSTOMIZE`. Copy - never edit the pack in place: a Documentation System update replaces it.
5. **Run the tests** - the starter's tests with the project's own, through the project's test script.
6. **Write the design doc** the guide's header names, from `docs/templates/DESIGN.md`, using the guide's "Your Design Doc" section. Record the project's values, and the choices it changed, in that design doc; a changed choice goes in `05_DESIGN-DECISIONS.md` too only when it rejects the guide's choice for a reason someone will question again. Link the design doc from `02_ARCHITECTURE.md`.
7. **Tick the guide's "Done When" list** in the session document, and leave unticked what isn't done yet.

## 3. Run a Task

When the request matches a task in a pack's **Tasks** row - adding a tenant table, re-exporting the API spec - read that pack's task and do only that. The task's own steps include its tests.

## 4. Leave Out an Optional Part

[`optional-parts.txt`](optional-parts.txt) lists the parts a project can do without, and the pack folders - or folders and files inside a pack - each one owns. To leave one out - at stand-up, or later:

1. Don't copy, or delete, the files that part owns - its packs' starter tables list them.
2. `python .claude/skills/apply-guide/remove-optional.py --without <part> .` strips the part's `optional: <part>` markers from everything else and relinks the migration chain. `--check` shows what it would change first.
3. Re-export the API spec, run the full test suite, and record the choice in `05_DESIGN-DECISIONS.md`.

### Add It Back

`/apply-guide add <part>` - a part left out at stand-up, or since, whose trigger has come:

1. `python .claude/skills/apply-guide/add-optional.py <part> . --check` shows what it would change; without `--check` it does it. It merges only the part's lines into each file the project already has, three-way, so the project's own changes stay; copies the part's own files; puts its migrations after the project's head; and appends its requirements.
2. Resolve any conflict it reports - a file the project has changed where the part's lines go.
3. A migration it reports - the part marks a line in one the database has run, such as a column's default - needs a new migration from the owner: never edit one that has shipped.
4. Apply the part's packs as in [Apply It](#2-apply-it) from Ask First on - their starter files are in place; adapt them, re-export the API spec, regenerate the clients, run every test.
5. Move the part's line in `03_TODO.md` from the upcoming phases into the current one, and record it in `05_DESIGN-DECISIONS.md` if it reverses a "Never".

## 5. When the Guide Is Wrong

If a choice doesn't fit this project, decide what to build instead and record it in the guide's design doc. Record it in `05_DESIGN-DECISIONS.md` as well only when it rejects the guide's choice for a reason someone will question again. Then build what was decided. If a step or a starter file is wrong, fix the project's copy and say what to report upstream.

## 6. Review an Update

A Documentation System update (`gh docsys update`) replaces the guides and their packs. It never touches the project's own code: what to bring over is the owner's decision. When asked what an update changed - `/apply-guide review-update` - report it and change nothing until the owner chooses:

1. **What changed**: the update's diff under `docs/guides/` and `.claude/skills/apply-guide/` - uncommitted after the update, or its commit once merged.
2. **The starters, three ways**: `python .claude/skills/apply-guide/update-triage.py` (with `--old <the commit before the update>` once it's committed). It lays out the packs before and after the update as this project has them, the parts it left out left out, and sorts each starter file the update changed against the project's copy: already new, already has the change, takes cleanly, merges cleanly, conflicts, no common base, new. Show its table and counts. Nearly every conflict is the same fix made on both sides - say which side to keep, and why.
3. **For each applied guide whose guide or pack changed**: what changed, in a few lines - a new choice, a fixed trap, a starter file changed or added, a step added - and which of the project's files it would touch. A choice the project recorded as its own, in `05_DESIGN-DECISIONS.md` or the guide's design doc, is the project's; say the guide moved and leave it.
4. **Newly installed guides**, not applied: name each with what it gives.
5. **Ask which to bring over**, one at a time. The clean ones can come over together, with the owner's yes: `update-triage.py --apply` writes only those - the takes, the clean merges, the new files - and nothing it would have to guess. For the rest, and for each guide the owner picks, follow section 2 for that part only - its tests included - and record it in the guide's design doc.

