#!/usr/bin/env bash

spin() {
  gum spin --spinner dot --title "$1" -- bash -c "$2" 2>/dev/null
}

install_system_utils() {
  log_info "Instalando utilidades del sistema..."

  case "$OS_TYPE" in
  arch)
    gum spin --spinner dot --title "Sistema (Arch)" -- $PKM jq curl wget ctags net-tools inetutils htop btop pigz ripgrep fzf lsd imagemagick neofetch
    ;;
  debian)
    gum spin --spinner dot --title "Sistema (Debian)" -- bash -c "$PKM jq curl wget exuberant-ctags net-tools telnet htop btop pigz ripgrep fzf imagemagick neofetch"
    curl -sL -o /tmp/lsd.deb https://github.com/lsd-rs/lsd/releases/download/v1.2.0/lsd_1.2.0_amd64.deb
    gum spin --spinner dot --title "Instalando lsd" -- sudo dpkg -i /tmp/lsd.deb
    ;;
  mac)
    gum spin --spinner dot --title "Sistema (macOS)" -- $PKM jq curl wget ctags htop btop pigz ripgrep fzf lsd imagemagick neofetch
    ;;
  esac
}

install_dev_utils() {
  log_info "Instalando herramientas de desarrollo..."

  case "$OS_TYPE" in
  arch)
    gum spin --spinner dot --title "Dev tools (Arch)" -- $PKM nodejs cmake git docker atuin uv
    gum spin --spinner dot --title "uv + posting" -- $HOME/.local/bin/uv tool install --python 3.12 posting
    gum spin --spinner dot --title "nvm" -- bash -c "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash"
    ;;
  debian)
    gum spin --spinner dot --title "Dev tools (Debian)" -- bash -c "sudo $PKM nodejs npm cmake git docker.io"
    gum spin --spinner dot --title "atuin" -- bash -c "curl -fsSL https://setup.atuin.sh | sh -s -- --non-interactive"
    gum spin --spinner dot --title "uv" -- bash -c "curl -fsSL https://astral.sh/uv/install.sh | sh"
    gum spin --spinner dot --title "uv + posting" -- $HOME/.local/bin/uv tool install --python 3.12 posting
    gum spin --spinner dot --title "nvm" -- bash -c "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash"
    ;;
  mac)
    gum spin --spinner dot --title "Dev tools (macOS)" -- $PKM node cmake git minikube pyenv docker atuin uv
    gum spin --spinner dot --title "uv + posting" -- uv tool install --python 3.12 posting
    gum spin --spinner dot --title "nvm" -- bash -c "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash"
    ;;
  esac
}

install_extra_utils() {
  log_info "Instalando herramientas extras..."

  case "$OS_TYPE" in
  arch)
    gum spin --spinner dot --title "Extras (AUR)" -- yay -S minikube pyenv postman-bin git-chglog aws-cli-v2 kubecolor catimg gotop firefox
    ;;
  debian)
    gum spin --spinner dot --title "firefox" -- $PKM firefox
    curl -fsSL -o /tmp/kubecolor.tar.gz https://github.com/kubecolor/kubecolor/releases/latest/download/kubecolor_linux_amd64.tar.gz
    gum spin --spinner dot --title "kubecolor" -- tar -xzf /tmp/kubecolor.tar.gz -C /usr/local/bin kubecolor
    ;;
  mac)
    gum spin --spinner dot --title "Extras (macOS)" -- $PKM --cask rectangle firefox mongodb-compass postman awscli kubecolor
    gum spin --spinner dot --title "git-chglog tap" -- brew tap git-chglog/git-chglog
    gum spin --spinner dot --title "git-chglog" -- $PKM git-chglog
    ;;
  esac
}

plugins_install() {
  install_system_utils
  install_dev_utils
  install_extra_utils
}
