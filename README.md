# 🚀 Dotfiles

My personal terminal configuration for macOS. One command to set up a complete development environment.

![Terminal Preview](https://raw.githubusercontent.com/catppuccin/catppuccin/main/assets/palette/macchiato.png)

## ⚡ Quick Install

```bash
git clone https://github.com/YOUR_USER/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./setup.sh
```

Or run directly from the web:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USER/dotfiles/main/setup.sh | bash
```

## 📦 What's Included

### Shell & Prompt
- **ZSH** with [Zinit](https://github.com/zdharma-continuum/zinit) plugin manager (fast!)
- **Starship** prompt with custom config
- Plugins: syntax-highlighting, autosuggestions, completions

### Modern CLI Tools
| Tool | Replaces | Description |
|------|----------|-------------|
| [eza](https://github.com/eza-community/eza) | `ls` | Modern file listing with icons |
| [bat](https://github.com/sharkdp/bat) | `cat` | Syntax highlighted file viewer |
| [fd](https://github.com/sharkdp/fd) | `find` | Fast file finder |
| [ripgrep](https://github.com/BurntSushi/ripgrep) | `grep` | Fast text search |
| [fzf](https://github.com/junegunn/fzf) | - | Fuzzy finder for everything |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | `cd` | Smart directory jumping |

### Editor & Terminal
- **Neovim** - Modern vim
- **Tmux** with [TPM](https://github.com/tmux-plugins/tpm) and Catppuccin theme
- **Kitty** / **Alacritty** terminal configs

### Git & Development
- **Lazygit** - Terminal UI for git
- **Lazydocker** - Terminal UI for Docker
- **gh** - GitHub CLI

### Kubernetes
- **kubectl** - K8s CLI
- **k9s** - Terminal K8s dashboard
- **helm** - K8s package manager
- **kubectx** - Context/namespace switcher

### Node.js
- **NVM** - Node version manager (lazy-loaded for speed)
- **Bun** - Fast JavaScript runtime

## 🎨 Theme

Using [Catppuccin Mocha](https://github.com/catppuccin/catppuccin) across all tools for a consistent look.

## 📁 Structure

```
~/dotfiles/
├── setup.sh           # Main installation script
├── Brewfile           # Homebrew packages
├── zsh/
│   └── .zshrc         # ZSH configuration
├── tmux/
│   └── tmux.conf      # Tmux configuration
├── starship/
│   └── starship.toml  # Starship prompt config
├── kitty/
│   └── kitty.conf     # Kitty terminal config
├── alacritty/
│   └── alacritty.toml # Alacritty terminal config
├── lazygit/
│   └── config.yml     # Lazygit config
├── yazi/
│   └── yazi.toml      # Yazi file manager config
├── btop/
│   └── btop.conf      # Btop system monitor config
├── k9s/
│   └── config.yaml    # K9s kubernetes config
├── git/
│   └── .gitconfig     # Git configuration
└── nvim/              # Neovim config (optional)
```

## ⌨️ Key Bindings

### ZSH
| Key | Action |
|-----|--------|
| `Ctrl+R` | Fuzzy search history |
| `Ctrl+T` | Fuzzy find files |
| `Alt+C` | Fuzzy cd to directory |

### Tmux (prefix: `Ctrl-s`)
| Key | Action |
|-----|--------|
| `prefix + r` | Reload config |
| `prefix + s` | Sesh session picker |
| `prefix + h/j/k/l` | Navigate panes |
| `prefix + I` | Install plugins |

### Useful Aliases
| Alias | Command |
|-------|---------|
| `v` | `nvim` |
| `ls` | `eza -lha` |
| `cat` | `bat` |
| `lzg` | `lazygit` |
| `lzd` | `lazydocker` |
| `k` | `kubectl` |
| `gst` | `git status` |
| `gp` | `git push` |
| `gph` | `git push origin head` |

### Functions
| Function | Description |
|----------|-------------|
| `mux` | Start/attach tmux with session restore |
| `fcd` | Fuzzy cd to directory |
| `fe` | Fuzzy find and edit file |
| `local_address` | Get local IP address |

## 🔧 Customization

1. Update `git/.gitconfig` with your name and email
2. Modify `Brewfile` to add/remove packages
3. Adjust themes in individual config files

## 📝 Post-Install

1. **Restart terminal** or `exec zsh`
2. **Install tmux plugins**: `prefix + I` (Ctrl-s + I)
3. **Install Node.js**: `nvm install --lts`
4. **Set git identity**:
   ```bash
   git config --global user.name "Your Name"
   git config --global user.email "your@email.com"
   ```

## 🔄 Updating

```bash
cd ~/dotfiles
git pull
./setup.sh
```

## 📄 License

MIT - Do whatever you want with it!

