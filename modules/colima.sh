#!/usr/bin/env bash

focus_install() {
  log_info "Installing 'colima'..."
  case "$OS_TYPE" in
  arch)
    gum spin --spinner dot --title "qemu, go, docker (Arch)" -- $PKM qemu-full go docker
    gum spin --spinner dot --title "lima-bin, colima-bin (AUR)" -- yay -S lima-bin colima-bin
    ;;
  debian)
    gum spin --spinner dot --title "Downloading colima" -- bash -c "sudo curl -LO https://github.com/abiosoft/colima/releases/latest/download/colima-$(uname)-$(uname -m) && sudo install colima-$(uname)-$(uname -m) /usr/local/bin/colima"
    ;;
  mac)
    gum spin --spinner dot --title "colima (macOS)" -- $PKM colima
    ;;
  esac

  return 0
}
