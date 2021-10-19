DOTFILES_EXCLUDES := .DS_Store .git .gitmodules
DOTFILES_TARGET   := $(wildcard .??*)
DOTFILES_DIR      := $(PWD)
DOTFILES_FILES    := $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))
CONFIG_DIR        := .config/
CONFIG_TARGET     := $(addprefix $(CONFIG_DIR), dein nvim terminator tmux alacritty zsh efm-langserver starship.toml)

deploy:
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@$(foreach val, $(CONFIG_TARGET), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

install-brew:
	/usr/bin/ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

install: install-brew
	cat pkg/brew_tap.txt | xargs -n1 brew tap
	cat pkg/brew.txt | xargs brew install || true
	cat pkg/cask.txt | xargs brew install --cask

update:
	brew tap > pkg/brew_tap.txt
	brew leaves > pkg/brew.txt
	brew list --cask > pkg/cask.txt

test.init:
	brew install coreutils
	gsplit -n 3 -d -a1 pkg/brew.txt brew-

test.tap: install-brew
	cat pkg/brew_tap.txt | xargs -n1 brew tap

test.brew.0: install-brew test.init test.tap
	cat brew-0 | xargs brew install || true

test.brew.1: install-brew test.init test.tap
	cat brew-1 | xargs brew install || true

test.brew.2: install-brew test.init test.tap
	cat brew-2 | xargs brew install || true

test.cask: install-brew test.tap
	cat pkg/cask.txt | xargs brew install --cask

test.deploy: deploy
