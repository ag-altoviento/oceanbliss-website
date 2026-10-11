# Stand-up Questions

> **📋 DOCUMENTATION RULES FOR AI ASSISTANTS**
>
> **Document Type**: Part of the `apply-guide` skill - the questions a new project answers once, before its packs are applied together
> **Purpose**: Every question more than one pack asks, every scope choice, and the product-shape choices with a default - each asked once, with where its answer goes
> **Update Frequency**: When a pack's Ask First gains, loses or shares a question, or an optional part is added
>
> **When editing this document**:
> - ✅ One row per question, under its group, with its key, its default - or "none" when it has to be asked - and every pack it sets
> - ✅ A pack's own Ask First keeps only the questions no other pack asks, and names the keys here it uses
> - ✅ A question a script can answer goes under "Checked, Not Asked"; a product decision the starter's example covers until a feature needs it, under "Asked With the Feature"
> - ❌ Don't explain a choice here - the guide that owns it does
>
> **Full Documentation System**: [docs/00_ONBOARDING.md](../../../docs/00_ONBOARDING.md)

A stack's packs ask about 130 questions between them, and most are the same few facts asked again - the app's prefix five times, the environments five, the account and region five. A stand-up asks each fact once, here, and every pack takes its answer from here. The rest of a pack's Ask First is its own: a product decision that can wait while the starter's example stands, or a tuning number whose starter value is a sound default.

The answers are recorded three ways: all of them in the stand-up's session document; each in the design doc of every guide it sets; and in `05_DESIGN-DECISIONS.md` only where it departs from the default for a reason someone will question.

## Before the Stand-up

What a person does first, in this order - each step is one the next needs, and none is an agent's. The stand-up's plan lists what's still open, with an owner each.

1. **A domain**, and its DNS where the team can add records.
2. **The company's directory** - Google Workspace, or another that speaks SAML and SCIM - with two-step verification enforced for everyone, passkeys or security keys preferred. It's where people's accounts live, and the inboxes the stand-up asks for: one for alarms, such as `alerts@`, and one for support, such as `support@`.
3. **An AWS account**, with MFA on the root user - a passkey or a security key - and no root access keys; a budget alarm to the alert inbox; the alternate contacts set. With `ai`, the account's Anthropic models enabled in Bedrock: the one-time use-case form, and each model's agreement accepted. Nothing in the stand-up's checks sees these - the inference profiles exist without them - and every model call is refused until they're done.
4. **AWS Organizations** turned on from it, so it's the management account, and **IAM Identity Center** with the directory as its identity source: SAML for sign-in, SCIM to sync users and groups. Moving production to its own account later is then a new member account, not a migration.
5. **The groups**, in the directory: `<app>-admins` and `<app>-developers`. Toolchain & Access's [`bootstrap-access.sh`](toolchain-access/IMPLEMENT.md) creates the permission sets and assigns them; until its first run, one temporary admin - an Identity Center assignment, or an IAM user deleted after - is `ADMIN_PROFILE_<env>` in `access.conf`.
6. **The GitHub repository**, its reviewers with two-factor authentication - on a paid plan: a private repository needs GitHub Pro or Team for the environments the deploys run in, and Enterprise for their reviewers; on Pro or Team the review moves to the branches (`REVIEW_GATE=branch`), and a second reviewer is what makes it someone else's. The account that pushes has a verified email: GitHub answers a new, unverified account's pushes with server errors, which read as an outage. With more than one GitHub account on the machine, the project gets its own gh configuration directory first - the Git Identities guide's [one account per project](../../../docs/guides/MULTI-IDENTITY-GIT-SSH-SETUP-GUIDE.md#7-the-github-cli-one-account-per-project) - so another project's `gh auth switch` can't move this one's account mid-stand-up.
7. **Jira**, if the team tracks work there: the site, a project with its board - the jira skill's [workflow for a new project](../jira/SKILL.md#a-workflow-for-a-new-project) unless the team has one - the GitHub for Jira app, so a branch or pull request that names a key shows on its ticket, and `acli` installed and signed in on the machine running the stand-up.
8. **The services the answers name**: the mail domain added at Resend, waiting for its DNS records; a Slack app with the alert channels, if Slack is wanted; a Sentry organization, if errors go there.

Several apps, and dev beside uat, can share the account at first - names and the deploy roles keep them apart; production moves to its own account once there are real users or real data. Toolchain & Access's choices 12 and 13 say how, and where sharing stops.

## Identity

Asked of everyone, with no defaults worth guessing.

| Key | Question | Default | Sets |
|-----|----------|---------|------|
| `app-name` | The app's prefix - lowercase, short, in every resource name | none | Auth `AppName`, Database `APP_NAME`, Deploy `APP_NAME`, Local Backend's prefix, Toolchain & Access `access.conf` |
| `product-name` | What the product is called where people see it | none | Email `EMAIL_BRAND_NAME`, API Structure's title, the Design System's `BRAND_NAME` in `core/brand/brand.ts` - the header, the public pages and a tenant site's fallback read it - and the Frontend Shell's `<title>` in `index.html` |
| `repo` | The GitHub repository, as `owner/name` | none | Toolchain & Access `access.conf` |
| `team` | Who maintains it - the `Team` tag on every AWS resource, one lowercase word | the app's prefix | Toolchain & Access `access.conf` `TEAM`, which sets the deploys' `TEAM` variable |
| `environments` | Which environments | `dev` and `prod` | API Structure `settings.py`, Auth, Database, Deploy, Toolchain & Access |
| `accounts` | One AWS account for every environment, or one each - and their IDs | one each | Deploy, Toolchain & Access, Local Backend's dev account |
| `region` | The AWS region of each environment | `us-east-1` | Deploy `AWS_REGION`, Bedrock's geography, Evals' `aws-region`, Local Backend |
| `release-branch` | The branch production deploys from | `production` | Deploy, Toolchain & Access, Release, Quality Gates' protected branches |
| `reviewers` | Who approves a production deploy and every infrastructure change | none | Toolchain & Access `REVIEWER_LOGINS` |
| `access-groups` | The directory groups for this app's Admins and Developers | `<app>-admins` and `<app>-developers` | Toolchain & Access |
| `admins` | The product's first admins, per environment | none | Admin Console, through Auth's admin group |
| `jira` | The Jira site and project key - or no tracker | none | The jira skill's `PROJECT.md`; Quality Gates' ticket check; the roadmap's tickets |

## Addresses

| Key | Question | Default | Sets |
|-----|----------|---------|------|
| `web-domain` | The web app's address in each environment | the CloudFront domain | Frontend Shell `FRONTEND_DOMAIN` and certificate, API Structure `CORS_ORIGINS` |
| `email-domain` | The domain mail comes from | `mail.` and `updates.` subdomains of the product's domain | Email `EMAIL_FROM`, Notifications `NOTIFICATION_EMAIL_FROM` |
| `mail-outside-prod` | Who may receive mail outside production | the team's `@domain` | Email `EMAIL_ALLOWED_RECIPIENTS` |
| `alert-email` | The person who reads the alarm email | none | Observability `ALERT_EMAIL`, Internal Alerts' backstop |
| `slack` | The Slack channels for alarms and for product activity, per environment | no Slack | Internal Alerts |
| `sentry` | Sentry, or no error tracker | none | Observability `SENTRY_DSN`, Auth's two hooks, Frontend Shell `CSP_CONNECT_EXTRA` |
| `local-ports` | The ports the local API, web app and database use on a developer's machine - others when another project there already has these | 8000, 4200 and 5434 | Local Backend `local-ports.env`, Frontend Shell's `angular.json` serve port |

## Scope

What the first version has. Each question takes one of three answers:

- **Now** - applied at stand-up.
- **Later** - left out at stand-up, and written into `03_TODO.md`'s upcoming phases with the trigger that brings it in: "Webhooks - when the first customer asks to integrate". When the trigger comes, `/apply-guide add <part>` puts it back.
- **Never** - left out, and recorded in `05_DESIGN-DECISIONS.md` with the reason.

Later and Never leave out an optional part - [`optional-parts.txt`](optional-parts.txt) - which the stand-up doesn't copy and strips with `remove-optional.py`; the template's CI proves the stack runs without each. A first version should be small: what isn't needed to learn whether the product works is Later.

| Key | Question | Default | Left out without it |
|-----|----------|---------|---------------------|
| `ai` | Does the product call a model? | Now | `ai`: Bedrock, Evals, Streaming, the AI allowance and kill switch |
| `ios` | Is there an iOS app? | Never | `ios-client`, and the iOS stack's guides |
| `public-site` | Does the product have public pages of its own? | Now | `public-site`: the pages, terms acceptance, the contact form |
| `paid-plans` | Does the product sell plans? | Later | `paid-plans`: one unlimited plan, no plan screens |
| `webhooks` | Will customers integrate with it? | Later | `webhooks` |
| `tenant-sites` | Does each workspace get its own branded site? | Never | `tenant-sites` |
| `welcome-email` | A welcome email on sign-up? | Now | Email's `welcome_email.py`, its template and its block |
| `planned` | Which of the [catalogue](CATALOGUE.md)'s planned guides - payments, social sign-in, account security, push, Fargate - does the roadmap expect, and on what trigger? | none | Nothing now: each one named goes into the upcoming phases |

The stand-up records the template version it assembled from beside the answers, so a later addition can tell what changed since. `add-optional.py` reads which parts a project lacks from its code - their markers are gone - and merges a part back three-way against the installed packs.

## The Roadmap It Writes

The stand-up writes `03_TODO.md`'s phases from the answers, so the first phases carry only what's needed now:

- **Phase 0 - Foundation**: the stand-up itself, through a working dev deploy.
- **Phase 1** - the product's first features, from the PRD.
- **Upcoming phases**: each Later part and planned guide, with its trigger, in the order expected. The owner moves one into a phase when its trigger arrives; nothing is planned in more detail before then.

Each question under "Asked With the Feature" below becomes a line under the first feature that needs its answer.

## Product Shape

Each has a default that stands until the product needs otherwise.

| Key | Question | Default | Sets |
|-----|----------|---------|------|
| `brand` | Colours, greys, type and shape | the starter's | Design System's [Rebrand](design-system/IMPLEMENT.md#rebrand) |
| `roles` | The roles in a workspace | owner, admin, member | Tenancy |
| `personal-workspace` | Does a new user get a workspace of their own? | no | Tenancy |
| `plans` | With `paid-plans`: the plans, each one's limits and features, and where a new workspace starts | free, pro and team; new ones on free | Subscription Tiers, Bedrock's allowance, Webhooks' and Audit Trail's features, Public Site `pricing.ts` |
| `ai-alarm` | With `ai`: the hourly model spend that pages someone, in cents | none | Bedrock `LLM_COST_ALARM_CENTS_PER_HOUR` |
| `support-email` | With `public-site`: where contact messages go | none | Public Site `SUPPORT_EMAIL` |
| `sites-domain` | With `tenant-sites`: the domain sites live under, such as `sites.example.com` | none | Tenant Sites `SITES_DOMAIN` |
| `password-policy` | The password rules | 8 characters, upper, lower and a number | Auth's pool and `PASSWORD_RULES` |

## Checked, Not Asked

A script answers these, and the stand-up stops on a failure.

| Check | Why | Owner |
|-------|-----|-------|
| The repository's plan has what `REVIEW_GATE` needs: `gh api repos/<owner>/<repo>/rulesets` answers, where a private repository on Free gets 403 "Upgrade to GitHub Pro" | Found at the access run instead, the upgrade stops the deploy half done | Toolchain & Access |
| The account's Lambda concurrency quota is above 100 plus every reservation | A new account's is 10, and the deploy fails | Rate Limiting |
| An organization trail already records the accounts | Then `ORGANIZATION_TRAIL=yes`, and no trail is deployed per account | Toolchain & Access, Audit Trail |
| The access groups exist in Identity Center | `bootstrap-access.sh` assigns them | Toolchain & Access |
| Each AI role's model has a profile in the region's geography | A missing one fails every call. It doesn't see the model agreements - [Before the Stand-up](#before-the-stand-up) step 3 | Bedrock |
| The mail domain is verified with Resend | Unverified, every send is refused | Email |
| With `ios`: an App Store Connect API key and an exported distribution certificate | The release workflows sign and upload with them | iOS Release |

A new project has no migration chain to baseline and no production commit to start `production` from: Database's and Release's questions about them don't arise.

## Asked With the Feature

The starter's example stands until the product needs its own. The stand-up asks none of these:

- What the product does: Event Bus's events and consumers, Notifications' types, Streaming's routes, Evals' tasks, Webhooks' public events, Audit Trail's and Rate Limiting's own actions, Privacy's own tables, Feature Flags' dark features.
- Its pages and words: Frontend Shell's areas, Public Site's pages and legal text, Admin Console's deactivation message.
- Its numbers: every limit, retention period, timeout, threshold and page size in a pack's Ask First keeps the starter's value; the pack's guide says why that value.
