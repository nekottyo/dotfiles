# https://bacchi.me/linux/change-terminal-bgcolor/
#
PRD_IP_PREFIX=${PRD_IP_PREFIX:-"prd-"}
STG_IP_PREFIX=${STG_IP_PREFIX:-"stg-"}
function ssh() {
  # tmux起動時
  if [[ -n $(printenv TMUX) ]] ; then
      # 現在のペインIDを記録
      local pane_id=$(tmux display -p '#{pane_id}')
      # 接続先ホスト名に応じて背景色を切り替え
      if [[ $(echo $1 | grep "${PRD_IP_PREFIX}") ]] ; then
          tmux select-pane -P 'bg=colour125'
      elif [[ $(echo $1 | grep "${STG_IP_PREFIX}") ]] ; then
          tmux select-pane -P 'bg=colour61'
      fi

      # 通常通りssh続行
      command ssh $@

      # デフォルトの背景色に戻す
      tmux select-pane -t $pane_id -P 'default'
  else
      command ssh $@
  fi
}
