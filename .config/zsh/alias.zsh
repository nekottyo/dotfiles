exists "bat"       && alias cat="bat --theme='OneHalfDark'"
exists "lsd"       && alias ls="lsd"
exists "colordiff" && alias diff="colordiff"
exists "terraform" && alias t="terraform"

# headroom wrap は外した。resume 時に CCR の headroom_retrieve 履歴修復 (neutralize) が
# 不正なリクエストを作り、セッションが 400 (tool use concurrency) で再開不能になった (2026-10-05)
exists "claude" \
  && claude() {
    command claude --model "opus[1m]" --append-system-prompt-file ~/.claude/sr_opus_5_system_prompt.md "$@"
}
# alias claude='claude --model "opusplan" --effort "high" --append-system-prompt-file ~/.claude/sr_opus_5_system_prompt.md'

alias oclaude='claude --model "opus[1m]"'
alias fclaude='claude --model "claude-fable-5-1[1m]"'
# alias srclaude='claude --model "opus[1m]" --append-system-prompt-file ~/.claude/sr_opus_5_system_prompt.md '


# Copilot CLI のテレメトリをローカルの LGTM スタックへ送る (hack/claude-telemetry)
# Claude Code は gRPC 4317 を使うが、Copilot CLI は OTLP HTTP のみ対応なので 4318 を使う。
# global に export すると OTel を読む他ツールへ波及するため、copilot 起動時だけ効く wrapper にしている。
exists "copilot" \
  && copilot() {
  OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318 \
  OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf \
  command copilot --model claude-opus-5.5 "$@"
}

# alias copilot='OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318 OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf copilot --model gemini-3.7-flash'

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
