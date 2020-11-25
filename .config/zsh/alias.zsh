exists "bat"       && alias cat="bat --theme='OneHalfDark'"
exists "lsd"       && alias ls="lsd"
exists "colordiff" && alias diff="colordiff"
exists "hub"       && alias git="hub"
exists "terraform" && alias t="terraform"

## aliases
alias vim="nvim"

# alias ls="ls --color=auto"
# exists "exa" && alias ls="exa"
alias d="docker"
alias dc="docker-compose"
alias k="kubecolor"
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

# https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/common-aliases/common-aliases.plugin.zsh
alias l='ls -lFh'     #size,show type,human readable
alias la='ls -lAFh'   #long list,show almost all,show type,human readable
alias lr='ls -tRFh'   #sorted by date,recursive,show type,human readable
alias lt='ls -ltFh'   #long list,sorted by date,show type,human readable
alias ll='ls -l'      #long list
alias ldot='ls -ld .*'
alias lS='ls -1FSsh'
alias lart='ls -1Fcart'
alias lrt='ls -1Fcrt'

alias zshrc='${=EDITOR} ~/.zshrc' # Quick access to the ~/.zshrc file
alias dotfiles='${=EDITOR} ~/dotfiles'
alias vimrc='${=EDITOR} ${XDG_CONFIG_HOME}/dein'
