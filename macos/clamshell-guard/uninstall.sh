#!/bin/sh
#
# clamshell-guard を取り外す。root 権限が要る。
#
#   sudo ./uninstall.sh
#
set -eu

LABEL=com.nekottyo.clamshell-guard
INSTALLED_SCRIPT=/usr/local/sbin/clamshell-guard.sh
INSTALLED_PLIST="/Library/LaunchDaemons/${LABEL}.plist"
INSTALLED_CONFIG=/usr/local/etc/clamshell-guard.conf

if [ "$(id -u)" -ne 0 ]; then
	echo "error: must be run as root (use sudo)" >&2
	exit 1
fi

launchctl bootout "system/${LABEL}" 2>/dev/null || true
rm -f "$INSTALLED_PLIST" "$INSTALLED_SCRIPT"

# 監視役がいなくなるため、抑止が有効なまま取り残されないよう必ず戻す
pmset -a disablesleep 0

echo "uninstalled: ${LABEL}"
echo "disablesleep restored to 0"

# 設定はリポジトリに無い実機側の資産なので、消さずに残して入れ直しに備える
if [ -f "$INSTALLED_CONFIG" ]; then
	echo "kept: ${INSTALLED_CONFIG} (remove it manually to discard the gateway list)"
fi
