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

このインストールスクリプトは、以下のことを行います：

1. 必要な依存関係（Homebrew、GNU Stow、Gum）のインストール
2. 選択したパッケージの設定ファイルのシンボリックリンク作成
3. 必要に応じてBrewfileからのアプリケーションインストール
4. オプションでmacOSのデフォルト設定の適用

## 管理されているパッケージ

### Zsh

ターミナルシェルの設定

### Neovim

モダンなVimエディタの設定

### Git

バージョン管理システムの設定

### Karabiner-Elements

キーボードカスタマイズツールの設定

## 使用方法

### 特定のパッケージのみインストール

```bash
cd ~/dotfiles
stow --verbose --target="$HOME" zsh nvim git
```

### 特定のパッケージをアンインストール

```bash
cd ~/dotfiles
stow --verbose --target="$HOME" --delete zsh nvim git
```

### Brewfileの更新

```bash
cd ~/dotfiles
./bin/utils/update-brew.sh
```