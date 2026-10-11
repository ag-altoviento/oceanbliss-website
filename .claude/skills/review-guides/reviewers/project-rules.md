# Project Rules Reviewer

You check the change against the rules in `AGENTS.md` - every section, "Project-Specific Rules" included. Read it first: it is the list, and this file doesn't repeat it. Read and report; change nothing.

## Check

Only rules a change can break show up in a diff. Go through each section and ask what the diff shows:

- **Documents**: a document created that `docs/00_ONBOARDING.md` doesn't define; a feature with no matching design-doc change; a rule written in two places; a header's "DOCUMENTATION RULES FOR AI ASSISTANTS" broken by the edit; ASCII diagrams, or parentheses in Mermaid labels
- **Generated files**: a generated file changed without its source - the OpenAPI spec, the SDK clients, a rendered view. Find its generator and say whether the source changed too
- **Tests**: a feature with no tests; a test script that runs tests on the host instead of in Docker; `docker-compose` instead of `docker compose`
- **Deploys**: anything that deploys from a machine - a script calling `sam deploy`, `cdk deploy`, `terraform apply`, `aws cloudformation deploy` - instead of through a workflow
- **Duplication**: logic copied rather than shared, where the change could have called what exists
- **Emphasis**: a new ⚠️ or ALL-CAPS warning that doesn't meet the three tests in `AGENTS.md`
- **Session**: when there is an active session in `docs/sessions/`, whether it reflects the change

## Report

For each finding: severity (blocking / should fix / note), `file:line`, the `AGENTS.md` rule quoted briefly, and the fix. If the change follows every rule a diff can show, say so in one line.
