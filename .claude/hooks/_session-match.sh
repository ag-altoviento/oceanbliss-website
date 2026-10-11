#!/bin/bash
# =============================================================================
# _session-match.sh - which active session doc belongs to the current branch
# =============================================================================
# Sourced by the session hooks, never run on its own. A session doc belongs to
# a branch when its Branch line names it, or when it carries the branch's
# ticket key - in its Tickets line or its file name. So a follow-up branch
# under the same ticket (feature/proj-42-retry-tests after
# feature/proj-42-checkout-retry) keeps the session it already has.
# =============================================================================

# branch_ticket BRANCH -> the ticket key a branch names (feature/proj-42-x -> PROJ-42), or nothing
branch_ticket() {
  printf '%s' "$1" | sed -n 's|^[^/]*/\([A-Za-z][A-Za-z0-9]*-[0-9][0-9]*\).*|\1|p' | tr '[:lower:]' '[:upper:]'
}

# session_for_branch FILE BRANCH -> success when the session doc FILE belongs to BRANCH
session_for_branch() {
  local f="$1" branch="$2" sbranch key
  sbranch="$(grep -m1 '\*\*Branch:\*\*' "$f" 2>/dev/null | sed -n 's/.*`\(.*\)`.*/\1/p')"
  [ -n "$branch" ] && [ "$sbranch" = "$branch" ] && return 0
  key="$(branch_ticket "$branch")"
  [ -n "$key" ] || return 1
  { grep -m1 '^\*\*Tickets:\*\*' "$f" 2>/dev/null; basename "$f"; } \
    | tr '[:lower:]' '[:upper:]' | grep -Eq "(^|[^A-Z0-9])${key}([^0-9]|\$)"
}
