#!/bin/bash

# Send bell to the current TTY to trigger tab decoration
printf '\a' >/dev/tty

# Play the frog ribbit sound
afplay /System/Library/Sounds/Frog.aiff &

# Notify when Claude finishes a task and is waiting for input
osascript -e 'display notification "Claude has finished and needs your input" with title "Claude Code" sound name "Frog"'

exit 0
