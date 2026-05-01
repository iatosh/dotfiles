# ============================================================================
# Plugin Management with Zinit
# ============================================================================

# ----------------------------------------------------------------------------
# Zinit Installation
# ----------------------------------------------------------------------------

if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

# Load Zinit
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# Enable Zinit completions
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# ----------------------------------------------------------------------------
# Theme - Load immediately for prompt
# ----------------------------------------------------------------------------

# Powerlevel10k
zinit ice depth=1
zinit light romkatv/powerlevel10k

# Load p10k configuration
[[ -f "$HOME/.config/p10k/.p10k.zsh" ]] && source "$HOME/.config/p10k/.p10k.zsh"

# ----------------------------------------------------------------------------
# Plugins - Turbo Mode for performance
# ----------------------------------------------------------------------------

# Zinit annexes
zinit wait lucid light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Syntax highlighting
zinit wait lucid atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    light-mode for zdharma-continuum/fast-syntax-highlighting

# Completions
zinit wait lucid blockf atpull'zinit creinstall -q .' \
    light-mode for zsh-users/zsh-completions

# Auto suggestions
zinit wait lucid atload"!_zsh_autosuggest_start" \
    light-mode for zsh-users/zsh-autosuggestions

# Additional utilities
zinit wait"1" lucid light-mode for \
    supercrabtree/k  # Better ls with git features
