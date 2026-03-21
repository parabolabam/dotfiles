# Dotfiles

This repo is the portable source of truth for my shell and terminal config. It is organized as Stow packages and managed through a global `dotfiles` CLI so I can recreate the same setup on any macOS machine without having to `cd ~/dotfiles` for every change.

## How It Works

- `~/dotfiles` is the source of truth.
- `dotfiles` is the global command you run from anywhere.
- `Brewfile` defines software to install with Homebrew.
- `stow-packages.txt` defines which config packages are symlinked into `$HOME`.
- Each top-level package directory mirrors the destination path inside `$HOME`.

In practice:
- software installation lives in `Brewfile`
- tracked config lives in a Stow package like `zsh/`, `tmux/`, or `nvim/`
- `dotfiles rebuild` restores both sides: Brew packages and symlinked config

## Install

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

## Daily Usage

Check that the CLI can see the repo and required tools:

```bash
dotfiles doctor
```

See which config packages are managed:

```bash
dotfiles list
```

Restow everything:

```bash
dotfiles stow
```

Restow only specific packages:

```bash
dotfiles stow zsh tmux nvim
```

Remove one package's symlinks:

```bash
dotfiles unstow kitty
```

Rebuild a machine from the repo:

```bash
dotfiles rebuild
```

Sync submodules, including the Neovim config:

```bash
dotfiles sync
```

Remove a tracked package cleanly:

```bash
dotfiles remove atuin --brew
```

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

## Adding Packages

The `dotfiles add` command does two jobs:
- it creates or adopts a Stow package in the repo
- it can also register a Homebrew formula or cask in `Brewfile`

The important part is this:
- `--brew` or `--cask` updates `Brewfile`
- `--install` actually runs `brew install` or `brew install --cask`
- if a local config already exists, it is automatically adopted into the repo

### Preferred Flow

In your shell, `brew install ...` is intentionally intercepted and routed through `dotfiles`.

That means these pasted commands:

```bash
brew install atuin
brew install --cask zed
brew install go-task/tap/go-task
```

behave like tracked dotfiles operations:
- the package is added to `Brewfile`
- a matching Stow package is created in `~/dotfiles`
- the package is installed immediately
- the config package is restowed

So the normal habit should be:
- paste `brew install ...` exactly as tools/docs provide it
- let the shell convert it into `dotfiles add ... --install`
- use `dotfiles` directly only when you want finer control

If you want to bypass tracking and call real Homebrew directly, use:

```bash
command brew install <package>
```

There is matching removal behavior too:

```bash
brew uninstall atuin
brew uninstall --cask zed
```

These are also routed through `dotfiles`, so they:
- remove the package from `Brewfile`
- remove the package from `stow-packages.txt`
- unstow and delete the matching package directory in `~/dotfiles`
- uninstall it from Homebrew

If you want raw Homebrew uninstall behavior without touching the repo, use:

```bash
command brew uninstall <package>
```

Only `brew install ...` and `brew uninstall ...` interception are special. Other commands like `brew info`, `brew update`, `brew bundle`, and `brew upgrade` still go to Homebrew normally.

Register a formula and create its tracked config package, but do not install it yet:

```bash
dotfiles add atuin --brew
```

Register and install a formula right now:

```bash
dotfiles add atuin --brew --install
```

Register and install a cask:

```bash
dotfiles add zed --cask --install
```

Create a package for something that stores config outside `.config`:

```bash
dotfiles add claude-local --path .claude
```

Add a formula with a custom Brewfile entry:

```bash
dotfiles add go-task --brew-name go-task/tap/go-task --tap go-task/tap --install
```

What `dotfiles add` changes:
- appends the package name to `stow-packages.txt`
- adds a Brewfile entry if `--brew`, `--brew-name`, `--cask`, or `--cask-name` is used
- creates a package directory under `~/dotfiles/<name>/...`
- moves existing local config into that package if the target already exists
- restows that package immediately

One caveat: the Homebrew formula name is not always the shell command you run later. For example, `forgit` installs `git-forgit`, not a `forgit` binary. When that matters, check `brew info <formula>`.

## Zsh Shortcuts

The tracked Zsh config includes:
- a `brew()` wrapper that intercepts `brew install ...` and `brew uninstall ...`
- two explicit shortcuts if you want to call the tracked flow directly

```bash
bi <formula>
bci <cask>
```

They expand to:
- `bi foo` -> `dotfiles add foo --brew --install`
- `bci foo` -> `dotfiles add foo --cask --install`

Examples:

```bash
brew install atuin
brew install --cask zed

bi atuin
bci zed
```

Reload your shell after pulling changes to pick these up:

```bash
source ~/.zshrc
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
- `dotfiles add ... --brew` only registers the formula; add `--install` if you want it installed immediately.
