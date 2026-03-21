# Dotfiles

This repo is the portable source of truth for my shell and terminal config. It is organized as Stow packages so I can recreate the same setup on any macOS machine with a small number of commands.

## Primary Workflow

1. Install the global CLI once.
2. Run `dotfiles` commands from anywhere.
3. Let the repo stay in `~/dotfiles` as the source of truth.

Quick start:

```bash
curl -fsSL https://raw.githubusercontent.com/parabolabam/dotfiles/main/scripts/install-cli.sh | bash
dotfiles doctor
dotfiles rebuild
```

If you already cloned the repo and just want the command:

```bash
~/dotfiles/scripts/install-cli.sh
```

If you want the full bootstrap path, `./setup.sh` still exists and now installs the CLI before applying packages.

## Repo Layout

Each top-level directory is a Stow package. Files underneath mirror their destination paths in `$HOME`.

```text
dotfiles/
├── stow-packages.txt
├── bin/dotfiles
├── scripts/add-package.sh
├── scripts/install-cli.sh
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
dotfiles list
```

Restow everything:

```bash
dotfiles stow
```

Restow just a few packages:

```bash
dotfiles stow zsh tmux
```

Unstow one package:

```bash
dotfiles unstow nvim
```

Add a new package and scaffold it in the repo:

```bash
dotfiles add atuin --brew
```

Adopt an existing local config directory into the repo and link it:

```bash
dotfiles add zed --cask --install
```

## Brew Usage

Audit package drift against the Brewfile:

```bash
dotfiles brew audit
```

Install or restore everything declared in the Brewfile:

```bash
dotfiles brew install
```

Preview packages that are installed locally but not declared in the Brewfile:

```bash
dotfiles brew cleanup-preview
```

Actually remove packages not declared in the Brewfile:

```bash
dotfiles brew cleanup-force
```

Rebuild a machine from the repo package set and restow configs:

```bash
dotfiles rebuild
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
- `dotfiles` is the global command entrypoint.
- `~/.config` is the live target directory after symlinks are applied.
- The supported path for now is Homebrew + Stow.
