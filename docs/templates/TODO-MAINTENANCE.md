# Project Status

> **📋 DOCUMENTATION RULES FOR AI ASSISTANTS**
>
> **Document Type**: Tier 1 Core Document (never archive, always keep current)
> **Purpose**: A short index of what is happening now - in Maintenance mode, Jira holds the work and this file points at it
> **Update Frequency**: When work starts or finishes
>
> **When editing this document**:
> - ✅ Every row names a Jira ticket; the ticket holds the details, the session doc holds the work log
> - ✅ Each person updates only their own rows in "Now"
> - ✅ When work finishes, move its row to "Recently Done" as one line with the archived session linked
> - ✅ Keep "Last checked" in "Status" current
> - ✅ Write in the present tense, as current truth
> - ❌ Don't copy ticket descriptions, acceptance criteria or discussion from Jira
> - ❌ Don't keep a running narrative - that is the session doc's job
> - ❌ Don't put procedures or analysis here (deploy steps, investigations) - they belong in a guide or design doc, linked from here
> - ❌ Don't keep an inbox of ideas here - new work becomes a Jira ticket; "Later" holds only what was deliberately deferred, each with its trigger
>
> **Full Documentation System**: [docs/00_ONBOARDING.md](../00_ONBOARDING.md)

<!-- This is the layout for Maintenance mode. When the planned phases are done,
     /documentation-system:status-update offers to switch docs/03_TODO.md to it: the whole
     build-era TODO is saved to docs/archive/, past phases collapse into "Completed Build Phases",
     its "Later" rows carry over as they are, and the sections below replace the rest. -->

## Status

**Project Name:** [PROJECT_NAME]
**Mode:** Maintenance
**Release:** continuous - or: [VERSION], target [DATE]
**Jira board:** [LINK]
**Last checked:** [DATE] - when someone last confirmed this file matches Jira

---

## Now

One row per ticket in progress. Each person updates only their own rows.

| Ticket | What | Session | Who |
|--------|------|---------|-----|
| [PROJ-123] | [One line] | [docs/sessions/YYYY-MM-DD-proj-123-[description]-active.md] | [NAME] |

## Next

The next tickets, in order - or "see the Jira board".

1. [PROJ-124] - [One line]

## Later

What the product deliberately doesn't build yet, carried over from the build phases. When a trigger comes, the row becomes a Jira ticket and leaves this table.

| What | Trigger | How it comes in |
|------|---------|-----------------|
| [Webhooks] | [The first customer asks to integrate] | [`/apply-guide add webhooks`] |

## Recently Done

Newest first. Trim rows older than a few weeks; the archived sessions keep the history.

| Date | Ticket | What | Session |
|------|--------|------|---------|
| [DATE] | [PROJ-120] | [One line] | [docs/archive/sessions/YYYY-MM-DD-proj-120-[description].md] |

## Completed Build Phases

One line per phase, from when the project was in Build mode. The full build-era TODO - plans, milestones, what shipped - is archived at [docs/archive/03_TODO-build-YYYY-MM-DD.md].

- [PHASE_NAME] - completed [DATE]
