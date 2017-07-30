DOTFILES_EXCLUDES := .DS_Store .git .gitmodules
DOTFILES_TARGET   := $(wildcard .??*)
DOTFILES_DIR      := $(PWD)
DOTFILES_FILES    := $(filter-out $(DOTFILES_EXCLUDES), $(DOTFILES_TARGET))
CONFIG_DIR        := .config/
CONFIG_TARGET     := $(addprefix $(CONFIG_DIR), dein nvim tmux-powerline) .tmux

deploy:
	@$(foreach val, $(DOTFILES_FILES), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)
	@$(foreach val, $(CONFIG_TARGET), ln -sfnv $(abspath $(val)) $(HOME)/$(val);)

#init:
#	@$(foreach val, $(wildcard ./etc/init/*.sh), bash $(val);)

