DOTFILES_EXCLUDES := .DS_Store .git .gitmodules
DOTFILES_TARGET   := $(wildcard .??*)
DOTFILES_DIR      := $(PWD)
DOTFILES_FILES    := $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))
CONFIG_DIR        := .config/
CONFIG_TARGET     := $(addprefix $(CONFIG_DIR), dein nvim terminator tmux alacritty zsh efm-langserver starship.toml)

deploy: install-zinit
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@$(foreach val, $(CONFIG_TARGET), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

install-brew:
	/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

install-zinit:
	where zinit || sh -c "$$(curl -fsSL https://git.io/zinit-install)"

install: install-brew
	cat pkg/brew.txt | xargs brew install || true
	cat pkg/npm.txt | xargs npm i -g

install-go:
	cat pkg/gopkg.txt | xargs -n1 go install

update:
	brew leaves > pkg/brew.txt
	brew list --cask > pkg/cask.txt
	bash ./hack/goinstall.sh show > pkg/gopkg.txt
	zsh ./hack/update-local.zsh
	npm list -g -j | jq -r '.dependencies | keys | .[]' > pkg/npm.txt

gopkg.update:
	./hack/goinstall.sh show | xargs -n1 go install

test.init:
	brew install coreutils
	gsplit -n 3 -d -a1 pkg/brew.txt brew-

test.brew.0: test.init
	cat brew-0 | xargs -t brew install || true

test.brew.1: install-brew test.init
	cat brew-1 | xargs -t brew install || true

test.brew.2: install-brew test.init
	cat brew-2 | xargs -t brew install || true

test.cask: install-brew
	cat pkg/cask.txt | xargs -t brew install --cask

test.deploy: deploy
