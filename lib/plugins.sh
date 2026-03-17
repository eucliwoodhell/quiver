#!/usr/bin/env bash

plugins_install() {
  log_info "Instalando Plugins..."

  case "$OS_TYPE" in
  arch)
    # ============================================
    # SYSTEM TOOLS
    # ============================================
    $PKM jq
    $PKM curl
    $PKM wget
    $PKM ctags
    $PKM net-tools
    $PKM inetutils
    $PKM htop
    $PKM btop
    $PKM pigz
    $PKM ripgrep
    $PKM fzf
    $PKM lsd
    $PKM imagemagick
    $PKM neofetch

    # ============================================
    # DEVELOPMENT TOOLS
    # ============================================
    $PKM nodejs
    $PKM cmake
    $PKM git
    $PKM docker
    $PKM atuin
    $PKM uv
    $HOME/.local/bin/uv tool install --python 3.12 posting
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

    # ============================================
    # AUR PACKAGES (via yay)
    # ============================================
    yay -S minikube
    yay -S pyenv
    yay -S postman-bin
    yay -S git-chglog
    yay -S aws-cli-v2
    yay -S kubecolor
    yay -S catimg
    yay -S gotop
    yay -S firefox

    # ============================================
    # COMPRESSION / ZIP
    # ============================================
    $PKM pigz
    ;;
  debian)
    # ============================================
    # SYSTEM TOOLS
    # ============================================
    $PKM jq
    $PKM curl
    $PKM wget
    $PKM exuberant-ctags
    $PKM net-tools
    $PKM telnet
    $PKM htop
    $PKM btop
    $PKM pigz
    $PKM ripgrep
    $PKM fzf
    $PKM imagemagick
    $PKM neofetch
    $PKM firefox

    # ============================================
    # DEVELOPMENT TOOLS
    # ============================================
    sudo $PKM nodejs npm
    $PKM cmake
    $PKM git
    $PKM docker.io

    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh -s -- --non-interactive
    curl -LsSf https://astral.sh/uv/install.sh | sh
    $HOME/.local/bin/uv tool install --python 3.12 posting

    # ============================================
    # TOOLS FROM GITHUB RELEASES
    # ============================================
    # kubecolor
    curl -Lo /tmp/kubecolor.tar.gz https://github.com/kubecolor/kubecolor/releases/latest/download/kubecolor_linux_amd64.tar.gz
    tar -xzf /tmp/kubecolor.tar.gz -C /usr/local/bin kubecolor

    # lsd
    sudo curl -L -o lsd.deb https://github.com/lsd-rs/lsd/releases/download/v1.2.0/lsd_1.2.0_arm64.deb
    sudo dpkg -i lsd.deb

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
    # ============================================
    # COMPRESSION / ZIP
    # ============================================
    $PKM pigz
    ;;
  mac)
    # ============================================
    # SYSTEM TOOLS
    # ============================================
    $PKM jq
    $PKM curl
    $PKM wget
    $PKM ctags
    $PKM netstat
    $PKM telnet
    $PKM htop
    $PKM btop
    $PKM pigz
    $PKM ripgrep
    $PKM fzf
    $PKM lsd
    $PKM catimg
    $PKM imagemagick
    $PKM neofetch
    $PKM --cask rectangle
    $PKM --cask firefox
    $PKM stats
    $PKM gotop

    # ============================================
    # DEVELOPMENT TOOLS
    # ============================================
    $PKM node
    $PKM cmake
    $PKM git
    $PKM minikube
    $PKM pyenv
    $PKM docker
    $PKM --cask mongodb-compass
    $PKM --cask postman
    brew tap git-chglog/git-chglog
    $PKM git-chglog
    $PKM awscli
    $PKM kubecolor
    $PKM atuin
    $PKM uv
    uv tool install --python 3.12 posting
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash

    # ============================================
    # COMPRESSION / ZIP
    # ============================================
    $PKM pigz
    ;;
  esac
  return 0
}
