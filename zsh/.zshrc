# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# ------------
# Main zsh file
# ------------

# --- Amazon Q pre block. Keep at the top of this file.
if [[ "$OSTYPE" == "darwin"* ]]; then
  fi
# --- Amazon Q pre block. Keep at the top of this file.

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Keep path unique
typeset -U path PATH

DOTFILES_PATH=$HOME/dotfiles
# Load module-specific configuration files
for config_file ($DOTFILES_PATH/zsh/.zsh/*.zsh); do
  source $config_file
done

# --- Amazon Q post block. Keep at the bottom of this file.
if [[ "$OSTYPE" == "darwin"* ]]; then
  fi
# --- Amazon Q post block. Keep at the bottom of this file.

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"
