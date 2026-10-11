#!/bin/bash
# =============================================================================
# block-manual-deploy.sh - an agent session deploys nothing
# =============================================================================
# The rule in AGENTS.md: deploy only through CI/CD. This hook runs before each
# shell command - Claude Code PreToolUse on Bash, Cursor preToolUse on Shell -
# and refuses one that deploys: a stack, a function's code, an app upload.
# Exit 2 blocks the command (Claude Code and Cursor); its message goes back to
# the agent with the way to ship the change instead.
#
# What it can't do: see commands a person types in their own terminal, or a
# deploy hidden inside a script it doesn't read. The IAM side is the real
# lock - the everyday Operator profile can't deploy at all (Toolchain & Access)
# - so this is the early, clear "no" before AWS says AccessDenied.
#
# Only the parts of a command that run are checked - split at ; && || | $( and
# backticks, past env assignments and wrappers - so `grep "sam deploy"` or a
# commit message that mentions one passes.
#
# Fails open: on any problem of its own it exits 0.
# Off switches: DOCSYS_HOOKS=off (this shell), or deploy_guard=off in
# .claude/hooks/docsys.conf (the project) - a person's choice, never an agent's.
# =============================================================================

INPUT="$(cat 2>/dev/null)"
command -v jq >/dev/null 2>&1 || exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ "${DOCSYS_HOOKS:-on}" = "off" ] && exit 0
if [ -n "$ROOT" ] && [ -f "$ROOT/.claude/hooks/docsys.conf" ] \
  && grep -Eq '^[[:space:]]*deploy_guard[[:space:]]*=[[:space:]]*off' "$ROOT/.claude/hooks/docsys.conf"; then
  exit 0
fi

CMD="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // .command // empty' 2>/dev/null)"
[ -n "$CMD" ] || exit 0

# What a deploy looks like, at the start of a part that runs. One extended regex per line.
DEPLOYS='^sam (deploy|sync)( |$)
^aws( [^ ]+)* cloudformation (deploy|create-stack|update-stack|delete-stack|create-change-set|execute-change-set)( |$)
^aws( [^ ]+)* lambda (update-function-code|update-function-configuration|publish-version|create-function|delete-function)( |$)
^aws( [^ ]+)* apigateway create-deployment( |$)
^aws( [^ ]+)* s3 (sync|cp|rm) .*s3://[^ ]*-frontend-
^(npx )?cdk (deploy|destroy)( |$)
^terraform (apply|destroy)( |$)
^tofu (apply|destroy)( |$)
^pulumi (up|destroy)( |$)
^(serverless|sls) deploy( |$)
^(npx )?(firebase|netlify|vercel|fly|flyctl|amplify) (deploy|publish)( |$)
^(npx )?vercel( .*)? --prod( |$)
^xcrun altool( .*)? --upload-app
^xcrun notarytool submit
^(bundle exec )?fastlane( .*)? (pilot|deliver|upload_to_testflight|upload_to_app_store|release)( |$)
^([^ ]*/)?bootstrap-access\.sh( |$)'

# Split into the parts that run, one per line
PARTS="$(printf '%s\n' "$CMD" | sed -E 's/(\&\&|\|\||;|\||\$\(|`)/\n/g')"

BLOCKED=""
while IFS= read -r part; do
  # Strip leading space and quotes, env assignments and wrappers that run what follows - a shell
  # among them, with its flags: `bash -c "x.sh"` runs x.sh as surely as `x.sh` does
  part="$(printf '%s' "$part" | sed -E 's/^[[:space:](\"'"'"']+//')"
  while :; do
    next="$(printf '%s' "$part" | sed -E 's/^([A-Za-z_][A-Za-z0-9_]*=("[^"]*"|'"'"'[^'"'"']*'"'"'|[^ ]*)|sudo|exec|command|time|env|nohup|xargs|(ba|z|da)?sh( -[A-Za-z]+)*)[[:space:]]+[\"'"'"']?//')"
    [ "$next" = "$part" ] && break
    part="$next"
  done
  part="$(printf '%s' "$part" | tr -s ' ' | sed -E 's/[\"'"'"'[:space:]]+$//')"  # and the quote a `-c` string ends with
  # The bootstrap's dry run changes nothing
  printf '%s' "$part" | grep -Eq 'bootstrap-access\.sh.*--dry-run' && continue
  while IFS= read -r pattern; do
    if printf '%s' "$part" | grep -Eq -- "$pattern"; then
      BLOCKED="$part"
      break 2
    fi
  done <<<"$DEPLOYS"
done <<<"$PARTS"

[ -n "$BLOCKED" ] || exit 0

echo "Blocked: \`${BLOCKED:0:120}\` deploys, and this project deploys only through CI/CD (AGENTS.md). Ship the change by merging it, or by running the workflow that deploys it - Deploy dev, Deploy prod, or Infra for the user pool and the database. If the access stacks need changing, prepare the change and ask the user to have an Admin run scripts/bootstrap-access.sh. Don't look for another way to run it." >&2
exit 2
