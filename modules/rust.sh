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
}
