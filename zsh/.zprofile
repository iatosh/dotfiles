# ============================================================================
# .zprofile - Login Shell Configuration
# ============================================================================

# ----------------------------------------------------------------------------
# Homebrew Initialization
# ----------------------------------------------------------------------------

# Detect Homebrew installation (cross-platform support)
if [[ -f /opt/homebrew/bin/brew ]]; then
    # Apple Silicon Mac
    HOMEBREW_PATH="/opt/homebrew"
elif [[ -f /usr/local/bin/brew ]]; then
    # Intel Mac
    HOMEBREW_PATH="/usr/local"
elif [[ -f ~/.linuxbrew/bin/brew ]]; then
    # Linux (user installation)
    HOMEBREW_PATH="$HOME/.linuxbrew"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    # Linux (system installation)
    HOMEBREW_PATH="/home/linuxbrew/.linuxbrew"
else
    echo "Warning: Homebrew not found"
fi

# Initialize Homebrew if found
if [[ -n "$HOMEBREW_PATH" ]]; then
    eval "$("$HOMEBREW_PATH/bin/brew" shellenv)"
fi

# Added by Obsidian
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
