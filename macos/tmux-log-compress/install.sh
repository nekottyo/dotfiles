#!/bin/sh
#
# tmux-log-compress をユーザーの LaunchAgent として登録する。毎日 12:00 に実行され、
# スリープ中で逃した回は復帰時に走る。
#
#   ./install.sh
#
set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
LABEL=com.nekottyo.tmux-log-compress
INSTALLED_PLIST="${HOME}/Library/LaunchAgents/${LABEL}.plist"

cp "${SCRIPT_DIR}/${LABEL}.plist" "$INSTALLED_PLIST"

# 再インストール時に備えて、既に登録されていれば一度降ろす
launchctl bootout "gui/$(id -u)/${LABEL}" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$INSTALLED_PLIST"

echo "installed: ${LABEL}"
echo "log: ${HOME}/.logs/tmux-log-compress.log"
