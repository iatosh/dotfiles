# Amazon Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"

# Homebrewのパスを通す
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$('/opt/homebrew/bin/brew' shellenv)"
elif [[ -f /usr/local/bin/brew ]]; then
    eval "$('/usr/local/bin/brew' shellenv)"
elif [[ -f ~/.linuxbrew/bin/brew ]]; then
    eval "$(~/.linuxbrew/bin/brew shellenv)"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    eval "$('/home/linuxbrew/.linuxbrew/bin/brew' shellenv)"
fi

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
