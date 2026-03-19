#!/usr/bin/env bash

focus_install() {
  log_info "Instalando Neovim..."

  gum spin --spinner dot --title "Neovim" -- $PKM neovim

  link_config "nvim"

  return 0
}
