#!/usr/bin/env bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Current directory (shortened relative to home)
dir_display="${cwd/#$HOME/\~}"

# Git branch and status indicators
git_info=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" -c "core.useBuiltinFSMonitor=false" -c "core.fsmonitor=false" branch --show-current 2>/dev/null || echo "detached")

  # Check for changes (skip optional locks)
  status=$(git -C "$cwd" -c "core.useBuiltinFSMonitor=false" -c "core.fsmonitor=false" status --porcelain 2>/dev/null)
  indicators=""

  if echo "$status" | grep -q '^M'; then
    indicators="${indicators}!"
  fi
  if echo "$status" | grep -q '^??'; then
    indicators="${indicators}?"
  fi

  if [ -n "$indicators" ]; then
    git_info=" ${branch} ${indicators} "
  else
    git_info=" ${branch} "
  fi
fi

# Python virtualenv
venv_info=""
if [ -n "$VIRTUAL_ENV" ]; then
  venv_name=$(basename "$VIRTUAL_ENV")
  venv_info=" (${venv_name})"
fi

# Context percentage
ctx_info=""
if [ -n "$remaining" ]; then
  ctx_info=" ${remaining}% ctx "
fi

# Time
time_info=$(date +%H:%M)

# Build the status line with colors (using printf for ANSI codes)
printf "\033[36m%s\033[0m" "$dir_display"
if [ -n "$git_info" ]; then
  printf " \033[35m%s\033[0m" "$git_info"
fi
if [ -n "$venv_info" ]; then
  printf "\033[33m%s\033[0m" "$venv_info"
fi
printf " \033[2m│\033[0m %s" "$model_name"
if [ -n "$ctx_info" ]; then
  printf " \033[2m│\033[0m%s" "$ctx_info"
fi
printf " \033[2m│\033[0m %s" "$time_info"
