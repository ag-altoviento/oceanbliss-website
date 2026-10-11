# Guide Catalogue

> **📋 DOCUMENTATION RULES FOR AI ASSISTANTS**
>
> **Document Type**: Part of the `apply-guide` skill - the one list of every guide the Documentation System offers
> **Purpose**: What a project can have, by capability and platform: each guide, what it gives, its install name and status, and what is planned
> **Update Frequency**: When a guide is added, changes status, or something is planned or dropped
>
> **When editing this document**:
> - ✅ One row per guide, in the capability it serves; "Gives the project" in one line
> - ✅ A planned row names what it would give, so a project can see what's coming
> - ✅ Keep each stack's line in the manifest and its guide's build order in step with this list
> - ❌ Don't explain a guide's choices here - its guide owns them
>
> **Full Documentation System**: [docs/00_ONBOARDING.md](../../../docs/00_ONBOARDING.md)

Every guide the Documentation System offers, grouped by what it gives a product. A project installs guides by stack or one at a time, and applies an installed one with `/apply-guide <name>`.

## Platforms and Stacks

| Platform | Stack | Install with |
|----------|-------|--------------|
| Web - Python API, Angular app, AWS | [python-angular-aws](../../../docs/guides/PYTHON-ANGULAR-AWS-STACK.md), which also sets the build order | `gh docsys update --stacks python-angular-aws` |
| iOS - SwiftUI app | ios-swiftui | `gh docsys update --stacks ios-swiftui` |
| Any | Guides that serve every project, installed with a stack or alone | `gh docsys update --guides <install name>` |

A product with a web app and an iOS app installs both stacks; the iOS app calls the web stack's API through the client SDK Generation builds.

**Status**: ✅ built, with tested starter code where the guide has a pack · ✅ optional - no stack installs it, add it on purpose · ⚪ planned - not written yet, and on the way; build it the plain way meanwhile, and record it in the design doc · ⚪ suggested - an idea for a later guide, not scheduled.

## By Capability

### Workstation and access

The tools, sign-in and accounts a person needs before writing code.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Toolchain & Access](../../../docs/guides/TOOLCHAIN-ACCESS-GUIDE.md) | Web | `toolchain-access` | Tools pinned in one file CI reads, Identity Center profiles per environment - an everyday Operator that can't deploy and an hour of Admin, the CI roles trusting GitHub environments that admit one branch and a reviewer, one script for the access stacks, a read-only check of all of it | ✅ |
| [AWS Multi-Account](../../../docs/guides/AWS-MULTI-ACCOUNT-SETUP.md) | Any | `aws-multi-account` | Claude Code's own Bedrock account kept apart from the project's, so neither's credentials leak into the other | ✅ |
| [Git Identities](../../../docs/guides/MULTI-IDENTITY-GIT-SSH-SETUP-GUIDE.md) | Any | `git-ssh-identities` | One SSH key and git identity per account on one machine | ✅ |
| [Claude Code Backends](../../../docs/guides/CLAUDE-CODE-MULTI-BACKEND-SWITCHING-GUIDE.md) | Any | `claude-code-backends` | Switching Claude Code between its backends | ✅ |
| [Statusline](../../../docs/guides/STATUSLINE_SETUP_GUIDE.md) | Any | `statusline` | Each project's own Claude Code status line - how to change it | ✅ |

### Delivery

Getting code tested, checked and shipped.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Deploy](../../../docs/guides/DEPLOY-GUIDE.md) | Web | `deploy` | Container Lambdas, a deploy role per environment with a permissions boundary, one reusable deploy that migrates first and verifies what it shipped | ✅ |
| Long-running services on Fargate | Web | - | For work that outgrows Lambda - steady high load, runs past 15 minutes, long-lived connections: an ECS service on Fargate behind the load balancer or reading its own queue, deployed by the same workflow, with the same alarm contract - running tasks, CPU and memory, the load balancer's errors and latency - and a row in the service profile | ⚪ planned |
| [Local Backend](../../../docs/guides/LOCAL-BACKEND-GUIDE.md) | Web | `local-backend` | API, workers and database in Docker, one start script | ✅ |
| [Testing](../../../docs/guides/TESTING-GUIDE.md) | Web | `testing` | Test tiers, Docker test scripts | ✅ |
| [iOS Testing](../../../docs/guides/IOS-TESTING-GUIDE.md) | iOS | `ios-testing` | Tests with xcodebuild in the Simulator, git hooks and CI, and the traps that make a green run lie | ✅ |
| [Quality Gates](../../../docs/guides/QUALITY-GATES-GUIDE.md) | Any | `quality-gates` | Pre-commit and PR checks | ✅ |
| [GitHub Actions](../../../docs/guides/GITHUB-ACTIONS-BEST-PRACTICES.md) | Web, iOS | `github-actions` | The map of every workflow on web and iOS and the pack that ships it, concurrency that queues deploys, one deploy role per environment, job-level permissions, change detection against what's deployed, stack recovery | ✅ |
| [Release](../../../docs/guides/RELEASE-MANAGEMENT.md) | Web | `release` | Conventional commits, semantic versions and a release branch prod is promoted from | ✅ |
| [iOS Release](../../../docs/guides/IOS-RELEASE-GUIDE.md) | iOS | `ios-release` | From main to TestFlight and the App Store through two dispatched workflows on one reusable release - per-target signing, the bundle and upload checks, TestFlight notes - plus build and version numbers, tags, App Review | ✅ |

### Data

Where the product's data lives, and who may reach it.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Database](../../../docs/guides/DATABASE-GUIDE.md) | Web | `database` | Aurora per environment, one session module, credentials that survive rotation, migrations guarded against breaking a deploy | ✅ |
| [Aurora Auth Security](../../../docs/guides/AURORA-DATABASE-AUTH-SECURITY-GUIDE.md) | Web | `aurora-auth-security` | Database credentials and IAM auth | ✅ |

### API

One backend, and the clients that call it.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [API Structure](../../../docs/guides/API-STRUCTURE-GUIDE.md) | Web | `api-structure` | One FastAPI app on Lambda, routes/services/adapters with a fake per adapter, one error mapping, CORS at both layers, health checks | ✅ |
| [SDK Generation](../../../docs/guides/SDK-GENERATION-GUIDE.md) | Web, iOS | `sdk-generation` | One committed spec exported from the code, the web client generated on every build and never hand-written, a breaking-change gate, and a thin checked iOS client | ✅ |

### Sign-in and identity

Accounts, sign-in and who a request is.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Auth](../../../docs/guides/AUTH-GUIDE.md) | Web | `auth` | Sign-up, sign-in, verification, password reset, token verification, users provisioned on first request, admin group | ✅ |
| OAuth and social sign-in | Web | - | Google, Apple and Microsoft sign-in beside email and password, through the same user pool | ⚪ planned |
| Account security - devices and sign-in alerts | Web, iOS | - | Each sign-in's device known to the API; an email on the first sign-in from a new device, with a "this wasn't me" link that signs it out; a "your devices" page on web and iOS to sign any one out; every event in the audit trail | ⚪ planned |

### Apps

What people see and touch.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Design System](../../../docs/guides/DESIGN-SYSTEM-GUIDE.md) | Web | `design-system` | One brand file that every shade, role and component derives from, light and dark themes, Tailwind 4 on the roles only, a small component kit, contrast checked in a real browser, a lint that keeps colours out of components | ✅ |
| [Frontend Shell](../../../docs/guides/FRONTEND-SHELL-GUIDE.md) | Web | `frontend-shell` | One Angular build configured at runtime, layouts as guarded parent routes, accessible toasts and dialogs, hosting behind CloudFront with a pinned CSP | ✅ |
| [Public Site](../../../docs/guides/PUBLIC-SITE-GUIDE.md) | Web | `public-site` | Landing, pricing, about, contact and legal pages prerendered at build with their own titles and canonical links, the app under `/app`, a real 404, a sitemap from the route table, a contact form that reaches support, terms acceptance on record | ✅ |
| [Angular Performance](../../../docs/guides/ANGULAR-PERFORMANCE.md) | Web | `angular-performance` | Frontend performance rules | ✅ |
| [SwiftUI Patterns](../../../docs/guides/SWIFTUI-PATTERNS-GUIDE.md) | iOS | `swiftui-patterns` | Keyboard, scrolling, sheets, toolbars and view wiring, and the anti-patterns that broke them | ✅ |

### AI

Model calls, what they cost, and whether they're any good.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Bedrock](../../../docs/guides/BEDROCK-GUIDE.md) | Web | `bedrock` | One Converse adapter with time-bounded retries, models per role in one registry, an exact cost ledger, server-side spend limits, spend alarms | ✅ |
| [Evals](../../../docs/guides/EVALS-GUIDE.md) | Web | `evals` | An eval per feature that calls a model, run through production code on real Bedrock, deterministic checks, committed results; a monthly scout for cheaper models and price drift | ✅ |
| [Streaming](../../../docs/guides/STREAMING-GUIDE.md) | Web | `streaming` | Answers past API Gateway's 29 seconds - a streaming Function URL from the same image, server-sent events that always end with done, the ledger charged once per stream, a fetch-based client | ✅ |

### Background work and messages

Work done after the request, and messages to people and systems.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Event Bus](../../../docs/guides/EVENT-BUS-GUIDE.md) | Web | `event-bus` | Domain events in one envelope, published after the commit, SNS to one queue per consumer, each event handled once, dead letters that page | ✅ |
| [Email](../../../docs/guides/EMAIL-GUIDE.md) | Web | `email` | Resend behind one client, escaped templates with a text part, sends from consumers that never send twice, Cognito's codes in branded emails, bounces suppressed, no mail to real people from dev | ✅ |
| [Notifications](../../../docs/guides/NOTIFICATIONS-GUIDE.md) | Web | `notifications` | Email people chose and can stop - types and defaults in code, preferences as changes, one consumer that decides who to tell, a record of every delivery, one-click unsubscribe, bulk mail on its own subdomain | ✅ |
| Push notifications | iOS | - | Notifications on the phone through APNs, as a second channel beside email: device tokens per signed-in device, the same types and preferences, a delivery record per push | ⚪ planned - after Account security |
| [Webhooks](../../../docs/guides/WEBHOOKS-GUIDE.md) | Web | `webhooks` | Public, versioned events per workspace, signed to the Standard Webhooks spec with KMS-encrypted secrets, delivered and retried per endpoint, never to a private address; endpoints, tests and redelivery on a settings page | ✅ |

### Teams and operators

Many people per product, and the people who run it.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Tenancy](../../../docs/guides/TENANCY-GUIDE.md) | Web | `tenancy` | Workspaces as the tenant, the workspace in every URL, ordered roles with an owner always kept, 404 isolation tested against a real foreign workspace, invitations bound to the invited address | ✅ |
| [Tenant Sites](../../../docs/guides/TENANT-SITES-GUIDE.md) | Web | `tenant-sites` | Each workspace on its own subdomain or custom domain with its own brand, hosts resolved in one place, certificates CloudFront issues and renews | ✅ optional |
| [Admin Console](../../../docs/guides/ADMIN-CONSOLE-GUIDE.md) | Web | `admin-console` | The operator's view across workspaces - one gated admin router swept by a test, accounts without their contents, deactivation that takes effect on the next request, every admin action recorded with its reason | ✅ |
| Admin Console - impersonation | Web | - | Seeing the product as a user sees it, read-only, with their consent on record and every view in the audit trail | ⚪ suggested |
| Admin Console - support notes | Web | - | Notes on an account or workspace that operators share, never shown to the customer | ⚪ suggested |
| Admin Console - usage and revenue | Web | - | Sign-ups, active workspaces, plans and AI spend over time, across every workspace | ⚪ suggested |
| Admin Console - moderation | Web | - | Reviewing reported content, hiding it, and acting on the account behind it | ⚪ suggested |
| Admin Console - bulk plan changes | Web | - | Moving many workspaces between plans at once, each with its reason recorded | ⚪ suggested |
| Admin Console - system health | Web | - | Alarms, dead letters, queue depth and recent errors on one page, with links to the logs | ⚪ suggested |

### Plans and billing

What each customer gets, and paying for it.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Subscription Tiers](../../../docs/guides/SUBSCRIPTION-TIERS-GUIDE.md) | Web | `subscription-tiers` | A plan per workspace from one registry in code, every limit enforced on the server - AI spend, members, free workspaces per owner, features - usage shown with "unlimited" never a 0, plan changes recorded with a reason | ✅ |
| Payments | Web | - | A payment provider's checkout and webhooks moving a workspace between plans | ⚪ planned - parked for research |

### Product controls

Changing what the product does without a deploy.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Feature Flags](../../../docs/guides/FEATURE-FLAGS-GUIDE.md) | Web | `feature-flags` | Flags declared in code with their defaults, overridden per environment from the Admin Console with a reason, read the same by API and workers within seconds, sent to the web app and iOS; release flags that expire, and kill switches for AI answers and webhook delivery | ✅ |
| Flag targeting | Web | - | Turning a flag on for chosen workspaces, people or a percentage of them | ⚪ suggested |

### Trust and safety

Keeping data, people and the bill safe.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Privacy](../../../docs/guides/PRIVACY-GUIDE.md) | Web | `privacy` | Self-serve account deletion with a grace period and one purge for users and admins, a copy of one's data as JSON, retention periods, one registry of personal data a test checks against the schema, a policy that says only what is built | ✅ |
| [Audit Trail](../../../docs/guides/AUDIT-TRAIL-GUIDE.md) | Web | `audit-trail` | Who did what in a workspace and to an account, written with the change and append-only in the database, operators shown as Support, a Team page with filters and CSV, kept a year; CloudTrail for the account | ✅ |
| [Rate Limiting](../../../docs/guides/RATE-LIMITING-GUIDE.md) | Web | `rate-limiting` | A WAF per-IP rule and a stage throttle before the API runs, reserved concurrency below the database's connections and on the public streaming URL, named limits on what costs money or sends email - counted atomically, refused with 429 and how long to wait | ✅ |
| [Hardening](../../../docs/guides/HOW-TO-CREATE-HARDENING-GUIDE.md) | Any | `hardening` | A security review of the whole system | ✅ |

### Operations

Knowing what the running system is doing.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Observability](../../../docs/guides/OBSERVABILITY-GUIDE.md) | Web | `observability` | JSON logs with a correlation ID on every line, alarms every function gets and tests prove can fire, a dashboard in code, Sentry | ✅ |
| [Internal Alerts](../../../docs/guides/INTERNAL-ALERTS-GUIDE.md) | Web | `internal-alerts` | Every alarm and a chosen few product events in the team's Slack, with email kept as the backstop - off until configured, IDs only, a notifier whose failures reach email | ✅ |
| [Tagging](../../../docs/guides/AWS_TAGGING-STRATEGY.md) | Any | `aws-tagging` | Cost and ownership tags on every resource | ✅ |

### Product discovery

Finding out what to build.

| Guide | Platform | Install name | Gives the project | Status |
|-------|----------|--------------|-------------------|--------|
| [Research Conversations](../../../docs/guides/RESEARCH-CONVERSATION-GUIDE.md) | Any | `research-conversations` | Short user conversations that find out whether a problem is real | ✅ |
