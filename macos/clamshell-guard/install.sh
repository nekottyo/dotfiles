#!/bin/sh
#
# clamshell-guard を LaunchDaemon として登録する。root 権限が要る。
#
#   sudo ./install.sh
#
set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
LABEL=com.nekottyo.clamshell-guard
INSTALLED_SCRIPT=/usr/local/sbin/clamshell-guard.sh
INSTALLED_PLIST="/Library/LaunchDaemons/${LABEL}.plist"
INSTALLED_CONFIG=/usr/local/etc/clamshell-guard.conf

if [ "$(id -u)" -ne 0 ]; then
	echo "error: must be run as root (use sudo)" >&2
	exit 1
fi

mkdir -p /usr/local/sbin /usr/local/etc

# LaunchDaemon が root で実行するため、書き換え可能な場所に置かない。
# root 所有かつ他ユーザーから書けない権限で配置する
install -o root -g wheel -m 0755 "${SCRIPT_DIR}/clamshell-guard.sh" "$INSTALLED_SCRIPT"
install -o root -g wheel -m 0644 "${SCRIPT_DIR}/${LABEL}.plist" "$INSTALLED_PLIST"

# 設定は実機側の資産なので、再インストールで書き潰さない
if [ -f "$INSTALLED_CONFIG" ]; then
	echo "config: ${INSTALLED_CONFIG} (existing, kept)"
else
	install -o root -g wheel -m 0644 "${SCRIPT_DIR}/clamshell-guard.conf.example" "$INSTALLED_CONFIG"
	echo "config: ${INSTALLED_CONFIG} (created from example)"
fi

# 再インストール時に備えて、既に動いていれば一度降ろす
launchctl bootout "system/${LABEL}" 2>/dev/null || true
launchctl bootstrap system "$INSTALLED_PLIST"

echo "installed: ${LABEL}"
echo "log: /var/log/clamshell-guard.log"

# 設定が空のままだと常時 no-op になり、入れたのに効かない状態に気づけないので明示する
KNOWN_GATEWAYS=''
ALWAYS_ON_GATEWAYS=''
# shellcheck source=/dev/null
. "$INSTALLED_CONFIG"
if [ -z "$KNOWN_GATEWAYS" ] && [ -z "$ALWAYS_ON_GATEWAYS" ]; then
	echo >&2
	echo "warning: KNOWN_GATEWAYS and ALWAYS_ON_GATEWAYS are both empty; sleep will never be disabled." >&2
	echo "         add the gateway MAC to ${INSTALLED_CONFIG}:" >&2
	echo "           arp -n \"\$(ipconfig getoption en0 router)\"" >&2
fi
