#!/bin/bash
printf '\a' >/dev/tty 2>/dev/null
osascript -e 'display notification "Claude needs permission" with title "Claude Code"'
afplay /System/Library/Sounds/Glass.aiff &
disown
exit 0
