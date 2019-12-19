[[ -f ~/.profile ]] && source ~/.profile

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

function exists() {
  (( ${+commands[$1]} ))
}

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

HISTSIZE=100000
SAVEHIST=100000

setopt always_last_prompt
setopt auto_cd
setopt auto_list
setopt auto_menu
setopt auto_param_keys
setopt auto_param_slash
setopt auto_pushd
setopt brace_ccl
setopt correct
setopt equals
setopt globdots
setopt hist_ignore_dups
setopt hist_no_store
setopt hist_reduce_blanks
setopt hist_reduce_blanks
setopt share_history
setopt append_history
setopt inc_append_history
setopt interactive_comments
setopt list_packed
setopt list_types
setopt magic_equal_subst
setopt mark_dirs
setopt no_beep
setopt no_tify
setopt nolistbeep
setopt prompt_subst
setopt pushd_ignore_dups

autoload colors
zstyle ':completion:*' use-cache true
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin \
                             /usr/sbin /usr/bin /sbin /bin /usr/local/git/bin
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([%0-9]#)*=0=01;31'
zstyle ':completion:*' insert-tab false
zstyle ':completion:*' completer _expand _complete _match _prefix _approximate _list
zstyle ':completion:*:messages' format '%F{YELLOW}%d'$DEFAULT
zstyle ':completion:*:warnings' format '%F{RED}No matches for:''%F{YELLOW} %d'$DEFAULT
zstyle ':completion:*:descriptions' format '%F{YELLOW}completing %B%d%b'$DEFAULT
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:descriptions' format '%F{yellow}Completing %B%d%b%f'$DEFAULT


if [ "${TMUX}" != "" ] ; then
  tmux pipe-pane 'cat | rotatelogs /var/log/tmux/%Y%m%d_%H-%M-%S_#S:#I.#P.log 86400 540'
fi


# The next line updates PATH for the Google Cloud SDK.
if [ -f "/home/${USERNAME}/google-cloud-sdk/path.zsh.inc" ]; then source "/home/${USERNAME}/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "/home/${USERNAME}/google-cloud-sdk/completion.zsh.inc" ]; then source "/home/${USERNAME}/google-cloud-sdk/completion.zsh.inc"; fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 60% --reverse --border --ansi'
export FZF_CTRL_T_OPTS="--preview 'head -100 {}'"


### Added by Zplugin's installer
source "$HOME/.zplugin/bin/zplugin.zsh"
autoload -Uz _zplugin


if [[ ! -f ${HOME}/.zplugin/bin/zplugin.zsh.zwc ]]; then
    zplugin self-update
fi
## End of Zplugin's installer chunk



## kubectl completion
if [[ -a ~/.kube/config ]]; then
  export KUBECONFIG=~/.kube/config
fi
#setopt nonomatch
# if ls ~/.kube/config-* 1>/dev/null 2>&1; then
#   for f in ~/.kube/config-*; do
#     export KUBECONFIG=${KUBECONFIG}:${f}
#   done
# fi
#setopt nomatch

zplugin light romkatv/zsh-defer


DIRCOLORS_SOLARIZED_ZSH_THEME="ansi-light"
zplugin ice wait lucid
zplugin light pinelibg/dircolors-solarized-zsh

zplugin ice wait lucid as"program" src"z.sh"
zplugin load "rupa/z"

zplugin ice wait lucid from"gh-r" as"program" mv"fzf-bin -> fzf" bpick"*linux*" if'[[ "$OSTYPE" != *darwin* ]]'
zplugin light junegunn/fzf-bin

ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd
zplugin ice wait'0c' lucid atload'_zsh_autosuggest_start'
zplugin load zsh-users/zsh-autosuggestions

zplugin ice wait'1' lucid atinit"ZPLGM[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay"
zplugin light zdharma/fast-syntax-highlighting

zplugin ice wait'1' lucid as"program" pick"bin/color" pick"bin/histuniq"
zplugin load "Jxck/dotfiles"


zplugin ice wait'1' lucid as"program" make
zplugin load jhawthorn/fzy

zplugin ice wait'1' lucid as"program" pick"hub/etc/hub.zsh_completion"
zplugin light github/hub

zplugin ice wait'1' lucid
zplugin light zsh-users/zsh-completions

zplugin ice wait lucid
zplugin light mafredri/zsh-async

zplugin ice wait'2' lucid as"program" pick "contrib/completion/git-completion.zsh"
zplugin light git/git

zplugin ice wait'2' lucid
zplugin light yous/vanilli.sh

zplugin ice wait'2' lucid
zplugin snippet OMZ::plugins/ssh-agent/ssh-agent.plugin.zsh

zplugin ice wait'3' lucid as"program" pick"git-foresta"
zplugin light takaaki-kasai/git-foresta

zplugin ice wait'3' lucid as"program" pick"cli/contrib/completion/zsh/_docker"
zplugin light docker/cli

zplugin ice wait'3' lucid as"program" pick"compose/contrib/completion/zsh"
zplugin light docker/compose
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

zplugin ice wait'3' lucid
zplugin snippet OMZ::plugins/git/git.plugin.zsh
zplugin cdclear -q
setopt promptsubst

zplugin ice wait'3' lucid
zplugin light greymd/tmux-xpanes

zplugin ice wait'3' lucid as"program" pick"gibo"
zplugin load simonwhitaker/gibo
zplugin ice wait'3' lucid
zplugin light mollifier/cd-gitroot


if [ -z "$TMUX" ]; then

  if [[ $(uname) == "Darwin" ]]; then
      export PATH=/usr/local/opt/coreutils/libexec/gnubin:${PATH}
  fi
  ## nvim
  export XDG_CONFIG_HOME=$HOME/.config

  ## PATH
  export PATH=/usr/local/bin:${PATH}


  # anyenv
  export PATH="${PATH}:/usr/bin"
  export PATH="${HOME}/.anyenv/bin:${PATH}"
  export PATH="${HOME}/.local/bin/powerline:${PATH}"
  zsh-defer . ~/.config/zsh/anyenv-defer.zsh
fi

export EDITOR=nvim


zsh-defer . ~/.config/zsh/lazy_completion.zsh


if exists "terraform"; then
  alias t="terraform"
  if [[ -f  "${HOME}/.anyenv/envs/tfenv/versions/0.11.14/terraform terraform" ]]; then
    complete -o nospace -C ${HOME}/.anyenv/envs/tfenv/versions/0.11.14/terraform terraform
  fi
fi

## for Mac OS
if [[ $(uname) == "Darwin" ]]; then
  zsh-defer . ~/.config/zsh/macos.zsh
fi

if exists "saml2aws"; then
  SAML_LOGIN_CMD="saml2aws login --skip-prompt -a default --force --session-duration=10800"

  alias alogin="${SAML_LOGIN_CMD}"
  alias aadmin="${SAML_LOGIN_CMD} --role=\"$SSO_ADMIN\""
  alias asand="${SAML_LOGIN_CMD} --role=\"$SSO_SANDBOX_ADMIN\""
fi

. ~/.config/zsh/alias.zsh
. ~/.config/zsh/tmux-ssh-overwrite-bg.zsh
. ~/.config/zsh/utils.zsh

autoload -U +X bashcompinit && bashcompinit
eval "$(starship init zsh)"
zsh-defer -c "$(pyenv init -)"

if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

if (which zprof > /dev/null) ;then
  zprof | less
fi

