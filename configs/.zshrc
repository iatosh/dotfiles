# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.pre.zsh"
# Q pre block. Keep at the top of this file.
typeset -U path PATH

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi
### End of Zinit's installer chunk

# Brewfile
if [ -f $(brew --prefix)/etc/brew-wrap ];then
  source $(brew --prefix)/etc/brew-wrap
fi

# ----------------------------------------------------------------
# source
# ----------------------------------------------------------------

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
source ~/.zsh/.git-prompt.sh
source <(fzf --zsh)
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# ----------------------------------------------------------------
# Zinit
# ----------------------------------------------------------------

autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust


# Packages
zinit light olets/zsh-abbr
zinit light zsh-users/zsh-syntax-highlighting
zinit light supercrabtree/k


# ----------------------------------------------------------------
# Terminal Settings
# ----------------------------------------------------------------

# bindkey -r '^I'

# Starship
# eval "$(starship init zsh)"
# export STARSHIP_CONFIG=~/.config/starship/pure-preset.toml

# Zoxide
eval "$(zoxide init zsh)"


setopt AUTO_CD # ディレクトリ名のみでcd
setopt AUTO_PUSHD # cdしたディレクトリをスタックに追加
setopt PUSHD_IGNORE_DUPS # スタックに同じディレクトリがある場合は追加しない
setopt AUTO_PARAM_KEYS # カッコなどを自動補完
setopt MARK_DIRS # ディレクトリに/を付ける
setopt CORRECT # 補完時に誤った入力を修正
setopt CORRECT_ALL # 補完時に誤った入力を全て修正
setopt SHARE_HISTORY # 複数のターミナルで履歴を共有
setopt HIST_REDUCE_BLANKS # 履歴に連続する空白を1つにする
setopt HIST_IGNORE_ALL_DUPS # 履歴に同じコマンドがある場合は追加しない
setopt PRINT_EIGHT_BIT # 8ビット文字を表示
setopt PROMPT_SUBST # プロンプトにコマンドの出力を埋め込む
setopt NO_BEEP # ベルを鳴らさない

## PROMPT customize
export CLICOLOR=1
export TERM=xterm-256color

export GREP_OPTIONS='--color=auto'
# export GREP_COLORS='ms=01;33:mc=:sl=01;32:01;32:fn=35:ln=32:bn=32:se=36'

## API key
export GROQ_KEY=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
export GROQ_BASE_URL=https://api.groq.dev/v1
export GOOGLE_API_KEY=AIzaSyA8lneUuFytbMUcqm-ZQ1IYcbJJ6SMBqTA
export HUGGINGFACE_API_KEY=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
export LANGSMITH_API_KEY="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"


# ----------------------------------------------------------------
# PATH
# ----------------------------------------------------------------

## C/C++
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

## Java
JAVA_HOME=/opt/homebrew/opt/openjdk
export PATH=$PATH:$JAVA_HOME/bin

## Emacs Path
export PATH="$HOME/.emacs.d/bin:$PATH"

## Path to Dotfiles
export DOTFILES_PATH=$HOME/dotfiles

# ----------------------------------------------------------------
# Alias
# ----------------------------------------------------------------

alias gcc="gcc-14"
alias g++="g++-14"
alias ls="eza --color=always --icons=always"
alias cd="z"

alias date="echo '2024年 7月27日 土曜日 10時45分22秒 JST'"

# thefuck
eval $(thefuck --alias fk)

# ----------------------------------------------------------------
# Others
# ----------------------------------------------------------------

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo $'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}


# ----------------------------------------------------------------

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniforge/base/bin/conda' 'shell.shzsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniforge/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniforge/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# bun completions
[ -s "/Users/atosh/.bun/_bun" ] && source "/Users/atosh/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/atosh/.cache/lm-studio/bin"

# Added by Windsurf
export PATH="/Users/atosh/.codeium/windsurf/bin:$PATH"


[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zshrc.post.zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
