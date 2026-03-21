#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_FILE="${PACKAGES_FILE:-$DOTFILES_DIR/stow-packages.txt}"
BREWFILE="${BREWFILE:-$DOTFILES_DIR/Brewfile}"
TARGET_DIR="${TARGET_DIR:-$HOME}"

usage() {
  cat <<'EOF'
Usage: ./scripts/remove-package.sh <package> [options]

Options:
  --brew            Remove brew "<package>" from Brewfile and uninstall it
  --brew-name NAME  Remove brew "NAME" from Brewfile and uninstall it
  --cask            Remove cask "<package>" from Brewfile and uninstall it
  --cask-name NAME  Remove cask "NAME" from Brewfile and uninstall it
  --tap TAP         Remove tap "TAP" if it is no longer referenced; may be repeated
  --target PATH     Override the stow target directory (default: $HOME)
  --no-uninstall    Update the repo only; do not run brew uninstall
  --keep-package    Keep the package directory in the repo after unstowing
  --zap             Pass --zap when uninstalling a cask
  -h, --help        Show this help

Examples:
  ./scripts/remove-package.sh atuin --brew
  ./scripts/remove-package.sh zed --cask --zap
  ./scripts/remove-package.sh go-task --brew-name go-task/tap/go-task --tap go-task/tap
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

line_exists() {
  local file="$1"
  local line="$2"
  [[ -f "$file" ]] && grep -Fqx "$line" "$file"
}

remove_exact_line() {
  local file="$1"
  local line="$2"
  local tmp_file=""

  [[ -f "$file" ]] || return 1
  line_exists "$file" "$line" || return 1

  tmp_file="$(mktemp "${TMPDIR:-/tmp}/dotfiles-remove.XXXXXX")"
  awk -v line="$line" '$0 != line { print }' "$file" > "$tmp_file"
  mv "$tmp_file" "$file"
  return 0
}

cleanup_submodules_for_package() {
  local package_name="$1"
  local key=""
  local path=""
  local name=""

  [[ -f "$DOTFILES_DIR/.gitmodules" ]] || return 0
  require_cmd git

  while IFS= read -r line; do
    key="${line%% *}"
    path="${line#* }"

    if [[ "$path" != "$package_name" && "$path" != "$package_name/"* ]]; then
      continue
    fi

    name="${key#submodule.}"
    name="${name%.path}"

    git config -f "$DOTFILES_DIR/.gitmodules" --remove-section "submodule.$name" 2>/dev/null || true
    git config -f "$DOTFILES_DIR/.git/config" --remove-section "submodule.$name" 2>/dev/null || true
    rm -rf "$DOTFILES_DIR/.git/modules/$path"
  done < <(git -C "$DOTFILES_DIR" config -f .gitmodules --get-regexp '^submodule\..*\.path$' 2>/dev/null || true)

  if [[ -f "$DOTFILES_DIR/.gitmodules" && ! -s "$DOTFILES_DIR/.gitmodules" ]]; then
    rm -f "$DOTFILES_DIR/.gitmodules"
  fi
}

remove_unused_tap() {
  local tap="$1"
  local escaped_tap=""

  line_exists "$BREWFILE" "tap \"$tap\"" || return 1
  escaped_tap="$(printf '%s' "$tap" | sed 's/[.[\*^$()+?{}|/]/\\&/g')"

  if grep -Eq "^(brew|cask) \"${escaped_tap}/" "$BREWFILE"; then
    return 1
  fi

  remove_exact_line "$BREWFILE" "tap \"$tap\""
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -eq 0 ]]; then
  usage >&2
  exit 1
fi

PACKAGE_NAME="$1"
shift

BREW_KIND=""
BREW_NAME=""
TAPS=()
UNINSTALL=true
KEEP_PACKAGE=false
ZAP=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --brew)
      if [[ -n "$BREW_KIND" && "$BREW_KIND" != "brew" ]]; then
        echo "Choose only one of --brew or --cask." >&2
        exit 1
      fi
      BREW_KIND="brew"
      shift
      ;;
    --brew-name)
      if [[ -n "$BREW_KIND" && "$BREW_KIND" != "brew" ]]; then
        echo "Choose only one of --brew-name or --cask-name." >&2
        exit 1
      fi
      BREW_KIND="brew"
      BREW_NAME="$2"
      shift 2
      ;;
    --cask)
      if [[ -n "$BREW_KIND" && "$BREW_KIND" != "cask" ]]; then
        echo "Choose only one of --brew or --cask." >&2
        exit 1
      fi
      BREW_KIND="cask"
      shift
      ;;
    --cask-name)
      if [[ -n "$BREW_KIND" && "$BREW_KIND" != "cask" ]]; then
        echo "Choose only one of --brew-name or --cask-name." >&2
        exit 1
      fi
      BREW_KIND="cask"
      BREW_NAME="$2"
      shift 2
      ;;
    --tap)
      TAPS+=("$2")
      shift 2
      ;;
    --target)
      TARGET_DIR="$2"
      shift 2
      ;;
    --no-uninstall)
      UNINSTALL=false
      shift
      ;;
    --keep-package)
      KEEP_PACKAGE=true
      shift
      ;;
    --zap)
      ZAP=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$ZAP" == true && "$BREW_KIND" == "brew" ]]; then
  echo "--zap is only valid for casks." >&2
  exit 1
fi

if [[ -z "$BREW_KIND" ]]; then
  if line_exists "$BREWFILE" "brew \"$PACKAGE_NAME\"" && line_exists "$BREWFILE" "cask \"$PACKAGE_NAME\""; then
    echo "Package exists as both brew and cask in Brewfile. Specify --brew or --cask." >&2
    exit 1
  elif line_exists "$BREWFILE" "brew \"$PACKAGE_NAME\""; then
    BREW_KIND="brew"
    BREW_NAME="$PACKAGE_NAME"
  elif line_exists "$BREWFILE" "cask \"$PACKAGE_NAME\""; then
    BREW_KIND="cask"
    BREW_NAME="$PACKAGE_NAME"
  fi
fi

if [[ -z "$BREW_NAME" && -n "$BREW_KIND" ]]; then
  BREW_NAME="$PACKAGE_NAME"
fi

PACKAGE_DIR="$DOTFILES_DIR/$PACKAGE_NAME"
had_package_dir=false
package_removed=false
brewfile_changed=false
package_entry_removed=false
uninstalled=false

if [[ -d "$PACKAGE_DIR" ]]; then
  had_package_dir=true
  "$DOTFILES_DIR/scripts/stow-packages.sh" --target "$TARGET_DIR" --delete "$PACKAGE_NAME" >/dev/null 2>&1 || true
fi

if remove_exact_line "$PACKAGES_FILE" "$PACKAGE_NAME"; then
  package_entry_removed=true
fi

if [[ -n "$BREW_KIND" ]] && remove_exact_line "$BREWFILE" "$BREW_KIND \"$BREW_NAME\""; then
  brewfile_changed=true
fi

if [[ ${#TAPS[@]} -gt 0 ]]; then
  for tap in "${TAPS[@]}"; do
    if remove_unused_tap "$tap"; then
      brewfile_changed=true
    fi
  done
fi

if [[ "$KEEP_PACKAGE" == false && -d "$PACKAGE_DIR" ]]; then
  cleanup_submodules_for_package "$PACKAGE_NAME"
  rm -rf "$PACKAGE_DIR"
  package_removed=true
fi

if [[ "$UNINSTALL" == true && -n "$BREW_KIND" ]]; then
  require_cmd brew
  if [[ "$BREW_KIND" == "cask" ]]; then
    if [[ "$ZAP" == true ]]; then
      brew uninstall --cask --zap "$BREW_NAME"
    else
      brew uninstall --cask "$BREW_NAME"
    fi
  else
    brew uninstall "$BREW_NAME"
  fi
  uninstalled=true
fi

echo
echo "Package removed: $PACKAGE_NAME"

if [[ "$package_entry_removed" == true ]]; then
  echo "Updated: stow-packages.txt"
fi

if [[ "$brewfile_changed" == true ]]; then
  echo "Updated: Brewfile"
fi

if [[ "$package_removed" == true ]]; then
  echo "Deleted: $PACKAGE_NAME/"
elif [[ "$had_package_dir" == true && "$KEEP_PACKAGE" == true ]]; then
  echo "Kept package directory: $PACKAGE_NAME/"
fi

if [[ "$uninstalled" == true ]]; then
  echo "Uninstalled: $BREW_KIND $BREW_NAME"
fi
