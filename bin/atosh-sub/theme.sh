#!/bin/bash

THEME_NAMES=(
  "Tokyo Night"
  "Catppuccin"
  "Nord"
  "Everforest"
  "Gruvbox"
  "Kanagawa"
  "Rose Pine")
THEME=$(gum choose "${THEME_NAMES[@]}" "<< Back" --header "Choose your theme" --height 10 | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')

if [ -n "$THEME" ] && [ "$THEME" != "<<-back" ]; then
  cp $DOTFILES_PATH/themes/$THEME/alacritty.toml ~/.config/alacritty/theme.toml
  # cp $DOTFILES_PATH/themes/$THEME/zellij.kdl ~/.config/zellij/themes/$THEME.kdl
  # sed -i "s/theme \".*\"/theme \"$THEME\"/g" ~/.config/zellij/config.kdl
  cp $DOTFILES_PATH/themes/$THEME/neovim.lua ~/.config/nvim/lua/plugins/theme.lua
fi
