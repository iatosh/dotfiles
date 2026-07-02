#!/usr/bin/env bash
set -eo pipefail

DOTFILES="${HOME}/dotfiles"
CONF="${DOTFILES}/pkg/install.conf"

# ─── Plain output (used before gum is available) ──────────────────────────────

_info()    { printf "  \033[0;34m▸\033[0m %s\n" "$1"; }
_success() { printf "  \033[0;32m✓\033[0m %s\n" "$1"; }
_err()     { printf "  \033[0;31m✗\033[0m %s\n" "$1"; }
_header()  { printf "\n\033[1;36m  ══ %s ══\033[0m\n\n" "$1"; }

# ─── Load config ──────────────────────────────────────────────────────────────

[[ -f "$CONF" ]] || { _err "install.conf not found: $CONF"; exit 1; }
# shellcheck source=pkg/install.conf
source "$CONF"

# ─── OS detection ─────────────────────────────────────────────────────────────

OS=""
case "$(uname -s)" in
  Linux*)  OS="linux"  ;;
  Darwin*) OS="darwin" ;;
  *)       _err "Unsupported OS: $(uname -s)"; exit 1 ;;
esac

ENV_TYPE=""  # linux only: "shared" | "private"

# ─── Bootstrap gum ────────────────────────────────────────────────────────────

bootstrap_gum() {
  # Bash doesn't load shell profiles, so prepend common bin locations first
  for _p in "/opt/homebrew/bin" "/usr/local/bin" "${HOME}/.local/bin"; do
    [[ -d "$_p" && ":${PATH}:" != *":${_p}:"* ]] && PATH="${_p}:${PATH}"
  done
  export PATH

  if command -v gum >/dev/null 2>&1; then
    _success "gum found."
    return 0
  fi

  _info "Downloading gum..."
  local install_dir="${HOME}/.local/bin"
  mkdir -p "$install_dir"

  local gum_os gum_arch
  case "$OS" in
    linux)  gum_os="Linux"  ;;
    darwin) gum_os="Darwin" ;;
  esac
  case "$(uname -m)" in
    x86_64)        gum_arch="x86_64" ;;
    aarch64|arm64) gum_arch="arm64"  ;;
    *) _err "Unsupported arch: $(uname -m)"; exit 1 ;;
  esac

  local version
  version=$(curl -sI "https://github.com/charmbracelet/gum/releases/latest" \
    | grep -i "^location:" | grep -oE "v[0-9]+\.[0-9]+\.[0-9]+" | head -1)
  [[ -z "$version" ]] && { _err "Could not detect gum version."; exit 1; }

  local fname="gum_${version#v}_${gum_os}_${gum_arch}.tar.gz"
  local url="https://github.com/charmbracelet/gum/releases/download/${version}/${fname}"
  local tmpdir
  tmpdir=$(mktemp -d)
  trap '[[ -n "${tmpdir}" && "${tmpdir}" == /tmp/* ]] && rm -rf "${tmpdir}"' EXIT

  curl -sL "$url" -o "${tmpdir}/${fname}" || { _err "Failed to download gum."; exit 1; }
  tar -xzf "${tmpdir}/${fname}" -C "$tmpdir" || { _err "Failed to extract gum."; exit 1; }
  local gum_bin
  gum_bin=$(find "$tmpdir" -type f -name "gum" | head -1)
  [[ -z "$gum_bin" ]] && { _err "gum binary not found after extraction."; exit 1; }
  mv "$gum_bin" "${install_dir}/gum"
  chmod +x "${install_dir}/gum"
  trap - EXIT
  rm -rf "$tmpdir"

  export PATH="${install_dir}:${PATH}"
  _success "gum installed to ${install_dir}/gum"
}

# ─── Symlink (bash-native, no stow dependency) ────────────────────────────────

symlink_package() {
  local action=$1
  local pkg=$2

  if [[ "$pkg" == config/* ]]; then
    local subname="${pkg#config/}"
    local src="${DOTFILES}/config/${subname}"
    local dst="${HOME}/.config/${subname}"

    if [[ ! -d "$src" ]]; then
      gum style --foreground 196 "  ✗ Not found: ${pkg}"
      return 1
    fi
    mkdir -p "${HOME}/.config"
    case "$action" in
      --restow)
        if [[ -d "$dst" && ! -L "$dst" ]]; then
          gum style --foreground 220 "  ⚠ Real dir exists, skipping: ${dst}"
          return
        fi
        ln -sfn "$src" "$dst"
        gum style --foreground 46 "  ✓ ${pkg}"
        ;;
      --delete)
        [[ -L "$dst" ]] && rm "$dst"
        gum style --foreground 46 "  ✓ removed ${pkg}"
        ;;
    esac

  else
    local pkg_dir="${DOTFILES}/${pkg}"
    if [[ ! -d "$pkg_dir" ]]; then
      gum style --foreground 196 "  ✗ Not found: ${pkg}"
      return 1
    fi
    local count=0
    while IFS= read -r src; do
      local name
      name=$(basename "$src")
      local dst="${HOME}/${name}"
      case "$action" in
        --restow)
          if [[ -d "$dst" && ! -L "$dst" ]]; then
            gum style --foreground 220 "  ⚠ Real dir exists, skipping: ${dst}"
            continue
          fi
          ln -sfn "$src" "$dst"
          ;;
        --delete)
          [[ -L "$dst" ]] && rm "$dst"
          ;;
      esac
      (( count++ )) || true
    done < <(find "$pkg_dir" -mindepth 1 -maxdepth 1 \
      -not -name ".git" \
      -not -name "README*" -not -name "*.md" -not -name ".DS_Store")
    gum style --foreground 46 "  ✓ ${pkg} (${count} items)"
  fi
}

# ─── Package detection ────────────────────────────────────────────────────────

detect_packages() {
  local exclude=("${EXCLUDE_ALWAYS[@]}")
  [[ "$OS" == "linux"  ]] && [[ ${#EXCLUDE_LINUX[@]}  -gt 0 ]] && exclude+=("${EXCLUDE_LINUX[@]}")
  [[ "$OS" == "darwin" ]] && [[ ${#EXCLUDE_DARWIN[@]} -gt 0 ]] && exclude+=("${EXCLUDE_DARWIN[@]}")

  is_excluded() {
    local name=$1
    for ex in "${exclude[@]}"; do
      [[ "$name" == "$ex" ]] && return 0
    done
    return 1
  }

  # Top-level packages (config/ handled separately below)
  for dir in "${DOTFILES}"/*/; do
    [[ -d "$dir" ]] || continue
    local name
    name=$(basename "$dir")
    [[ "$name" == "config" ]] && continue
    is_excluded "$name" || printf '%s\n' "$name"
  done

  # config/ subdirectories as individual packages
  for dir in "${DOTFILES}/config"/*/; do
    [[ -d "$dir" ]] || continue
    local subname
    subname=$(basename "$dir")
    is_excluded "$subname" || printf 'config/%s\n' "$subname"
  done
}

# ─── Brew setup ───────────────────────────────────────────────────────────────

setup_brew() {
  if command -v brew >/dev/null 2>&1; then
    _success "Homebrew is already installed."
    return 0
  fi

  _info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  local brew_paths=(
    "/opt/homebrew/bin/brew"
    "${HOME}/.linuxbrew/bin/brew"
    "/home/linuxbrew/.linuxbrew/bin/brew"
    "/usr/local/bin/brew"
  )
  local found=0
  for p in "${brew_paths[@]}"; do
    if [[ -f "$p" ]]; then
      eval "$("$p" shellenv)"
      found=1
      break
    fi
  done
  [[ $found -eq 0 ]] && { _err "Homebrew installed but could not locate brew binary."; exit 1; }
}

# ─── mise setup ───────────────────────────────────────────────────────────────

setup_mise() {
  if command -v mise >/dev/null 2>&1; then
    _success "mise is already installed."
    return 0
  fi
  _info "Downloading mise..."
  local install_dir="${HOME}/.local/bin"
  mkdir -p "$install_dir"
  curl -sL https://mise.run | MISE_INSTALL_PATH="${install_dir}/mise" sh
  export PATH="${install_dir}:${PATH}"
  _success "mise installed to ${install_dir}/mise"
}

install_mise_tools() {
  setup_mise
  gum style --foreground 212 "Installing CLI tools via mise..."
  for entry in "${MISE_TOOLS[@]}"; do
    local mise_name
    [[ "$entry" == *";"* ]] && mise_name="${entry#*;}" || mise_name="$entry"
    gum spin --spinner dot --title "  Installing ${mise_name}..." --show-error -- \
      mise use --global "${mise_name}@latest" \
      || gum style --foreground 196 "  ✗ Failed: ${mise_name}"
  done
  gum style --foreground 46 "CLI tools installation complete."
}

# ─── Brew bundle ──────────────────────────────────────────────────────────────

install_brew_tools() {
  setup_brew
  local brewfile="${DOTFILES}/pkg/Brewfile"
  [[ -f "$brewfile" ]] || { gum style --foreground 196 "Brewfile not found."; return 1; }
  gum spin --spinner dot --title "Installing from Brewfile..." --show-error -- \
    brew bundle --file="$brewfile"
  gum style --foreground 46 "Brewfile installation complete."
}

# ─── macOS defaults ───────────────────────────────────────────────────────────

apply_macos_defaults() {
  local script="${DOTFILES}/bin/macos/defaults.sh"
  if [[ ! -f "$script" ]]; then
    gum style --foreground 220 "macOS defaults script not found."
    return
  fi
  gum confirm "Apply macOS default settings? (Some apps may restart)" \
    && gum spin --spinner dot --title "Applying macOS defaults..." -- bash "$script" \
    && gum style --foreground 46 "macOS defaults applied." \
    || true
}

# ─── Stow flow ────────────────────────────────────────────────────────────────

stow_flow() {
  local all_pkgs=()
  while IFS= read -r pkg; do
    all_pkgs+=("$pkg")
  done < <(detect_packages)

  if [[ ${#all_pkgs[@]} -eq 0 ]]; then
    gum style --foreground 220 "No packages detected."
    return
  fi

  local preselected
  preselected=$(IFS=,; printf '%s' "${all_pkgs[*]}")

  gum style --foreground 212 "Deselect packages to skip (space to toggle, enter to confirm):"
  local selected
  selected=$(gum choose --no-limit --selected="$preselected" "${all_pkgs[@]}") || true
  [[ -z "$selected" ]] && { gum style --foreground 220 "No packages selected."; return; }

  local action
  action=$(gum choose --header "Action:" \
    "Install / Update (--restow)" \
    "Uninstall (--delete)") || return

  local flag
  [[ "$action" == "Install / Update (--restow)" ]] && flag="--restow" || flag="--delete"

  gum confirm "Proceed with ${flag} for selected packages?" || return

  while IFS= read -r pkg; do
    [[ -n "$pkg" ]] && symlink_package "$flag" "$pkg"
  done <<< "$selected"

  gum style --foreground 46 "Stow complete."
}

# ─── CLI install flow ─────────────────────────────────────────────────────────

cli_flow() {
  if [[ "$OS" == "linux" && "$ENV_TYPE" == "shared" ]]; then
    install_mise_tools
  else
    install_brew_tools
  fi
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
  _header "Dotfiles Setup"

  # Phase 0: bootstrap (plain output, no gum yet)
  bootstrap_gum

  # Linux: determine environment type via gum
  if [[ "$OS" == "linux" ]]; then
    local env_choice
    env_choice=$(gum choose \
      --header "What kind of Linux environment is this?" \
      "Shared server (no root — use mise)" \
      "Private server (can install Homebrew)")
    [[ "$env_choice" == *"Shared"* ]] && ENV_TYPE="shared" || ENV_TYPE="private"
  fi

  # Welcome banner
  gum style \
    --border double \
    --margin "1" \
    --padding "1 2" \
    --border-foreground 212 \
    "✦  Dotfiles Installer  ✦" \
    "OS: ${OS}${ENV_TYPE:+ | ${ENV_TYPE} server}"

  # Build menu options
  local opts=("Stow packages" "Install CLI tools" "Full setup" "Exit")
  [[ "$OS" == "darwin" ]] && opts=(
    "Stow packages"
    "Install CLI tools"
    "Full setup"
    "Apply macOS defaults"
    "Exit"
  )

  local choice
  choice=$(gum choose --height 8 "${opts[@]}") || exit 0

  case "$choice" in
    "Stow packages")
      stow_flow
      ;;
    "Install CLI tools")
      cli_flow
      ;;
    "Full setup")
      stow_flow
      cli_flow
      [[ "$OS" == "darwin" ]] && apply_macos_defaults
      ;;
    "Apply macOS defaults")
      apply_macos_defaults
      ;;
    "Exit")
      exit 0
      ;;
  esac

  gum style --foreground 46 "✦ Dotfiles setup complete!"
  gum style --foreground 39 "  Run: source ~/.zshrc"
}

main
