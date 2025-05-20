# dotfiles

Mac OS向けにGNU Stowを使用して管理する個人設定ファイル集です。

## 概要

このリポジトリは以下のようなディレクトリ構造になっています：

- `bin/`: 実行可能スクリプト
- `zsh/`: Zsh設定
- `nvim/`: Neovim設定
- `brew/`: Brewfile
- `git/`: Git設定
- `karabiner/`: Karabiner-Elements設定
- `macos/`: macOS固有の設定

## 必要なツール

- [GNU Stow](https://www.gnu.org/software/stow/)
- [Homebrew](https://brew.sh/)
- [Gum](https://github.com/charmbracelet/gum)

## インストール方法

```bash
# リポジトリをクローン
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles

# インストールスクリプトを実行
cd ~/dotfiles
chmod +x install.sh
./install.sh
```

各種APIキーなどは`dotfiles/.secrets`に置いてください。
ファイル名やパスは`dotfiles/zsh/.zsh/env.zsh`の末尾にある下記の内容を編集することで変更可能です。
```
# API KEYS
SECRET_FILE="$DOTFILES_PATH/.secrets"
[[ -f "$SECRET_FILE" ]] && source "$SECRET_FILE"
```
