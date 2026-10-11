#!/bin/bash
# =============================================================================
# session-briefing.sh - brief the agent at the start of every session
# =============================================================================
# Runs on session start in Claude Code (SessionStart: startup, resume, /clear,
# compaction) and Cursor (sessionStart). Builds a short briefing from the docs
# - mode, branch, your active sessions, current phase or "Now" rows - so every
# session, including one right after a reset, starts caught up without reading
# the whole history.
#
# Output: Claude Code adds plain stdout to the agent's context; Cursor reads
# {"additional_context": "..."} from stdout. The tool is told apart by the
# event name in the JSON on stdin (SessionStart vs sessionStart).
#
# Fails open: on any problem it prints nothing and exits 0.
# Off switches: DOCSYS_HOOKS=off (this shell), or briefing=off in
# .claude/hooks/docsys.conf (the project).
# =============================================================================

INPUT="$(cat 2>/dev/null)"

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -n "$ROOT" ] && [ -d "$ROOT" ] || exit 0
cd "$ROOT" 2>/dev/null || exit 0

# --- Off switches ---
[ "${DOCSYS_HOOKS:-on}" = "off" ] && exit 0
if [ -f .claude/hooks/docsys.conf ] && grep -Eq '^[[:space:]]*briefing[[:space:]]*=[[:space:]]*off' .claude/hooks/docsys.conf; then
  exit 0
fi

TODO=docs/03_TODO.md
[ -f "$TODO" ] || exit 0

field() { # field "Name" FILE -> value of a "**Name:** value" line
  grep -m1 "^\*\*$1:\*\*" "$2" 2>/dev/null | sed "s/^\*\*$1:\*\* *//"
}

ME="$(git config user.name 2>/dev/null)"
BRANCH="$(git branch --show-current 2>/dev/null)"
MODE="$(field Mode "$TODO")"
MODE="${MODE:-not set}"

# --- Active sessions: yours vs others; does this branch have one? ---
MINE=""
OTHERS=0
BRANCH_HAS_SESSION=no
. .claude/hooks/_session-match.sh 2>/dev/null || session_for_branch() { return 1; }
for f in docs/sessions/*-active.md; do
  [ -f "$f" ] || continue
  owner="$(field Owner "$f" | sed 's/ *·.*//')"
  this=no
  [ -n "$BRANCH" ] && session_for_branch "$f" "$BRANCH" && this=yes && BRANCH_HAS_SESSION=yes
  if [ -n "$ME" ] && [ "$(printf '%s' "$owner" | tr '[:upper:]' '[:lower:]')" = "$(printf '%s' "$ME" | tr '[:upper:]' '[:lower:]')" ]; then
    mark=""
    [ "$this" = yes ] && mark=" (this branch)"
    MINE="${MINE}  - ${f}${mark}
"
  else
    OTHERS=$((OTHERS + 1))
  fi
done

# Rows of a Markdown table under a "## <heading>", skipping the header,
# the separator and template example rows
table_rows() { # table_rows "Heading" FILE
  awk -v h="## $1" '
    index($0, h) == 1 { on = 1; n = 0; next }
    on && /^## / { exit }
    on && /^\|/ { n++; if (n > 2 && $0 !~ /YYYY-MM-DD|PLACEHOLDER/) print }
  ' "$2"
}

# --- Build the briefing ---
B="## Documentation System briefing

Mode: ${MODE} · Branch: ${BRANCH:-unknown} · You: ${ME:-unknown (git user.name not set)}
"
case "$MODE" in
  Maintenance*)
    NOW="$(table_rows Now "$TODO" | head -8)"
    if [ -n "$NOW" ]; then
      B="${B}
In progress (docs/03_TODO.md \"Now\"):
${NOW}
"
    else
      B="${B}
Nothing is listed in \"Now\" in docs/03_TODO.md.
"
    fi
    ;;
  *)
    PHASE="$(field 'Current Phase' "$TODO")"
    case "$PHASE" in
      "") ;;
      *\[*_*\]*|*PLACEHOLDER*)   # still the template's text
        B="${B}Current phase: not set yet - docs/03_TODO.md still has its template text (/documentation-system:init helps fill it in)
" ;;
      *) B="${B}Current phase: ${PHASE}
" ;;
    esac
    ;;
esac

if [ -n "$MINE" ]; then
  B="${B}
Your active sessions:
${MINE}"
else
  B="${B}
You have no active session doc.
"
fi
[ "$OTHERS" -gt 0 ] && B="${B}Other people's active sessions: ${OTHERS}
"

B="${B}
Before starting work, read your session doc for this branch."
case "$BRANCH" in
  ""|main|master) ;;
  *)
    if [ "$BRANCH_HAS_SESSION" = no ]; then
      B="${B}
This branch has no session doc yet. When you start changing code here, create one from docs/templates/SESSION.md (named per docs/00_ONBOARDING.md \"Session Document Naming\", with you as Owner) and tell the user in one line."
    fi
    ;;
esac
B="${B}
For the full picture, run /documentation-system:catch-up."

# --- Emit for the calling tool ---
if printf '%s' "$INPUT" | grep -q '"hook_event_name"[[:space:]]*:[[:space:]]*"sessionStart"'; then
  if command -v jq >/dev/null 2>&1; then
    jq -n --arg c "$B" '{additional_context: $c}'
  fi
else
  printf '%s\n' "$B"
fi
exit 0
