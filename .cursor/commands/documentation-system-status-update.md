---
description: Update the session document and TODO to reflect where the work stands
---

Following the Documentation System (`docs/00_ONBOARDING.md`), update the docs to reflect where we are right now. "Your" session is the active one whose **Owner** matches `git config user.name`; don't edit other people's sessions or TODO rows.

- **Session doc:** update your active session in `docs/sessions/` so it is ready to hand over to the next LLM session.
- **TODO:** update `docs/03_TODO.md` according to its **Mode**:
  - **Build:** check off finished tasks and update your row in "Active Sessions".
  - **Maintenance:** update your row in "Now".
- **Generated views:** if you changed a source that has a generated view, rerun its generator; never edit the view by hand.
- **If the session is complete:**
  - Archive it: move it from `docs/sessions/` to `docs/archive/sessions/` and remove the `-active` suffix.
  - **Build:** remove your row from "Active Sessions"; if the milestone is done, record it in "Completed Work".
  - **Maintenance:** move your row from "Now" to "Recently Done", linking the archived session. Offer to move the ticket to the team's final status with the `jira` skill - ask first.
  - Offer to commit the changes on the current branch. Don't commit without the user's OK.
- **If Build mode's last planned phase is done:** offer to switch the TODO to Maintenance mode. Ask before switching. Then:
  1. Save the whole TODO as it stands to `docs/archive/03_TODO-build-YYYY-MM-DD.md` (today's date), unchanged - it's the project's build history.
  2. Rewrite `docs/03_TODO.md` with the layout in `docs/templates/TODO-MAINTENANCE.md`: past phases become one line each in "Completed Build Phases", linking the archived TODO, and "Now", "Next" and "Recently Done" replace the phase sections.
- **If a design phase is ending, or the decision log has grown past its key decisions:** offer the phase reset in onboarding's "Resetting the Decision Log". Ask before starting. Then archive `docs/05_DESIGN-DECISIONS.md` unchanged to `docs/archive/05_DESIGN-DECISIONS-<PHASE>.md` with `git mv`, and walk through the rest of the reset with the user.
- **If we are ready to start new work:** suggest a branch and a session document from `docs/templates/SESSION.md`, named per onboarding's "Session Document Naming". Build mode: the next milestone. Maintenance mode: the next ticket - if the work has no ticket yet, propose creating one first.
