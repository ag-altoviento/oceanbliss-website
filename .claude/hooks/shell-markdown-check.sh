#!/bin/bash
# =============================================================================
# shell-markdown-check.sh - catch Markdown written through shell commands
# =============================================================================
# block-wrong-markdown.sh guards the agent's file tools (Write, Edit), but a
# shell command (a python or sed replace, a redirect) can write a Markdown
# file without passing through it. This hook runs after each shell command -
# Claude Code PostToolUse on Bash, Cursor postToolUse on Shell - and tells the
# agent if the command wrote Markdown where the Documentation System doesn't
# allow it.
#
# Candidates: Claude Code's tool_response.bashEditDiff.changedFiles when
# present (a beta field, not always filled in), plus Markdown files in
# `git status` modified while the command ran. Each candidate is checked with
# block-wrong-markdown.sh itself, so the rules live in one place.
#
# Quiet by design: reports each file version once, and says nothing when
# nothing is wrong.
#
# Fails open: on any problem it prints nothing and exits 0.
# Off switches: DOCSYS_HOOKS=off (this shell), or shell_markdown=off in
# .claude/hooks/docsys.conf (the project).
# =============================================================================

INPUT="$(cat 2>/dev/null)"

ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"
[ -n "$ROOT" ] && [ -d "$ROOT" ] || exit 0
cd "$ROOT" 2>/dev/null || exit 0
command -v jq >/dev/null 2>&1 || exit 0
GUARD=.claude/hooks/block-wrong-markdown.sh
[ -f "$GUARD" ] || exit 0

# --- Off switches ---
[ "${DOCSYS_HOOKS:-on}" = "off" ] && exit 0
if [ -f .claude/hooks/docsys.conf ] && grep -Eq '^[[:space:]]*shell_markdown[[:space:]]*=[[:space:]]*off' .claude/hooks/docsys.conf; then
  exit 0
fi

mtime() { stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null; }

# --- Candidates ---
NOW="$(date +%s)"
DURATION_MS="$(printf '%s' "$INPUT" | jq -r '.duration_ms // .duration // empty' 2>/dev/null)"
case "$DURATION_MS" in ''|*[!0-9]*) WINDOW=60 ;; *) WINDOW=$(( DURATION_MS / 1000 + 5 )) ;; esac
SINCE=$(( NOW - WINDOW ))

CANDIDATES="$(
  printf '%s' "$INPUT" | jq -r '.tool_response.bashEditDiff.changedFiles[]? // empty' 2>/dev/null \
    | sed "s|^$ROOT/||"
  git status --porcelain -uall 2>/dev/null | sed 's/^...//; s/.* -> //' | while IFS= read -r p; do
    t="$(mtime "$p")"
    [ -n "$t" ] && [ "$t" -ge "$SINCE" ] && printf '%s\n' "$p"
  done
)"

# --- Check each Markdown candidate with the Markdown guard itself ---
STATE_DIR="$(git rev-parse --git-dir 2>/dev/null)/docsys"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0
REPORTED="$STATE_DIR/shell-markdown-reported"
touch "$REPORTED" 2>/dev/null || exit 0

BAD=""
while IFS= read -r p; do
  case "$p" in *.md) ;; *) continue ;; esac
  [ -f "$p" ] || continue
  key="$(mtime "$p") $p"
  grep -qxF -- "$key" "$REPORTED" && continue
  rc=0
  printf '{"tool_input":{"file_path":"%s"}}' "$ROOT/$p" \
    | CLAUDE_PROJECT_DIR="$ROOT" bash "$GUARD" >/dev/null 2>&1 || rc=$?
  if [ "$rc" -eq 2 ]; then
    BAD="${BAD}${p} "
    echo "$key" >> "$REPORTED"
  fi
done <<EOF
$(printf '%s\n' "$CANDIDATES" | sort -u)
EOF
[ -n "$BAD" ] || exit 0

MSG="That shell command wrote Markdown where the Documentation System doesn't allow it: ${BAD% }. Documentation goes in the places docs/00_ONBOARDING.md defines - move the content there, or remove the file. If this path really does belong, ask the user to add it to .claude/hooks/allowed-markdown.txt. Don't use shell commands to get around the Markdown hook."

# --- Emit for the calling tool ---
if printf '%s' "$INPUT" | grep -q '"hook_event_name"[[:space:]]*:[[:space:]]*"postToolUse"'; then
  jq -n --arg m "$MSG" '{additional_context: $m}'
else
  jq -n --arg m "$MSG" '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $m}}'
fi
exit 0
