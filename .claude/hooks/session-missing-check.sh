#!/bin/bash
# =============================================================================
# session-missing-check.sh - create a session doc when work starts
# =============================================================================
# Runs after the agent edits a file: Claude Code PostToolUse (Write, Edit,
# MultiEdit), Cursor postToolUse (Write). When code changes on a working
# branch that has no session doc of yours yet, it tells the agent to create
# one now and tell the user in one line - the user doesn't have to ask.
#
# Quiet by design:
#   - only for code: edits under docs/, .claude/, .cursor/ and .docsys/ don't count
#   - never on main or master
#   - at most once every 30 minutes per branch, in case the agent is mid-task
#
# Output: Claude Code - hookSpecificOutput.additionalContext; Cursor -
# additional_context. Both are added next to the tool result.
#
# Fails open: on any problem it prints nothing and exits 0.
# Off switches: DOCSYS_HOOKS=off (this shell), or new_session=off in
# .claude/hooks/docsys.conf (the project).
# =============================================================================

INPUT="$(cat 2>/dev/null)"

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -n "$ROOT" ] && [ -d "$ROOT" ] || exit 0
cd "$ROOT" 2>/dev/null || exit 0
command -v jq >/dev/null 2>&1 || exit 0

# --- Off switches ---
[ "${DOCSYS_HOOKS:-on}" = "off" ] && exit 0
if [ -f .claude/hooks/docsys.conf ] && grep -Eq '^[[:space:]]*new_session[[:space:]]*=[[:space:]]*off' .claude/hooks/docsys.conf; then
  exit 0
fi
[ -f docs/03_TODO.md ] || exit 0   # not a Documentation System project

# --- Only code edits count ---
FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // .file_path // empty' 2>/dev/null)"
[ -n "$FILE" ] || exit 0
REL="${FILE#"$ROOT"/}"
case "$REL" in
  /*) exit 0 ;;   # outside the project
  docs/*|.claude/*|.cursor/*|.docsys/*) exit 0 ;;
esac

# --- A working branch without a session doc of yours ---
ME="$(git config user.name 2>/dev/null)"
BRANCH="$(git branch --show-current 2>/dev/null)"
[ -n "$ME" ] && [ -n "$BRANCH" ] || exit 0
case "$BRANCH" in main|master) exit 0 ;; esac

. .claude/hooks/_session-match.sh 2>/dev/null || exit 0
field() { grep -m1 "^\*\*$1:\*\*" "$2" 2>/dev/null | sed "s/^\*\*$1:\*\* *//"; }
lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
for f in docs/sessions/*-active.md; do
  [ -f "$f" ] || continue
  owner="$(field Owner "$f" | sed 's/ *·.*//')"
  session_for_branch "$f" "$BRANCH" && [ "$(lower "$owner")" = "$(lower "$ME")" ] && exit 0
done

# --- At most once every 30 minutes per branch ---
STATE_DIR="$(git rev-parse --git-dir 2>/dev/null)/docsys"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0
STAMP="$STATE_DIR/new-session-$(printf '%s' "$BRANCH" | tr '/' '_')"
NOW="$(date +%s)"
if [ -f "$STAMP" ]; then
  LAST="$(cat "$STAMP" 2>/dev/null)"
  case "$LAST" in ''|*[!0-9]*) LAST=0 ;; esac
  [ $((NOW - LAST)) -lt 1800 ] && exit 0
fi
echo "$NOW" > "$STAMP" 2>/dev/null

# A ticket key in the branch name (feature/proj-123-...) becomes the work-id
TICKET="$(branch_ticket "$BRANCH")"
if [ -n "$TICKET" ]; then
  TICKET_NOTE="Tickets: $TICKET."
else
  TICKET_NOTE="The branch names no ticket: if docs/03_TODO.md is in Maintenance mode, propose a Jira ticket before going further."
fi

MSG="You are changing code on branch $BRANCH, which has no session doc of yours. Create one now from docs/templates/SESSION.md, named per docs/00_ONBOARDING.md \"Session Document Naming\", with Owner: $ME and Branch: $BRANCH. $TICKET_NOTE Add your row to docs/03_TODO.md (\"Active Sessions\" in Build mode, \"Now\" in Maintenance mode). Then tell the user in one line that you created it, and carry on."

# --- Emit for the calling tool ---
if printf '%s' "$INPUT" | grep -q '"hook_event_name"[[:space:]]*:[[:space:]]*"postToolUse"'; then
  jq -n --arg m "$MSG" '{additional_context: $m}'
else
  jq -n --arg m "$MSG" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $m}}'
fi
exit 0
