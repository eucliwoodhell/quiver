#!/usr/bin/env bash

install_rust_tools() {
  if gum confirm "Install Manga Reader (manga-tui)?"; then
    gum spin --spinner dot --title "manga-tui" -- ~/.cargo/bin/cargo install manga-tui
  fi

  if gum confirm "Install Ghgrab?"; then
    gum spin --spinner dot --title "ghgrab" -- ~/.cargo/bin/cargo install ghgrab
  fi

  if gum confirm "Install Deadbranch?"; then
    gum spin --spinner dot --title "deadbranch" -- ~/.cargo/bin/cargo install deadbranch
  fi

  if gum confirm "Install flux?"; then
    gum spin --spinner dot --title "flux-cli" -- ~/.cargo/bin/cargo install flux-cli
  fi

  if gum confirm "Install suvadu?"; then
    gum spin --spinner dot --title "suvadu" -- ~/.cargo/bin/cargo install suvadu
    echo 'eval "$(suv init zsh)"' >>~/.zshrc
  fi
}

focus_install() {
  log_info "Installing Rust..."

  gum spin --spinner dot --title "Installing Rust (rustup)" -- bash -c 'curl --proto '\''=https'\'' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y'

  log_success "Rust installed."

  install_rust_tools
  return 0
}
