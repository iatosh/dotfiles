# Q pre block. Keep at the top of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.pre.zsh"
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Nodebrew
export PATH=$HOME/.nodebrew/current/bin:$PATH

# For self made commands
export PATH=$PATH:$HOME/.commands

# For MATLAB
export PATH=$PATH:/Applications/MATLAB_R2024a.app/bin

# Q post block. Keep at the bottom of this file.
[[ -f "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh" ]] && builtin source "${HOME}/Library/Application Support/amazon-q/shell/zprofile.post.zsh"
