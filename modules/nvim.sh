#!/usr/bin/env bash

focus_install() {
  log_info "Instalando Neovim..."

  case "$OS_TYPE" in
  arch) $PKM neovim ;;
  debian) $PKM neovim ;;
  mac) $PKM neovim ;;
  esac

  link_config "nvim"

  return 0
}
