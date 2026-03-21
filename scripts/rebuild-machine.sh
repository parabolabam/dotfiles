#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$DOTFILES_DIR"

git submodule update --init --recursive

./scripts/brew-sync.sh install
./scripts/stow-packages.sh "$@"
