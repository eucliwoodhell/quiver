#!/usr/bin/env bash

focus_install() {
  log_info "Installing Neovim..."

  gum spin --spinner dot --title "Neovim" -- $PKM neovim

  link_config "nvim"

  install_nvim_configs
  return 0
}

install_nvim_configs() {
  if gum confirm "Install Neovim configs?"; then
    log_info "Installing Neovim configs..."
    gum spin --spinner dot --title "Neovim configs" -- git clone https://github.com/eucliwoodhell/my-nvim-lua.git ~/.config/nvim

    if gum confirm "Use lazy branch?"; then
      git -C ~/.config/nvim checkout lazy-config
    fi
  fi

  return 0
}
