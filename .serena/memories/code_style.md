# Code Style and Conventions

Based on the `Makefile` and file structure, the following conventions are observed:

- **Configuration Management**: Dotfiles and configuration directories (within `.config/`) are managed using symbolic links from the `~/dotfiles` directory to the user's home directory (`~`). The `make deploy` command automates this process.
- **Automation**: `Makefile` is heavily used for automating installation, deployment, and update procedures.
- **Package Management**: Dedicated `pkg/` directory is used to list packages for different package managers (`brew.txt`, `cask.txt`, `npm.txt`, `gopkg.txt`). These lists are managed programmatically via `make update` and consumed by install commands.
- **Scripting**: Shell scripts (e.g., in `hack/` and `install/`) are used for more complex automation tasks.
- **Comments**: Code comments in shell scripts and Makefiles should explain the *why* rather than the *what*.
- **Naming Conventions**:
    - Dotfiles typically start with a `.` (e.g., `.zshrc`, `.tmux.conf`).
    - Makefile targets are descriptive (e.g., `install`, `deploy`, `update`, `test.init`).
    - Script filenames are descriptive (e.g., `goinstall.sh`, `update-local.zsh`).
- **Terminal Aesthetics**: The mention of `MesloLGS NF` font in the `README.md` suggests a focus on a visually pleasing and functional terminal environment.
- **GitHub Actions**: Workflows in `.github/workflows/` indicate a practice of automated testing and potentially continuous integration for changes to the dotfiles.
- **No Hardcoding**: Sensitive information like passwords or API keys should not be hardcoded (as per `GEMINI.md`).
- **Error Handling**: Error handling should be implemented (as per `GEMINI.md`).
- **Documentation**: All public APIs should have documentation (as per `GEMINI.md`).
- **Test-Driven Development (TDD)**: TDD should be practiced according to `t-watda`'s recommended methods (as per `GEMINI.md`).
- **Source Code Comments/Documentation Style**: Use "だ,である調" (plain style) rather than "です,ます調" (polite style) (as per `GEMINI.md`).
- **Performance, Backward Compatibility, Security Best Practices**: These are important considerations (as per `GEMINI.md`).
- **AGENTS.md**: If present, `AGENTS.md` should be read and understood (as per `GEMINI.md`).
- **MCP Server**: If available, MCP server should be utilized (as per `GEMINI.md`).
