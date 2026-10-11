# Design Decisions Log

> **📋 DOCUMENTATION RULES FOR AI ASSISTANTS**
>
> **Document Type**: Tier 1 Core Document (never archive; reset at the end of a design phase)
> **Purpose**: Record the key decisions - the few choices with a real alternative that someone will want to reverse
> **Update Frequency**: When a key decision is made, and at a phase reset
>
> **When editing this document**:
> - ✅ Record only key decisions: a real alternative was rejected, and someone will want to reverse it. A product rule goes in the product spec or the PRD, a setup fact in `02_ARCHITECTURE.md`, `04_INFRASTRUCTURE.md` or a design doc
> - ✅ Use the template below: **one paragraph** - the decision, a short why, and the main alternative rejected
> - ✅ Put the Jira ticket key in the title when there is one, and name an owner
> - ✅ Give each decision a short anchor (`<a id="decision-001"></a>`) and link to it from the index - a long heading slug breaks when the title is reworded
> - ✅ Keep each entry in its final form. When a decision changes, rewrite its paragraph and date; supersede it (`Superseded by DECISION_XXX`) only when the old one shipped and must stay readable
> - ✅ At the end of a design phase, archive the log and collapse it - see "Resetting the Decision Log" in `00_ONBOARDING.md`. Each surviving entry names the old numbers it replaces
> - ✅ Cite decisions by ID (`DECISION_001`) in design docs and in code comments where the code exists because of the decision
> - ❌ Don't log rules, revisions of rules, or setup facts - the log is not the project's history; session docs and the archive are
> - ❌ Don't log open questions - they go in the product spec's or the PRD's Open questions
> - ❌ Don't put incident narratives here - they go in `10_TROUBLESHOOTING.md` or the session doc
> - ❌ Don't include code, or duplicate architecture docs (link to them instead)
>
> **Full Documentation System**: [docs/00_ONBOARDING.md](00_ONBOARDING.md)

---

**The key decisions only.** How the product behaves is in the product spec ([`design/PRODUCT-DESIGN.md`](design/PRODUCT-DESIGN.md), if the project has one); what and why is in [`01_PRD.md`](01_PRD.md). A rule is written there, not here - a new entry is for a choice someone will want to reverse.

<!-- After a phase reset, add: **Reset [DATE].** [N] decisions from [PHASE] were collapsed into the ones below, in final form; the rest became rules in the spec and the PRD. The full log is kept in [archive/05_DESIGN-DECISIONS-[PHASE].md](archive/05_DESIGN-DECISIONS-[PHASE].md), with its old numbers. -->

## Index of All Decisions

| ID | Title | Date | Status |
|----|-------|------|--------|
| [DECISION_001](#decision-001) | Plain HTML and CSS, no site generator | 2026-10-10 | Accepted |
| [DECISION_002](#decision-002) | Bookings stay on 360 Blue | 2026-10-10 | Accepted |

---

## Template for New Decisions

Copy this template when recording a new design decision:

```markdown
<a id="decision-xxx"></a>
### DECISION_XXX: [DECISION_TITLE] ([TICKET-KEY])

**Date:** [DATE] · **Status:** Accepted / Rejected / Superseded by DECISION_XXX · **Owner:** [NAME]

[One paragraph: what was decided, why, the main alternative and why it lost, and what we give up. After a reset, end with "Replaces [OLD_NUMBERS]."]

**Related:** [Links to design docs, sessions or architecture sections]
```

---

## Decision Log

<a id="decision-001"></a>
### DECISION_001: Plain HTML and CSS, no site generator

**Date:** 2026-10-10 · **Status:** Accepted · **Owner:** Andres Garcia

The site is hand-written HTML and one CSS file, served as-is by GitHub Pages, because it's a handful of pages that change rarely and the owner wants nothing to learn or maintain. Jekyll, which GitHub Pages builds natively, and other generators such as Hugo or Astro lost: they bring templates, a build step and dependencies to update. We give up shared layouts, so the header and footer are repeated in each page - worth revisiting if the site grows past a few pages or gets a second language.

**Related:** [02_ARCHITECTURE.md](./02_ARCHITECTURE.md)

<a id="decision-002"></a>
### DECISION_002: Bookings stay on 360 Blue

**Date:** 2026-10-10 · **Status:** Accepted · **Owner:** Andres Garcia

The site is a marketing site: it takes no bookings, and every booking call to action goes to the house's listing on 360 Blue, who manage the rental. Direct booking - a calendar, payments and guest messages on the owner's own site - lost because it duplicates what 360 Blue already does and may conflict with the management agreement. We give up seeing which ad led to a stay: the site measures clicks through to the listing, and booking numbers depend on what 360 Blue reports.

**Related:** [01_PRD.md](./01_PRD.md)

---

**Last Updated:** 2026-10-10
