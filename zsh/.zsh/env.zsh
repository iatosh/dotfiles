# ENV settings

# エディタ設定
export EDITOR='nvim'
export VISUAL='nvim'

## Path to Dotfiles
export DOTFILES_PATH=$HOME/dotfiles

# fzf
show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Default Brewfile Location
export HOMEBREW_BREWFILE="$DOTFILES_PATH/brew/Brewfile"

# API KEYS
SECRET_FILE="$DOTFILES_PATH/.secrets"
[[ -f "$SECRET_FILE" ]] && source "$SECRET_FILE"