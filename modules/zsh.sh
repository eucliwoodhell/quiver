#!/usr/bin/env bash

focus_install() {
  log_info "Instalando Oh My Zsh..."
  case "$OS_TYPE" in
  arch) $PKM zsh ;;
  debian) $PKM zsh ;;
  mac) $PKM zsh ;;
  esac

  install_powerline_fonts
  link_config "zsh"
  return 0
}

install_omz_plugins() {
  local plugins_dir="/usr/share/zsh/plugins"
  sudo mkdir -p "$plugins_dir"

  case "$OS_TYPE" in
  arch) $PKM zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search ;;
  debian) $PKM zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search ;;
  mac) $PKM zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search ;;
  *)
    log_error "OS desconocida. No se instalaron plugins de Zsh."
    ;;
  esac

  if gum confirm "Quieres instalar el theme Powerlevel10k?"; then
    log_info "Instalando Powerlevel10k..."
    case "$OS_TYPE" in
    arch)
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $plugins_dir/powerlevel10k
      ;;
    debian)
      git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $plugins_dir/powerlevel10k
      ;;
    mac) $PKM powerlevel10k ;;
    esac
  fi

  log_success "Plugins de Zsh instalados en $plugins_dir."
}
