# Zsh Configuration Fixes (Feb 2026)

## Issues Addressed
1. **Completion Conflicts:**
    - `git/git` (Bash wrapper), `github/hub` (alias override), and `OMZ::plugins/git` were interfering with Zsh's standard `_git` completion, causing it to fall back to file completion (e.g., `git stash <TAB>` showing files).
    - `hub` command completion was missing or broken.
    - `docker` completion relied on potentially outdated plugin scripts.
2. **Load Order:**
    - `compinit` was running before completion paths (`fpath`) were fully populated due to incorrect `wait` times in `zinit`.
3. **Missing Paths:**
    - Homebrew's completion directory (`/opt/homebrew/share/zsh/site-functions`) was not in `fpath`.

## Solutions Applied

### 1. Plugin Cleanup & Configuration
- **Disabled:** `git/git`, `docker/cli`, `docker/compose`, `github/hub` plugins in `.config/zsh/zinit.zsh`.
- **Re-enabled:** `OMZ::plugins/git` for aliases, but with `zinit cdclear -q` to discard its conflicting completion definitions.
- **Switched to `gh`:** Removed `hub` configuration entirely. Generated `gh` completion (`gh completion -s zsh > ~/.config/zsh/_gh`) and added it to `fpath`.

### 2. Path & Load Order Fixes
- **`fpath` Adjustment:** Explicitly added `~/.config/zsh` and `/opt/homebrew/share/zsh/site-functions` to `fpath` *before* `compinit` runs.
- **`zinit` Timing:**
    - Moved essential completion plugins to `wait'1'` (before `compinit`).
    - Kept `zsh-users/zsh-completions` at `wait'2'` with `atload"zicompinit; zicdreplay"`.

### 3. Terraform Completion
- Moved `terraform -install-autocomplete` logic from `.zshrc` to `.config/zsh/zinit.zsh` using `bashcompinit` and lazy loading via a dummy plugin (`zdharma-continuum/null`).
- Replaced hardcoded path with `terraform` command from PATH to support version managers like `mise`.

## Resulting Configuration Structure
- **Git:** Uses Zsh/Homebrew standard `_git` + Oh My Zsh aliases.
- **GitHub:** Uses `gh` CLI with generated `_gh` completion.
- **Docker:** Uses Homebrew standard `_docker` completion.
- **Terraform:** Uses `bashcompinit` via lazy loading in `zinit`.

## Verification Commands
- Rebuild cache: `rm -f ~/.zcompdump; compinit`
- Test: `git stash <TAB>`, `gh pr <TAB>`, `terraform plan <TAB>`
