#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PACKAGES_FILE="${PACKAGES_FILE:-$DOTFILES_DIR/stow-packages.txt}"
BREWFILE="${BREWFILE:-$DOTFILES_DIR/Brewfile}"
TARGET_DIR="${TARGET_DIR:-$HOME}"

usage() {
  cat <<'EOF'
Usage: ./scripts/add-package.sh <package> [options]

Options:
  --path PATH       Relative target path inside $HOME (default: .config/<package>)
  --adopt           Move existing local files into the new package before stowing
  --brew            Add brew "<package>" to Brewfile
  --brew-name NAME  Add brew "NAME" to Brewfile instead of using <package>
  --cask            Add cask "<package>" to Brewfile
  --cask-name NAME  Add cask "NAME" to Brewfile instead of using <package>
  --tap TAP         Add tap "TAP" to Brewfile if missing; may be repeated
  --install         Install the Brew package immediately after updating Brewfile
  --target PATH     Override the stow target directory (default: $HOME)
  -h, --help        Show this help

Examples:
  ./scripts/add-package.sh atuin --brew
  ./scripts/add-package.sh zed --cask --adopt
  ./scripts/add-package.sh claude-local --path .claude --adopt
  ./scripts/add-package.sh go-task --brew-name go-task/tap/go-task --tap go-task/tap
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

append_line_if_missing() {
  local file="$1"
  local line="$2"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '%s\n' "$line" >> "$file"
    return 0
  fi
  return 1
}

ensure_gitkeep_ignore() {
  local package_dir="$1"
  local ignore_file="$package_dir/.stow-local-ignore"
  local ignore_rule='(^|/)\.gitkeep$'

  if [[ ! -f "$ignore_file" ]]; then
    printf '%s\n' "$ignore_rule" > "$ignore_file"
    return 0
  fi

  if ! grep -Fqx "$ignore_rule" "$ignore_file"; then
    printf '%s\n' "$ignore_rule" >> "$ignore_file"
    return 0
  fi

  return 1
}

move_local_target_into_package() {
  local local_target="$1"
  local package_target="$2"
  local package_parent="$3"

  mkdir -p "$package_parent"

  if [[ ! -e "$local_target" || -L "$local_target" ]]; then
    return 1
  fi

  if [[ ! -e "$package_target" ]]; then
    mv "$local_target" "$package_target"
    return 0
  fi

  echo "Cannot auto-adopt because both paths already exist:" >&2
  echo "  local:   $local_target" >&2
  echo "  package: $package_target" >&2
  echo "Move or merge the files manually, then rerun the command." >&2
  exit 1
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

PATH_IN_HOME=".config/$PACKAGE_NAME"
ADOPT=false
INSTALL=false
BREW_KIND=""
BREW_NAME=""
TAPS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --path)
      PATH_IN_HOME="$2"
      shift 2
      ;;
    --adopt)
      ADOPT=true
      shift
      ;;
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
    --install)
      INSTALL=true
      shift
      ;;
    --target)
      TARGET_DIR="$2"
      shift 2
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

if [[ "$PATH_IN_HOME" = /* ]]; then
  echo "--path must be relative to \$HOME, not absolute: $PATH_IN_HOME" >&2
  exit 1
fi

if [[ "$INSTALL" == true && -z "$BREW_KIND" ]]; then
  echo "--install requires one of --brew, --brew-name, --cask, or --cask-name." >&2
  exit 1
fi

if [[ -z "$BREW_NAME" && -n "$BREW_KIND" ]]; then
  BREW_NAME="$PACKAGE_NAME"
fi

PACKAGE_DIR="$DOTFILES_DIR/$PACKAGE_NAME"
PACKAGE_TARGET="$PACKAGE_DIR/$PATH_IN_HOME"
LOCAL_TARGET="$TARGET_DIR/$PATH_IN_HOME"
PACKAGE_PARENT="$(dirname "$PACKAGE_TARGET")"
LOCAL_PARENT="$(dirname "$LOCAL_TARGET")"
EFFECTIVE_ADOPT="$ADOPT"
ADOPTED_EXISTING=false

if [[ -e "$LOCAL_TARGET" && ! -L "$LOCAL_TARGET" ]]; then
  EFFECTIVE_ADOPT=true
fi

mkdir -p "$PACKAGE_PARENT" "$LOCAL_PARENT"
mkdir -p "$PACKAGE_DIR"

package_added=false
brewfile_changed=false
placeholder_created=false

if append_line_if_missing "$PACKAGES_FILE" "$PACKAGE_NAME"; then
  package_added=true
fi

if [[ ${#TAPS[@]} -gt 0 ]]; then
  for tap in "${TAPS[@]}"; do
    if append_line_if_missing "$BREWFILE" "tap \"$tap\""; then
      brewfile_changed=true
    fi
  done
fi

if [[ -n "$BREW_KIND" ]]; then
  if append_line_if_missing "$BREWFILE" "$BREW_KIND \"$BREW_NAME\""; then
    brewfile_changed=true
  fi
fi

if [[ "$EFFECTIVE_ADOPT" == false ]]; then
  mkdir -p "$PACKAGE_TARGET"
  ensure_gitkeep_ignore "$PACKAGE_DIR" >/dev/null || true
  if [[ ! -e "$PACKAGE_TARGET/.gitkeep" ]]; then
    touch "$PACKAGE_TARGET/.gitkeep"
    placeholder_created=true
  fi
else
  if move_local_target_into_package "$LOCAL_TARGET" "$PACKAGE_TARGET" "$PACKAGE_PARENT"; then
    ADOPTED_EXISTING=true
  fi
fi

if [[ "$INSTALL" == true ]]; then
  require_cmd brew
  if [[ ${#TAPS[@]} -gt 0 ]]; then
    for tap in "${TAPS[@]}"; do
      brew tap "$tap"
    done
  fi
  if [[ "$BREW_KIND" == "brew" ]]; then
    brew install "$BREW_NAME"
  else
    brew install --cask "$BREW_NAME"
  fi
fi

"$DOTFILES_DIR/scripts/stow-packages.sh" --target "$TARGET_DIR" "$PACKAGE_NAME"

echo
echo "Package ready: $PACKAGE_NAME"
echo "Target path: $PATH_IN_HOME"

if [[ "$package_added" == true ]]; then
  echo "Updated: stow-packages.txt"
fi

if [[ "$brewfile_changed" == true ]]; then
  echo "Updated: Brewfile"
fi

if [[ "$placeholder_created" == true ]]; then
  echo "Created placeholder: $PACKAGE_NAME/$PATH_IN_HOME/.gitkeep"
fi

if [[ "$ADOPTED_EXISTING" == true && "$ADOPT" == false ]]; then
  echo "Adopted existing local files automatically because $LOCAL_TARGET already existed."
fi

GIT_ADD_ARGS="$PACKAGE_NAME stow-packages.txt"
if [[ "$brewfile_changed" == true ]]; then
  GIT_ADD_ARGS="$GIT_ADD_ARGS Brewfile"
fi

echo
echo "Next git command:"
echo "  git -C $DOTFILES_DIR add $GIT_ADD_ARGS"
