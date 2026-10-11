---
name: pre-pr
description: Run, locally and in Docker, the checks the pull request will run - generated files up to date, lint and types, tests, migrations, templates and image, a scan of the diff for debug leftovers - and report READY or NOT READY, one line per phase. Mechanical only; it changes nothing. Use before opening or updating a pull request, when asked "is this ready", "will CI pass", "verify before PR", or when the user types /pre-pr. For judgment on the change, follow with /review-guides and /code-review.
argument-hint: "[backend | frontend | ios | all]"
user-invocable: true
---

# /pre-pr - Will the Pull Request Pass?

READY should mean CI will pass. So this runs what the project's own pull-request workflows run, through the project's own scripts - it never brings commands of its own. Where a check has no script or workflow job, it is skipped and the report says so.

Arguments passed: `$ARGUMENTS` - with none, the areas the change touches.

## 1. Find the Checks

Read, in this order, and build the list of checks to run:

1. **The pull-request workflows**: every `.github/workflows/*.yml` with a `pull_request` trigger - in a project with the Quality Gates guide, `pr-check.yml` (jobs `lint`, `security`, `test`, `frontend`, `infrastructure`, `image`, `docs`), plus `api-contract.yml` from SDK Generation and `ios-build.yml` from iOS Testing. Each job's steps are the checks; its `changes` job or `paths` filter says which area it belongs to.
2. **The project's scripts** those steps call, in `scripts/`, `frontend/scripts/` and `package.json` - the test runner from the Testing guide, `check-*.sh`, `export-openapi.py --check`.
3. **`AGENTS.md` "Project-Specific Rules"** for how tests run where Docker can't host them - iOS with `xcodebuild`.

Keep only the areas the change touches: `git diff --name-only main...HEAD` and uncommitted work, classified the way the workflow's `changes` job classifies them (`scripts/ci-changed-areas.py` where it exists).

## 2. Run Them, Cheapest First

Stop a phase at its first failure, but run every phase: the report should show everything that is red.

| Phase | What runs | Where |
|-------|-----------|-------|
| 1. Diff scan | Section 3, below | Read the diff |
| 2. Generated files | Each generator's `--check`: the API spec and plans, the web client, iOS's snapshot | Docker, or the workflow's step as written |
| 3. Lint and types | The lint job's tools at the versions it pins - `requirements-test.txt`, `package.json` - never a linter cached on the machine; the frontend's lint and token checks | The test image or a throwaway container |
| 4. Tests | The project's test scripts - `scripts/run-tests-docker.sh`, and `scripts/run-web-tests-docker.sh` for the web app's specs; the "tests actually ran" check after the first, and inside the second | Docker, through the scripts, never Compose by hand |
| 5. Migrations | `scripts/check-migrations.sh` - the PR check's `migrations` job: upgrade, downgrade, upgrade and `alembic check` against Postgres, on any backend change, since a model change alone can fail `alembic check` | Docker, through the script |
| 6. Templates and image | cfn-lint and actionlint on touched templates and workflows, actionlint with shellcheck beside it - `pip install actionlint-py shellcheck-py`, as GitHub's runner has both; without shellcheck it skips each step's shell and passes what the PR check fails; the image build and its imports check | Docker |
| 7. Contract | The breaking-change check against the base branch | Docker |
| 8. iOS | The build and tests per "Project-Specific Rules" | The Mac |

Skip a phase whose area the change doesn't touch, or which the project has no check for. A security scan the workflow runs (bandit, pip-audit) belongs with phase 3.

## 3. Scan the Diff

Only lines the change adds:

| Look for | Why |
|----------|-----|
| `print(`, `breakpoint()`, `pdb`, `console.log`, `debugger` | Debug leftovers |
| `fdescribe`, `fit(`, `.only(`, `@pytest.mark.skip` without a reason | A focused or skipped test hides the rest of the suite |
| `# noqa`, `# type: ignore`, `eslint-disable`, `swiftlint:disable` without a reason on the line | A suppression nobody can review |
| `\|\| true`, `set +e`, `continue-on-error: true` | A check that can no longer fail |
| Keys, tokens, passwords, `.env` files, account IDs | Secrets; pre-commit's scanner, if installed, is the rule |
| A generated file changed without its source | Regenerate it - `AGENTS.md` |

## 4. Report

```
Diff scan       PASS
Generated files FAIL  openapi.json is stale - export-openapi.py --check
Lint and types  PASS
Tests           PASS  412 passed
Migrations      PASS
Templates/image SKIPPED  no template, workflow or Dockerfile in the change
Contract        PASS
iOS             SKIPPED  no iOS change

NOT READY - 1 failing phase
```

One line per phase - PASS, FAIL with the first error, or SKIPPED with why - then READY or NOT READY. A phase CI runs but this machine couldn't - Docker down, no Mac for iOS - makes it NOT READY, not SKIPPED: say what's missing.

Then:

- **On failure**, offer `/fix-build` for the failing phases. Fix nothing here.
- **On READY**, suggest `/review-guides` and `/code-review`: this skill checks that the change builds and passes; they check whether it is right.
