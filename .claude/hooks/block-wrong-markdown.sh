#!/bin/bash
# Blocks agents from writing Markdown outside the places the Documentation
# System defines. Projects allow more paths in .claude/hooks/allowed-markdown.txt.
# Exit 2 blocks the write (Claude Code and Cursor); anything else allows it.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

# Skip if not .md file
[[ ! "$FILE_PATH" =~ \.md$ ]] && exit 0

# Expand ~ to home directory if present for checking
EXPANDED_PATH=$(echo "$FILE_PATH" | sed "s|^~|$HOME|")

# Agent tool folders (home or project) hold their own Markdown
if echo "$EXPANDED_PATH" | grep -qE '(^|/)\.(claude|cursor)/'; then
  exit 0
fi

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null)}"

# Convert absolute path to relative path for matching
RELATIVE_PATH="$FILE_PATH"
if [[ "$EXPANDED_PATH" = /* ]]; then
  if [[ -n "$PROJECT_ROOT" ]]; then
    case "$EXPANDED_PATH" in
      "$PROJECT_ROOT"/*) RELATIVE_PATH="${EXPANDED_PATH#"$PROJECT_ROOT"/}" ;;
      # Outside the project (e.g. Claude Code memory): not ours to police
      *) exit 0 ;;
    esac
  fi
fi
RELATIVE_PATH="${RELATIVE_PATH#./}"

# Documentation System locations
if echo "$RELATIVE_PATH" | grep -qE '^(docs/sessions/|docs/guides/|docs/design/|docs/templates/|docs/archive/|docs/[0-9]+.*\.md$|README\.md$)'; then
  exit 0
fi

# Agent instruction files are allowed at any level
if echo "$RELATIVE_PATH" | grep -qE '(^|/)(AGENTS|CLAUDE)\.md$'; then
  exit 0
fi

# Project-specific additions: one pattern per line, "#" starts a comment.
# A pattern ending in "/" allows everything under that folder; anything else
# is a glob matched against the whole path (e.g. CHANGELOG.md, docs/api/*.md).
ALLOWLIST="${PROJECT_ROOT:-.}/.claude/hooks/allowed-markdown.txt"
if [[ -f "$ALLOWLIST" ]]; then
  while IFS= read -r pattern || [[ -n "$pattern" ]]; do
    pattern="${pattern%%#*}"
    pattern="${pattern#"${pattern%%[![:space:]]*}"}"
    pattern="${pattern%"${pattern##*[![:space:]]}"}"
    [[ -z "$pattern" ]] && continue
    case "$pattern" in
      */) [[ "$RELATIVE_PATH" == "$pattern"* ]] && exit 0 ;;
      *)  [[ "$RELATIVE_PATH" == $pattern ]] && exit 0 ;;
    esac
  done < "$ALLOWLIST"
fi

# Everything else is blocked
echo "❌ BLOCKED: $FILE_PATH" >&2
echo "Markdown files ONLY allowed in: docs/sessions/, docs/guides/, docs/design/, docs/templates/, docs/archive/, .claude/, .cursor/, README.md, AGENTS.md / CLAUDE.md," >&2
echo "or paths listed in .claude/hooks/allowed-markdown.txt. See docs/00_ONBOARDING.md" >&2
exit 2
