#!/usr/bin/env bash

focus_install() {
  log_info "Instalando Neovim..."

  gum spin --spinner dot --title "Neovim" -- $PKM neovim

  link_config "nvim"

  install_nvim_configs
  return 0
}

install_nvim_configs() {
  if gum confirm "Instalar configs de Neovim?"; then
    log_info "Instalando Neovim configs..."
    gum spin --spinner dot --title "Neovim configs" -- git clone https://github.com/eucliwoodhell/my-nvim-lua.git ~/.config/nvim

    if gum confirm "Desea utilizar la rama lazy?"; then
      git -C ~/.config/nvim checkout lazy-config
    fi
  fi

  return 0
}
