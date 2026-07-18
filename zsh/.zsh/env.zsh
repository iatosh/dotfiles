# ============================================================================
# Environment Variables, PATH, and Shell Options
# ============================================================================

# ----------------------------------------------------------------------------
# Environment Variables
# ----------------------------------------------------------------------------

# Editor
export EDITOR='nvim'
export VISUAL='nvim'

# Dotfiles location
export DOTFILES_PATH="$HOME/dotfiles"

# FZF configuration
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Homebrew
export HOMEBREW_BREWFILE="$DOTFILES_PATH/pkg/Brewfile"

# Bun
export BUN_INSTALL="$HOME/.bun"

# ----------------------------------------------------------------------------
# PATH Configuration
# ----------------------------------------------------------------------------

# Custom commands and local binaries
export PATH="$PATH:$HOME/.commands"
export PATH="$PATH:$HOME/.local/bin"

# macOS-specific paths
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Java (Homebrew)
    if [[ -d "/opt/homebrew/opt/openjdk/bin" ]]; then
        export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
        export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"
    fi
    # LLVM (Homebrew)
    [[ -n "$HOMEBREW_PREFIX" ]] && export PATH="$HOMEBREW_PREFIX/opt/llvm/bin:$PATH"
    # LaTeX
    export PATH="$PATH:/Library/TeX/texbin/"
fi

# Language tools
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="$PATH:$HOME/.lmstudio/bin"

# ----------------------------------------------------------------------------
# Shell Options
# ----------------------------------------------------------------------------

# Directory navigation
setopt AUTO_CD              # Change directory by typing directory name
setopt AUTO_PUSHD          # Make cd push the old directory onto the stack
setopt PUSHD_IGNORE_DUPS   # Don't push duplicates onto the stack
setopt CDABLE_VARS         # Expand variables in cd command

# Completion
setopt AUTO_PARAM_KEYS     # Automatically insert paired characters
setopt MARK_DIRS          # Add trailing slash to directories
setopt CORRECT            # Suggest corrections for misspelled commands
setopt CORRECT_ALL        # Suggest corrections for all arguments

# History
setopt SHARE_HISTORY       # Share history between all sessions
setopt HIST_REDUCE_BLANKS  # Remove superfluous blanks from history
setopt HIST_IGNORE_ALL_DUPS # Remove all duplicates from history
setopt HIST_IGNORE_SPACE   # Don't record commands starting with space
setopt HIST_VERIFY         # Show command with history expansion before running

# Display
setopt PRINT_EIGHT_BIT    # Display 8-bit characters properly
setopt PROMPT_SUBST       # Enable command substitution in prompt
setopt NO_BEEP           # Disable terminal beep

