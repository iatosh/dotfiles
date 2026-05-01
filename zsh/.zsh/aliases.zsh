
# Command Aliases
# ============================================================================

# ----------------------------------------------------------------------------
# File and Directory Operations
# ----------------------------------------------------------------------------

# ls with eza (modern replacement for ls)
alias ls='eza --color=always --icons=always'
alias ll='eza -la --git'
alias la='eza -al'
alias lt='eza -T --level=2'
alias l='eza -F'

# Directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias -- -='cd -'

# File operations with confirmation
alias cp='cp -iv'
alias mv='mv -iv'
alias rm='rm -iv'
alias mkdir='mkdir -pv'

# ----------------------------------------------------------------------------
# Git
# ----------------------------------------------------------------------------

alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -v'
alias gc!='git commit -v --amend'
alias gcl='git clone'
alias gco='git checkout'
alias gst='git status'
alias gl='git pull'
alias gp='git push'
alias gd='git diff'
alias gb='git branch'
alias grb='git rebase'
alias gm='git merge'
alias glog='git log --oneline --decorate --graph'

# ----------------------------------------------------------------------------
# Development Tools
# ----------------------------------------------------------------------------

# Editor
alias v='nvim'
alias vi='nvim'
alias nv='nvim'

# Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
alias dex='docker exec -it'

# Homebrew
alias bu='brew update && brew upgrade'
alias bi='brew install'
alias bs='brew search'
alias bf='brew info'

alias tailscale='/Applications/Tailscale.app/Contents/MacOS/Tailscale'

# ----------------------------------------------------------------------------
# System Utilities
# ----------------------------------------------------------------------------

# Terminal
alias c='clear'
alias h='history'
alias j='jobs -l'
alias reload='exec $SHELL -l'

# Grep with color
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
 
# Network
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# ----------------------------------------------------------------------------
# macOS Specific
# ----------------------------------------------------------------------------

if [[ "$OSTYPE" == "darwin"* ]]; then
    alias showfiles="defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder"
    alias hidefiles="defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder"
    alias cleanup="find . -type f -name '*.DS_Store' -ls -delete"
fi

# ----------------------------------------------------------------------------
# Quick Access
# ----------------------------------------------------------------------------

# Dotfiles management
alias dotfiles='cd $DOTFILES_PATH'
alias dots='cd $DOTFILES_PATH'

# SSH and attach to TMUX
# alias sr='sst kodama.remote'
# alias sl='sst kodama.local'
