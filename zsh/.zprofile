# Amazon Q pre block. Keep at the top of this file.
if [[ "$OSTYPE" == "darwin"* ]]; then
    [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
fi

# Homebrewのパスを通す
if [[ -f /opt/homebrew/bin/brew ]]; then
    HOMEBREW_PATH="/opt/homebrew"
elif [[ -f /usr/local/bin/brew ]]; then
    HOMEBREW_PATH="/usr/local"
elif [[ -f ~/.linuxbrew/bin/brew ]]; then
    HOMEBREW_PATH="$HOME/.linuxbrew"
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
    HOMEBREW_PATH="/home/linuxbrew/.linuxbrew"
else
    echo "Homebrew not found. Please install Homebrew first."
    exit 1
fi

eval "$("$HOMEBREW_PATH/bin/brew" shellenv)"

[ -s "$HOMEBREW_PATH/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PATH/opt/nvm/nvm.sh"  # This loads nvm
[ -s "$HOMEBREW_PATH/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PATH/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Amazon Q post block. Keep at the bottom of this file.
if [[ "$OSTYPE" == "darwin"* ]]; then
    [[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
fi