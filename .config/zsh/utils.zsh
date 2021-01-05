fpath=($XDG_CONFIG_HOME/zsh/functions/ $fpath)

autoload -Uz fstash

autoload -Uz fghq
zle -N fghq
bindkey '^g' fghq

autoload -Uz fzf-z-search
zle -N fzf-z-search
bindkey '^f' fzf-z-search
bindkey '^[f' fzf-z-search

autoload -Uz fcd
zle -N fcd
bindkey '^t' fcd

if exists "lsec2"; then
  autoload -z lssh
  autoload -z xssh
fi

autoload -Uz eks-write-config
autoload -Uz fdv
autoload -Uz fbr
autoload -Uz ggrok
autoload -z kubectl-get-pod-on-ng
autoload -z aws-list-tg-health
