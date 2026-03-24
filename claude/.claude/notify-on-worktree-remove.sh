#!/bin/bash
printf '\a' >/dev/tty 2>/dev/null
osascript -e 'display notification "Claude is removing a worktree" with title "Claude Code"'
afplay "$HOME/.claude/no-no-no-wait.mp3" &
disown
exit 0
