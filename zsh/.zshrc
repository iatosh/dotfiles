# ============================================================================
# .zshrc - Main ZSH Configuration
# ============================================================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----------------------------------------------------------------------------
# Configuration Loading
# ----------------------------------------------------------------------------

# Keep PATH unique
typeset -U path PATH

# Set dotfiles path
DOTFILES_PATH=$HOME/dotfiles

# Load all configuration files
for config_file in $DOTFILES_PATH/zsh/.zsh/*.zsh(N); do
    source "$config_file"
done
