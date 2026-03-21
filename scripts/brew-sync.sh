#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREWFILE="${BREWFILE:-$DOTFILES_DIR/Brewfile}"
MODE="${1:-audit}"

usage() {
  cat <<'EOF'
Usage: ./scripts/brew-sync.sh [audit|install|cleanup-preview|cleanup-force]

Modes:
  audit            Show missing and extra taps/formulae/casks relative to Brewfile.
  install          Run brew bundle install using the repo Brewfile.
  cleanup-preview  Show what would be removed if you reconciled to the Brewfile.
  cleanup-force    Uninstall extra formulae/casks and untap extra taps.
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

collect_expected() {
  EXPECTED_TAPS=()
  EXPECTED_FORMULAE=()
  EXPECTED_CASKS=()

  while IFS= read -r line; do
    case "$line" in
      tap\ \"*\")
        value="${line#tap \"}"
        value="${value%%\"*}"
        EXPECTED_TAPS+=("$value")
        ;;
      brew\ \"*\")
        value="${line#brew \"}"
        value="${value%%\"*}"
        EXPECTED_FORMULAE+=("${value##*/}")
        ;;
      cask\ \"*\")
        value="${line#cask \"}"
        value="${value%%\"*}"
        EXPECTED_CASKS+=("$value")
        ;;
    esac
  done < "$BREWFILE"
}

sorted_unique() {
  printf '%s\n' "$@" | awk 'NF' | sort -u
}

get_actual_formulae() {
  brew list --formula | sort -u
}

get_actual_casks() {
  brew list --cask | sort -u
}

get_actual_taps() {
  brew tap | sort -u
}

show_section() {
  local title="$1"
  shift
  echo "$title"
  if [[ $# -eq 0 ]] || [[ -z "${1:-}" ]]; then
    echo "  (none)"
    return
  fi
  while IFS= read -r item; do
    [[ -n "$item" ]] && echo "  $item"
  done <<< "$1"
  return 0
}

compare_lists() {
  local expected="$1"
  local actual="$2"
  local missing extra
  missing="$(comm -23 <(printf '%s\n' "$expected") <(printf '%s\n' "$actual"))"
  extra="$(comm -13 <(printf '%s\n' "$expected") <(printf '%s\n' "$actual"))"
  printf '%s\n__SPLIT__\n%s\n' "$missing" "$extra"
}

force_uninstall_list() {
  local kind="$1"
  local list="$2"
  [[ -z "$list" ]] && return 0
  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    case "$kind" in
      formula) brew uninstall "$item" ;;
      cask) brew uninstall --cask "$item" ;;
      tap) brew untap "$item" ;;
    esac
  done <<< "$list"
}

require_cmd brew
collect_expected

expected_taps="$(sorted_unique "${EXPECTED_TAPS[@]}")"
expected_formulae="$(sorted_unique "${EXPECTED_FORMULAE[@]}")"
expected_casks="$(sorted_unique "${EXPECTED_CASKS[@]}")"

actual_taps="$(get_actual_taps)"
actual_formulae="$(get_actual_formulae)"
actual_casks="$(get_actual_casks)"

tap_compare="$(compare_lists "$expected_taps" "$actual_taps")"
formula_compare="$(compare_lists "$expected_formulae" "$actual_formulae")"
cask_compare="$(compare_lists "$expected_casks" "$actual_casks")"

tap_missing="${tap_compare%%__SPLIT__*}"
tap_extra="${tap_compare#*__SPLIT__$'\n'}"
formula_missing="${formula_compare%%__SPLIT__*}"
formula_extra="${formula_compare#*__SPLIT__$'\n'}"
cask_missing="${cask_compare%%__SPLIT__*}"
cask_extra="${cask_compare#*__SPLIT__$'\n'}"

case "$MODE" in
  audit)
    show_section "Missing formulae:" "$formula_missing"
    show_section "Missing casks:" "$cask_missing"
    show_section "Missing taps:" "$tap_missing"
    echo
    show_section "Potential extra formulae (review manually; may include dependencies):" "$formula_extra"
    show_section "Extra casks:" "$cask_extra"
    show_section "Extra taps:" "$tap_extra"
    ;;
  install)
    exec brew bundle install --file="$BREWFILE"
    ;;
  cleanup-preview)
    show_section "Potential extra formulae (manual review required):" "$formula_extra"
    show_section "Would uninstall casks:" "$cask_extra"
    show_section "Would untap taps:" "$tap_extra"
    ;;
  cleanup-force)
    echo "Skipping formula cleanup automatically because Homebrew inventory is noisy on this machine."
    echo "Review these formulae manually before uninstalling:"
    show_section "Potential extra formulae:" "$formula_extra"
    force_uninstall_list cask "$cask_extra"
    force_uninstall_list tap "$tap_extra"
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
