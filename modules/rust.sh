#!/usr/bin/env bash

focus_install() {
  log_info "Instalando Rust..."

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

  install_manga_reader
  return 0
}

install_manga_reader() {
  # https://github.com/mayocream/koharu
  if gum confirm "Instalar Manga Reader?"; then
    log_info "Instalando Manga Reader..."
    cargo install manga-tui
  fi

  if gum confirm "Instalar Ghgrab?"; then
    log_info "Instalando Ghgrab..."
    cargo install ghgrab
  fi

  if gum confirm "Instalar Deadbranch?"; then
    log_info "Instalando Manga Downloader..."
    cargo install deadbranch
  fi

  if gum confirm "Instalar flux" then
    log_info "Instalando flux..."
    cargo install flux-cli
  fi

  if gum confirm "Instalar suvadu" then
    cargo install suvadu
    echo 'eval "$(suv init zsh)"' >> ~/.zshrc && source ~/.zshrc
  fi
}
