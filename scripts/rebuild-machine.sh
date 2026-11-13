#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$DOTFILES_DIR"

git submodule update --init --recursive

./scripts/brew-sync.sh install
./scripts/stow-packages.sh "$@"

# Only refresh when zsh is stowed for real, not for listing, removal or dry runs.
refresh_shell_init=true
stow_target="${TARGET_DIR:-$HOME}"
selected_packages=0
zsh_selected=false
while (($#)); do
  case "$1" in
    --target) stow_target="$2"; shift 2 ;;
    --dry-run|--delete|--list|-h|--help) refresh_shell_init=false; shift ;;
    --adopt) shift ;;
    *) ((selected_packages+=1)); [[ "$1" == zsh ]] && zsh_selected=true; shift ;;
  esac
done
if ((selected_packages == 0)); then
  while IFS= read -r package; do
    if [[ "${package%%#*}" == zsh ]]; then zsh_selected=true; fi
  done < "${PACKAGES_FILE:-$DOTFILES_DIR/stow-packages.txt}"
fi
if [[ "$refresh_shell_init" == true && "$zsh_selected" == true ]]; then
  if [[ "$stow_target" == "$HOME" ]]; then
    "$DOTFILES_DIR/zsh/.local/bin/refresh-shell-init"
  else
    XDG_CONFIG_HOME="$stow_target/.config" "$DOTFILES_DIR/zsh/.local/bin/refresh-shell-init"
  fi
fi
