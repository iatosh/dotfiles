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

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOMEBREW_PREFIX/Caskroom/miniforge/base/bin/conda" 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOMEBREW_PREFIX/Caskroom/miniforge/base/etc/profile.d/conda.sh" ]; then
        . "$HOMEBREW_PREFIX/Caskroom/miniforge/base/etc/profile.d/conda.sh"
    else
        export PATH="$HOMEBREW_PREFIX/Caskroom/miniforge/base/bin:$PATH"
    fi
fi
unset __conda_setup

if [ -f "$HOMEBREW_PREFIX/Caskroom/miniforge/base/etc/profile.d/mamba.sh" ]; then
    . "$HOMEBREW_PREFIX/Caskroom/miniforge/base/etc/profile.d/mamba.sh"
fi
# <<< conda initialize <<<

# Amazon Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
