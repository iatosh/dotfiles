# ------------
# Path
# ------------

# C/C++
export PATH="$HOMEBREW_PREFIX/opt/llvm/bin:$PATH"

# Latex
if [[ "$OSTYPE" == "darwin"* ]]; then
    export PATH="$PATH:/Library/TeX/texbin/"
fi

# Create NVM directory if it doesn't exist
[ -d "$HOME/.nvm" ] || mkdir -p "$HOME/.nvm"
export NVM_DIR="$HOME/.nvm"

# Perl
# eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"

# Bun
# Bun setup based on OS
export BUN_INSTALL="$HOME/.bun"
if [[ "$OSTYPE" == "darwin"* ]]; then
    export PATH="$BUN_INSTALL/bin:$PATH"
else
    [ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"
fi
