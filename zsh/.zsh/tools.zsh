
# External Tool Integrations
# ============================================================================

# ----------------------------------------------------------------------------
# Essential Tools (Load Immediately)
# ----------------------------------------------------------------------------

# mise - Runtime manager
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
elif [[ -x "$HOME/.local/bin/mise" ]]; then
    eval "$($HOME/.local/bin/mise activate zsh)"
fi

# Zoxide - Smart cd command
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi

# FZF - Fuzzy finder
if command -v fzf &>/dev/null; then
    source <(fzf --zsh)
fi

# ----------------------------------------------------------------------------
# Development Tools
# ----------------------------------------------------------------------------

# NVM - Node Version Manager
if [ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]; then
    source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
fi

if [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ]; then
    source "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
fi

# Bun completions
if [[ -s "$HOME/.bun/_bun" ]]; then
    source "$HOME/.bun/_bun"
fi

# ----------------------------------------------------------------------------
# Package Management
# ----------------------------------------------------------------------------

# Brew wrap - Brewfile management
if command -v brew &>/dev/null && [ -f "$(brew --prefix)/etc/brew-wrap" ]; then
    source "$(brew --prefix)/etc/brew-wrap"

    _post_brewfile_update() {
        echo "Brewfile was updated!"
    }
fi

# ----------------------------------------------------------------------------
# Optional Tools
# ----------------------------------------------------------------------------

# ngrok completion
if command -v ngrok &>/dev/null; then
    eval "$(ngrok completion)"
fi

# Kiro terminal integration
if [[ "$TERM_PROGRAM" == "kiro" ]]; then
    source "$(kiro --locate-shell-integration-path zsh)"
fi

if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi
# ----------------------------------------------------------------------------
# Perl (if needed)
# ----------------------------------------------------------------------------

# Uncomment if using Perl with local::lib
# eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"
