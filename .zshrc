[[ -f ~/.profile ]] && source ~/.profile
. ~/.config/zsh/p10k.zsh

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



# The next line updates PATH for the Google Cloud SDK.
# if [ -f "/home/${USERNAME}/google-cloud-sdk/path.zsh.inc" ]; then source "/home/${USERNAME}/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
# if [ -f "/home/${USERNAME}/google-cloud-sdk/completion.zsh.inc" ]; then source "/home/${USERNAME}/google-cloud-sdk/completion.zsh.inc"; fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 60% --reverse --border --ansi'
export FZF_CTRL_T_OPTS="--preview 'head -100 {}'"


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

source ~/.config/zsh/zinit.zsh
zinit ice depth=1; zinit light romkatv/powerlevel10k

if [ -z "$TMUX" ]; then

  if [[ $(uname) == "Darwin" ]]; then
      export PATH=/usr/local/opt/coreutils/libexec/gnubin:${PATH}
  fi
  ## nvim
  export XDG_CONFIG_HOME=$HOME/.config

  ## PATH
  export PATH=${PATH}:/usr/local/bin

  ## krew
  ### https://github.com/kubernetes-sigs/krew
  export PATH="${PATH}:${HOME}/.krew/bin"

  ## anyenv
  export PATH="${PATH}:/usr/bin"
  export PATH="${HOME}/.anyenv/bin:${PATH}"
  export PATH="${HOME}/.local/bin/powerline:${PATH}"
  . ~/.config/zsh/anyenv-defer.zsh
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
  alias aadmin="${SAML_LOGIN_CMD} --role=\"${SSO_ADMIN}\""
  alias asand="${SAML_LOGIN_CMD} --role=\"${SSO_SANDBOX_ADMIN}\""
fi


. ~/.config/zsh/utils.zsh
. ~/.config/zsh/alias.zsh
. ~/.config/zsh/tmux-ssh-overwrite-bg.zsh
. ~/.config/zsh/utils.zsh

# zsh-defer eval "$(starship init zsh)"
zsh-defer -c "$(pyenv init -)"

autoload -Uz compinit
compinit
zinit cdreplay -q

zsh-defer source ~/.config/zsh/logging_tmux_pane.zsh

if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

if (which zprof > /dev/null) ;then
  zprof | less
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
