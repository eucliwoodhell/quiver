# Quiver - Archer's Dotfiles Manager

> A modular and interactive dotfiles manager to set up your development environment in minutes.

---

## What is a Dotfiles Manager?

**Dotfiles** are configuration files for tools and applications on Unix/Linux/macOS systems. The name comes from the convention of starting with a dot (`.`), which makes them hidden by default (e.g. `.config/nvim`, `.zshrc`, `.gitconfig`).

The problem they solve is straightforward: when you customize your development environment (terminal colors, keybindings, plugins, themes), that configuration lives scattered across your system. If you switch machines or reinstall the OS, you lose everything.

A **dotfiles manager** centralizes all those configurations in a Git repository and allows you to:

- **Version** your configurations — every change is recorded in history
- **Sync** your environment across multiple machines with a `git pull`
- **Automate** tool installation and configuration in one shot
- **Reproduce** your full setup on a new machine with a single command

#### The Symlink Pattern

Instead of copying configuration files to their final destination, a **symbolic link** (symlink) is created from the location each app expects, pointing to the repository folder. This way, any change in the repo is immediately reflected on the system, and vice versa — the repo and the system are always in sync.

```
~/.config/nvim   →  (symlink)  →  ~/dotfiles/configs/nvim/
~/.config/fish   →  (symlink)  →  ~/dotfiles/configs/fish/
~/.config/kitty  →  (symlink)  →  ~/dotfiles/configs/kitty/
```

In Quiver, the `link_config` function in `lib/utils.sh` handles creating these symlinks automatically when each module is installed.

---

## What is Quiver for?

**Quiver** automates the installation and configuration of your development environment. With an interactive menu you can choose which tools to install, and the script takes care of:

1. Detecting your operating system (Arch Linux, Debian/Ubuntu, macOS)
2. Installing the tool with the correct package manager
3. Symlinking the repo configuration into `~/.config/`

---

## Project Structure

```
quiver/
├── install.sh          # Main entry point
├── lib/
│   └── utils.sh        # Shared utility functions
├── modules/            # One module per tool
│   ├── fastfetch.sh
│   ├── fish.sh
│   ├── kitty.sh
│   ├── nvim.sh
│   ├── omzsh.sh
│   └── rust.sh
└── configs/            # Configuration files (dotfiles)
    ├── nvim/
    ├── fish/
    ├── kitty/
    └── fastfetch/
```

### `install.sh` - Entry point

Orchestrates the full flow:
1. Loads utilities from `lib/utils.sh`
2. Detects the OS and package manager
3. Automatically scans available modules in `modules/`
4. Presents an interactive menu with [gum](https://github.com/charmbracelet/gum) to select what to install
5. Runs each selected module by calling its `focus_install` function

### `lib/utils.sh` - Shared utilities

Contains the base functions all modules can use:

| Function | Description |
|---|---|
| `detect_os` | Detects the OS and exports `$OS_TYPE` and `$PKM` (package manager) |
| `ensure_gum` | Installs [gum](https://github.com/charmbracelet/gum) if not present |
| `link_config` | Creates a symlink from `configs/<app>` to `~/.config/<app>` |
| `ensure_git` | Installs Git if not available |
| `log_info/success/warn/error` | Colored terminal loggers |
| `print_banner` | Prints a formatted banner |

### `modules/` - Installation modules

Each module is an independent bash script that exposes a `focus_install` function. This is the **pattern contract**: any `.sh` file inside `modules/` must implement `focus_install` to be compatible with the system.

| Module | Tool | Description |
|---|---|---|
| `nvim.sh` | [Neovim](https://neovim.io/) | Modal text editor |
| `fish.sh` | [Fish Shell](https://fishshell.com/) + [Fisher](https://github.com/jorgebucaran/fisher) + [Tide](https://github.com/IlanCosman/tide) | Modern shell with autocompletion and prompt |
| `kitty.sh` | [Kitty](https://sw.kovidgoyal.net/kitty/) + Powerline Fonts | GPU-accelerated terminal emulator |
| `omzsh.sh` | [Oh My Zsh](https://ohmyz.sh/) | Zsh configuration framework |
| `fastfetch.sh` | [Fastfetch](https://github.com/fastfetch-cli/fastfetch) | System info display in the terminal |
| `rust.sh` | [Rust](https://www.rust-lang.org/) + manga-tui | Programming language + TUI manga reader |

---

## Usage

#### 1. Clone the repository

```bash
git clone <your-repo> ~/dotfiles
cd ~/dotfiles
```

#### 2. Run the installer

```bash
bash install.sh
```

An interactive menu powered by [gum](https://github.com/charmbracelet/gum) will open:

- `[SPACE]` — select / deselect a tool
- `[ENTER]` — confirm selection and start installation

The script automatically detects your OS and uses the correct package manager. After each module finishes, it symlinks the corresponding configuration into `~/.config/`.

#### 3. Unattended installation (no menu)

To install specific modules without interaction (useful for CI scripts or provisioning):

```bash
AUTO_SELECT="nvim fish" bash install.sh
```

---

## Adding a new module

1. Create a file at `modules/my-tool.sh`
2. Implement the `focus_install` function:

```bash
#!/usr/bin/env bash

focus_install() {
  log_info "Installing my-tool..."

  case "$OS_TYPE" in
  arch)   $PKM my-tool ;;
  debian) $PKM my-tool ;;
  mac)    $PKM my-tool ;;
  esac

  # Optional: symlink configuration
  link_config "my-tool"

  return 0
}
```

3. Add your configuration files in `configs/my-tool/` if applicable.

The module will appear automatically in the menu the next time you run `install.sh`.

---

## Compatibility

Quiver automatically detects the operating system at startup and sets the `$PKM` variable with the correct install command. Each module uses `$PKM` internally, so you don't need to worry about the OS when writing or running modules.

| OS | Package Manager | `$OS_TYPE` value |
|---|---|---|
| Arch Linux | `sudo pacman -S --noconfirm` | `arch` |
| Debian / Ubuntu | `sudo apt install -y` | `debian` |
| macOS | `brew install` | `mac` |

> **Note:** On macOS, if Homebrew is not installed, `ensure_gum` will install it automatically before proceeding.
