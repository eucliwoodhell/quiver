#!/usr/bin/env bash

focus_install() {
  log_info "Instalando Rust..."

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

  log_success "Rust instalado."

  install_plugins
  return 0
}

install_plugins() {
  # https://github.com/mayocream/koharu
  if gum confirm "Instalar Manga Reader?"; then
    cargo install manga-tui
  fi

  if gum confirm "Instalar Ghgrab?"; then
    cargo install ghgrab >
  fi

  if gum confirm "Instalar Deadbranch?"; then
    cargo install deadbranch
  fi

  if gum confirm "Instalar flux" then
    cargo install flux-cli
  fi

  if gum confirm "Instalar suvadu" then
    cargo install suvadu
    echo 'eval "$(suv init zsh)"' >> ~/.zshrc
  fi
}
