---
description: Audit documentation for consistency, orphans, verbosity, and broken links
---

# Documentation System Audit

## Files to Audit

**Tier 1 (Source of Truth):**
- `docs/01_PRD.md`
- `docs/02_ARCHITECTURE.md`
- `docs/04_INFRASTRUCTURE.md`
- `docs/design/PRODUCT-DESIGN.md`, if it exists - the product spec

**Design Documents:**
- `docs/design/*.md` (all files)
- `docs/design/product/`, if it exists - scenarios that test the spec, and any view generated from them

**Reference Documents:**
- `docs/05_DESIGN-DECISIONS.md`
- `docs/10_TROUBLESHOOTING.md`

## Audit Criteria

**Consistency Check:**
- Features mentioned in PRD exist in Architecture
- Architecture tech stack matches Infrastructure
- Terminology is consistent across all three
- If there is a product spec: every PRD Key Feature has a spec section, and each open question is listed once, in one Open questions list
- Each rule is stated once: flag a rule written out in two documents - spec and decision log, or spec and PRD - and say which copy to replace with a link

**Orphan Detection:**
- Design doc is linked from the Components table in 02_ARCHITECTURE or "Details" in 04_INFRASTRUCTURE. The product spec is linked from 02_ARCHITECTURE, and the scenarios from the spec
- If unreferenced → orphaned (candidate for removal or should be referenced)

**Hub-and-Spoke Structure:**
- 02_ARCHITECTURE and 04_INFRASTRUCTURE stay thin: flag any component or area described in more than one paragraph there - the detail belongs in its design doc or guide
- One design doc per component: flag files in `docs/design/` named after a ticket, a bug or a mechanism - they should be sections in their component's doc. The product spec and `docs/design/product/` are exempt
- Component status markers (🟢 🟡 ⚪) match what the code shows

**TODO Hygiene:**
- `03_TODO.md` states its Mode, and its layout matches it (Build: phases; Maintenance: Now / Next / Recently Done)
- Flag running narrative, procedures or analysis in the TODO - they belong in session docs, guides or design docs
- Flag completed items left in place

**Decision Log Health:**
- Flag entries that read as product rules or setup facts: no rejected alternative, nothing anyone would want to reverse. Say where each belongs - its spec section, the PRD, 02/04 or a design doc
- Flag revision chains: an entry revised more than once, or a `Superseded by` chain longer than one step
- Count the active entries (not superseded or rejected). Past about 30, or with the flags above piling up, offer the phase reset in onboarding's "Resetting the Decision Log". Ask first; the audit itself changes nothing

**Headers Current:**
- The core documents' "DOCUMENTATION RULES FOR AI ASSISTANTS" headers match the template's current ones. Check them as `/documentation-system:init` does under "Headers are current", and offer to replace the header block only

**Generated Views:**
- For each file whose source's header says it is generated, run its generator's `--check` (or, without one, compare the view's timestamp with its source's) and flag drift
- Flag a rendered copy of a document - an HTML view of a Markdown source, say - that has no generator: one of the two copies is hand-kept and will drift

**Verbosity Flags:**
- Design decisions: more than one paragraph per decision (see the header of `05_DESIGN-DECISIONS.md`)
- Troubleshooting items: "one-time" or speculative entries (vs. recurring issues likely to help others)
- Decision/troubleshooting sections: >5 paragraphs without clear subsections (hard to scan)

**Emphasis:**
- ⚠️ markers and ALL-CAPS words used for emphasis, per document (skip status symbols in tables, acronyms, code and `docs/archive/`)
- For each one, check the three-part bar in `AGENTS.md` → "Emphasis". Flag the ones that don't meet it, with a plain-prose rewrite
- Flag any document with more than 6 ⚠️

**Link Validation:**
- If `lychee` is installed, run `lychee --offline --include-fragments=anchor-only --exclude-path docs/archive docs README.md` (or `lychee --config .lychee.toml docs README.md` if the project has one) and report its failures
- Otherwise check by reading: relative links and `@file.md` references resolve, and `#section` anchors exist
- External links (if any) are current

## Checklist

- [ ] Tier 1 Consistency - PRD ↔ Spec ↔ Architecture ↔ Infrastructure alignment, each rule stated once
- [ ] Design Document Orphans - Unreferenced design docs
- [ ] Hub-and-Spoke - Thin hubs, one design doc per component, status markers current
- [ ] TODO Hygiene - Mode, layout, no narrative
- [ ] Decision Log Health - Key decisions only, no revision chains, size - offer the reset if needed
- [ ] Headers Current - Core document headers match the template's
- [ ] Generated Views - Every view matches its source, and every rendered copy has a generator
- [ ] Verbosity Scan - Overly verbose decisions and troubleshooting entries
- [ ] Emphasis - ⚠️ and ALL CAPS only where they meet the bar
- [ ] Link Validation - Broken internal references
- [ ] Cross-Reference Check - Tier 1 docs properly reference design docs

## Report

Report findings grouped by checklist item, with file and section for each. Don't change any files without asking the user first.
