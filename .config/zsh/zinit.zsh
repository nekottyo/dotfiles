# module
module_path+=( "${HOME}/.zinit/bin/zmodules/Src" )
zmodload zdharma/zplugin

### Added by zinit's installer
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

if [[ ! -f ${HOME}/.zinit/bin/zinit.zsh.zwc ]]; then
    zinit self-update
fi
## End of zinit's installer chunk

zinit ice depth=1 atload"!source ~/.p10k.zsh"
zinit light romkatv/powerlevel10k

zinit light romkatv/zsh-defer

zinit ice wait lucid for \
  greymd/tmux-xpanes

DIRCOLORS_SOLARIZED_ZSH_THEME="ansi-light"
zinit ice wait lucid
zinit light pinelibg/dircolors-solarized-zsh

zinit ice wait lucid as"program" src"z.sh"
zinit load "rupa/z"

zinit ice wait lucid from"gh-r" as"program" mv"fzf-bin -> fzf" bpick"*linux*" if'[[ "$OSTYPE" != *darwin* ]]'
zinit light junegunn/fzf-bin

ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd
zinit ice wait'0c' lucid atload'_zsh_autosuggest_start'
zinit load zsh-users/zsh-autosuggestions

zinit ice wait'1' lucid
zinit light zdharma/fast-syntax-highlighting

zinit ice wait'1' lucid as"program" pick"bin/color" pick"bin/histuniq"
zinit load "Jxck/dotfiles"

zinit ice wait'1' lucid as"program" pick"hub/etc/hub.zsh_completion"
zinit light github/hub

zinit ice wait'2' lucid atload"zicompinit; zicdreplay" blockf for \
  zsh-users/zsh-completions

zinit ice wait'2' lucid as"program" pick "contrib/completion/git-completion.zsh"
zinit light git/git

zinit ice wait'2' lucid
zinit light yous/vanilli.sh

zinit ice wait'2' lucid
zinit snippet OMZ::plugins/ssh-agent/ssh-agent.plugin.zsh

zinit ice wait'3' lucid as"program" pick"cli/contrib/completion/zsh/_docker"
zinit light docker/cli

zinit ice wait'3' lucid as"program" pick"compose/contrib/completion/zsh"
zinit light docker/compose
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

zinit ice wait'3' lucid
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit cdclear -q
setopt promptsubst

zinit ice wait'3' lucid
zinit light mollifier/cd-gitroot

zinit ice wait'3' lucid
zinit load zdharma/history-search-multi-word

zinit ice wait'3' lucid as"program" pick"bin/git-dsf"
zinit light zdharma/zsh-diff-so-fancy

zinit ice wait'4' lucid as"program" pick"gibo"
zinit load simonwhitaker/gibo

zinit ice wait'4' lucid as"completion"
zinit snippet OMZ::plugins/terraform/_terraform

zsh-defer -t 1 -c 'autoload -Uz compinit && compinit && zinit cdreplay -q'
# autoload -Uz compinit && compinit && zinit cdreplay -q
