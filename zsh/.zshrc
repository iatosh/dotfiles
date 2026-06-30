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

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/atosh/.lmstudio/bin"
# End of LM Studio CLI section


alias claude-mem='bun "/Users/atosh/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'

# Added by Antigravity
export PATH="/Users/atosh/.antigravity/antigravity/bin:$PATH"


# bun completions
[ -s "/Users/atosh/.bun/_bun" ] && source "/Users/atosh/.bun/_bun"
