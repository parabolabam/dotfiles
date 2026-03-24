#!/bin/bash
printf '\a' >/dev/tty 2>/dev/null
osascript -e 'display notification "Claude needs permission" with title "Claude Code"'
afplay "$HOME/.claude/tom-scream.mp3" &
disown
exit 0
