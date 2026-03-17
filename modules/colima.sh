#!/usr/bin/env bash

focus_install() {
  log_info "Instalando 'colima'..."
  case "$OS_TYPE" in
  arch)
    $PKM qemu-full go docker
    yay -S lima-bin colima-bin
    ;;
  debian)
    echo "$(uname -m) - $(uname -m)"
    sudo curl -LO https://github.com/abiosoft/colima/releases/latest/download/colima-$(uname)-$(uname -m)
    sudo install colima-$(uname)-$(uname -m) /usr/local/bin/colima
    ;;
  mac) $PKM colima ;;
  esac

  return 0
}
