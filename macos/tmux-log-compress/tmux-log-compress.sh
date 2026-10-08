#!/bin/sh
#
# rotatelogs が日次で切り出した tmux pane ログ (.config/zsh/logging_tmux_pane.zsh) を gzip する。
#
set -eu

LOG_DIR="${HOME}/.logs/tmux"
now=$(date +%s)

for f in "$LOG_DIR"/*.log.[0-9]*; do
	[ -e "$f" ] || continue
	case "$f" in *.gz) continue ;; esac

	# 末尾の epoch は rotatelogs が付けた期間の開始時刻。期間を過ぎたファイルへは
	# rotatelogs が二度と書かないので、fd が開いたままでも圧縮して失うものはない。
	# offset 指定でずれる境界を気にしなくて済むよう、2 日の余裕をとる
	start=${f##*.}
	[ $((start + 172800)) -lt "$now" ] || continue

	gzip "$f"
	echo "compressed: $f"
done
