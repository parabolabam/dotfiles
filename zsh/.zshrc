# ============================================================================
#  ⚡ Fast ZSH Configuration
# ============================================================================

# XDG Base Directories
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
mkdir -p "$ZDOTDIR" "$XDG_CACHE_HOME"

# ============================================================================
#  Zinit Plugin Manager
# ============================================================================
ZINIT_HOME="${XDG_DATA_HOME}/zinit/zinit.git"
[[ -d "$ZINIT_HOME" ]] || git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions

# OMZ snippets (async)
zinit ice wait lucid; zinit snippet OMZP::git
zinit ice wait lucid; zinit snippet OMZP::web-search

# ============================================================================
#  Completion (cached for speed)
# ============================================================================
autoload -Uz compinit
_comp_files=("$ZDOTDIR/.zcompdump"(Nm-20))
(( $#_comp_files )) && compinit -C -d "$ZDOTDIR/.zcompdump" || compinit -d "$ZDOTDIR/.zcompdump"
unset _comp_files

zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' special-dirs true

# ============================================================================
#  History
# ============================================================================
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$ZDOTDIR/.zsh_history"

setopt EXTENDED_HISTORY HIST_EXPIRE_DUPS_FIRST HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS HIST_FIND_NO_DUPS HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS SHARE_HISTORY APPEND_HISTORY

# ============================================================================
#  Key Bindings
# ============================================================================
bindkey -e
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ============================================================================
#  Prompt (Starship)
# ============================================================================
eval "$(starship init zsh)"

# ============================================================================
#  Tools
# ============================================================================

# Homebrew
export HOMEBREW_NO_AUTO_UPDATE=1
[[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Zoxide
eval "$(zoxide init zsh)"

# FZF
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --header 'CTRL-Y to copy'"
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh

# ============================================================================
#  Lazy-loaded Tools
# ============================================================================

# NVM
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  unset -f nvm node npm npx yarn pnpm 2>/dev/null
  [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
}
for _cmd in nvm node npm npx yarn pnpm; do
  eval "$_cmd() { _load_nvm && $_cmd \"\$@\" }"
done; unset _cmd

# TheFuck
command -v thefuck &>/dev/null && fuck() { unset -f fuck; eval "$(thefuck --alias)"; fuck "$@"; }

# ============================================================================
#  Aliases
# ============================================================================
alias ls="eza -lha"
alias ll="eza -lh"
alias la="eza -lha"
alias tree="eza --tree"
alias v="nvim"
alias vim="nvim"
alias cat="bat"
alias lzd="lazydocker"
alias lzg="lazygit"

# Git
alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gb="git branch"
alias gc="git commit -v"
alias gcm="git commit -m"
alias gco="git checkout"
alias gd="git diff"
alias gf="git fetch"
alias gl="git pull"
alias glog="git log --oneline --graph --decorate"
alias gp="git push"
alias gph="git push origin head"
alias gpl="git pull origin main"
alias gst="git status"
alias gsw="git switch"

# FZF with preview
alias fzf="fzf --preview 'bat --color=always {} 2>/dev/null || cat {}'"

# Kubernetes
alias k="kubectl"
alias k9s-prod='KUBECONFIG="$HOME/.kube/config.prod" k9s --context dt-prod-usw2'
alias k9s-dev='KUBECONFIG="$HOME/.kube/config" k9s --context dt-dev-euc1'

# ============================================================================
#  Functions
# ============================================================================

# Tmux session manager
mux() {
  command -v tmux >/dev/null || return
  if ! pgrep -qx tmux 2>/dev/null; then
    tmux new -d -s delete-me
    tmux run-shell "$XDG_CONFIG_HOME/tmux/plugins/tmux-resurrect/scripts/restore.sh" 2>/dev/null
    tmux kill-session -t delete-me 2>/dev/null
  fi
  tmux attach
}

# Fuzzy cd
fcd() {
  local dir
  dir=$(fd --type d --hidden --exclude .git 2>/dev/null | fzf --preview 'eza -la {}' +m) && cd "$dir"
}

# Fuzzy edit
fe() {
  local file
  file=$(fzf --preview 'bat --color=always {}') && nvim "$file"
}

# Local IP
local_address() {
  echo "http://$(ipconfig getifaddr en0 2>/dev/null || echo 'localhost')"
}

# ============================================================================
#  PATH
# ============================================================================
export PATH="$HOME/.local/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ============================================================================
#  Auto-tmux (set AUTO_TMUX=1 to enable)
# ============================================================================
[[ -o interactive && -z "$TMUX" && "${AUTO_TMUX:-0}" = "1" ]] && mux

export PATH="$HOME/.local/bin:$PATH"
# Add to ~/.zshrc or ~/.bashrc

# Added by Antigravity
export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
