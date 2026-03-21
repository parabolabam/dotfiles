#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
REPO_URL="${REPO_URL:-https://github.com/parabolabam/dotfiles.git}"
CLI_NAME="${CLI_NAME:-dotfiles}"
FORCE=false

usage() {
  cat <<'EOF'
Usage: ./scripts/install-cli.sh [options]

Options:
  --repo-dir PATH  Clone or reuse the dotfiles repo at PATH (default: ~/dotfiles)
  --bin-dir PATH   Install the CLI launcher into PATH (default: ~/.local/bin)
  --repo-url URL   Clone from URL if the repo does not exist yet
  --force          Replace an existing unmanaged CLI file
  -h, --help       Show this help

Examples:
  ./scripts/install-cli.sh
  ./scripts/install-cli.sh --repo-dir ~/src/dotfiles --bin-dir ~/.local/bin
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-dir)
      DOTFILES_DIR="$2"
      shift 2
      ;;
    --bin-dir)
      BIN_DIR="$2"
      shift 2
      ;;
    --repo-url)
      REPO_URL="$2"
      shift 2
      ;;
    --force)
      FORCE=true
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

require_cmd git
mkdir -p "$BIN_DIR"

if [[ ! -d "$DOTFILES_DIR/.git" ]]; then
  git clone --recurse-submodules "$REPO_URL" "$DOTFILES_DIR"
else
  git -C "$DOTFILES_DIR" submodule update --init --recursive
fi

CLI_SOURCE="$DOTFILES_DIR/bin/$CLI_NAME"
CLI_TARGET="$BIN_DIR/$CLI_NAME"
MANAGED_MARKER="# dotfiles-cli launcher"

[[ -x "$CLI_SOURCE" ]] || chmod +x "$CLI_SOURCE"

if [[ -e "$CLI_TARGET" && "$FORCE" != true ]]; then
  if ! grep -Fqx "$MANAGED_MARKER" "$CLI_TARGET" 2>/dev/null; then
    echo "Refusing to replace existing file: $CLI_TARGET" >&2
    echo "Use --force if you want to replace it." >&2
    exit 1
  fi
fi

cat > "$CLI_TARGET" <<EOF
#!/usr/bin/env bash
$MANAGED_MARKER
DOTFILES_DIR="$DOTFILES_DIR" exec "$CLI_SOURCE" "\$@"
EOF

chmod +x "$CLI_TARGET"

printf 'Installed %s -> %s\n' "$CLI_TARGET" "$CLI_SOURCE"

case ":$PATH:" in
  *":$BIN_DIR:"*)
    ;;
  *)
    printf 'Add %s to PATH if it is not already there.\n' "$BIN_DIR"
    ;;
esac

printf '\nNext steps:\n'
printf '  %s doctor\n' "$CLI_NAME"
printf '  %s rebuild\n' "$CLI_NAME"
