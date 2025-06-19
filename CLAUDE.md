# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive dotfiles repository for macOS and Linux development environments, managed with GNU Stow for symlink management and Gum for beautiful CLI interfaces. The configuration supports a full development stack including Zsh, Neovim, Tmux, Wezterm, and various CLI tools.

## Common Commands

### Installation and Management
```bash
# Interactive installation (recommended)
./install.sh

# Uninstall all configurations
./install.sh --uninstall

# Update after pulling changes
git pull && ./install.sh
```

### Package Management
```bash
# Install all Homebrew packages
brew bundle --file=brew/Brewfile

# Install OS-specific packages
brew bundle --file=brew/Brewfile.darwin    # macOS only
brew bundle --file=brew/Brewfile.linux     # Linux only

# Update brew packages
bin/utils/update-brew.sh
```

### macOS Configuration
```bash
# Apply macOS system defaults
bin/macos/defaults.sh
```

## Architecture

### Package Management Strategy
- **GNU Stow**: Creates symlinks from `~` and `~/.config` to repository files
- **Homebrew**: Cross-platform package management with OS-specific Brewfiles
- **Modular Configuration**: Each tool has its own directory that can be independently stowed

### Key Directories
- `config/`: XDG-compliant configurations (symlinked to `~/.config`)
- `brew/`: Homebrew bundle files for different platforms
- `bin/`: Executable scripts and utilities
- `zsh/.zsh/`: Modularized Zsh configuration (aliases, env, functions, etc.)

### Configuration Modules
- **Zsh**: Zinit plugin manager + Powerlevel10k theme + modular config in `zsh/.zsh/`
- **Neovim**: Managed as Git submodule based on Kickstart.nvim
- **Tmux**: Feature-rich setup with plugins in `config/tmux/plugins/`
- **Wezterm**: Modern terminal emulator with custom configuration
- **Git**: Global Git configuration and aliases

### Secret Management
Store sensitive data in `~/dotfiles/.secrets` (automatically sourced by `zsh/.zsh/env.zsh` if present).

### Platform Support
- **Darwin (macOS)**: Full feature set including Karabiner-Elements key remapping
- **Linux**: All features except macOS-specific tools (Karabiner excluded automatically)

### Current Git State
- Working branch: `darwin`
- Main branch: `main`
- Neovim config managed as submodule

## Development Workflow

When modifying configurations:
1. Test changes in the specific tool/application
2. Update the relevant configuration file in its module directory
3. Use `./install.sh` to re-stow if needed
4. Commit changes with descriptive messages following the existing emoji-prefixed format

## Notable Tools and CLIs
The repository configures modern CLI alternatives: `bat` (cat), `eza` (ls), `fzf` (fuzzy finder), `ripgrep` (grep), `zoxide` (cd), `btop` (top), and `fd` (find).