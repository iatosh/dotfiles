# ------------
# Plugins
# ------------

# Zinit (ZSHプラグインマネージャー)
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

# Zinitの読み込み
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"

# Zinitの自動補完
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Zinitのアネックス（拡張）
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

# Zinitで管理するパッケージ
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit load supercrabtree/k

# powerlevel10k
zinit ice depth=1; zinit light romkatv/powerlevel10k

# ------------

# p10k
[[ -f $HOME/.p10k.zsh ]] && source ~/.p10k.zsh

# Brewfile
if [ -f $(brew --prefix)/etc/brew-wrap ];then
  source $(brew --prefix)/etc/brew-wrap

  _post_brewfile_update () {
    echo "Brewfile was updated!"
  }
fi

# FZF
source <(fzf --zsh)

# thefuck
eval $(thefuck --alias fk)

# Zoxide
eval "$(zoxide init zsh)"

