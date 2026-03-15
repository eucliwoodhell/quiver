#!/usr/bin/env bash

focus_install() {
  log_info "Instalando 'fastfetch'..."
  case "$OS_TYPE" in
  arch) $PKM fastfetch ;;
  debian)
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
    sudo apt-get update
    $PKM fastfetch
    ;;
  mac) $PKM fastfetch ;;
  esac

  link_config "fastfetch"

  return 0
}
