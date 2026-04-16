#!/usr/bin/env bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
model_id=$(echo "$input" | jq -r '.model.id // ""')
input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
cache_read_tokens=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
total_tokens=$(( input_tokens + cache_read_tokens ))
token_k=$(( total_tokens / 1000 ))

# Shorten cwd: show last 2 path components
dir_name=$(echo "$cwd" | sed "s|$HOME|~|" | awk -F/ '{if(NF>3) printf "…/%s/%s",$(NF-1),$NF; else print}')

# Git info
branch=""
git_dirty=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" -c "core.useBuiltinFSMonitor=false" -c "core.fsmonitor=false" branch --show-current 2>/dev/null || echo "detached")
  status=$(git -C "$cwd" -c "core.useBuiltinFSMonitor=false" -c "core.fsmonitor=false" status --porcelain 2>/dev/null)
  modified=$(echo "$status" | grep -c '[MADRC]' 2>/dev/null || echo 0)
  untracked=$(echo "$status" | grep -c '^??' 2>/dev/null || echo 0)
  if [ "$modified" -gt 0 ] 2>/dev/null; then
    git_dirty=" ~${modified}"
  fi
  if [ "$untracked" -gt 0 ] 2>/dev/null; then
    git_dirty="${git_dirty} +${untracked}"
  fi
fi

# Effort level from settings
effort_level="unknown"
for settings_path in "$HOME/.claude/settings.json" "$HOME/dotfiles/claude/.claude/settings.json"; do
  if [ -f "$settings_path" ]; then
    effort_level=$(jq -r '.effortLevel // "unknown"' "$settings_path" 2>/dev/null)
    break
  fi
done

# Catppuccin Mocha RGB values (R;G;B)
rgb_surface0="49;50;68"     # #313244
rgb_surface1="69;71;90"     # #45475a
rgb_mauve="203;166;247"     # #cba6f7
rgb_teal="148;226;213"      # #94e2d5
rgb_green="166;227;161"     # #a6e3a1
rgb_yellow="249;226;175"    # #f9e2af
rgb_red="243;139;168"       # #f38ba8
rgb_lavender="180;190;254"  # #b4befe
rgb_peach="250;179;135"     # #fab387
rgb_blue="137;180;250"      # #89b4fa
rgb_crust="17;17;27"        # #11111b

# Powerline round glyphs (UTF-8 encoded to survive file writes)
round_l=$'\xee\x82\xb6'     # U+E0B6 - left semicircle (opens segment)
round_r=$'\xee\x82\xb4'     # U+E0B4 - right semicircle (closes segment)

# Nerd font icons (UTF-8 encoded)
icon_gauge=$'\xef\x83\xa4'   # U+F0E4 - tachometer (context)
icon_chip=$'\xef\x8b\x9b'    # U+F2DB - microchip (model)
icon_effort=$'\xef\x83\xa3'   # U+F0E3 - balance scale (effort)
icon_folder=$'\xef\x81\xbc'  # U+F07C - folder open (cwd)
icon_branch=$'\xee\x82\xa0'  # U+E0A0 - git branch

# Render a powerline line with overlapping round segments
# Each new segment's left edge covers the previous segment
render_line() {
  local segs=("$@")
  local i=0

  for seg in "${segs[@]}"; do
    IFS='|' read -r bg fg text <<< "$seg"

    if [ "$i" -eq 0 ]; then
      # First segment: round left opening on default bg
      printf "\033[38;2;%sm%s" "$bg" "$round_l"
    else
      # Next segment's left edge overlaps into previous segment
      printf "\033[38;2;%sm\033[48;2;%sm%s" "$bg" "$prev_bg" "$round_l"
    fi

    # Segment content
    printf "\033[48;2;%sm\033[38;2;%sm%s" "$bg" "$fg" "$text"

    prev_bg="$bg"
    i=$((i + 1))
  done

  # Close last segment with round right on default bg
  printf "\033[0m\033[38;2;%sm%s\033[0m" "$prev_bg" "$round_r"
}

# === LINE 1: context, model, thinking — vivid bg, dark text ===
line1=()

# Context remaining — vivid colored bg
if [ -n "$remaining" ]; then
  remaining_int=${remaining%.*}
  if [ "$remaining_int" -gt 20 ] 2>/dev/null; then
    ctx_bg="$rgb_green"
  elif [ "$remaining_int" -gt 10 ] 2>/dev/null; then
    ctx_bg="$rgb_yellow"
  else
    ctx_bg="$rgb_red"
  fi
  line1+=("${ctx_bg}|${rgb_crust}| ${icon_gauge} ${remaining}% ctx ")
fi

# Model — teal bg
line1+=("${rgb_teal}|${rgb_crust}| ${icon_chip} ${model_name} ")

# Effort level — color by intensity
case "$effort_level" in
  high)   effort_bg="$rgb_red" ;;
  medium) effort_bg="$rgb_yellow" ;;
  low)    effort_bg="$rgb_green" ;;
  *)      effort_bg="$rgb_lavender" ;;
esac
line1+=("${effort_bg}|${rgb_crust}| ${icon_effort} ${effort_level} ")

render_line "${line1[@]}"

# Blank line to separate from built-in control UI
printf "\n"

# === LINE 2: cwd, git branch — vivid bg, dark text ===
line2=()

# Directory — blue bg
line2+=("${rgb_blue}|${rgb_crust}| ${icon_folder} ${dir_name} ")

# Git branch — mauve bg (always present for consistent layout)
if [ -n "$branch" ]; then
  line2+=("${rgb_mauve}|${rgb_crust}| ${icon_branch} ${branch}${git_dirty} ")
else
  line2+=("${rgb_mauve}|${rgb_crust}| ${icon_branch} ")
fi

# Token usage — always visible, color escalates near 350k
if [ "$token_k" -ge 330 ] 2>/dev/null; then
  tok_bg="$rgb_red"; tok_icon="🔥"
elif [ "$token_k" -ge 300 ] 2>/dev/null; then
  tok_bg="$rgb_peach"; tok_icon="⚡"
else
  tok_bg="$rgb_lavender"; tok_icon="💬"
fi
line2+=("${tok_bg}|${rgb_crust}| ${tok_icon} ${token_k}k ")

render_line "${line2[@]}"
