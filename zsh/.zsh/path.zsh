# ------------
# Path
# ------------

# C/C++
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# Latex
export PATH="$PATH:/Library/TeX/texbin/"

# Perl
eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"