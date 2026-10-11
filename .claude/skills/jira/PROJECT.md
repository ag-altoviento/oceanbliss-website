# Jira Project Settings

Settings for the `jira` skill in this project. The skill (`SKILL.md`) is shared and updated
by the Documentation System; this file belongs to the project and is never overwritten.

[PLACEHOLDER_JIRA_SETTINGS]: Not set up yet. Ask your agent to "set up the Jira settings"
(or run `/jira setup`), or fill in the values below by hand. Remove this line when done.

## Project

| Setting | Value |
|---------|-------|
| **Jira site** | `[JIRA_SITE_URL]` - e.g. `https://yourcompany.atlassian.net` |
| **Project key** | `[JIRA_PROJECT_KEY]` - e.g. `PROJ`, for tickets like `PROJ-123` |

## Issue Types

Which types the team uses, and when.

| Type | Use for |
|------|---------|
| `[TYPE]` | `[WHEN]` - e.g. Story: user-facing features |
| `[TYPE]` | `[WHEN]` - e.g. Bug: defects in released behavior |

**Epics / parents:** `[YES_OR_NO]` - link new stories and tasks to an epic? If yes, how to pick it.

## Workflow

| Setting | Value |
|---------|-------|
| **Statuses, in order** | `[STATUS_1] → [STATUS_2] → ... → Done` - e.g. Backlog → To Do → In Progress → In Review → Ready for QA → Done, the skill's "A Workflow for a New Project" |
| **Our final status** | `[FINAL_STATUS]` - the last status agents set when work is done, e.g. `Ready for QA` |
| **Who moves to Done** | `[WHO]` - e.g. QA after testing, or "us" if the final status is `Done` |
| **Won't-do status** | `[STATUS_OR_NONE]` - e.g. `Won't Do`, for tickets closed without doing the work |

**Proven transitions** - each move tried once on a scratch ticket at setup, since `acli` can't list them:

| From → To | Result | Checked |
|-----------|--------|---------|
| `[FROM] → [TO]` | `[WORKED_OR_REFUSED]` - with Jira's message when refused | `[DATE]` |

## Labels

**Used:** `[YES_OR_NO]` - if no, agents never add labels.

| Label | Use for |
|-------|---------|
| `[LABEL]` | `[WHEN]` - e.g. `web`: work on the web app |

## Boards and Sprints

**Sprints used:** `[YES_OR_NO]` · **Board:** `[BOARD_NAME]` (ID `[BOARD_ID]`)

## Team Conventions

[Optional: anything else agents should know - required fields, description templates, who to assign, etc.]
