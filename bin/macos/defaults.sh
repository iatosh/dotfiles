#!/bin/bash

defaults write com.apple.dock autohide-delay -int 0 # Dockの自動非表示の遅延を0に設定
defaults write com.apple.spaces spans-displays -bool true # ウィンドウをアプリケーションごとにグループ化

# AeroSpace関連
defaults write com.apple.dock expose-group-apps -bool true && killall Dock # アプリケーションごとにExposeをグループ化
defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer # 複数ディスプレイでのスペースを有効化

# Finderを再起動
killall Finder

# Dockを再起動
killall Dock

# システム環境設定を再起動
killall SystemUIServer