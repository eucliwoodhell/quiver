#!/usr/bin/env bash

focus_install() {
  log_info "Instalando 'fish'..."
  case "$OS_TYPE" in
  arch) $PKM fish ;;
  debian)
    sudo add-apt-repository ppa:fish-shell/release-4
    sudo apt-get update
    $PKM fish
    ;;
  mac) $PKM fish ;;
  esac

  link_config "fish"
  return 0
}
