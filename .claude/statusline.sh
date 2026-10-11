#!/bin/bash
# This project's Claude Code status line. It's yours: change it freely - a Documentation System
# update never replaces it. Claude Code runs it as the session changes and shows what it prints.
#
#   🟢 42% · my-app ⎇ main · Session: Fix the login page · Opus · $0.12
#
# The session's name shows once it has one - /rename sets it.
#
# The colour is how full the context window is: yellow from 60%, red from 75% - time for a fresh
# session. The session arrives as JSON on stdin; the Statusline guide lists every field
# (gh docsys update --guides statusline). .claude/settings.json's statusLine runs this file.

input=$(cat)
if ! command -v jq >/dev/null 2>&1; then
  echo "📁 ${PWD##*/} - install jq for the full status line"
  exit 0
fi

# One jq call, fields split on the unit separator: tabs would collapse an empty field
IFS=$'\x1f' read -r pct dir model cost session <<<"$(printf '%s' "$input" | jq -r '[
    ((.context_window.used_percentage // 0) | tonumber? // 0 | floor | tostring),
    (.workspace.project_dir // .workspace.current_dir // ""),
    (.model.display_name // ""),
    ((.cost.total_cost_usd // 0) | tonumber? // 0 | tostring),
    (.session_name // "" | tostring | if length > 30 then .[:29] + "…" else . end)
  ] | join("\u001f")')"

branch=$(git -C "${dir:-.}" branch --show-current 2>/dev/null)
if [ "${pct:-0}" -ge 75 ]; then light="🔴"; elif [ "${pct:-0}" -ge 60 ]; then light="🟡"; else light="🟢"; fi
cost=$(awk -v c="${cost:-0}" 'BEGIN { printf "%.2f", c }')
name="${dir:-$PWD}"

echo "${light} ${pct:-0}% · ${name##*/}${branch:+ ⎇ $branch}${session:+ · Session: $session}${model:+ · $model} · \$${cost}"
