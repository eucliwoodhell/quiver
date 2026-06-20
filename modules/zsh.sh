#!/usr/bin/env bash

focus_install() {
  log_info "Installing Oh My Zsh..."
  gum spin --spinner dot --title "zsh" -- $PKM zsh

  install_omz_plugins
  link_config "zsh"
  return 0
}

install_omz_plugins() {
  local plugins_dir="/usr/share/zsh/plugins"
  sudo mkdir -p "$plugins_dir"

  gum spin --spinner dot --title "zsh plugins" -- $PKM zsh-autosuggestions zsh-syntax-highlighting

  if gum confirm "Install Powerlevel10k theme?"; then
    case "$OS_TYPE" in
    arch | debian)
      gum spin --spinner dot --title "Powerlevel10k" -- git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $plugins_dir/powerlevel10k
      log_info "Configuring Powerlevel10k..."
      gum spin --spinner dot --title "history-substring-search" -- git clone --depth=1 git clone https://github.com/zsh-users/zsh-history-substring-search $plugins_dir/zsh-history-substringtsearch
      log_info "Configuring zsh-history-substring-search..."
      ;;
    mac)
      gum spin --spinner dot --title "Powerlevel10k" -- $PKM powerlevel10k
      ;;
    esac
  fi

  log_success "Zsh plugins installed in $plugins_dir."
}
