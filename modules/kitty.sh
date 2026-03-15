#!/usr/bin/env bash

focus_install() {
  log_info "Instalando 'kitty'..."

  case "$OS_TYPE" in
  arch) $PKM kitty ;;
  debian) curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin ;;
  mac) $PKM --cask kitty ;;
  esac

  install_powerline_fonts
  link_config "kitty"

  return 0
}

install_powerline_fonts() {
  log_info "Instalando Powerline Fonts..."
  if gum confirm "Instalar Powerline Fonts?"; then
    log_info "Descargando Powerline Fonts..."
    case "$OS_TYPE" in
    arch) $PKM powerline-fonts ;;
    debian) $PKM fonts-powerline ;;
    mac)
      ensure_git

      git clone https://github.com/powerline/fonts.git --depth=1 /tmp/powerline-fonts
      bash /tmp/powerline-fonts/install.sh
      rm -rf /tmp/powerline-fonts
      ;;
    esac
    log_success "Fuentes Powerline instaladas."
  fi
}
