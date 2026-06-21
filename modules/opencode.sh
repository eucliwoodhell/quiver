#!/usr/bin/env bash
abacus_key="$ABACUS_API_KEY"
abacus_replace_word="__ABACUS_API_KEY__"

focus_install() {
  log_info "Installing 'Opencode'..."
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

  replace_opencode_config
  link_config "opencode"
  return 0
}

add_opencode_config() {
  log_info "Adding Opencode configuration..."
  local src="$CONFIGS_DIR/opencode/"
  local dest="$HOME/.config/opencode"

  if [ -d "$src" ]; then
    log_info "Linking opencode configuration..."
    mkdir -p "$HOME/.config/opencode"
    ln -sfn "$src/opencode.json" "$dest/opencode.json"

    log_info "Adding opencode themes..."
    mkdir -p "$HOME/.config/opencode/themes"
    ln -sfn "$src/themes/"* "$dest/themes/"

    log_info "Adding abacus path to opencode config..."
    mkdir -p "$HOME/.abacus-ai"
    touch "$HOME/.abacus-ai/api-key"
  fi
}

replace_opencode_config() {
  local src="$CONFIGS_DIR/opencode/opencode.json"
  log_info "Replacing Opencode configuration..."
  sed -i "s/$abacus_replace_word/$abacus_key/g" "$src"
}
