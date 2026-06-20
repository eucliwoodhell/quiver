#!/usr/bin/env bash

focus_install() {
  log_info "Installing 'fastfetch'..."
  case "$OS_TYPE" in
  arch)
    gum spin --spinner dot --title "fastfetch (Arch)" -- $PKM fastfetch
    ;;
  debian)
    gum spin --spinner dot --title "Adding fastfetch PPA" -- bash -c "sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y && sudo apt-get update"
    gum spin --spinner dot --title "fastfetch (Debian)" -- $PKM fastfetch
    ;;
  mac)
    gum spin --spinner dot --title "fastfetch (macOS)" -- $PKM fastfetch
    ;;
  esac

  link_config "fastfetch"

  return 0
}
