#!/usr/bin/env bash
# =============================================================================
# backup_projects.sh — Respalda proyectos Node, Python, Rust y Java
# excluyendo carpetas de dependencias/build pesadas.
# Uso: ./backup_projects.sh [directorio] [nombre_salida.zip]
# Ejemplo: ./backup_projects.sh ~/proyectos/rust mis_proyectos_rust
# =============================================================================

set -euo pipefail

# ── Colores ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Argumentos ───────────────────────────────────────────────────────────────
SOURCE_DIR="${1:-.}" # Carpeta a respaldar (default: actual)
OUTPUT_NAME="${2:-backup_$(basename "$(realpath "$SOURCE_DIR")")_$(date +%Y%m%d_%H%M%S)}"
OUTPUT_ZIP="${OUTPUT_NAME%.zip}.zip" # Asegura extensión .zip

# ── Directorios/archivos excluidos por ecosistema ────────────────────────────
# Node.js
EXCLUDES=(
  "node_modules"
  ".npm"
  ".yarn/cache"
  ".pnp"
  "dist"
  "build"
  ".next"
  ".nuxt"
  ".svelte-kit"
  "out"
)

# Python
EXCLUDES+=(
  "__pycache__"
  "*.pyc"
  "*.pyo"
  "*.pyd"
  ".venv"
  "venv"
  "env"
  ".env"
  "*.egg-info"
  "dist"
  "build"
  ".mypy_cache"
  ".pytest_cache"
  ".ruff_cache"
  "htmlcov"
  ".tox"
)

# Rust
EXCLUDES+=(
  "target"
)

# Java / Kotlin / Gradle / Maven
EXCLUDES+=(
  "target" # Maven
  "build"  # Gradle
  ".gradle"
  ".idea"
  "*.class"
  "*.jar"
  "*.war"
  "*.ear"
  "out"
)

# Genéricos
EXCLUDES+=(
  ".git"
  ".DS_Store"
  "Thumbs.db"
  "*.log"
  "*.tmp"
  "*.swp"
  "*.swo"
  ".cache"
  "coverage"
  ".nyc_output"
)

# ── Construir flags de exclusión para zip ────────────────────────────────────
build_exclude_flags() {
  local flags=()
  for pattern in "${EXCLUDES[@]}"; do
    flags+=(-x "*/${pattern}/*" -x "*/${pattern}" -x "${pattern}/*" -x "${pattern}")
    # Para extensiones de archivo (*.pyc, etc.)
    if [[ "$pattern" == \** ]]; then
      flags+=(-x "$pattern")
    fi
  done
  echo "${flags[@]}"
}

# ── Validaciones ─────────────────────────────────────────────────────────────
if [[ ! -d "$SOURCE_DIR" ]]; then
  echo -e "${RED}✗ El directorio '${SOURCE_DIR}' no existe.${RESET}"
  exit 1
fi

if ! command -v zip &>/dev/null; then
  echo -e "${RED}✗ 'zip' no está instalado. Instálalo con:${RESET}"
  echo -e "  ${CYAN}sudo apt install zip${RESET}  /  ${CYAN}brew install zip${RESET}"
  exit 1
fi

SOURCE_DIR="$(realpath "$SOURCE_DIR")"
PARENT_DIR="$(dirname "$SOURCE_DIR")"
FOLDER_NAME="$(basename "$SOURCE_DIR")"

echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════╗"
echo "║         🗜  Backup de Proyectos              ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "  ${BOLD}Origen   :${RESET} $SOURCE_DIR"
echo -e "  ${BOLD}Destino  :${RESET} $(pwd)/$OUTPUT_ZIP"
echo -e "  ${BOLD}Excluye  :${RESET} node_modules, target, __pycache__, .venv, build, .git, etc."
echo ""

# ── Crear ZIP ────────────────────────────────────────────────────────────────
echo -e "${YELLOW}⏳ Generando respaldo...${RESET}"

# Cambiamos al directorio padre para que el zip contenga la carpeta raíz
cd "$PARENT_DIR"

# Construir el comando zip con todas las exclusiones
EXCLUDE_FLAGS=()
for pattern in "${EXCLUDES[@]}"; do
  EXCLUDE_FLAGS+=(-x "*/${pattern}/*")
  EXCLUDE_FLAGS+=(-x "*/${pattern}")
  EXCLUDE_FLAGS+=(-x "${FOLDER_NAME}/${pattern}/*")
  EXCLUDE_FLAGS+=(-x "${FOLDER_NAME}/${pattern}")
  # Patrones de archivo (*.pyc, *.class, etc.)
  if [[ "$pattern" == \** ]]; then
    EXCLUDE_FLAGS+=(-x "$pattern")
    EXCLUDE_FLAGS+=(-x "*/$pattern")
  fi
done

zip -r "${OLDPWD}/${OUTPUT_ZIP}" "$FOLDER_NAME" "${EXCLUDE_FLAGS[@]}" \
  2>&1 | grep -v "^  adding:" | grep -v "^updating:" || true

# ── Resultado ────────────────────────────────────────────────────────────────
cd "$OLDPWD"

if [[ -f "$OUTPUT_ZIP" ]]; then
  SIZE=$(du -sh "$OUTPUT_ZIP" | cut -f1)
  FILES=$(unzip -l "$OUTPUT_ZIP" 2>/dev/null | tail -1 | awk '{print $2}')
  echo -e "\n${GREEN}✔ Respaldo creado exitosamente${RESET}"
  echo -e "  ${BOLD}Archivo  :${RESET} $OUTPUT_ZIP"
  echo -e "  ${BOLD}Tamaño   :${RESET} $SIZE"
  echo -e "  ${BOLD}Archivos :${RESET} $FILES"
else
  echo -e "${RED}✗ Error al crear el respaldo.${RESET}"
  exit 1
fi
