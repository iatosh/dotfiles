# ============================================================================
# Custom Functions
# ============================================================================

# ----------------------------------------------------------------------------
# File and Directory Operations
# ----------------------------------------------------------------------------

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar e "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)          echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ----------------------------------------------------------------------------
# FZF Custom Functions
# ----------------------------------------------------------------------------

# FZF completion configuration
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

# Pick a directory via fzf: subdirectories of $1 (default cwd) + zoxide history
# Displays paths with $HOME shortened to ~, but returns the real absolute path
_fcd_pick() {
    { command -v zoxide &>/dev/null && zoxide query -l
      find "${1:-$PWD}" -type d -name ".git" -prune -o -type d -print 2> /dev/null ; } |
    awk -v home="$HOME" '!seen[$0]++ {
        disp = $0
        if (disp == home || index(disp, home "/") == 1) disp = "~" substr(disp, length(home) + 1)
        print disp "\t" $0
    }' |
    fzf +m --delimiter='\t' --with-nth=1 --preview 'eza --tree --color=always {2} | head -200' |
    cut -f2
}

# Jump to a directory via zoxide's z (falls back to cd if zoxide isn't installed)
_fcd_jump() {
    if command -v zoxide &>/dev/null; then z "$1"; else cd "$1"; fi
}

# Find and cd to directory (also searches zoxide history); also bound to Ctrl+G as a zle widget
fcd() {
    local dir
    dir=$(_fcd_pick "$1") && _fcd_jump "$dir"
    if [[ -n $WIDGET ]]; then
        # Powerlevel10k only recomputes prompt segments in precmd, so a plain
        # `zle reset-prompt` redraws the stale pre-cd prompt; re-run precmd first.
        local fn
        for fn in $precmd_functions; do "$fn"; done
        zle reset-prompt
    fi
}
zle -N fcd
bindkey '^G' fcd

# Find file and open in editor
fe() {
    local files
    IFS=$'\n' files=($(fzf --query="$1" --multi --select-1 --exit-0))
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# ----------------------------------------------------------------------------
# Git Functions
# ----------------------------------------------------------------------------

# Git branch selector with fzf
fbr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
    branch=$(echo "$branches" | fzf -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
    git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Git commit browser with fzf
fshow() {
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort \
        --bind "ctrl-m:execute:
            (grep -o '[a-f0-9]\{7\}' | head -1 |
            xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
            {}
FZF-EOF"
}

# ----------------------------------------------------------------------------
# System Information
# ----------------------------------------------------------------------------

# Show system information
sysinfo() {
    echo "System Information:"
    echo "==================="
    echo "Hostname: $(hostname)"
    echo "OS: $(uname -s)"
    echo "Kernel: $(uname -r)"
    echo "Architecture: $(uname -m)"
    echo "CPU: $(sysctl -n machdep.cpu.brand_string 2>/dev/null || lscpu | grep 'Model name' | cut -d':' -f2 | xargs)"
    echo "Memory: $(free -h 2>/dev/null || vm_stat | grep 'Pages free' | awk '{print $3}')"
    echo "Uptime: $(uptime)"
}

# ----------------------------------------------------------------------------
# Development Helpers
# ----------------------------------------------------------------------------

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    python3 -m http.server "$port"
}


# SSH and attach to Tmux
sst() {
    # 引数チェック
    if [[ -z "$1" ]]; then
        echo "Usage: sst <host>"
        return 1
    fi

    local host="$1"

    # tmuxセッション一覧を取得
    local sessions=$(ssh "$host" 'zsh -l -c "tmux ls 2>/dev/null"')

    # 選択肢を作成（新規セッション作成オプションを追加）
    local options="[Create New Session]"
    if [[ -n "$sessions" ]]; then
        options="$options\n$sessions"
    fi

    # fzfで選択
    local selected=$(echo -e "$options" | fzf \
        --prompt="Select tmux session on $host > " \
        --height=50% \
        --layout=reverse \
        --border \
        --header="Enter: attach | Ctrl-C: cancel")

    # 選択されなかった場合
    if [[ -z "$selected" ]]; then
        return
    fi

    # 新規セッション作成を選択した場合
    if [[ "$selected" == "[Create New Session]" ]]; then
        echo -n "Enter new session name: "
        read session_name
        if [[ -n "$session_name" ]]; then
            ssh "$host" -t "zsh -l -c \"tmux new -s '$session_name'\""
        else
            ssh "$host" -t 'zsh -l -c "tmux"'
        fi
    else
        # セッション名を抽出
        local session_name=$(echo "$selected" | cut -d':' -f1)
        echo "Attaching to session: $session_name on $host"
        ssh "$host" -t "zsh -l -c \"tmux a -t '$session_name'\""
    fi
}

if [[ "$OSTYPE" == "darwin"* ]]; then
  # SSH to kodama with tailscale-aware host selection
  sk() {
    # Tailscaleの出力から100.で始まるIPアドレスがあるかチェック（接続中の証拠）
    if tailscale status 2>/dev/null | grep -q "100\."; then
    else
      echo "Starting Tailscale..."
      tailscale up
    fi
    sst kodama
  }
fi

# --- for agmsg ---
codex() {
  OPENAI_BASE_URL=$KODAMA_ENDPOINT \
  OPENAI_API_KEY=$KODAMA_KEY \
  OPENAI_MODEL_NAME="qwen3.6-27b" \
  $HOME/.agents/skills/agmsg/scripts/drivers/types/codex/codex-shim.sh "$@"
}

ccl() {
  ANTHROPIC_BASE_URL=$KODAMA_ENDPOINT \
  ANTHROPIC_AUTH_TOKEN=$KODAMA_KEY \
  ANTHROPIC_MODEL="qwen3.6-27b" \
  ANTHROPIC_DEFAULT_HAIKU_MODEL="qwen3.6-35b" \
  ANTHROPIC_SMALL_FAST_MODEL="qwen3.6-35b" \
  CLAUDE_CODE_ATTRIBUTION_HEADER=0 \
  CLAUDE_CODE_ENABLE_TELEMETRY=0 \
  CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY=1 \
  claude
}
