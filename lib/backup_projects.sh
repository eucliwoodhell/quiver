#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

SOURCE_DIR="${1:-.}"
OUTPUT_NAME="${2:-backup_$(basename "$(realpath "$SOURCE_DIR")")_$(date +%Y%m%d_%H%M%S)}"
OUTPUT_ZIP="${OUTPUT_NAME%.zip}.zip"

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

EXCLUDES+=(
  "target"
)

EXCLUDES+=(
  "target"
  "build"
  ".gradle"
  ".idea"
  "*.class"
  "*.jar"
  "*.war"
  "*.ear"
  "out"
)

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

build_exclude_flags() {
  local flags=()
  for pattern in "${EXCLUDES[@]}"; do
    flags+=(-x "*/${pattern}/*" -x "*/${pattern}" -x "${pattern}/*" -x "${pattern}")
    if [[ "$pattern" == \** ]]; then
      flags+=(-x "$pattern")
    fi
  done
  echo "${flags[@]}"
}

if [[ ! -d "$SOURCE_DIR" ]]; then
  echo -e "${RED}✗ Directory '${SOURCE_DIR}' does not exist.${RESET}"
  exit 1
fi

if ! command -v zip &>/dev/null; then
  echo -e "${RED}✗ 'zip' is not installed. Install it with:${RESET}"
  echo -e "  ${CYAN}sudo apt install zip${RESET}  /  ${CYAN}brew install zip${RESET}"
  exit 1
fi

SOURCE_DIR="$(realpath "$SOURCE_DIR")"
PARENT_DIR="$(dirname "$SOURCE_DIR")"
FOLDER_NAME="$(basename "$SOURCE_DIR")"

echo -e "${BOLD}${CYAN}"
echo "╔══════════════════════════════════════════════╗"
echo "║         🗜  Project Backup                 ║"
echo "╚══════════════════════════════════════════════╝"
echo -e "${RESET}"
echo -e "  ${BOLD}Source   :${RESET} $SOURCE_DIR"
echo -e "  ${BOLD}Destination  :${RESET} $(pwd)/$OUTPUT_ZIP"
echo -e "  ${BOLD}Excludes  :${RESET} node_modules, target, __pycache__, .venv, build, .git, etc."
echo ""

echo -e "${YELLOW}⏳ Generating backup...${RESET}"

cd "$PARENT_DIR"

EXCLUDE_FLAGS=()
for pattern in "${EXCLUDES[@]}"; do
  EXCLUDE_FLAGS+=(-x "*/${pattern}/*")
  EXCLUDE_FLAGS+=(-x "*/${pattern}")
  EXCLUDE_FLAGS+=(-x "${FOLDER_NAME}/${pattern}/*")
  EXCLUDE_FLAGS+=(-x "${FOLDER_NAME}/${pattern}")
  # File patterns (*.pyc, *.class, etc.)
  if [[ "$pattern" == \** ]]; then
    EXCLUDE_FLAGS+=(-x "$pattern")
    EXCLUDE_FLAGS+=(-x "*/$pattern")
  fi
done

zip -r "${OLDPWD}/${OUTPUT_ZIP}" "$FOLDER_NAME" "${EXCLUDE_FLAGS[@]}" \
  2>&1 | grep -v "^  adding:" | grep -v "^updating:" || true

cd "$OLDPWD"

if [[ -f "$OUTPUT_ZIP" ]]; then
  SIZE=$(du -sh "$OUTPUT_ZIP" | cut -f1)
  FILES=$(unzip -l "$OUTPUT_ZIP" 2>/dev/null | tail -1 | awk '{print $2}')
  echo -e "\n${GREEN}✔ Backup created successfully${RESET}"
  echo -e "  ${BOLD}File  :${RESET} $OUTPUT_ZIP"
  echo -e "  ${BOLD}Size   :${RESET} $SIZE"
  echo -e "  ${BOLD}Files :${RESET} $FILES"
else
  echo -e "${RED}✗ Error creating backup.${RESET}"
  exit 1
fi
