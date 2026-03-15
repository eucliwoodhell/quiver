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
  install_fisher

  return 0
}

install_fisher() {
  log_info "Instalando 'fisher'..."

  curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
  fisher install IlanCosman/tide@v6

  return 0
}
