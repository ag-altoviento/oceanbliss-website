#!/bin/bash
# =============================================================================
# ticket-prompt.sh - offer Jira updates at the moments work finishes
# =============================================================================
# Runs after shell commands - Claude Code PostToolUse on Bash, Cursor
# postToolUse on Shell - and prompts the agent at two moments:
#   - a commit: if it finishes the ticket's work, offer to move the ticket to
#     the team's final status; otherwise say nothing about Jira
#   - a session doc archived to docs/archive/sessions/: offer to move its
#     tickets to the final status
# The agent always asks the user before changing anything in Jira.
#
# Tickets come from the session doc's "Tickets:" line, or the branch name.
# The final status comes from .claude/skills/jira/PROJECT.md.
#
# Quiet by design: silent until Jira is set up (PROJECT.md filled in) and
# when there is no ticket; commit prompts at most once every 2 hours per
# branch; each archived session prompts once.
#
# Fails open: on any problem it prints nothing and exits 0.
# Off switches: DOCSYS_HOOKS=off (this shell), or tickets=off in
# .claude/hooks/docsys.conf (the project).
# =============================================================================

INPUT="$(cat 2>/dev/null)"

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -n "$ROOT" ] && [ -d "$ROOT" ] || exit 0
cd "$ROOT" 2>/dev/null || exit 0
command -v jq >/dev/null 2>&1 || exit 0

# --- Off switches, and Jira must be set up ---
[ "${DOCSYS_HOOKS:-on}" = "off" ] && exit 0
if [ -f .claude/hooks/docsys.conf ] && grep -Eq '^[[:space:]]*tickets[[:space:]]*=[[:space:]]*off' .claude/hooks/docsys.conf; then
  exit 0
fi
JIRA=.claude/skills/jira/PROJECT.md
[ -f "$JIRA" ] || exit 0
grep -q 'PLACEHOLDER_JIRA_SETTINGS' "$JIRA" && exit 0

COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // .command // empty' 2>/dev/null)"
[ -n "$COMMAND" ] || exit 0

FINAL="$(grep -m1 'Our final status' "$JIRA" | sed -n 's/^[^`]*`\([^`]*\)`.*/\1/p')"
case "$FINAL" in ''|*\[*) FINAL="the team's final status (see $JIRA)" ;; esac

field() { grep -m1 "^\*\*$1:\*\*" "$2" 2>/dev/null | sed "s/^\*\*$1:\*\* *//"; }
lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }
keys_in() { printf '%s' "$1" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | sort -u | paste -sd, - | sed 's/,/, /g'; }

STATE_DIR="$(git rev-parse --git-dir 2>/dev/null)/docsys"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0
NOW="$(date +%s)"
ME="$(git config user.name 2>/dev/null)"
BRANCH="$(git branch --show-current 2>/dev/null)"
MSG=""

# --- Moment 1: a session doc was archived ---
ARCHIVED="$(git status --porcelain -uall 2>/dev/null | sed 's/^...//; s/.* -> //' | grep '^docs/archive/sessions/.*\.md$')"
if [ -n "$ARCHIVED" ]; then
  PROMPTED="$STATE_DIR/tickets-archived"
  touch "$PROMPTED" 2>/dev/null
  while IFS= read -r f; do
    [ -f "$f" ] || continue
    grep -qxF -- "$f" "$PROMPTED" && continue
    owner="$(field Owner "$f" | sed 's/ *·.*//')"
    [ -n "$ME" ] && [ "$(lower "$owner")" = "$(lower "$ME")" ] || continue
    echo "$f" >> "$PROMPTED"
    tickets="$(keys_in "$(field Tickets "$f")")"
    [ -n "$tickets" ] || continue
    MSG="${MSG}You archived the session $f for $tickets. Offer the user to move $tickets to $FINAL in Jira with the jira skill - ask first. "
  done <<EOF
$ARCHIVED
EOF
fi

# --- Moment 2: a commit ---
if printf '%s' "$COMMAND" | grep -Eq '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+commit([[:space:]]|$)' \
   && ! printf '%s' "$COMMAND" | grep -q -- '--dry-run' \
   && [ -n "$BRANCH" ]; then
  case "$BRANCH" in main|master) ;; *)
    STAMP="$STATE_DIR/tickets-commit-$(printf '%s' "$BRANCH" | tr '/' '_')"
    LAST=0
    [ -f "$STAMP" ] && LAST="$(cat "$STAMP" 2>/dev/null)"
    case "$LAST" in ''|*[!0-9]*) LAST=0 ;; esac
    if [ $((NOW - LAST)) -ge 7200 ]; then
      tickets=""
      for f in docs/sessions/*-active.md; do
        [ -f "$f" ] || continue
        sbranch="$(grep -m1 '\*\*Branch:\*\*' "$f" | sed -n 's/.*`\(.*\)`.*/\1/p')"
        [ "$sbranch" = "$BRANCH" ] && tickets="$(keys_in "$(field Tickets "$f")")" && break
      done
      [ -n "$tickets" ] || tickets="$(keys_in "$(printf '%s' "$BRANCH" | tr '[:lower:]' '[:upper:]')")"
      if [ -n "$tickets" ]; then
        echo "$NOW" > "$STAMP" 2>/dev/null
        MSG="${MSG}You committed on $BRANCH ($tickets). If this commit finishes the ticket's work, offer the user to move $tickets to $FINAL in Jira with the jira skill - ask first. If it doesn't, say nothing about Jira."
      fi
    fi
  ;; esac
fi

[ -n "$MSG" ] || exit 0

# --- Emit for the calling tool ---
if printf '%s' "$INPUT" | grep -q '"hook_event_name"[[:space:]]*:[[:space:]]*"postToolUse"'; then
  jq -n --arg m "${MSG% }" '{additional_context: $m}'
else
  jq -n --arg m "${MSG% }" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $m}}'
fi
exit 0
