# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.pre.zsh"

typeset -U path PATH

# ----------------------------------------------------------------
# Zinit
# ----------------------------------------------------------------

### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk


# ----------------------------------------------------------------
# Packages
# ----------------------------------------------------------------
zinit light olets/zsh-abbr
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light supercrabtree/k


# ----------------------------------------------------------------
# Basics
# ----------------------------------------------------------------

bindkey -r '^I'

eval "$(starship init zsh)"
# export STARSHIP_CONFIG=~/.config/pastel-powerline.toml


TMOUT=1
TRAPALRM() {
    if [ "$WIDGET" != "expand-or-complete" ]; then
        zle reset-prompt
    fi
}

# DIRSTACKSIZE=100

setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt SHARE_HISTORY
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_ALL_DUPS
setopt PRINT_EIGHT_BIT
setopt PROMPT_SUBST
setopt NO_BEEP

source ~/.zsh/.git-prompt.sh

## zsh settings
# source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
# source /opt/homebrew/share/zsh-completions


## PROMPT customize
# PROMPT='%F{#ff6699}%B%~%b%f
# %F{#efa585}%#%f '
# PROMPT='%F{#D77DE5}%(5~,%-2~/.../%2~,%~)%f %F{#00ffff}❯%f '
# RPROMPT="%F{red}$(__git_ps1 "[%s]" )%f %F{white} %D{%H:%M} %f"
export CLICOLOR=1
export TERM=xterm-256color


# ----------------------------------------------------------------
# PATH
# ----------------------------------------------------------------

## C/C++
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
# LDFLAGS="-L/opt/homebrew/opt/llvm/lib/c++ -Wl,-rpath,/opt/homebrew/opt/llvm/lib/c++"
# export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
# export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

## Java
JAVA_HOME=/opt/homebrew/opt/openjdk
export PATH=$PATH:$JAVA_HOME/bin
# export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

## Emacs Path
export PATH="$HOME/.emacs.d/bin:$PATH"


# ----------------------------------------------------------------
# alias 
# ----------------------------------------------------------------

## Homebrew
alias br="brew update && brew outdated && brew upgrade && brew cleanup && brew"

## Python
alias python="python3"

## C/C++
alias gcc="gcc-12"
alias g++="g++-12"

## Emacs
alias E="emacs -nw"
alias em="open -a Emacs.app"
## Others
alias wget="wget --user-agent=\"Mozilla/5.0 (iPhone; CPU iPhone OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.5\""
alias la="ls -a"
alias ka="k -a"
alias latex-tree="/usr/local/texlive/texmf-local/tex/latex/tree"
alias mecabn="mecab -d /opt/homebrew/lib/mecab/dic/mecab-ipadic-neologd"
alias git-heroku="git add . && git commit -m \"update\" && git push heroku main" # git-heroku push
alias cdd='cd ..' # 親ディレクトリに移動
alias cds='dirs -v; echo -n "select number: "; read newdir; cd +"$newdir"' 

# ------------------------------------------------------------------
# conda initialize
# ------------------------------------------------------------------

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


# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zshrc.post.zsh" ]] && builtin source "$HOME/.fig/shell/zshrc.post.zsh"
