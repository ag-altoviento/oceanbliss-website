#!/bin/bash
# =============================================================================
# session-update-check.sh - keep the session doc current, turn by turn
# =============================================================================
# Runs when the agent finishes a turn: Claude Code Stop, Cursor stop. If code
# changed after your session doc for this branch was last updated, it asks
# the agent to update the doc before stopping - so a reset (/clear, a new
# chat) never loses work.
#
# Quiet by design:
#   - acts only when your session doc for this branch is older than the
#     newest change (uncommitted files, or the last commit)
#   - never twice in a row: skips when the agent is already continuing
#     because of a stop hook (Claude Code stop_hook_active, Cursor loop_count)
#   - at most once every DOCSYS_NUDGE_MINUTES (default 10) per session doc
#
# Output: Claude Code - hookSpecificOutput.additionalContext ("Stop hook
# feedback", keeps the turn going). Cursor - followup_message (sent as the
# next user message).
#
# Fails open: on any problem it prints nothing and exits 0.
# Off switches: DOCSYS_HOOKS=off (this shell), or progress=off in
# .claude/hooks/docsys.conf (the project).
# =============================================================================

INPUT="$(cat 2>/dev/null)"

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -n "$ROOT" ] && [ -d "$ROOT" ] || exit 0
cd "$ROOT" 2>/dev/null || exit 0
command -v jq >/dev/null 2>&1 || exit 0

# --- Off switches ---
[ "${DOCSYS_HOOKS:-on}" = "off" ] && exit 0
if [ -f .claude/hooks/docsys.conf ] && grep -Eq '^[[:space:]]*progress[[:space:]]*=[[:space:]]*off' .claude/hooks/docsys.conf; then
  exit 0
fi

# --- Loop guards: already continuing because of a stop hook ---
[ "$(printf '%s' "$INPUT" | jq -r '.stop_hook_active // false' 2>/dev/null)" = "true" ] && exit 0
LOOPS="$(printf '%s' "$INPUT" | jq -r '.loop_count // 0' 2>/dev/null)"
case "$LOOPS" in ''|*[!0-9]*) LOOPS=0 ;; esac
[ "$LOOPS" -gt 0 ] && exit 0

# --- Your session doc for this branch ---
field() { grep -m1 "^\*\*$1:\*\*" "$2" 2>/dev/null | sed "s/^\*\*$1:\*\* *//"; }
lower() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]'; }

ME="$(git config user.name 2>/dev/null)"
BRANCH="$(git branch --show-current 2>/dev/null)"
[ -n "$ME" ] && [ -n "$BRANCH" ] || exit 0

. .claude/hooks/_session-match.sh 2>/dev/null || exit 0
DOC=""
for f in docs/sessions/*-active.md; do
  [ -f "$f" ] || continue
  owner="$(field Owner "$f" | sed 's/ *·.*//')"
  if session_for_branch "$f" "$BRANCH" && [ "$(lower "$owner")" = "$(lower "$ME")" ]; then
    DOC="$f"
    break
  fi
done
[ -n "$DOC" ] || exit 0   # no session doc: the briefing and first-edit nudge handle that

# --- Is the doc older than the newest change? ---
mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null; }
DOC_TIME="$(mtime "$DOC")"
[ -n "$DOC_TIME" ] || exit 0

# The last commit counts, unless it also carried the session doc
NEWEST="$(git log -1 --format=%ct 2>/dev/null)"
case "$NEWEST" in ''|*[!0-9]*) NEWEST=0 ;; esac
if git log -1 --format= --name-only 2>/dev/null | grep -qxF "$DOC"; then
  NEWEST=0
fi
# Uncommitted changes, not counting the session docs and TODO themselves
while IFS= read -r path; do
  [ -f "$path" ] || continue
  case "$path" in docs/sessions/*|docs/archive/sessions/*|docs/03_TODO.md) continue ;; esac
  t="$(mtime "$path")"
  [ -n "$t" ] && [ "$t" -gt "$NEWEST" ] && NEWEST="$t"
done <<EOF
$(git status --porcelain -uall 2>/dev/null | sed 's/^...//; s/.* -> //')
EOF
[ "$NEWEST" -gt "$DOC_TIME" ] || exit 0

# --- At most once every DOCSYS_NUDGE_MINUTES per session doc ---
STATE_DIR="$(git rev-parse --git-dir 2>/dev/null)/docsys"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0
STAMP="$STATE_DIR/nudged-$(printf '%s' "$DOC" | tr '/' '_')"
NOW="$(date +%s)"
MINUTES="${DOCSYS_NUDGE_MINUTES:-10}"
case "$MINUTES" in ''|*[!0-9]*) MINUTES=10 ;; esac
if [ -f "$STAMP" ]; then
  LAST="$(cat "$STAMP" 2>/dev/null)"
  case "$LAST" in ''|*[!0-9]*) LAST=0 ;; esac
  [ $((NOW - LAST)) -lt $((MINUTES * 60)) ] && exit 0
fi
echo "$NOW" > "$STAMP" 2>/dev/null

MSG="Code changed after your session doc ($DOC) was last updated. Before stopping, update it briefly - progress, current state, next steps - so a new session can take over. Update your row in docs/03_TODO.md too if it changed. Keep it short, and don't mention this reminder to the user."

# --- Emit for the calling tool ---
if printf '%s' "$INPUT" | grep -q '"hook_event_name"[[:space:]]*:[[:space:]]*"stop"'; then
  jq -n --arg m "$MSG" '{followup_message: $m}'
else
  jq -n --arg m "$MSG" '{hookSpecificOutput: {hookEventName: "Stop", additionalContext: $m}}'
fi
exit 0
