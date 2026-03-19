#!/usr/bin/env bash

focus_install() {
  log_info "Instalando 'Opencode'..."
  case "$OS_TYPE" in
  arch)
    gum spin --spinner dot --title "Opencode (Arch)" -- bash -c "curl -fsSL https://opencode.ai/install | bash"
    ;;
  debian)
    gum spin --spinner dot --title "Opencode (Debian)" -- bash -c "curl -fsSL https://opencode.ai/install | bash"
    ;;
  mac)
    gum spin --spinner dot --title "Opencode (macOS)" -- $PKM anomalyco/tap/opencode
    ;;
  esac

  link_config "opencode"
  return 0
}

add_opencode_config() {
  log_info "Agregando configuración de Opencode..."
  local src="$CONFIGS_DIR/opencode/"
  local dest="$HOME/.config/opencode"

  if [ -d "$src" ]; then
    log_info "Linkeando configuración de opencode..."
    mkdir -p "$HOME/.config/opencode"
    ln -sfn "$src/opencode.json" "$dest/opencode.json"

    log_info "Agregando themes de opencode..."
    mkdir -p "$HOME/.config/opencode/themes"
    ln -sfn "$src/themes/"* "$dest/themes/"
  fi
}
