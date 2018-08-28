source ~/.zplug/init.zsh

# Make sure to use double quotes
#zplug "zsh-users/zsh-history-substring-search", use:zsh-history-substring-search.zsh

# Use the package as a command
# And accept glob patterns (e.g., brace, wildcard, ...)
zplug "Jxck/dotfiles", as:command, use:"bin/{histuniq,color}"

# Can manage everything e.g., other person's zshrc
#zplug "tcnksm/docker-alias", use:zshrc

# Disable updates using the "frozen" tag
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

#zplug "b4b4r07/dotfiles",  \
#    use:bin/peco-tmux

# Supports oh-my-zsh plugins and the like
zplug "plugins/git",   from:oh-my-zsh

# Also prezto
#zplug "modules/prompt", from:prezto

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

# Can manage gist file just like other packages
#zplug "b4b4r07/79ee61f7c140c63d2786", \
#    from:gist, \
#    as:command, \
#    use:get_last_pane_path.sh

# Support bitbucket
#zplug "b4b4r07/hello_bitbucket", \
#    from:bitbucket, \
#    as:command, \
#    use:"*.sh"

# Rename a command with the string captured with `use` tag
zplug "b4b4r07/httpstat", \
    as:command, \
    use:'(*).sh', \
    rename-to:'$1'

# Set the priority when loading
# e.g., zsh-syntax-highlighting must be loaded
# after executing compinit command and sourcing other plugins
# (If the defer tag is given 2 or above, run after compinit command)
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# Can manage local plugins
#zplug "~/.zsh", from:local

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

zplug "zsh-users/zsh-autosuggestions", \
    defer:2

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
# anyenv
export PATH="/usr/bin:$PATH"
export PATH="$HOME/.anyenv/bin:$PATH"
export PATH="$HOME/.local/bin/powerline:$PATH"
eval "$(anyenv init - --no-rehash)"

# go
export GOPATH=$HOME/.golang
export GOROOT=$( go env GOROOT )
export PATH=$GOPATH/bin:$PATH


## aliases
alias vim="nvim"
alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias hop="ssh hop"
alias dcp="docker-compose"
alias k="kubectl"
alias vimdiff="nvim -d"

## env
export LC_CTYPE='ja_JP.UTF-8'

source /usr/share/nvm/init-nvm.sh

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

# direnv
eval "$(direnv hook zsh)"


## kubectl completion
export KUBECONFIG=~/.kube/config:$(ls ~/.kube/config-*)
. <(kubectl completion zsh)
. <(helm completion zsh)
. <(stern --completion zsh)

if [ $DOTFILES/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi
