# ------------
# Path
# ------------

# C/C++
export PATH="$HOMEBREW_PREFIX/opt/llvm/bin:$PATH"

# Latex
if [[ "$OSTYPE" == "darwin"* ]]; then
    export PATH="$PATH:/Library/TeX/texbin/"
fi

# Perl
# eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"