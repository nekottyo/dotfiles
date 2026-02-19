ZINIT_HOME="$HOME/.zinit/bin/"
if [[ -d ${XDG_DATA_HOME:-${HOME}/.local/share}/zinit ]]; then
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
fi

### Added by zinit's installer
source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

## End of zinit's installer chunk

zinit ice depth=1 atload"!source ~/.p10k.zsh"
zinit light romkatv/powerlevel10k

zinit light romkatv/zsh-defer

DIRCOLORS_SOLARIZED_ZSH_THEME="ansi-light"
zinit ice wait lucid
zinit light pinelibg/dircolors-solarized-zsh

zinit ice wait lucid as"program" src"z.sh"
zinit load "rupa/z"

zinit ice wait'0c' lucid atload'_zsh_autosuggest_start; ZSH_AUTOSUGGEST_STRATEGY=match_prev_cmd'
zinit load zsh-users/zsh-autosuggestions

zinit ice wait'1' lucid
zinit light zdharma-continuum/fast-syntax-highlighting

zinit ice wait'1' lucid as"program" pick"bin/color" pick"bin/histuniq"
zinit load "Jxck/dotfiles"

fpath=(~/.config/zsh /opt/homebrew/share/zsh/site-functions $fpath)

zinit ice wait'2' lucid atload"zicompinit; zicdreplay" blockf for \
  zsh-users/zsh-completions

zinit ice wait'2' lucid
zinit light yous/vanilli.sh

zinit ice wait'2' lucid
zinit snippet OMZ::plugins/ssh-agent/ssh-agent.plugin.zsh

zinit ice wait'3' lucid
zinit snippet OMZ::plugins/git/git.plugin.zsh
zinit cdclear -q

zinit ice wait'3' lucid
zinit light mollifier/cd-gitroot

zinit ice wait'3' lucid as"program" pick"bin/git-dsf"
zinit light zdharma-continuum/zsh-diff-so-fancy

zinit ice wait'3' lucid
zinit light greymd/tmux-xpanes

zinit ice wait'4' lucid as"program" pick"src/batman.sh" atload"alias man=batman.sh"
zinit light eth-p/bat-extras

zinit ice wait'4' lucid atload"autoload -U +X bashcompinit && bashcompinit; complete -o nospace -C terraform terraform"
zinit light zdharma-continuum/null

zsh-defer -t 1 -c 'autoload -Uz compinit && compinit && zinit cdreplay -q'
