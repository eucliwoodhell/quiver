#!/usr/bin/env bash

focus_install() {
  log_info "Instalando 'Opencode'..."
  case "$OS_TYPE" in
  arch) curl -fsSL https://opencode.ai/install | bash ;;
  debian)
    curl -fsSL https://opencode.ai/install | bash
    ;;
  mac) $PKM anomalyco/tap/opencode ;;
  esac

  link_config "opencode"
  return 0
}

add_opencode_config() {
  log_info "Agregando configuración de Opencode..."
  local src="$CONFIGS_DIR/opencode/opencode.json"
  local dest="$HOME/.config/opencode"

  if [ -d "$src" ]; then
    log_info "Linkeando configuración de opencode..."
    mkdir -p "$HOME/.config/opencode"
    ln -sfn "$src" "$dest/opencode.json"
  fi
}
