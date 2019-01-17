source ~/.zplug/init.zsh

zplug "Jxck/dotfiles", as:command, use:"bin/{histuniq,color}"
zplug "k4rthik/git-cal", as:command

# Grab binaries from GitHub Releases
# and rename with the "rename-to:" tag
zplug "junegunn/fzf-bin", \
    from:gh-r, \
    as:command, \
    rename-to:fzf, \
    use:"*linux*amd64*"

zplug "junegunn/fzf", \
    as:command, \
    use:"bin/fzf-tmux"

# Supports oh-my-zsh plugins and the like
zplug "plugins/git", \
    from:oh-my-zsh

# Load if "if" tag returns true
zplug "lib/clipboard", from:oh-my-zsh, if:"[[ $OSTYPE == *darwin* ]]"

# Run a command after a plugin is installed/updated
# Provided, it requires to set the variable like the following:
zplug "jhawthorn/fzy", \
    as:command, \
    rename-to:fzy, \
    hook-build:"make && sudo make install"

# Supports checking out a specific branch/tag/commit
zplug "b4b4r07/enhancd", use:enhancd.sh
zplug "mollifier/anyframe"

# Rename a command with the string captured with `use` tag
zplug "b4b4r07/httpstat", \
    as:command, \
    use:'(*).sh', \
    rename-to:'$1'

zplug "zsh-users/zsh-syntax-highlighting", defer:2


# ##########
# user setting
# ##########
source ~/.profile

zplug "joel-porquet/zsh-dircolors-solarized", \
    use:"zsh-dircolors-solarized.plugin.zsh", \
    hook-load:"setupsolarized dircolors.256dark"

zplug "takaaki-kasai/git-foresta", \
    as:command, \
    use:'git-foresta'

zplug "technosophos/glide-zsh"


zplug "simonwhitaker/gibo", \
    as:command, \
    use:gibo
zplug "simonwhitaker/gibo"

zplug "yous/vanilli.sh"
zplug "zsh-users/zsh-completions"
zplug "mollifier/anyframe"
zplug "mafredri/zsh-async", from:github
zplug "greymd/tmux-xpanes"
zplug "mollifier/cd-gitroot"
#zplug "pierpo/fzf-docker"
zplug "docker/cli", \
    use:"cli/contrib/completion/zsh/_docker"

zplug "github/hub", \
    use: "hub/etc/hub.zsh_completion"

zplug "zsh-users/zsh-autosuggestions"
ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd

zplug "rupa/z", use:z.sh
fzf-z-search() {
    local res=$(z | sort -rn | cut -c 12- | fzf)
    if [ -n "$res" ]; then
        BUFFER+="cd $res"
        zle accept-line
    else
        return 1
    fi
}

zle -N fzf-z-search
bindkey '^f' fzf-z-search

# theme
#setopt prompt_subst
#zplug "adambiggs/zsh-theme", use:adambiggs.zsh-theme
#zplug "sindresorhus/pure", use:pure.zsh, from:github, as:theme
zplug "fcamblor/oh-my-zsh-agnoster-fcamblor", use:agnoster-fcamblor.zsh-theme, as:theme
#zplug "martinrotter/powerless", use:powerless.zsh, as:theme
#zstyle ':prezto:module:prompt' theme 'paradox'


# oh-my-zsh
zplug "plugins/git",   from:oh-my-zsh
zplug "plugins/common-aliases",   from:oh-my-zsh
zplug "plugins/archlinux",   from:oh-my-zsh
zplug "plugins/ssh-agent",   from:oh-my-zsh
zplug "plugins/vagrant",   from:oh-my-zsh
zplug "plugins/tmux",   from:oh-my-zsh

setopt share_history
## nvim
export XDG_CONFIG_HOME=$HOME/.config

## PATH
## for Mac OS
if [[ $(uname) == "Darwin" ]]; then
    export PATH=/usr/local/opt/coreutils/libexec/gnubin:${PATH}
fi

if [ -z $TMUX ]; then
  # anyenv
  export PATH="/usr/bin:$PATH"
  export PATH="$HOME/.anyenv/bin:$PATH"
  export PATH="$HOME/.local/bin/powerline:$PATH"
  eval "$(anyenv init - --no-rehash)"

  # go
  export GO111MODULE=on
  export GOPATH=$HOME/.golang
  export GOROOT=$( go env GOROOT )
  export PATH=$GOPATH/bin:$PATH
fi


## aliases
alias vim="nvim"
alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias hop="ssh hop"
alias d="docker"
alias dcp="docker-compose"
alias dc="docker-compose"
alias k="kubectl"
alias vimdiff="nvim -d"

## env
export LC_CTYPE='ja_JP.UTF-8'

#source /usr/share/nvm/init-nvm.sh

zplug check || zplug install
zplug load

if [ "${TMUX}" != "" ] ; then
  tmux pipe-pane 'cat | rotatelogs -L /var/log/tmux/tmux.lnk /var/log/tmux/%Y%m%d_#S:#I.#P.log 86400 540'
fi

if (which zprof > /dev/null) ;then
  zprof | less
fi
eval $(thefuck --alias)

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/${USERNAME}/google-cloud-sdk/path.zsh.inc' ]; then source '/home/staro/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/${USERNAME}/google-cloud-sdk/completion.zsh.inc' ]; then source '/home/staro/google-cloud-sdk/completion.zsh.inc'; fi

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

# fstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
# https://www.reddit.com/r/zsh/comments/5ogkbt/fzf_help/
fstash() {
  emulate -L sh
  local out q k sha
  while out=$(
    git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
    fzf --ansi --no-sort --query="$q" --print-query \
        --expect=ctrl-d,ctrl-b);
  do
    out=( "${(@f)out}" )
    q="${out[0]}"
    k="${out[1]}"
    sha="${out[-1]}"
    sha="${sha%% *}"
    [[ -z "$sha" ]] && continue
    if [[ "$k" == 'ctrl-d' ]]; then
      git diff $sha
    elif [[ "$k" == 'ctrl-b' ]]; then
      git stash branch "stash-$sha" $sha
      break;
    else
      git stash show -p $sha
    fi
  done
}

# direnv
eval "$(direnv hook zsh)"


## kubectl completion
export KUBECONFIG=~/.kube/config:$(ls ~/.kube/config-*)
. <(kubectl completion zsh)
. <(helm completion zsh)
. <(stern --completion zsh)

alias mlcl=molecule

if [ $DOTFILES/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi
