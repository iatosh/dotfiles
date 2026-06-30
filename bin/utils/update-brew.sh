#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"
BREWFILE="$DOTFILES/brew/Brewfile"

echo "Checking for packages not listed in Brewfile..."
echo "(Uses 'brew leaves' to show only top-level packages, excluding transitive deps)"
echo ""

echo "=== brew packages not in Brewfile ==="
brew leaves | while read -r pkg; do
  if ! grep -q "\"${pkg}\"" "$BREWFILE"; then
    echo "  MISSING: $pkg"
  fi
done

echo ""
echo "=== casks not in Brewfile ==="
brew list --cask 2>/dev/null | while read -r pkg; do
  if ! grep -q "\"${pkg}\"" "$BREWFILE"; then
    echo "  MISSING: $pkg"
  fi
done

echo ""
echo "Review the above and manually add intentional packages to:"
echo "  $BREWFILE"
