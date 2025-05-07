#!/usr/bin/env bash
set -e

DOTFILES="$HOME/dotfiles"

# 色付き出力関数
print_header() {
  printf "\n\033[1;36m%s\033[0m\n\n" "$1"
}

print_info() {
  printf "\033[0;34m%s\033[0m\n" "$1"
}

print_success() {
  printf "\033[0;32m%s\033[0m\n" "$1"
}

print_warning() {
  printf "\033[0;33m%s\033[0m\n" "$1"
}

print_error() {
  printf "\033[0;31m%s\033[0m\n" "$1"
}

# 依存関係のインストール
install_dependencies() {
  print_header "Installing dependencies"

  # Homebrewのインストール
  if ! command -v brew >/dev/null 2>&1; then
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Homebrewのパスを通す
    if [[ -f /opt/homebrew/bin/brew ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f /usr/local/bin/brew ]]; then
      eval "$(/usr/local/bin/brew shellenv)"
    fi

    print_success "Homebrew installed successfully."
  else
    print_info "Homebrew is already installed."
  fi

  # stowのインストール
  if ! command -v stow >/dev/null 2>&1; then
    print_info "Installing GNU Stow..."
    brew install stow
    print_success "GNU Stow installed successfully."
  else
    print_info "GNU Stow is already installed."
  fi

  # gumのインストール
  if ! command -v gum >/dev/null 2>&1; then
    print_info "Installing Charmbracelet Gum..."
    brew install gum
    print_success "Charmbracelet Gum installed successfully."
  else
    print_info "Charmbracelet Gum is already installed."
  fi

  print_success "All dependencies are installed."
}

# Brewfileのインストール
install_brewfile() {
  gum style --foreground 212 "Installing applications from Brewfile..."

  if [[ -f "$DOTFILES/brew/Brewfile" ]]; then
    gum spin --spinner dot --title "Installing brew packages..." -- brew bundle --file="$DOTFILES/brew/Brewfile"
    gum style --foreground 46 "Brewfile installed successfully."
  else
    gum style --foreground 196 "Brewfile not found."
  fi
}

# macOSデフォルト設定の適用
apply_macos_defaults() {
  gum style --foreground 212 "Applying macOS default settings..."

  if [[ -f "$DOTFILES/macos/defaults.sh" ]]; then
    gum confirm "Do you want to apply macOS default settings? This may restart some applications." && {
      gum spin --spinner dot --title "Applying settings..." -- bash "$DOTFILES/macos/defaults.sh"
      gum style --foreground 46 "macOS settings applied successfully."
    }
  else
    gum style --foreground 196 "macOS defaults script not found."
  fi
}

# stowの実行
run_stow() {
  local action=$1
  shift
  local packages=("$@")

  # dotfilesディレクトリに移動
  cd "$DOTFILES"

  # 各パッケージを処理
  for package in "${packages[@]}"; do
    if [[ -d "$package" ]]; then
      gum style --foreground 212 "stow $action $package"
      gum spin --spinner dot --title "Processing $package..." -- stow --verbose --target="$HOME" "$action" "$package"
    else
      gum style --foreground 196 "Package directory not found: $package"
    fi
  done

  gum style --foreground 46 "All packages processed successfully!"
}

# すべてのパッケージを検出
detect_packages() {
  local exclude_dirs=("bin" "macos" "brew" ".git" "misc" "theme")
  local packages=()

  for dir in "$DOTFILES"/*/; do
    dir=$(basename "$dir")

    # 除外チェック
    local exclude=false
    for excluded in "${exclude_dirs[@]}"; do
      if [[ "$dir" == "$excluded" ]]; then
        exclude=true
        break
      fi
    done

    if [[ "$exclude" == "false" ]]; then
      packages+=("$dir")
    fi
  done

  echo "${packages[@]}"
}

# メイン処理
main() {
  print_header "Setting up dotfiles"

  # 依存関係のインストール
  install_dependencies

  # ウェルカムメッセージ
  gum style \
    --border normal \
    --margin "1" \
    --padding "1" \
    --border-foreground 212 \
    "Welcome to dotfiles installer"

  # インストールオプションの選択
  CHOICE=$(gum choose --height 15 \
    "Stow all packages" \
    "Stow specific packages" \
    "Install Brewfile" \
    "Apply macOS defaults" \
    "Full installation" \
    "Exit")

  case "$CHOICE" in
  "Stow all packages")
    # アクション選択
    ACTION=$(gum choose --height 10 "install/update (--restow)" "uninstall (--delete)")

    case "$ACTION" in
    "install/update (--restow)")
      ACTION="--restow"
      ;;
    "uninstall (--delete)")
      ACTION="--delete"
      ;;
    esac

    # パッケージ検出
    PACKAGES=($(detect_packages))

    # 検出されたパッケージを表示
    gum style --foreground 212 "Detected packages: $(gum style --foreground 220 "${PACKAGES[*]}")"

    # 確認
    gum confirm "Continue with stow $ACTION for these packages?" && run_stow "$ACTION" "${PACKAGES[@]}"
    ;;

  "Stow specific packages")
    # パッケージ検出
    PACKAGES=($(detect_packages))

    # パッケージを選択
    SELECTED=$(printf "%s\n" "${PACKAGES[@]}" | gum filter --placeholder "Select packages to stow (type to filter)")

    if [[ -n "$SELECTED" ]]; then
      # アクション選択
      ACTION=$(gum choose --height 10 "install/update (--restow)" "uninstall (--delete)")

      case "$ACTION" in
      "install/update (--restow)")
        ACTION="--restow"
        ;;
      "uninstall (--delete)")
        ACTION="--delete"
        ;;
      esac

      # 選択されたパッケージを処理
      run_stow "$ACTION" $SELECTED
    else
      gum style --foreground 220 "No packages selected."
    fi
    ;;

  "Install Brewfile")
    install_brewfile
    ;;

  "Apply macOS defaults")
    apply_macos_defaults
    ;;

  "Full installation")
    # Brewfileインストール
    install_brewfile

    # パッケージ検出
    PACKAGES=($(detect_packages))

    # パッケージをstow
    gum style --foreground 212 "Stowing all packages..."
    run_stow "--restow" "${PACKAGES[@]}"

    # macOSデフォルト設定を適用
    apply_macos_defaults
    ;;

  "Exit")
    gum style --foreground 212 "Exiting..."
    exit 0
    ;;
  esac

  gum style --foreground 46 "Dotfiles setup completed!"
}

# スクリプト実行
main
