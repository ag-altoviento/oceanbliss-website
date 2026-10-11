# [COMPONENT] Guide

> **📋 DOCUMENTATION RULES FOR AI ASSISTANTS**
>
> **Document Type**: Tier 2 Reference Guide - a foundation guide, part of the [STACK] stack
> **Purpose**: How to build [COMPONENT] on this stack - the shape, the choices and why, starter files, and the traps
> **Update Frequency**: When a choice changes, a trap is learned, or the starter files change how they work
>
> **When editing this document**:
> - ✅ Keep the [implementation pack](../../.claude/skills/apply-guide/[component]/) in step with the text, and its tests passing - the guide says what and why, the pack says how
> - ✅ Give every choice its reason in a sentence; a choice learned from a failure says so
> - ✅ Keep it generic: no product names, account IDs or pool IDs - those belong in the project's design doc
> - ✅ If this is one of several ways to do something, say so in "Alternatives" and keep the stack guide's "Choosing Between Guides" in step
> - ✅ If this guide is optional - no stack installs it - mark each line it adds to another guide's files with a comment `optional: [component]`, and keep that wiring inert until it's configured
> - ❌ Don't document what another guide owns - name that guide and link it
> - ❌ Don't keep a history of how the choices were reached - the reasons are enough
>
> **Full Documentation System**: [docs/00_ONBOARDING.md](../00_ONBOARDING.md)

[One paragraph: what a project has once this guide is applied, and what it deliberately leaves to other guides.]

| | |
|---|---|
| **Stack** | [STACK] - see the [stack guide]([STACK]-STACK.md) |
| **Alternatives** | [OTHER_GUIDES_FOR_THE_SAME_JOB_AND_WHEN_TO_PICK_EACH - or "None: the stack's one way"] |
| **Use when** | [THE_REQUESTS_THAT_SHOULD_LEAD_AN_AGENT_HERE] |
| **Depends on** | [GUIDES_THIS_BUILDS_ON] |
| **Creates** | `docs/design/[COMPONENT]-DESIGN.md` in the project |

---

## 1. The Shape

[A Mermaid diagram of the main flow, then one line per step.]

## 2. Choices

[Numbered. Each: the choice in bold, then why - the alternative it beat, or the failure that taught it.]

1. **[CHOICE].** [WHY]

## 3. Implementation

The steps, the starter code and its tests are in the [[COMPONENT] implementation pack](../../.claude/skills/apply-guide/[component]/IMPLEMENT.md), made from [`docs/templates/IMPLEMENT.md`](IMPLEMENT.md). An agent applies it with `/apply-guide [component]`.

## 4. Your Design Doc

Create `docs/design/[COMPONENT]-DESIGN.md` from `docs/templates/DESIGN.md` and record what this project chose. The guide stays generic; the design doc holds this project's values.

| Design doc section | Record |
|--------------------|--------|
| [SECTION] | [WHAT] |

Add the choices you kept or changed to `05_DESIGN-DECISIONS.md`.

## 5. Traps

| Symptom | Cause | Fix |
|---------|-------|-----|
| [SYMPTOM] | [CAUSE] | [FIX] |

## 6. Done When

- [ ] [CHECK]
