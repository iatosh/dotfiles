# Dotfiles Collection

A curated set of personal configuration files ("dotfiles") for macOS and Linux, managed with GNU Stow and an installation script powered by [Gum](https://github.com/charmbracelet/gum).

---

## Prerequisites

You should have the following tools installed, though the installer will handle the rest:

- **Git** and **curl**: usually pre-installed on most systems.
- **Xcode Command Line Tools** (macOS only): provides `git`, `curl`, and other build utilities.
- **Development tools** (Linux only): GCC, Make, and other essentials (e.g., install `build-essential` on Debian/Ubuntu).

All other dependencies—including Homebrew, GNU Stow, and Gum—are automatically installed by the script.

---

## Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/iatosh/dotfiles.git $HOME/dotfiles
   ```

2. **Run the install script**

   ```bash
   cd ~/dotfiles
   chmod +x install.sh
   ./install.sh
   ```

This script uses GNU Stow to create symlinks from your home directory (`~`) and `~/.config` to the files in this repository.

---

## Configuration

### Secrets and API Keys

Store any private keys or environment variables in a separate file:

```bash
~/dotfiles/.secrets
```

The installation script automatically sources this file if it exists. To change its path, edit the following line in `zsh/.zsh/env.zsh`:

```bash
SECRET_FILE="$DOTFILES_PATH/.secrets"
[[ -f "$SECRET_FILE" ]] && source "$SECRET_FILE"
```

---

## Directory Structure

```text
brew/             # Homebrew bundles (Brewfile)
git/              # Git configuration
karabiner/        # Karabiner-Elements configuration
nvim/             # Neovim settings
p10k/             # Powerlevel10k theme for Zsh
theme/            # Terminal and editor color schemes
zsh/              # Zsh configuration and plugins
install.sh        # Installation script using Stow and Gum
```

---

## Updating & Maintenance

After pulling new changes, run:

```bash
cd ~/dotfiles
git pull
./install.sh
```

To remove all stowed configurations:

```bash
./install.sh --uninstall
```

---

## License

This repository is open-source under the MIT License. See the [LICENSE](LICENSE) file for details.
