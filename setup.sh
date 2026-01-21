#!/usr/bin/env bash
# ============================================================================
#  🚀 Dotfiles Setup - One command to rule them all
#  Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_USER/dotfiles/main/setup.sh | bash
#  Or:    ./setup.sh
# ============================================================================

set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
REPO_URL="${REPO_URL:-https://github.com/parabolabam/dotfiles.git}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log_header()  { echo -e "\n${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${PURPLE}  $1${NC}"; echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"; }
log_step()    { echo -e "${CYAN}▶${NC} $1"; }
log_success() { echo -e "${GREEN}✔${NC} $1"; }
log_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error()   { echo -e "${RED}✖${NC} $1"; }

# ============================================================================
#  Pre-flight checks
# ============================================================================
log_header "🔍 Pre-flight Checks"

if [[ "$OSTYPE" != "darwin"* ]]; then
    log_error "This script is designed for macOS"
    exit 1
fi

log_success "Running on macOS"

# ============================================================================
#  Clone dotfiles if running from curl
# ============================================================================
if [[ ! -d "$DOTFILES_DIR" ]]; then
    log_header "📦 Cloning Dotfiles"
    git clone "$REPO_URL" "$DOTFILES_DIR"
    cd "$DOTFILES_DIR"
fi

# ============================================================================
#  Install Homebrew
# ============================================================================
log_header "🍺 Homebrew"

if ! command -v brew &>/dev/null; then
    log_step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    log_success "Homebrew installed"
else
    log_success "Homebrew already installed"
fi

# ============================================================================
#  Install packages via Brewfile
# ============================================================================
log_header "📦 Installing Packages"

if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    log_step "Installing from Brewfile..."
    brew bundle --file="$DOTFILES_DIR/Brewfile" || true
    log_success "Packages installed"
else
    log_warning "No Brewfile found, installing essential packages..."
    
    FORMULAS=(zsh starship eza bat fd ripgrep fzf zoxide neovim tmux git lazygit lazydocker gh kubernetes-cli k9s helm kubectx jq nvm bun stow neofetch btop thefuck yazi sesh)
    
    for pkg in "${FORMULAS[@]}"; do
        brew list "$pkg" &>/dev/null || brew install "$pkg"
    done
fi

# ============================================================================
#  Setup Zinit (ZSH Plugin Manager)
# ============================================================================
log_header "⚡ Zinit Plugin Manager"

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    log_step "Installing Zinit..."
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
    log_success "Zinit installed"
else
    log_success "Zinit already installed"
fi

# ============================================================================
#  Setup FZF keybindings
# ============================================================================
log_header "🔍 FZF Setup"

if [[ ! -f ~/.fzf.zsh ]]; then
    log_step "Installing FZF keybindings..."
    "$(brew --prefix)"/opt/fzf/install --key-bindings --completion --no-update-rc --no-bash --no-fish
    log_success "FZF configured"
else
    log_success "FZF already configured"
fi

# ============================================================================
#  Setup Tmux Plugin Manager
# ============================================================================
log_header "🖥️  Tmux Plugin Manager"

TPM_PATH="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_PATH" ]]; then
    log_step "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_PATH"
    log_success "TPM installed"
else
    log_success "TPM already installed"
fi

# ============================================================================
#  Setup NVM
# ============================================================================
log_header "📦 Node Version Manager"

export NVM_DIR="$HOME/.nvm"
mkdir -p "$NVM_DIR"

if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    log_step "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    log_success "NVM installed"
else
    log_success "NVM already installed"
fi

# ============================================================================
#  Create directories
# ============================================================================
log_header "📁 Directory Structure"

mkdir -p "$HOME/.config"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/.config/zsh"

log_success "Directories created"

# ============================================================================
#  Symlink dotfiles with Stow
# ============================================================================
log_header "🔗 Symlinking Dotfiles with Stow"

cd "$DOTFILES_DIR"

# Create required directories first
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
mkdir -p "$HOME/.config"

# Stow all packages (each subdirectory is a "package")
PACKAGES=(zsh git ssh tmux kitty alacritty starship lazygit yazi btop k9s claude gemini)
for pkg in "${PACKAGES[@]}"; do
    if [[ -d "$DOTFILES_DIR/$pkg" ]]; then
        log_step "Stowing $pkg..."
        # Remove existing symlinks/files that might conflict
        stow -D "$pkg" -t "$HOME" 2>/dev/null || true
        # Stow the package
        if stow -R "$pkg" -t "$HOME" 2>/dev/null; then
            log_success "Stowed $pkg"
        else
            log_warning "Failed to stow $pkg (may have conflicts)"
        fi
    fi
done

# Neovim (if you want to manage it here)
if [[ -d "$DOTFILES_DIR/nvim" ]] && [[ -n "$(ls -A $DOTFILES_DIR/nvim 2>/dev/null)" ]]; then
    log_step "Stowing nvim..."
    stow -R "nvim" -t "$HOME" 2>/dev/null && log_success "Stowed nvim" || log_warning "Failed to stow nvim"
fi

# ============================================================================
#  Install Nerd Fonts
# ============================================================================
log_header "🔤 Fonts"

FONTS=(font-meslo-lg-nerd-font font-jetbrains-mono-nerd-font)
for font in "${FONTS[@]}"; do
    if ! brew list --cask "$font" &>/dev/null; then
        log_step "Installing $font..."
        brew install --cask "$font" 2>/dev/null || true
    else
        log_success "$font already installed"
    fi
done

# ============================================================================
#  Set ZSH as default shell
# ============================================================================
log_header "🐚 Default Shell"

ZSH_PATH="$(brew --prefix)/bin/zsh"
if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    if ! grep -q "$ZSH_PATH" /etc/shells; then
        log_step "Adding zsh to /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells
    fi
    log_step "Setting zsh as default shell..."
    chsh -s "$ZSH_PATH"
    log_success "ZSH set as default shell"
else
    log_success "ZSH already default shell"
fi

# ============================================================================
#  Cleanup
# ============================================================================
log_header "🧹 Cleanup"

# Remove old zcompdump files
rm -f ~/.zcompdump* 2>/dev/null || true
rm -f ~/.config/zsh/.zcompdump* 2>/dev/null || true
log_success "Cleaned up old caches"

# ============================================================================
#  Done!
# ============================================================================
log_header "✨ Setup Complete!"

echo -e "
${GREEN}Your terminal environment is ready!${NC}

${CYAN}What was installed:${NC}
  • ZSH with Zinit plugin manager
  • Starship prompt
  • Modern CLI tools (eza, bat, fd, ripgrep, fzf, zoxide)
  • Neovim, Tmux, Lazygit, Lazydocker
  • Kubernetes tools (kubectl, k9s, helm)
  • Node.js management (nvm, bun)

${YELLOW}Next steps:${NC}
  1. Restart your terminal (or run: exec zsh)
  2. Install tmux plugins: prefix + I (Ctrl-s + I)
  3. Install Node.js: nvm install --lts

${PURPLE}Enjoy your new setup! 🚀${NC}
"

