# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

A cross-platform dotfiles repository for macOS and Linux (including shared servers without root). Uses a bash-native symlink manager (no stow dependency), Homebrew for package management, and mise for rootless CLI tool installation on shared Linux servers.

## Common Commands

### Installation and Management
```bash
# Interactive installation (recommended)
./install.sh

# Update brew packages and auto-insert new ones into Brewfile
bin/utils/update-brew.sh
```

### Package Management
```bash
# Install all packages
brew bundle --file=brew/Brewfile

# Apply macOS system defaults
bin/macos/defaults.sh
```

## Architecture

### Symlink Strategy
- **No stow dependency**: `install.sh` uses a bash-native `symlink_package()` with `find + ln -sf`
- Top-level dirs (e.g. `zsh/`, `git/`) are symlinked targeting `$HOME`
- `config/<subdir>` packages target `$HOME/.config/<subdir>` individually
- Exclusions defined in `brew/install.conf` (`EXCLUDE_ALWAYS`, `EXCLUDE_LINUX`, `EXCLUDE_DARWIN`)

### Package Management Strategy
- **Single Brewfile** (`brew/Brewfile`) with `on_macos do` / `on_linux do` blocks
- **mise**: used on shared Linux servers (no root) — tools defined in `brew/install.conf` `MISE_TOOLS`
- `bin/utils/update-brew.sh`: auto-inserts `brew leaves` + casks into the correct OS block

### Key Directories
- `config/`: XDG-compliant configurations (symlinked to `~/.config`)
- `brew/`: Brewfile and install.conf
- `bin/`: Executable scripts and utilities
- `zsh/.zsh/`: Modularized Zsh configuration (aliases, env, functions, etc.)

### Configuration Modules
- **Zsh**: Zinit plugin manager + Powerlevel10k theme + modular config in `zsh/.zsh/`
- **Neovim**: Managed as Git submodule
- **Tmux**: Feature-rich setup with plugins in `config/tmux/plugins/`
- **Wezterm**: Modern terminal emulator with custom configuration
- **Git**: Global Git configuration and aliases

### Platform Support
- **Darwin (macOS)**: Full feature set including Karabiner-Elements, Aerospace
- **Linux private server**: Homebrew-based (same Brewfile, `on_linux` block)
- **Linux shared server**: mise-based, no root required

### Secret Management
Store sensitive data in `~/dotfiles/.secrets` (auto-sourced by `zsh/.zsh/env.zsh`).

## Git Commit Style

- Use emoji prefix (e.g. `✨`, `🔧`, `●`, `◆`) to match existing history
- **Do not add `Co-Authored-By` trailers**
- Keep messages concise and descriptive

## Notable Tools and CLIs
`bat` (cat), `eza` (ls), `fzf` (fuzzy finder), `ripgrep` (grep), `zoxide` (cd), `btop` (top), `fd` (find), `gum` (TUI), `mise` (runtime manager)
