#!/usr/bin/env bash
set -eo pipefail

DOTFILES="$HOME/dotfiles"
BREWFILE="$DOTFILES/brew/Brewfile"

# Detect which block to insert into based on OS
case "$(uname -s)" in
  Linux*)  BLOCK="on_linux"  ;;
  Darwin*) BLOCK="on_macos" ;;
  *) echo "Unsupported OS"; exit 1 ;;
esac

# Insert a brew/cask line before the `end` of the target block
insert_into_block() {
  local line=$1  # e.g. '  brew "foo"' or '  cask "bar"'
  local tmpfile
  tmpfile=$(mktemp)
  local in_block=0 inserted=0
  while IFS= read -r row; do
    if [[ "$row" =~ ^${BLOCK}\ do ]]; then
      in_block=1
    fi
    if [[ $in_block -eq 1 && "$row" == "end" && $inserted -eq 0 ]]; then
      echo "$line" >> "$tmpfile"
      inserted=1
    fi
    echo "$row" >> "$tmpfile"
  done < "$BREWFILE"
  mv "$tmpfile" "$BREWFILE"
}

added=0

echo "Checking brew leaves against Brewfile..."
while read -r pkg; do
  if ! grep -q "\"${pkg}\"" "$BREWFILE"; then
    insert_into_block "  brew \"${pkg}\""
    echo "  + brew \"${pkg}\" → ${BLOCK}"
    (( added++ )) || true
  fi
done < <(brew leaves)

echo "Checking casks..."
while read -r pkg; do
  if ! grep -q "\"${pkg}\"" "$BREWFILE"; then
    insert_into_block "  cask \"${pkg}\""
    echo "  + cask \"${pkg}\" → ${BLOCK}"
    (( added++ )) || true
  fi
done < <(brew list --cask 2>/dev/null)

if [[ $added -eq 0 ]]; then
  echo "Brewfile is up to date."
else
  echo ""
  echo "${added} package(s) added to ${BLOCK} block in Brewfile."
  echo "Move to the common section if needed on both platforms."
fi
