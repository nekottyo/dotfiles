# source command override technique
# https://zenn.dev/fuzmare/articles/zsh-source-zcompile-all
function source {
  ensure_zcompiled $1
  builtin source $1
}
function ensure_zcompiled {
  local compiled="$1.zwc"
  if [[ ! -r "$compiled" || "$1" -nt "$compiled" ]]; then
    echo "\033[1;36mCompiling\033[m $1"
    zcompile $1
  fi
}
ensure_zcompiled ~/.zshrc

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ -f ~/.profile ]] && source ~/.profile

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

# https://sunday-morning.app/posts/2019-08-31-tmux-ctrl-a
bindkey -e

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
zstyle ':completion:*:(ssh|scp|sftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'



## kubectl completion
if [[ -a ~/.kube/config ]]; then
  export KUBECONFIG=~/.kube/config
fi

if [[ -a ~/.localenv ]]; then
  . ~/.localenv
fi

[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
if [ -z "$TMUX" ]; then
  [[ -d /opt/homebrew/bin ]] && export PATH="$PATH:/opt/homebrew/bin"

  if [[ $(uname) == "Darwin" ]]; then
      export PATH=/usr/local/opt/coreutils/libexec/gnubin:${PATH}
  fi
  ## nvim
  export XDG_CONFIG_HOME=$HOME/.config

  ## PATH
  export PATH="${PATH}:/usr/local/bin:/usr/bin:/bin:${HOME}/.local/bin"

  ## krew
  ### https://github.com/kubernetes-sigs/krew
  export PATH="${PATH}:${HOME}/.krew/bin"

  export PATH="${HOME}/.local/bin/powerline:${PATH}"

  if [[ -d "${KREW_ROOT:-$HOME/.krew}" ]]; then
    export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
  fi

  if [[ -d  "${HOME}/.cargo/bin" ]]; then
    export PATH="$PATH:$HOME/.cargo/bin"
  fi

  if exists "go"; then
    export PATH="$(go env GOPATH)/bin:${PATH}"
  fi
fi

source ~/.config/zsh/zinit.zsh
export EDITOR=nvim

[ -f ~/.fzf.zsh ] && . ~/.fzf.zsh
export FZF_DEFAULT_OPTS='--height 60% --reverse --border --ansi'
export FZF_CTRL_T_OPTS="--preview 'head -100 {}'"

zsh-defer . ~/.config/zsh/lazy_completion.zsh

## for Mac OS
if [[ $(uname) == "Darwin" ]]; then
  . ~/.config/zsh/macos.zsh
fi

if exists "saml2aws"; then
  SAML_LOGIN_CMD="export AWS_PROFILE=default; saml2aws login --skip-prompt -a default --force --session-duration=10800"

  alias alogin="${SAML_LOGIN_CMD}"
  alias aadmin="${SAML_LOGIN_CMD} --role=\"${SSO_ADMIN}\""
  alias asand="${SAML_LOGIN_CMD} --role=\"${SSO_SANDBOX_ADMIN}\""
fi


. ~/.config/zsh/alias.zsh
. ~/.config/zsh/tmux-ssh-overwrite-bg.zsh
. ~/.config/zsh/utils.zsh

# zsh-defer eval "$(starship init zsh)"
zsh-defer -c "$(pyenv init -)"

zsh-defer source ~/.config/zsh/logging_tmux_pane.zsh


if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

if (which zprof > /dev/null) ;then
  zprof | less
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

if [ -x "/opt/homebrew/bin/mise" ]; then
  export MISE_ACTIVATE_AGGRESSIVE=1
  eval "$(/opt/homebrew/bin/mise activate zsh)"
fi
