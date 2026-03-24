#!/usr/bin/env bash

install_rust_tools() {
  if gum confirm "Instalar Manga Reader (manga-tui)?"; then
    gum spin --spinner dot --title "manga-tui" -- ~/.cargo/bin/cargo install manga-tui
  fi

  if gum confirm "Instalar Ghgrab?"; then
    gum spin --spinner dot --title "ghgrab" -- ~/.cargo/bin/cargo install ghgrab
  fi

  if gum confirm "Instalar Deadbranch?"; then
    gum spin --spinner dot --title "deadbranch" -- ~/.cargo/bin/cargo install deadbranch
  fi

  if gum confirm "Instalar flux"; then
    gum spin --spinner dot --title "flux-cli" -- ~/.cargo/bin/cargo install flux-cli
  fi

  if gum confirm "Instalar suvadu"; then
    gum spin --spinner dot --title "suvadu" -- ~/.cargo/bin/cargo install suvadu
    echo 'eval "$(suv init zsh)"' >>~/.zshrc
  fi

  if gum confirm "Instalar youtube-tui"; then
    gum spin --spinner dot --title "starship" -- ~/.cargo/bin/cargo install youtube-tui
  fi
}

focus_install() {
  log_info "Instalando Rust..."

  gum spin --spinner dot --title "Instalando Rust (rustup)" -- bash -c 'curl --proto '\''=https'\'' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'

  log_success "Rust instalado."

  install_rust_tools
  return 0
}
