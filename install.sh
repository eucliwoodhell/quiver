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

# 1. Escanear módulos disponibles en la carpeta modules/
MODULE_FILES=($(ls "$MODULES_DIR"/*.sh))
MODULE_NAMES=()

# 2. Mostrar menú interactivo con GUM
if [ -n "$AUTO_SELECT" ]; then
  SELECTED="$AUTO_SELECT"
else
  log_info "Usa [ESPACIO] para seleccionar y [ENTER] para confirmar"
  SELECTED=$(gum choose --no-limit --cursor-prefix "○ " --selected-prefix "◉ " --unselected-prefix "○ " "${MODULE_NAMES[@]}")
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

print_banner "¡Todo listo, Archer! Disfruta tu setup."
