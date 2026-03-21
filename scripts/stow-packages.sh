#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_FILE="${PACKAGES_FILE:-$DOTFILES_DIR/stow-packages.txt}"
TARGET_DIR="${TARGET_DIR:-$HOME}"

usage() {
  cat <<'EOF'
Usage: ./scripts/stow-packages.sh [options] [package...]

Options:
  --target PATH   Override the stow target directory (default: $HOME)
  --adopt         Adopt existing files into the package before restowing
  --delete        Unstow instead of restowing
  --dry-run       Show what would change without changing it
  --list          Print the package list and exit
  -h, --help      Show this help

Examples:
  ./scripts/stow-packages.sh
  ./scripts/stow-packages.sh --adopt zsh tmux
  ./scripts/stow-packages.sh --delete nvim
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

read_packages() {
  ALL_PACKAGES=()
  while IFS= read -r package; do
    ALL_PACKAGES+=("$package")
  done < <(sed -e 's/#.*$//' -e '/^[[:space:]]*$/d' "$PACKAGES_FILE")
}

MODE="restow"
STOW_FLAGS=(-v)
FILTERED_PACKAGES=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET_DIR="$2"
      shift 2
      ;;
    --adopt)
      STOW_FLAGS+=(--adopt)
      shift
      ;;
    --delete)
      MODE="delete"
      shift
      ;;
    --dry-run)
      STOW_FLAGS+=(-n)
      shift
      ;;
    --list)
      read_packages
      printf '%s\n' "${ALL_PACKAGES[@]}"
      exit 0
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      FILTERED_PACKAGES+=("$1")
      shift
      ;;
  esac
done

require_cmd stow
read_packages

if [[ ${#FILTERED_PACKAGES[@]} -eq 0 ]]; then
  FILTERED_PACKAGES=("${ALL_PACKAGES[@]}")
fi

mkdir -p "$TARGET_DIR/.config" "$TARGET_DIR/.ssh"
chmod 700 "$TARGET_DIR/.ssh" 2>/dev/null || true

cd "$DOTFILES_DIR"

for package in "${FILTERED_PACKAGES[@]}"; do
  if [[ ! -d "$DOTFILES_DIR/$package" ]]; then
    echo "Skipping missing package: $package" >&2
    continue
  fi

  if [[ "$MODE" == "delete" ]]; then
    echo "Unstowing $package -> $TARGET_DIR"
    stow "${STOW_FLAGS[@]}" -D "$package" -t "$TARGET_DIR"
  else
    echo "Restowing $package -> $TARGET_DIR"
    stow "${STOW_FLAGS[@]}" -R "$package" -t "$TARGET_DIR"
  fi
done
