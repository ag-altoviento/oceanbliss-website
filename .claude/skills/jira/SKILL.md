---
name: jira
description: Work with this project's Jira through the Atlassian CLI (acli) - search, view, create, edit, transition, assign, comment on and link work items, and look up boards and sprints. Use when the user mentions a ticket key (e.g. "PROJ-69"), asks about TODO or in-progress work, wants to file a bug or story, move a ticket's status, comment, or link tickets. Also sets up the project's Jira settings in PROJECT.md.
user-invocable: true
allowed-tools:
  - Bash(acli *)
---

# /jira - Jira through the Atlassian CLI (acli)

Work is tracked in Jira. This skill drives Jira from the terminal with `acli`, Atlassian's
official CLI for Jira Cloud.

Arguments passed: `$ARGUMENTS`

When the user types `/jira <something>`, treat `<something>` as the intent (e.g.
`/jira show PROJ-69`, `/jira list my open`, `/jira bug login crash`) and run the matching
commands below. `/jira setup` runs "Setting Up PROJECT.md". If the intent is ambiguous,
prefer a read-only `search` or `view`.

---

## Before Anything Else: Project Settings

This project's Jira settings live in [`PROJECT.md`](PROJECT.md) next to this file. This
skill is shared by every project; `PROJECT.md` belongs to this project and is never
overwritten by Documentation System updates.

1. **Read `PROJECT.md`** before running any command. Use its project key, workflow,
   final status, issue types and label rules everywhere below. Examples here use `PROJ`.
2. **If it still has `[PLACEHOLDER_...]` values**, run "Setting Up PROJECT.md" below
   before doing anything else.

## Setting Up PROJECT.md

Fill `PROJECT.md` in with the user. Discover what you can from Jira, then confirm each
value with the user - Jira shows what exists, not how the team wants to use it.

1. **Check `acli`:** `acli --version`. If it's missing, point the user to "Install and
   Sign In" below and stop until it works. Then `acli jira auth status`.
2. **Project key:** ask the user, or list candidates with `acli jira project list`.
   Confirm with `acli jira project view --key PROJ`.
3. **Discover** from recent work items (read-only):
   ```bash
   acli jira workitem search --jql "project = PROJ ORDER BY updated DESC" \
     --fields "issuetype,status,labels" --limit 200 --json
   ```
   Collect the issue types, statuses and labels actually in use.
4. **Ask the user**, one topic at a time, offering what you found:
   - **Issue types** the team uses, and when (e.g. Story for features, Bug for defects).
   - **Workflow:** the statuses in order, from new to done. A new project with no workflow
     yet: offer "A Workflow for a New Project" below.
   - **Our final status:** the last status agents set when work is done, and who
     moves tickets to `Done` if that's someone else (e.g. QA).
   - **Won't-do status:** whether the team closes tickets without doing them, and
     with which status (e.g. `Not Doing`).
   - **Labels:** does the team use them? If yes, which ones and when. If no, agents
     never add labels.
   - **Epics / parents:** should new stories and tasks be linked to an epic?
   - **Boards and sprints:** does the team use sprints? If yes, the board name
     (`acli jira board search --project PROJ` gives its ID).
   - **Jira site URL** (e.g. `https://yourcompany.atlassian.net`), for links in docs.
   - **Anything else** agents should know (required fields, conventions).
5. **Prove the workflow** on a scratch ticket. `acli` can't list a status's transitions,
   and "No allowed transitions found" doesn't say whether a status is missing, renamed
   or not connected - a board that looked complete has refused In Review at the first
   pull request. With the user's OK, create one ticket titled "Workflow check - delete
   me", then move it through the statuses in order, and to the won't-do status:
   ```bash
   acli jira workitem transition --key PROJ-99 --status "In Progress"
   acli jira workitem view --key PROJ-99 --fields status   # read it back
   ```
   Record each move as it went - worked, or refused with its message. A refused one is
   the user's to fix on the board, now rather than when work needs it. Then delete the
   ticket (`acli jira workitem delete --key PROJ-99`), or move it to the won't-do status
   if deleting isn't allowed.
6. **Write `PROJECT.md`**: fill in every value, the proven transitions included, remove
   the placeholder line, and show the user the result.

---

## A Workflow for a New Project

What the Documentation System recommends when a team has no workflow yet - each status a real
step in how work ships. A team that has one keeps it; `PROJECT.md` records what's in use.

| Status | Category | Means | Set by |
|--------|----------|-------|--------|
| Backlog | To Do | Known, not chosen; Later items wait here, labelled `later`, with their trigger | anyone |
| To Do | To Do | Chosen for the current phase or sprint | the owner, at planning |
| In Progress | In Progress | Its `feature/<key>-...` branch and session document exist | whoever starts it |
| In Review | In Progress | Its pull request is open: CI, `/review-guides`, a reviewer | the agent, opening the PR |
| Ready for QA | In Progress | Merged, so CI deployed it to dev - someone checks it there | the agent, after the merge: **our final status** |
| Done | Done | Verified and released to production through its reviewed branch | a person, never an agent |
| Won't Do | Done | Closed without the work, the reason commented | the owner |

Blocked is Jira's flag, not a status: the work keeps its column, and the flag says what it waits
on. A team-managed project takes these in its board settings in a few minutes - `acli` can't
change a workflow.

## Write the Roadmap

`/stand-up`'s hand-over, or any time `docs/03_TODO.md` has phases and no tickets. Read it, then
show the user every ticket below as a list - summary, type, parent - and create nothing until
they agree:

1. **An epic per phase** - "Phase 0 - Foundation", "Phase 1 - ..." - each first, since a child
   gets its parent only at creation: `acli` can't re-parent.
2. **A story per item under it**, with `--parent <epic>`: Phase 0's groups, Phase 1's features.
   A question STANDUP.md leaves for the feature goes in the description of the first story that
   needs it.
3. **A story per "Later" row**, in Backlog, labelled `later` if the team uses labels, with no
   parent: its trigger and how it comes in - `/apply-guide add <part>`, or the guide - in the
   description.
4. **Each key back into `03_TODO.md`**, on its row, so the file stays an index and the ticket holds
   the detail.

Read each ticket back after creating it - the default assignee is often the project lead.

## Rules

- **Confirm before any change.** Show the exact command and the affected ticket keys,
  and wait for the user's OK before `create`, `edit`, `transition`, `assign`, `link`,
  `comment`, `clone`, `archive` or `delete`. Read-only commands need no confirmation.
- **Stop at our final status.** When our work is finished, move the ticket to the final
  status in `PROJECT.md` and stop. If that status isn't `Done`, someone else owns the
  move to `Done` - **never set `Done` yourself.**
- **Never delete or archive** work items unless the user explicitly asks for that ticket.
- **Bulk changes** (`--jql`, `--filter`, `create-bulk`): run the same JQL as a `search`
  first, show the user the list, and only then run the change.
- **Follow the label rules** in `PROJECT.md`. If the team doesn't use labels, leave
  every `--label` / `labels =` out of commands.
- **A ticket isn't the system of record.** Before building what a ticket describes, check
  `docs/05_DESIGN-DECISIONS.md` and the design docs - an earlier decision may already settle it.
- **Verify a ticket's premise.** Tickets describe what someone believed when they wrote them.
  Confirm the problem still exists in the code before building the fix.
- **Won't-do tickets:** if the team has a won't-do status (see `PROJECT.md`), comment the
  reason on the ticket before moving it there.
- **Ticket keys in names:** session docs and branches use the key in lowercase as
  their work-id (e.g. `proj-191`), per `docs/00_ONBOARDING.md`.

---

## What acli Can and Can't Do

Checked against `acli` 1.3.x. Run `acli jira <command> --help` if something here looks
out of date.

| Area | Supported |
|------|-----------|
| Work items | search (JQL), view, create, bulk create (JSON/CSV), edit, transition, assign, clone, archive/unarchive, delete |
| Fields on create/edit | summary, description (plain text or ADF), type, labels, assignee, parent |
| Comments | create, list, update, delete |
| Links | create, list, delete, list link types |
| Watchers | list, remove |
| Attachments | list, delete |
| Projects | list, view |
| Boards and sprints | find boards, list a board's sprints, list a sprint's work items, create/update sprints |
| Filters | list, view, search |
| Output | `--json`, `--csv`, `--web` (opens the browser) |

**Not supported - do these in the Jira web UI** (`acli jira workitem view PROJ-1 --web`):

- **Uploading attachments** - only list and delete.
- **Adding watchers** - only list and remove.
- **Setting a status on create** - create, then `transition` as a second command.
- **Adding or moving work items into a sprint.**
- **Logging work** (worklogs, time tracking).
- **Priority, components, fix versions, due dates, custom fields** - there are no flags
  for these. `create --from-json` may accept them; run
  `acli jira workitem create --generate-json` to see the structure, and fall back to
  the web UI if it doesn't work. Priority can only be set at creation: `edit` has no
  `--priority` flag, and `edit --from-json` rejects the field.
- **Re-parenting** - `create` has `--parent`, `edit` doesn't. Decide the parent when you
  create the ticket; moving it later, or converting it to a type that needs a parent
  (Story to Subtask), is the web UI's Move action.
- **Listing a status's transitions** - there's no way to check a status is reachable
  except by trying it. `/jira setup` tries each one once and records the result in
  `PROJECT.md`'s "Proven transitions".
- **Jira Service Management and Confluence** - out of scope for this skill.

---

## Install and Sign In (one-time)

```bash
# macOS
brew tap atlassian/homebrew-acli
brew install acli

# Other platforms: https://developer.atlassian.com/cloud/acli/guides/install-acli/

acli jira auth login      # OAuth in the browser, or an API token
acli jira auth status     # check who you're signed in as
```

---

## Search / List

```bash
acli jira workitem search --jql "project = PROJ AND status = 'To Do'"
acli jira workitem search --jql "project = PROJ AND assignee = currentUser() AND statusCategory != Done"
acli jira workitem search --jql "project = PROJ AND labels = 'web'"          # only if the team uses labels
acli jira workitem search --jql "project = PROJ" --fields "key,summary,status,assignee" --limit 50
acli jira workitem search --jql "project = PROJ AND status = 'To Do'" --count
```

## View

```bash
acli jira workitem view PROJ-1
acli jira workitem view PROJ-1 --fields "summary,status,comment" --json
acli jira workitem view PROJ-1 --web
```

`view --json` returns a fixed set of fields and leaves out `labels` and `priority`, so
they read as missing even when they're set. Check them with `search` instead:

```bash
acli jira workitem search --jql "key = PROJ-1" --fields "key,labels,priority"
```

## Create

```bash
acli jira workitem create --project PROJ --type Task --summary "Add dark mode"
acli jira workitem create --project PROJ --type Bug --summary "Login crash" --assignee "@me"
acli jira workitem create --project PROJ --type Story --summary "Faster checkout" \
  --description "As a returning customer, I want ... so that ..." --parent PROJ-10
```

Add `--label "web"` only if `PROJECT.md` says the team uses labels.

A create without `--assignee` gets the project's default assignee, which is often the
project lead - not "unassigned". Read the field back before telling anyone who owns a
ticket.

## Edit and Assign

```bash
acli jira workitem edit --key PROJ-1 --summary "New summary"
acli jira workitem edit --key PROJ-1 --labels "web,urgent"
acli jira workitem edit --key PROJ-1 --remove-labels "urgent"
acli jira workitem assign --key PROJ-1 --assignee "@me"
acli jira workitem edit --key PROJ-1 --remove-assignee --yes
```

`--labels` adds to the existing labels; it doesn't replace them. Replacing a label is
three commands: add the new one, `--remove-labels` the old one, then check with
`search --fields labels` - neither edit's output shows the result, and `view --json`
doesn't return labels.

## Transition

```bash
acli jira workitem transition --key PROJ-1 --status "In Progress"
acli jira workitem transition --key PROJ-1 --status "<our final status from PROJECT.md>"
```

`acli` can't list the transitions a work item allows, and a `--jql` transition that
matches nothing fails the same way for a valid status and a misspelled one. When moving
a batch to a status you haven't used before, move one ticket first and read it back.

## Comments

```bash
acli jira workitem comment create --key PROJ-1 --body "This is a comment"
acli jira workitem comment create --key PROJ-1 --body-file comment.txt
acli jira workitem comment list --key PROJ-1
acli jira workitem comment update --key PROJ-1 --id 12627 --body-adf comment.json
acli jira workitem comment delete --key PROJ-1 --id 12627
```

`comment list` flattens each body to plain text, even with `--json`: formatting goes, and
so do whole bullet lists, with nothing to say they were there (still true on 1.3.30).
Use it only for ids and authors. To read a comment, use `view`, which returns the body
as ADF with nothing dropped:

```bash
acli jira workitem view PROJ-1 --fields comment --json
```

To edit a comment in place, change that ADF and pass it back to `comment update`
(`--body-adf` takes a file path). `comment delete` takes `--key`, although its help
example says `--issue`, and it has no confirmation - the comment is gone for good. Read
the whole thread before deleting, and fold anything unique into the comment you keep.

## Links

`--out` is meant to be the outward item and `--in` the inward one, so for `Blocks`,
`--out` blocks `--in`.

```bash
acli jira workitem link create --out PROJ-67 --in PROJ-68 --type Relates --yes
acli jira workitem link list --key PROJ-67
acli jira workitem link delete --id 11926 --yes     # by link id, from view --fields issuelinks
acli jira workitem link type                        # available link types
```

`link create` has been seen storing the link the other way round while echoing your
flags back as if it worked. For `Relates` that's harmless; for `Blocks` it inverts the
meaning. `link list` can't show you: it prints only the outward key, and nothing on the
inward ticket. Check a link's direction with `view` on both tickets:

```bash
acli jira workitem view PROJ-67 --fields issuelinks --json
```

## Boards and Sprints

```bash
acli jira board search --project PROJ
acli jira board list-sprints --id <board-id> --state active
acli jira sprint list-workitems --board <board-id> --sprint <sprint-id>
```

## Useful JQL

| Filter | JQL |
|--------|-----|
| My open work | `project = PROJ AND assignee = currentUser() AND statusCategory != Done` |
| Bugs | `project = PROJ AND type = Bug AND statusCategory != Done` |
| High priority | `project = PROJ AND priority = High` |
| Created this week | `project = PROJ AND created >= -7d` |
| Current sprint | `project = PROJ AND sprint in openSprints()` |
| Not labelled `x`, unlabelled included | `project = PROJ AND (labels IS EMPTY OR labels != 'x')` |

`!=` never matches an empty field, so `labels != 'x'` silently drops every unlabelled
ticket. Use the `IS EMPTY OR` form on any field that can be empty; keep the parentheses,
or the `OR` binds to the whole query. `status` is never empty, so `status != ...` and
`NOT IN` are safe. The subtask type is spelled `Subtask` in JQL; `Sub-task` fails.
