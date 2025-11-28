# Suggested Commands for Development

This document outlines essential commands for developing and maintaining the dotfiles project.

## Project-Specific Commands (via `make`)

These commands are defined in the `Makefile` and automate common tasks:

-   **`make install`**:
    -   **Purpose**: Performs initial setup, including Homebrew installation (if needed) and installation of packages from `pkg/brew.txt` and `pkg/npm.txt`.
    -   **Usage**: `make install`

-   **`make deploy`**:
    -   **Purpose**: Creates symbolic links for all dotfiles (files starting with `.`) and specified configuration directories from the project's root to your home directory (`~`). This makes your dotfiles active.
    -   **Usage**: `make deploy`

-   **`make update`**:
    -   **Purpose**: Updates installed packages and regenerates the package lists in the `pkg/` directory. This ensures your `pkg/*.txt` files reflect your current installed software.
    -   **Usage**: `make update`

-   **`make install-brew`**:
    -   **Purpose**: Installs Homebrew, the macOS package manager, if it's not already installed.
    -   **Usage**: `make install-brew`

-   **`make install-zinit`**:
    -   **Purpose**: Installs Zinit, a Zsh plugin manager, if it's not found in your system's PATH.
    -   **Usage**: `make install-zinit`

-   **`make install-go`**:
    -   **Purpose**: Installs Go packages listed in `pkg/gopkg.txt`.
    -   **Usage**: `make install-go`

-   **`make gopkg.update`**:
    -   **Purpose**: Specifically updates Go packages and refreshes `pkg/gopkg.txt`.
    -   **Usage**: `make gopkg.update`

-   **`make test.<category>`**:
    -   **Purpose**: A suite of commands (e.g., `test.init`, `test.brew.0`, `test.cask`, `test.deploy`) designed to test the installation and deployment process. Refer to the `Makefile` for specific test targets.
    -   **Usage**: `make test.deploy` (example)

## General System Utilities (Darwin/macOS)

These are standard commands frequently used in this development environment:

-   **`git`**:
    -   **Purpose**: Version control operations (cloning, committing, pushing, pulling, branching, etc.).
    -   **Usage**: `git status`, `git add .`, `git commit -m "Message"`, `git push`

-   **`brew`**:
    -   **Purpose**: Homebrew package manager for installing, updating, and managing software on macOS.
    -   **Usage**: `brew install <package>`, `brew update`, `brew upgrade`, `brew doctor`

-   **`npm`**:
    -   **Purpose**: Node.js package manager for installing, updating, and managing JavaScript packages.
    -   **Usage**: `npm install <package>`, `npm update`, `npm list -g`

-   **`go`**:
    -   **Purpose**: Go programming language toolchain for building, installing, and managing Go applications and packages.
    -   **Usage**: `go install <package>`, `go build`, `go run`

-   **`zsh`**:
    -   **Purpose**: The default shell for this project. Customizations are in `.zshrc` and `.config/zsh/`.
    -   **Usage**: Interacting with the terminal.

-   **`ls`, `cd`, `pwd`, `cp`, `mv`, `rm`**:
    -   **Purpose**: Fundamental file system navigation and manipulation commands.
    -   **Note**: On macOS, some GNU core utilities (like `gsplit` used in `Makefile`) might need to be installed via Homebrew (`brew install coreutils`) if their BSD equivalents behave differently.

-   **`grep`, `find`**:
    -   **Purpose**: Powerful command-line utilities for searching text within files and locating files/directories based on various criteria.
    -   **Usage**: `grep -r "pattern" .`, `find . -name "*.zsh"`

-   **`curl`**:
    -   **Purpose**: Used in installation scripts to download files from the internet.
    -   **Usage**: `curl -fsSL <URL>`

-   **`xargs`**:
    -   **Purpose**: Builds and executes command lines from standard input. Often used with `cat` and `brew install`.
    -   **Usage**: `cat file.txt | xargs command`

-   **`jq`**:
    -   **Purpose**: A lightweight and flexible command-line JSON processor, used in the `update` target for `npm list`.
    -   **Usage**: `cat data.json | jq '.key'`

-   **`ln`**:
    -   **Purpose**: Creates links (symbolic or hard) between files. Used extensively by `make deploy`.
    -   **Usage**: `ln -sfnv <source> <destination>`
