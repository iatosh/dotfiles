# dotfiles

My personal configuration files for macOS and Linux development environments, with an interactive installer powered by [Gum](https://github.com/charmbracelet/gum).

> **Note:** This is a personal setup tailored to my workflow — not a plug-and-play solution. Feel free to browse and borrow whatever looks useful.

---

## What's inside

| Area | Tool | Notes |
|------|------|-------|
| Shell | Zsh + [Zinit](https://github.com/zdharma-continuum/zinit) | Modular config under `zsh/.zsh/` |
| Prompt | [Powerlevel10k](https://github.com/romkatv/powerlevel10k) | |
| Editor | [Neovim](https://neovim.io) | Managed as a submodule, based on Kickstart.nvim |
| Terminal | [WezTerm](https://wezfurlong.org/wezterm/) | |
| Multiplexer | [Tmux](https://github.com/tmux/tmux) | Plugin manager via TPM |
| Key remapping | [Karabiner-Elements](https://karabiner-elements.pqrs.org) | macOS only |
| Window manager | [Aerospace](https://github.com/nikitabobko/AeroSpace) | macOS only |
| Git UI | [Lazygit](https://github.com/jesseduffield/lazygit) | |
| File manager | [Yazi](https://github.com/sxyazi/yazi) | |
| Package manager | [Homebrew](https://brew.sh) | Single Brewfile with `on_macos`/`on_linux` blocks |
| Runtime manager | [mise](https://mise.jdx.dev) | Used on shared Linux servers (no root needed) |

### Modern CLI replacements

| Classic | Replacement |
|---------|-------------|
| `cat` | [bat](https://github.com/sharkdp/bat) |
| `ls` | [eza](https://github.com/eza-community/eza) |
| `grep` | [ripgrep](https://github.com/BurntSushi/ripgrep) |
| `find` | [fd](https://github.com/sharkdp/fd) |
| `cd` | [zoxide](https://github.com/ajeetdsouza/zoxide) |
| `top` | [btop](https://github.com/aristocratsoftware/btop) |
| `fzf` | — (fuzzy finder, used throughout) |

---

## Directory structure

```
dotfiles/
├── bin/            # Utility scripts (macos/defaults.sh, …)
├── pkg/            # Brewfile, install.conf, update-brew.sh (mise tool list, exclusions)
├── claude/         # Claude Code configuration
├── config/         # XDG configs → ~/.config/ (tmux, wezterm, zed, yazi, …)
├── git/            # .gitconfig
├── karabiner/      # Karabiner-Elements (macOS)
├── nvim/           # Neovim config (git submodule)
├── p10k/           # Powerlevel10k config
├── zsh/            # .zshrc + modular config under zsh/.zsh/
└── install.sh      # Interactive installer (no stow required)
```

---

## Installation

Requires only `git` and `curl` to get started.

```bash
git clone https://github.com/iatosh/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The installer will:

- Ask which packages to symlink into `~` / `~/.config`
- On **macOS** or a **private Linux server**: install packages via Homebrew
- On a **shared Linux server** (no root): install CLI tools via mise into `~/.local/bin`

### Secrets

Keep private keys and environment variables out of the repo:

```bash
# ~/dotfiles/.secrets  (gitignored)
export GITHUB_TOKEN="..."
```

This file is sourced automatically by `zsh/.zsh/env.zsh` if it exists.

---

## License

MIT
