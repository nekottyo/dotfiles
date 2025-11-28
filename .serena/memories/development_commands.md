# Development Commands

This section outlines commands relevant for developing and maintaining this dotfiles project.

## Installation and Deployment

- `make install`: Installs Homebrew, then installs packages listed in `pkg/brew.txt` and `pkg/npm.txt`.
- `make deploy`: Creates symbolic links for the dotfiles (files starting with `.`) and configuration directories (`.config/`) from the project directory to the user's home directory.
- `make install-brew`: Installs Homebrew (if not already installed).
- `make install-zinit`: Installs Zinit (a flexible and fast Zsh plugin manager) if it's not found in the PATH.
- `make install-go`: Installs Go packages listed in `pkg/gopkg.txt`.

## Updating

- `make update`: Updates package lists (`pkg/brew.txt`, `pkg/cask.txt`, `pkg/gopkg.txt`, `pkg/npm.txt`) and executes local update scripts.
- `make gopkg.update`: Specifically updates Go packages and regenerates `pkg/gopkg.txt`.

## Testing

The `Makefile` includes several targets for testing the installation process:
- `make test.init`: Installs `coreutils` (specifically `gsplit`) and splits `pkg/brew.txt` into smaller files for staged testing.
- `make test.brew.0`: Installs brew packages from `brew-0`.
- `make test.brew.1`: Installs brew packages from `brew-1`.
- `make test.brew.2`: Installs brew packages from `brew-2`.
- `make test.cask`: Installs Homebrew Cask applications from `pkg/cask.txt`.
- `make test.deploy`: Verifies the deployment of dotfiles by running the `deploy` target.

**Note**: There are no explicit `lint` or `format` targets defined in the `Makefile`. Code style is likely enforced through individual tool configurations (e.g., Neovim linting plugins, editor settings) or implicitly by the nature of dotfile configuration. For shell scripts, it's advisable to manually run linters like `shellcheck`. For Go, `go fmt` and `go lint` are standard. For JavaScript, linters like ESLint and formatters like Prettier would typically be used.

## Entrypoints
The primary "entrypoint" for this project is the `Makefile`, which orchestrates the setup and maintenance. Users interact with the system by invoking `make` commands.
Individual shell scripts in `hack/` and `install/` also serve as entrypoints for specific functionalities.
The various configuration files (e.g., `.zshrc`, `.tmux.conf`, `.config/nvim/init.vim`) are implicitly "run" or sourced by their respective applications when the environment is loaded.

## Utility Commands (System-specific for Darwin)
- `brew`: Homebrew package manager.
- `git`: Version control.
- `ls`, `cd`, `grep`, `find`: Standard Unix-like commands, possibly with GNU versions installed via Homebrew (`coreutils`).
- `npm`: Node.js package manager.
- `go`: Go toolchain.
- `zsh`: Default shell.
- `curl`: Used in installation scripts.
- `xargs`: Command line utility.
- `jq`: JSON processor used in `update` target.
- `ln`: For creating symbolic links.

Users should be familiar with these commands for effective development in this environment.