# Troubleshooting Guide

> **📋 DOCUMENTATION RULES FOR AI ASSISTANTS**
>
> **Document Type**: Tier 2 Reference Document (stable, grows with issues discovered)
> **Purpose**: Common issues, diagnostics, and solutions organized by category
> **Update Frequency**: When new issues are discovered or solutions are refined
>
> **When editing this document**:
> - ✅ Add solutions to issues discovered during development/deployment
> - ✅ Keep organized by category (Rendering, Docker, Redis, API, etc.)
> - ✅ Give every entry the same four parts: **Symptoms**, **Cause**, **Fix**, **Related**
> - ✅ Put incident narratives here or in the session doc, not in design decisions
> - ✅ Link to related docs (README.md, guides/, etc.)
> - ❌ Don't add architectural decisions (lives in 05_DESIGN-DECISIONS.md)
> - ❌ Don't duplicate product requirements (lives in 01_PRD.md)
> - ❌ Don't add new implementation details beyond troubleshooting (lives in design docs)
> - ❌ Don't remove historical issues that might recur - condense them instead
>
> **Full Documentation System**: [docs/00_ONBOARDING.md](00_ONBOARDING.md)

---

## General Troubleshooting

Add each issue with **Symptoms**, **Cause**, **Fix** and **Related**.

### Issue: Deploy job fails with "repository not found"

**Symptoms:** The Site workflow's `check` job passes, but `deploy` fails at checkout: `repository 'https://github.com/ag-altoviento/oceanbliss-website/' not found`, exit code 128.

**Cause:** A job's `permissions` replace the workflow's. A deploy job that lists only `pages` and `id-token` gets no `contents: read`, so it can't read a private repository.

**Fix:** List `contents: read` in the deploy job's permissions, beside `pages: write` and `id-token: write`.

**Related:** `.github/workflows/pages.yml` · [SITE-DESIGN.md](design/SITE-DESIGN.md)

### Issue: The github.io address redirects to oceanbliss.life, which doesn't show the site

**Symptoms:** `ag-altoviento.github.io/oceanbliss-website/` redirects to `oceanbliss.life`, which shows a parking or "Website Filtered" page.

**Cause:** Once a custom domain is set in the Pages settings, GitHub redirects the github.io address to it. Until the domain's DNS points to GitHub, the domain serves something else.

**Fix:** Point the DNS at GitHub - see [04_INFRASTRUCTURE.md](04_INFRASTRUCTURE.md#hosting). Check with `dig +short oceanbliss.life`: it should list `185.199.108.153` to `185.199.111.153`. To see the deployed site before then, `curl -H "Host: oceanbliss.life" http://185.199.108.153/`.

**Related:** [04_INFRASTRUCTURE.md](04_INFRASTRUCTURE.md#hosting)
