DOTFILES_EXCLUDES := .DS_Store .git .gitmodules
DOTFILES_TARGET   := $(wildcard .??*)
DOTFILES_DIR      := $(PWD)
DOTFILES_FILES    := $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))
CONFIG_DIR        := .config/
CONFIG_TARGET     := $(addprefix $(CONFIG_DIR), dein nvim terminator tmux alacritty zsh efm-langserver starship.toml)

deploy:
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@$(foreach val, $(CONFIG_TARGET), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

install:
	/usr/bin/ruby -e "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	cat pkg/brew_tap.txt | xargs -n1 brew tap
	cat pkg/brew.txt | xargs brew install || true
	cat pkg/cask.txt | xargs brew cask install

update:
	brew tap > pkg/brew_tap.txt
	brew leaves > pkg/brew.txt
	brew list --cask > pkg/cask.txt
