#!/bin/sh
# Open the agent side pane (~36 cols) on the LEFT of the current tab; no-op if already open.
W=36
P=${HERDR_PANE_ID:-$(herdr pane current | jq -r '.result.pane.pane_id')}
TAB=$(herdr pane get "$P" | jq -r '.result.pane.tab_id')
for p in $(herdr pane list | jq -r --arg t "$TAB" '.result.panes[]|select(.tab_id==$t)|.pane_id'); do
  if herdr pane process-info --pane "$p" | grep -q 'agent_select.py'; then
    exit 0 # already open
  fi
done
AREA=$(herdr pane layout --pane "$P" | jq -r '.result.layout.area.width')
# ratio applies to the ORIGINAL pane (left); after the swap the new pane sits left with the same width
N=$(herdr pane split --pane "$P" --direction right --no-focus --ratio "$(echo "$W $AREA" | awk '{printf "%.4f", $1/$2}')" \
  | jq -r '.result.pane.pane_id')
herdr pane swap --source-pane "$P" --target-pane "$N" >/dev/null
herdr pane run "$N" python3 "\$HOME/.config/herdr/agent-select/agent_select.py" --side >/dev/null
