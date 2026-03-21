# Dotfiles

This repo is the portable source of truth for my shell and terminal config. It is organized as Stow packages so I can recreate the same setup on any macOS machine with a small number of commands.

## Primary Workflow

1. Clone the repo.
2. Install packages from the Brewfile if needed.
3. Stow the packages into `$HOME`.

Quick start:

```bash
git clone --recurse-submodules https://github.com/parabolabam/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle --file Brewfile
./scripts/stow-packages.sh
```

If you already cloned the repo without submodules, run this once before stowing:

```bash
git submodule update --init --recursive
```

If you want the full bootstrap path, `./setup.sh` still exists and now delegates the symlink step to `./scripts/stow-packages.sh`.

## Repo Layout

Each top-level directory is a Stow package. Files underneath mirror their destination paths in `$HOME`.

```text
dotfiles/
├── stow-packages.txt
├── scripts/stow-packages.sh
├── Brewfile
├── setup.sh
├── zsh/
├── git/
├── ssh/
├── tmux/
├── kitty/
├── alacritty/
├── starship/
├── lazygit/
├── yazi/
├── btop/
├── k9s/
├── claude/
├── gemini/
└── nvim/
```

The `nvim/.config/nvim` directory is a Git submodule that points at `https://github.com/parabolabam/LazyVimStarter`.

## Stow Usage

List all configured packages:

```bash
./scripts/stow-packages.sh --list
```

Restow everything:

```bash
./scripts/stow-packages.sh
```

Adopt existing files into a package before restowing:

```bash
./scripts/stow-packages.sh --adopt zsh tmux
```

Unstow one package:

```bash
./scripts/stow-packages.sh --delete nvim
```

## Brew Usage

Audit package drift against the Brewfile:

```bash
./scripts/brew-sync.sh audit
```

Install or restore everything declared in the Brewfile:

```bash
./scripts/brew-sync.sh install
```

Preview packages that are installed locally but not declared in the Brewfile:

```bash
./scripts/brew-sync.sh cleanup-preview
```

Actually remove packages not declared in the Brewfile:

```bash
./scripts/brew-sync.sh cleanup-force
```

Rebuild a machine from the repo package set and restow configs:

```bash
./scripts/rebuild-machine.sh
```

## Portability Rules

Keep in this repo:
- shell/editor/tool config that should follow you to another machine
- theme files, aliases, tmux config, Neovim config, and portable app settings

Keep out of this repo:
- credentials, tokens, OAuth state, cloud configs, logs, caches, history files
- auto-generated backups and app runtime state
- host-specific overrides that only make sense on one machine

## Notes

- `~/dotfiles` is the source of truth.
- `~/.config` is the live target directory after symlinks are applied.
- The supported path for now is Homebrew + Stow.
