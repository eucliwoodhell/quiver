#!/usr/bin/env bash

focus_install() {
  log_info "Instalando 'kitty'..."

  case "$OS_TYPE" in
  arch)
    gum spin --spinner dot --title "kitty (Arch)" -- $PKM kitty
    ;;
  debian)
    gum spin --spinner dot --title "kitty (Debian)" -- bash -c "curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin"
    ;;
  mac)
    gum spin --spinner dot --title "kitty (macOS)" -- $PKM --cask kitty
    ;;
  esac

  install_powerline_fonts
  link_config "kitty"

  return 0
}

install_powerline_fonts() {
  if gum confirm "Instalar Powerline Fonts?"; then
    case "$OS_TYPE" in
    arch)
      gum spin --spinner dot --title "Powerline Fonts (Arch)" -- $PKM powerline-fonts
      ;;
    debian)
      gum spin --spinner dot --title "Powerline Fonts (Debian)" -- $PKM fonts-powerline
      ;;
    mac)
      gum spin --spinner dot --title "Powerline Fonts (macOS)" -- bash -c "git clone https://github.com/powerline/fonts.git --depth=1 /tmp/powerline-fonts && bash /tmp/powerline-fonts/install.sh && rm -rf /tmp/powerline-fonts"
      ;;
    esac
    log_success "Fuentes Powerline instaladas."
  fi
}
