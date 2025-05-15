# ------------
# Plugins
# ------------

# Zinit (ZSH plugin manager)
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

# Load Zinit
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# Zinit's autocompletion
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Zinit's default annexes (extensions)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Custom plugins
zinit light-mode for \
    zsh-users/zsh-autosuggestions \
    zsh-users/zsh-syntax-highlighting \
    zsh-users/zsh-completions \
    supercrabtree/k

# powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# ------------


# Brewfile
if [ -f $(brew --prefix)/etc/brew-wrap ];then
  source $(brew --prefix)/etc/brew-wrap

  # Brewfileが更新されたら実行
  _post_brewfile_update () {
    echo "Brewfile was updated!"
  }
fi

# p10k
[[ -f $HOME/.p10k.zsh ]] && source ~/.p10k.zsh

# FZF
source <(fzf --zsh)

# thefuck
eval $(thefuck --alias fk)

# Zoxide
eval "$(zoxide init zsh)"
