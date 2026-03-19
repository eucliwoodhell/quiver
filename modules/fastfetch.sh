#!/usr/bin/env bash

focus_install() {
  log_info "Instalando 'fastfetch'..."
  case "$OS_TYPE" in
  arch)
    gum spin --spinner dot --title "fastfetch (Arch)" -- $PKM fastfetch
    ;;
  debian)
    gum spin --spinner dot --title "Añadiendo PPA fastfetch" -- bash -c "sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y && sudo apt-get update"
    gum spin --spinner dot --title "fastfetch (Debian)" -- $PKM fastfetch
    ;;
  mac)
    gum spin --spinner dot --title "fastfetch (macOS)" -- $PKM fastfetch
    ;;
  esac

  link_config "fastfetch"

  return 0
}
