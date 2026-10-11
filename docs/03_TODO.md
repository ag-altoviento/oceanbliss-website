# Project Status & Roadmap

> **📋 DOCUMENTATION RULES FOR AI ASSISTANTS**
>
> **Document Type**: Tier 1 Core Document (never archive, always keep current)
> **Purpose**: Track active tasks and current phase progress, nothing else
> **Update Frequency**: Daily when tasks complete or change
>
> **When editing this document**:
> - ✅ Check off `[x]` completed tasks immediately after finishing them
> - ✅ Update "Current Phase" and "Current Task" at top when changing focus
> - ✅ Keep task descriptions brief (1 line max)
> - ✅ When a phase completes, collapse it into "Completed Work" (1 line per milestone, link its archived session docs)
> - ✅ Write in the present tense, as current truth
> - ✅ "Later" holds what the product deliberately doesn't build yet, each with the trigger that brings it in; when a trigger comes, move its row into a phase
> - ✅ Keep the **Mode** current. **Build**: phases and milestones, as below. **Maintenance**: once the planned phases are done, switch to the layout in `docs/templates/TODO-MAINTENANCE.md` - `/documentation-system:status-update` offers the switch
> - ❌ Don't add verbose descriptions or implementation details
> - ❌ Don't keep a running narrative of what happened - that is the session doc's job
> - ❌ Don't leave a completed item in place "for context" - collapse it into "Completed Work"
> - ❌ Don't put procedures or analysis here - they belong in a guide or design doc, linked from here
> - ❌ Don't duplicate information from design docs or architecture docs
>
> **Full Documentation System**: [docs/00_ONBOARDING.md](00_ONBOARDING.md)

## 📊 Project Overview

**Project Name:** Ocean Bliss Website
**Mode:** Build
**Last Updated:** 2026-10-10
**Current Phase:** Phase 1: Launch the site
**Next Phase:** Later - waiting for a trigger

---

## 🎯 Active Sessions

One row per active session. Each person updates only their own row.

| Session | Owner | What's being worked on |
|---------|-------|------------------------|

---

## 📋 Current Phase Status

### Phase 1: Launch the site - In Progress

#### Milestone 1.1: Content
- [x] Get 360 Blue's OK to use the listing photos
- [ ] Answer the PRD's other open questions - booking reporting, direct contact
- [ ] Download, resize and compress the photos

#### Milestone 1.2: Build the site
- [ ] Page structure and stylesheet, mobile first
- [ ] Home, The house, Location sections, with booking buttons to the listing
- [ ] Google tag: Analytics, and an Ads conversion on clicks through to the listing
- [ ] HTML/CSS validation script in Docker

#### Milestone 1.3: Publish
- [ ] GitHub Actions workflow: validate, then deploy to GitHub Pages on push to `main`
- [ ] Turn on GitHub Pages for the repository, source "GitHub Actions"
- [ ] DNS for `oceanbliss.life` and `www` at the registrar - see [04_INFRASTRUCTURE.md](04_INFRASTRUCTURE.md#hosting)
- [ ] Verify `oceanbliss.life` in the GitHub account, set it as the Pages custom domain, enforce HTTPS

**Owner:** Andres Garcia

---

## 🔮 Upcoming Phases

### Later - Waiting for a Trigger

| What | Trigger | How it comes in |
|------|---------|-----------------|
| Second language | Guests from another-language market | A copy of each page per language |
| Availability calendar | Guests keep asking for dates | An embedded calendar from the booking platform |
| Campaign landing pages | Ads run more than one message | One page per campaign, sharing the stylesheet |

---

## ✅ Completed Work

Nothing yet.

---

**Owner:** Andres Garcia
