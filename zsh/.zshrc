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

# Source API keys and private configurations
SECRET_FILE="$DOTFILES_PATH/.secrets"
[[ -f "$SECRET_FILE" ]] && source "$SECRET_FILE"

# Load all configuration files
for config_file in $DOTFILES_PATH/zsh/.zsh/*.zsh(N); do
    source "$config_file"
done

# Added by LM Studio CLI (lms)
if [[ -d "$HOME/.lmstudio/bin" ]]; then
    export PATH="$PATH:$HOME/.lmstudio/bin"
fi
# End of LM Studio CLI section

CLAUDE_MEM_WORKER="$HOME/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"
if [[ -f "$CLAUDE_MEM_WORKER" ]]; then
    alias claude-mem="bun \"$CLAUDE_MEM_WORKER\""
fi
unset CLAUDE_MEM_WORKER

# Added by Antigravity
if [[ -d "$HOME/.antigravity/antigravity/bin" ]]; then
    export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
fi

# bun completions
if [[ -s "$HOME/.bun/_bun" ]]; then
    source "$HOME/.bun/_bun"
fi

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
fpath=(~/.grok/completions/zsh $fpath)
autoload -Uz compinit && compinit -C
# <<< grok installer <<<
