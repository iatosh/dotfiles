#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"
BREWFILE="$DOTFILES/brew/Brewfile"

# ディレクトリが存在しない場合は作成
mkdir -p "$(dirname "$BREWFILE")"

# 現在のパッケージをBrewfileに書き出し
echo "Updating Brewfile..."
brew bundle dump --force --file="$BREWFILE"

# Gitリポジトリが変更されていれば通知
cd "$DOTFILES"
if ! git diff --quiet brew/Brewfile; then
  echo "Brewfile has been updated. Consider committing the changes."
else
  echo "No changes to Brewfile."
fi