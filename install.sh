#!/usr/bin/env bash

# --- Configuración Global ---
export DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export CONFIGS_DIR="$DOTFILES_DIR/configs"
export MODULES_DIR="$DOTFILES_DIR/modules"

# --- Cargar Utilidades ---
source "$DOTFILES_DIR/lib/utils.sh"

# --- Detección de OS y Package Manager ---
detect_os

# --- Asegurar que GUM esté instalado (para el menú pro) ---
ensure_gum

# --- Inicio del Script ---
print_banner "QUIVER: Archer's Dotfiles Manager"

# 0. Seleccionar utilidades a instalar
log_section "Paso 1: Utilidades"
SELECTED_UTILS=$(select_utilities)
if [ -n "$SELECTED_UTILS" ]; then
  install_selected_utilities "$SELECTED_UTILS"
else
  log_warn "No seleccionaste utilidades. Continuando..."
fi

# 1. Escanear módulos disponibles en la carpeta modules/
MODULE_NAMES=($(ls "$MODULES_DIR"/*.sh))

log_section "Paso 2: Módulos"

if [ -n "$AUTO_SELECT" ]; then
  SELECTED="$AUTO_SELECT"
else
  MODULE_BASES=("${MODULE_NAMES[@]##*/}")
  log_info "Usa [ESPACIO] para seleccionar y [ENTER] para confirmar"
  SELECTED=$(gum choose --no-limit --cursor-prefix "○ " --selected-prefix "◉ " --unselected-prefix "○ " "${MODULE_BASES[@]}")
fi

if [ -z "$SELECTED" ]; then
  log_warn "No seleccionaste nada. Saliendo..."
  exit 0
fi

for item in $SELECTED; do
  log_section "Instalando: $item"
  source "$MODULES_DIR/$item.sh"

  if focus_install; then
    log_success "$item completado con éxito."
  else
    log_error "Error instalando $item."
  fi
done

if gum confirm "Agregar configuración zsh a .zshrc?"; then
  log_info "Agregando configuración zsh..."
  echo "source $HOME/.config/zsh/config.zsh" >>~/.zshrc
fi

print_banner "¡Todo listo, Archer! Disfruta tu setup."
