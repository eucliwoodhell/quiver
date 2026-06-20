#!/usr/bin/env bash

focus_install() {
  log_info "Installing 'fish'..."
  case "$OS_TYPE" in
  arch)
    gum spin --spinner dot --title "fish (Arch)" -- $PKM fish
    ;;
  debian)
    gum spin --spinner dot --title "Adding fish repository" -- bash -c "sudo add-apt-repository ppa:fish-shell/release-4 && sudo apt-get update -y"
    gum spin --spinner dot --title "fish (Debian)" -- $PKM fish
    ;;
  mac)
    gum spin --spinner dot --title "fish (macOS)" -- $PKM fish
    ;;
  esac

  link_config "fish"
  return 0
}
