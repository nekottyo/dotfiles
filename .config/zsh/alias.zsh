exists "bat"       && alias cat="bat --theme='OneHalfDark'"
exists "lsd"       && alias ls="lsd"
exists "colordiff" && alias diff="colordiff"
exists "terraform" && alias t="terraform"

exists "headroom" && exists "claude" \
  && claude() {
    # headroom の persistent-docker コンテナは HOME (/tmp/headroom-home) 直下が root:root で、
    # 実行ユーザー (ホスト uid に一致) から .cache を作れず、huggingface_hub の cache 書き込みが
    # EACCES で失敗しログを延々と汚す。native wrapper は HF_HOME を forward しないため、
    # コンテナが起動していれば .cache をホスト uid:gid 所有で先に用意しておく (冪等・無害)。
    if command -v docker >/dev/null 2>&1 && docker ps -q -f name='^headroom-default$' | grep -q .; then
      docker exec -u 0 headroom-default sh -c "mkdir -p \"\$HOME/.cache\" && chown $(id -u):$(id -g) \"\$HOME/.cache\"" 2>/dev/null
    fi
    # --memory は付けない。DB が {cwd}/.headroom/memory.db に落ちるうえ storage=project が
    # cwd から project key を切るため、worktree ごとに memory が分断されて実用にならない。
    headroom wrap claude --no-serena --1m --model "claude-opus-5[1m]" -- "$@"
}

# Copilot CLI のテレメトリをローカルの LGTM スタックへ送る (hack/claude-telemetry)
# Claude Code は gRPC 4317 を使うが、Copilot CLI は OTLP HTTP のみ対応なので 4318 を使う。
# global に export すると OTel を読む他ツールへ波及するため、copilot 起動時だけ効く wrapper にしている。
exists "headroom" && exists "copilot" \
  && copilot() {
  OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318 \
  OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf \
  headroom wrap copilot --subscription -- --model claude-opus-5 -- "$@"
}

## aliases
alias vim="nvim"

# alias ls="ls --color=auto"
# exists "exa" && alias ls="exa"
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
