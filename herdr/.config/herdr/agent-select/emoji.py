#!/usr/bin/env python3
"""Give every agent pane emoji state labels for the sidebar state_text token; drop the old emoji token. Stdlib only."""
import json, os, subprocess

L = dict(working="🚀", blocked="🆘", idle="🌙", done="🌟", unknown="👽")
H = os.environ.get("HERDR_BIN_PATH", "herdr")
out = subprocess.run([H, "agent", "list"], capture_output=True, text=True).stdout
for a in json.loads(out)["result"]["agents"]:
    labels = [f for k, v in L.items() for f in ("--state-label", f"{k}={v}")]
    subprocess.run([H, "pane", "report-metadata", a["pane_id"], "--source", "user:emoji", *labels, "--clear-token", "emoji"])
