---
name: fix-build
description: Fix a failing build, type check, lint, migration check, generated-file check or test run with the smallest change - collect every error first, fix root causes one at a time, rerun the failing check in Docker after each fix, and stop rather than suppress a check or redesign. Covers Python (pip, ruff, mypy, pytest), Alembic, Angular (tsc, esbuild, lint, design tokens), the generated OpenAPI spec and clients, SAM and cfn-lint, and xcodebuild / Swift packages. Use when a check or CI job is red, after /pre-pr reports NOT READY, when asked to "fix the build", "make CI green", "fix the type errors", or when the user types /fix-build.
argument-hint: "[failing check or CI job]"
user-invocable: true
---

# /fix-build - Make a Failing Check Pass

The goal is the check green with the change's intent intact - not the check quiet. Fix the cause with the smallest diff, prove it with the same check, and stop when the fix stops being small.

Arguments passed: `$ARGUMENTS` - with none, the checks `/pre-pr` reported failing, or ask which.

## 1. Collect Every Error

1. **Run the failing check** the way CI does - the project's script or the workflow step, in Docker (iOS per "Project-Specific Rules"). For a red CI job, read its log: `gh run view --log-failed`.
2. **List every error**, not just the first. Group them by root cause: one missing import or one renamed field often explains twenty lines.
3. **Order the groups**: dependencies and imports first, then generated files, then types, then lint, then tests - an earlier group often clears a later one.

## 2. Fix One Root Cause at a Time

For each group: fix it, rerun the same check, confirm those errors are gone and no new ones appeared, then take the next.

| Area | Usual root causes | Fix at the source |
|------|-------------------|-------------------|
| pip / imports | A package missing from `requirements.txt`, a pin clash, a module that only imports on the host | Add or align the pin; rebuild the test image - never `pip install` in the runner |
| ruff / mypy | A real type mismatch, an unused import, a changed signature | Fix the code; run them at the versions CI pins |
| pytest | Behaviour changed on purpose, so the test's expectation is stale; or the code is wrong | Decide which, from the change's intent; when unclear, ask - never weaken the assertion to pass |
| Alembic | Two heads, a model outside `models.py`, `alembic check` drift, a downgrade that doesn't undo | The Database pack's "Add a migration" task; renumber the incoming migration, never re-point an applied one; rerun `scripts/check-migrations.sh` |
| tsc / esbuild | A changed generated type, a signal read without calling it, a missing standalone import | Fix the caller; if the type came from the API, regenerate (below) |
| Angular lint | `HttpClient` or `httpResource` outside `src/app/api`, a raw colour or spacing value | Call the generated hey-api client; use the design token - the guides say why |
| Generated spec / clients | `export-openapi.py --check` or `check-generated-clients.sh` fails because routes changed | Regenerate from the code with the generator; commit the result. A breaking change needs the `breaking-change-approved` label, not a workaround |
| SAM / cfn-lint | A wrong intrinsic, a missing parameter, a policy over its size | Fix the template; the trap tables in the Deploy and GitHub Actions guides cover the usual ones |
| xcodebuild / SPM | A package resolution failure, a strict-concurrency error, a scheme setting | Resolve the package pin; fix the isolation, don't add `nonisolated` or `@unchecked Sendable` to quiet it |

When an installed guide's trap table names the symptom, its fix is the fix.

## 3. Never Without Asking

- **Suppressions**: `# noqa`, `# type: ignore`, `eslint-disable`, `swiftlint:disable`, `@pytest.mark.skip`, `xfail`, `.skip(`
- **Loosening a check**: a lint rule turned off, a threshold lowered, `|| true`, `continue-on-error`, a test deleted
- **Generated files edited by hand**: change the source and rerun its generator - `AGENTS.md`
- **Changing behaviour** to make a test pass, or anything beyond the failing check's scope

If one of these looks like the right answer, say why and let the user decide.

## 4. Know When to Stop

Stop and report, rather than keep trying, when:

- three attempts at the same error haven't fixed it;
- the fix needs a design change - a new table, a changed contract, a different layer owning something;
- the failure is in the environment, not the code - Docker down, credentials expired, a registry unreachable.

## 5. Report

For each root cause: the error, the cause, the fix, and the check that now passes. Then what is still red, and why it was left. Finish by rerunning `/pre-pr`, or the full check that failed, to show the whole picture.
