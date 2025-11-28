# Tech Stack

The project utilizes the following technologies and tools:

**Operating System:**
- Darwin (macOS)

**Shell & Environment:**
- Zsh (with Zinit for plugin management)

**Package Managers:**
- Homebrew (for macOS system packages and applications)
- npm (Node.js package manager)
- Go modules (for Go packages)

**Core Tools:**
- Git (Version Control System)
- make (Build automation tool)
- curl (Data transfer tool)
- xargs (Command line utility)
- jq (JSON processor)
- gsplit (GNU split utility, likely from `coreutils`, used in testing)

**Configuration Managed Tools (examples from .config/):**
- Alacritty (GPU-accelerated terminal emulator)
- Neovim (Vim-fork focused on extensibility and usability)
- Terminator (Multiple GNOME terminals in one window)
- tmux (Terminal multiplexer)
- efm-langserver (Executable Friendly Manager Language Server)
- starship.toml (Cross-shell prompt)

**GitHub Actions:**
- Used for continuous integration, including testing brew installations.

**Programming Languages (implied by package managers and config files):**
- Shell Scripting (Bash/Zsh)
- Go
- JavaScript/TypeScript (via npm)
- Vimscript/Lua (for Neovim configuration)