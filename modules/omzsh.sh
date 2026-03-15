#!/usr/bin/env bash

focus_install() {
  log_info "Instalando Oh My Zsh..."
  case "$OS_TYPE" in
  arch) sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" ;;
  debian) sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" ;;
  mac) sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" ;;
  esac

  install_powerline_fonts
  return 0
}
