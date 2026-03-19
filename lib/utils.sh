#!/usr/bin/env bash

# Colores
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
RED=$(tput setaf 1)
BOLD=$(tput bold)
RESET=$(tput sgr0)

detect_os() {
  log_info "Detectando OS..."
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if [ -f /etc/arch-release ]; then
      export OS_TYPE="arch"
      export PKM="sudo pacman -S --noconfirm"
      echo "OS: Arch Linux"
    elif [ -f /etc/debian_version ] || [ -f /etc/lsb-release ]; then
      export OS_TYPE="debian"
      export PKM="sudo apt install -y"
      log_info "OS: Debian"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    export OS_TYPE="mac"
    export PKM="brew install"
    log_info "OS: macOS"
  fi
}

ensure_gum() {
  if ! command -v gum &>/dev/null; then
    log_info "Instalando 'gum' para el menú interactivo..."
    case "$OS_TYPE" in
    arch) sudo pacman -S --noconfirm gum ;;
    debian)
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
      echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
      sudo apt update && sudo apt install gum
      ;;
    mac)
      if ! command -v brew &>/dev/null; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      fi
      brew install gum
      ;;
    esac
  fi
}

link_config() {
  local app=$1
  local src="$CONFIGS_DIR/$app"
  local dest="$HOME/.config/$app"

  if [ -d "$src" ]; then
    log_info "Linkeando configuración de $app..."
    mkdir -p "$HOME/.config"
    ln -sfn "$src" "$dest"
  fi
}

ensure_git() {
  if ! command -v git &>/dev/null; then
    log_info "Instalando Git..."
    gum spin --spinner dot --title "Instalando git" -- $PKM git
  fi
}

# Loggers
log_info() { echo -e "${BLUE}${BOLD}INFO:${RESET} $1"; }
log_success() { echo -e "${GREEN}${BOLD}SUCCESS:${RESET} $1"; }
log_warn() { echo -e "${YELLOW}${BOLD}WARN:${RESET} $1"; }
log_error() { echo -e "${RED}${BOLD}ERROR:${RESET} $1"; }
log_section() { echo -e "\n${BOLD}--- $1 ---${RESET}"; }
print_banner() { echo -e "${BLUE}${BOLD}$1${RESET}\n"; }

run_spin() {
  gum spin --spinner dot --title "$1" -- $2 >/dev/null 2>&1
}

select_utilities() {
  log_info "Selecciona las categorías a instalar con [ESPACIO] y confirma con [ENTER]"

  SELECTED=$(gum choose --no-limit --cursor-prefix "○ " --selected-prefix "◉ " --unselected-prefix "○ " \
    "Sistema (jq, curl, ripgrep, htop, fzf...)" \
    "Desarrollo (git, docker, node, pyenv...)" \
    "Extras (firefox, postman, minikube...)")

  echo "$SELECTED"
}

install_selected_utilities() {
  local selections="$1"
  [ -z "$selections" ] && return 0

  source "$DOTFILES_DIR/lib/plugins.sh"

  for item in $selections; do
    case "$item" in
    Sistema*)
      install_system_utils
      ;;
    Desarrollo*)
      install_dev_utils
      ;;
    Extras*)
      install_extra_utils
      ;;
    esac
  done
}
