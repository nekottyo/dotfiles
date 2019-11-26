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

## aliases
alias vim="nvim"

# alias ls="ls --color=auto"
# exists "exa" && alias ls="exa"
alias grep="grep --color=auto"
alias hop="ssh hop"
alias d="docker"
alias dc="docker-compose"
alias k="kubectl"
#if [[ -n "$PROXY" ]]; then
#  alias kubectl="https_proxy=${PROXY} kubectl"
#  alias skaffold="https_proxy=${PROXY} skaffold"
#  alias stern="https_proxy=${PROXY} stern"
#fi
alias vimdiff="nvim -d"
alias mlcl=molecule

alias ta='tmux attach -t'
alias tad='tmux attach -d -t'
alias ts='tmux new-session -s'
alias tl='tmux list-sessions'
alias tksv='tmux kill-server'
alias tkss='tmux kill-session -t'
alias kunset='kubectl config unset current-context'

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

# fbr - checkout git branch
fbr() {
  local branches branch
  branches=$(git branch -vv) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | awk '{print $1}' | sed "s/.* //")
}




### Added by Zplugin's installer
source "$HOME/.zplugin/bin/zplugin.zsh"
autoload -Uz _zplugin
(( ${+_comps} )) && _comps[zplugin]=_zplugin
zplugin cdclear -q
## End of Zplugin's installer chunk

autoload -Uz compinit
compinit -C

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

DIRCOLORS_SOLARIZED_ZSH_THEME="ansi-light"
# zplugin light zsh-users/zsh-syntax-highlighting
zplugin light zdharma/fast-syntax-highlighting

zplugin ice as"program" pick"git-cal"; zplugin load k4rthik/git-cal

zplugin ice as"program" pick"bin/color" pick"bin/histuniq"; zplugin load "Jxck/dotfiles"

# zplugin ice from"gh-r" as"program" mv"fzf-bin -> fzf" bpick"*linux*" if'[[ "$OSTYPE" != *darwin* ]]'; zplugin light junegunn/fzf-bin

zplugin ice as"program" make; zplugin load jhawthorn/fzy

zplugin ice as"program" pick"unhanced.sh"; zplugin light b4b4r07/enhancd

zplugin ice as"program" cp"httpstat.sh -> httpstat" pick"httpstat"; zplugin light b4b4r07/httpstat

zplugin ice wait'!0' silent; zplugin light pinelibg/dircolors-solarized-zsh

zplugin ice as"program" pick"git-foresta"; zplugin light takaaki-kasai/git-foresta

zplugin ice as"program" pick"gibo"; zplugin load simonwhitaker/gibo


zplugin ice as"program" pick"cli/contrib/completion/zsh/_docker"

zplugin light docker/cli

zplugin ice as"program" pick"compose/contrib/completion/zsh"

zplugin light docker/compose
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1

zplugin ice as"program" pick"hub/etc/hub.zsh_completion"; zplugin light github/hub

zplugin light mafredri/zsh-async

zplugin ice as"program" pick "contrib/completion/git-completion.zsh"; zplugin light git/git

# zplugin ice pick"async.zsh" src"spaceship.zsh"; zplugin light denysdovhan/spaceship-prompt

zplugin load zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd

zplugin ice as"program" src"z.sh"; zplugin load "rupa/z"

zplugin ice wait'0' silent; zplugin light yous/vanilli.sh
zplugin ice wait'0' silent; zplugin light zsh-users/zsh-completions
zplugin ice wait'0' silent; zplugin light greymd/tmux-xpanes
zplugin ice wait'0' silent; zplugin light mollifier/cd-gitroot
# zplugin ice wait'0' silent; zplugin light nnao45/zsh-kubectl-completion


zplugin snippet OMZ::plugins/git/git.plugin.zsh
zplugin snippet OMZ::lib/clipboard.zsh if'[[ "$OSTYPE" == *darwin* ]]'

zplugin snippet OMZ::plugins/common-aliases/common-aliases.plugin.zsh
# zplugin snippet OMZ::plugins/archlinux/archlinux.plugin.zsh
#
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
  eval "$(anyenv init - --no-rehash)"


  # go
  export GO111MODULE=auto
  export GOPATH=${HOME}/.golang
  export GOROOT=$( go env GOROOT )
  export PATH=${GOPATH}/bin:$(go env GOPATH)/bin:${PATH}

  # user npm
  exists "npm" && export PATH=${PATH}:$(npm bin):$(npm -g  bin)

  export EDITOR=nvim
fi


  zplugin ice wait'0' silent; zplugin snippet OMZ::plugins/ssh-agent/ssh-agent.plugin.zsh
  zplugin ice wait'0' silent; exists "kubectl"   && . <(kubectl completion zsh)
  zplugin ice wait'0' silent; exists "helm"      && . <(helm completion zsh)
  zplugin ice wait'0' silent; exists "stern"     && . <(stern --completion zsh)
  zplugin ice wait'0' silent; exists "minikube"  && . <(minikube completion zsh)
  zplugin ice wait'0' silent; exists "direnv"    && . <(direnv hook zsh)
  zplugin ice wait'0' silent; exists "skaffold"  && . <(skaffold completion zsh)
  # zplugin ice wait'0' silent; exists "eksctl"    && . <(eksctl completion zsh)
  zplugin ice wait'0' silent; exists "bat"       && alias cat="bat --theme='OneHalfDark'"
  zplugin ice wait'0' silent; exists "lsd"       && alias ls="lsd"
  zplugin ice wait'0' silent; exists "colordiff" && alias diff="colordiff"
  zplugin ice wait'0' silent; exists "hub"       && alias git="hub"

## for Mac OS
if [[ $(uname) == "Darwin" ]]; then
    zplugin ice wait'0' silent; exists "gxargs" && alias xargs="gxargs"
    zplugin ice wait'0' silent; exists "ggrep"  && alias grep="ggrep --color=auto"
    zplugin ice wait'0' silent; exists "gsed"   && alias sed="gsed"
fi


unalias fd # delete alias set in OMZ::common-aliases


if exists "saml2aws"; then
  SAML_LOGIN_CMD="saml2aws login --skip-prompt -a default --force --session-duration=10800"

  alias alogin="${SAML_LOGIN_CMD}"
  alias aadmin="${SAML_LOGIN_CMD} --role=\"$SSO_ADMIN\""
  alias asand="${SAML_LOGIN_CMD} --role=\"$SSO_SANDBOX_ADMIN\""
fi

. ~/.config/zsh/utils.zsh

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C ${HOME}/.anyenv/envs/tfenv/versions/0.11.14/terraform terraform
eval "$(starship init zsh)"
eval "$(pyenv init -)"

if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

if (which zprof > /dev/null) ;then
  zprof | less
fi

