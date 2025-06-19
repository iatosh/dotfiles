#!/usr/bin/env bash
set -e

# 定数定義
DOTFILES="${HOME}/dotfiles"
EXCLUDE_DIRS=("bin" "macos" "brew" ".git" "theme" "misc" "config")
BREW_PATHS=(
	"/opt/homebrew/bin/brew"
	"/usr/local/bin/brew"
	"${HOME}/.linuxbrew/bin/brew"
	"/home/linuxbrew/.linuxbrew/bin/brew"
)

# OS判定
case "$(uname -s)" in
Linux*) OS="Linux" ;;
Darwin*) OS="Mac" ;;
*) OS="UNKNOWN:$(uname -s)" ;;
esac

if [[ ${OS} == "Linux" ]]; then
	EXCLUDE_DIRS+=("karabiner")
fi

# 色付き出力関数
print_header() { printf "\n\033[1;36m%s\033[0m\n\n" "$1"; }
print_info() { printf "\033[0;34m%s\033[0m\n" "$1"; }
print_success() { printf "\033[0;32m%s\033[0m\n" "$1"; }
print_warning() { printf "\033[0;33m%s\033[0m\n" "$1"; }
print_error() { printf "\033[0;31m%s\033[0m\n" "$1"; }

# Homebrewのパス設定
setup_brew_path() {
	for brew_path in "${BREW_PATHS[@]}"; do
		if [[ -f "${brew_path}" ]]; then
			eval "$("${brew_path}" shellenv)"
			return 0
		fi
	done
	return 1
}

# 依存関係のインストール
install_dependencies() {
	print_header "Installing dependencies"

	# Homebrewのインストール
	if ! command -v brew >/dev/null 2>&1; then
		print_info "Installing Homebrew..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
		setup_brew_path
		print_success "Homebrew installed successfully."
	else
		print_info "Homebrew is already installed."
	fi

	# 必要なパッケージのインストール
	local packages=("stow" "gum")
	local package_names=("GNU Stow" "Charmbracelet Gum")

	for i in "${!packages[@]}"; do
		if ! command -v "${packages[$i]}" >/dev/null 2>&1; then
			print_info "Installing ${package_names[$i]}..."
			brew install "${packages[$i]}"
			print_success "${package_names[$i]} installed successfully."
		else
			print_info "${package_names[$i]} is already installed."
		fi
	done

	print_success "All dependencies are installed."
}

# Brewfileのインストール
install_brewfile() {
	gum style --foreground 212 "Installing applications from Brewfile..."
	local brewfile="${DOTFILES}/brew/Brewfile"

	if [[ -f "${brewfile}" ]]; then
		gum spin --spinner dot --title "Installing brew packages..." -- brew bundle --file="${brewfile}"
		gum style --foreground 46 "Brewfile installed successfully."
	else
		gum style --foreground 196 "Brewfile not found."
	fi
}

# macOSデフォルト設定の適用
apply_macos_defaults() {
	if [[ ${OS} != "Mac" ]]; then
		gum style --foreground 220 "macOS defaults skipped (not macOS)."
		return
	fi

	local defaults_script="${DOTFILES}/bin/macos/defaults.sh"
	gum style --foreground 212 "Applying macOS default settings..."

	if [[ -f "${defaults_script}" ]]; then
		gum confirm "Do you want to apply macOS default settings? This may restart some applications." && {
			gum spin --spinner dot --title "Applying settings..." -- bash "${defaults_script}"
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

	cd "${DOTFILES}" || exit 1

	for package in "${packages[@]}"; do
		if [[ -d ${package} ]]; then
			gum style --foreground 212 "stow ${action} ${package}"
			gum spin --spinner dot --title "Processing ${package}..." -- stow --verbose --target="${HOME}" "${action}" "${package}"
		else
			gum style --foreground 196 "Package directory not found: ${package}"
		fi
	done

	gum style --foreground 46 "All packages processed successfully!"
}

# config stowの実行
run_config_stow() {
	local action=$1
	
	if [[ ! -d "${DOTFILES}/config" ]]; then
		gum style --foreground 196 "Config directory not found."
		return 1
	fi
	
	# config内のパッケージを検出して表示
	local config_packages=()
	local dir
	for dir in "$DOTFILES/config"/*/; do
		[[ -d "$dir" ]] && config_packages+=("$(basename "$dir")")
	done
	
	if [[ ${#config_packages[@]} -eq 0 ]]; then
		gum style --foreground 196 "No config packages found."
		return 1
	fi
	
	gum style --foreground 212 "Detected config packages: $(gum style --foreground 220 "${config_packages[*]}")"
	
	cd "${DOTFILES}" || exit 1
	
	gum style --foreground 212 "stow ${action} config (target: ~/.config)"
	gum spin --spinner dot --title "Processing config packages..." -- stow --verbose --target="${HOME}/.config" "${action}" config
	
	gum style --foreground 46 "Config packages processed successfully!"
}

# パッケージ検出
detect_packages() {
	local packages=()
	local dir

	# 通常のパッケージを検出
	for dir in "$DOTFILES"/*/; do
		dir=$(basename "$dir")
		[[ " ${EXCLUDE_DIRS[*]} " =~ ${dir} ]] || packages+=("$dir")
	done

	echo "${packages[@]}"
}

# アクション選択
select_stow_action() {
	local action
	action=$(gum choose --height 10 "install/update (--restow)" "uninstall (--delete)")
	case "$action" in
	"install/update (--restow)") echo "--restow" ;;
	"uninstall (--delete)") echo "--delete" ;;
	esac
}

# メイン処理
main() {
	print_header "Setting up dotfiles"
	install_dependencies

	gum style \
		--border normal \
		--margin "1" \
		--padding "1" \
		--border-foreground 212 \
		"Welcome to dotfiles installer"

	local choice
	choice=$(gum choose --height 15 \
		"Stow all packages" \
		"Install Brewfile" \
		"Apply macOS defaults" \
		"Full installation" \
		"Exit")

	case "$choice" in
	"Stow all packages")
		local action
		action=$(select_stow_action)
		read -r -a packages <<<"$(detect_packages)"
		gum style --foreground 212 "Detected packages: $(gum style --foreground 220 "${packages[*]}")"
		gum confirm "Continue with stow $action for these packages?" && {
			run_stow "$action" "${packages[@]}"
			run_config_stow "$action"
		}
		;;

	"Install Brewfile")
		install_brewfile
		;;

	"Apply macOS defaults")
		apply_macos_defaults
		;;

	"Full installation")
		install_brewfile
		read -r -a packages <<<"$(detect_packages)"
		gum style --foreground 212 "Stowing all packages..."
		run_stow "--restow" "${packages[@]}"
		run_config_stow "--restow"
		apply_macos_defaults
		;;

	"Exit")
		gum style --foreground 212 "Exiting..."
		exit 0
		;;
	esac

	gum style --foreground 46 "Dotfiles setup completed!"
}

main
