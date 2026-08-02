#!/bin/sh
#
# 蓋を閉じたときのスリープ (Clamshell Sleep) を、信頼できる場所かつ AC 接続時だけ抑止する。
#
# macOS の `pmset disablesleep` は電源ソース別に持てない (plist の SystemPowerSettings に
# 書かれるため `-c` を付けても全体へ適用される)。素で有効にするとバッテリー駆動時も蓋閉じで
# スリープしなくなり、カバンの中で発熱し続けることになる。そこで条件判定をこのスクリプトが
# 外側から受け持ち、条件を外れたら自動で元に戻す。
#
# 場所の判定に SSID を使わないのは、macOS 15 以降 SSID / BSSID の取得に位置情報の TCC 権限が
# 要り、root の LaunchDaemon からは `<redacted>` しか返らないため。代わりにゲートウェイの MAC
# アドレスを使う。権限不要で読め、同名 SSID の別ネットワークとも取り違えない。
#
set -eu

# 許可するネットワークのゲートウェイ MAC はこのファイルに書かず、設定ファイル側へ逃がす。
# ルーターの LAN 側 MAC は無線側の BSSID と近い値を取るため、公開されている BSSID の
# 位置情報データベースと突き合わせると設置場所の推定に使えてしまう。
# このリポジトリは public なので、自宅ネットワークを同定できる値をコードに含めない。
CONFIG_FILE=${CLAMSHELL_GUARD_CONFIG:-/usr/local/etc/clamshell-guard.conf}

# 設定ファイルが無い、または KNOWN_GATEWAYS が空のときは「どこも既知でない」扱いになり
# 抑止しない。設定漏れが抑止の垂れ流しにならない側へ倒してある。
KNOWN_GATEWAYS=''
if [ -r "$CONFIG_FILE" ]; then
	# shellcheck source=/dev/null
	. "$CONFIG_FILE"
fi

POWER_PLIST=/Library/Preferences/com.apple.PowerManagement.plist

log() {
	printf '%s clamshell-guard: %s\n' "$(date '+%Y-%m-%dT%H:%M:%S%z')" "$1"
}

# MAC アドレスを比較可能な形へ正規化する。
# arp(8) は先頭ゼロを落とすため (例: 1:0:5e:0:0:fb)、各オクテットを 2 桁へ揃える。
normalize_mac() {
	awk -F: '{
		out = ""
		for (i = 1; i <= NF; i++) {
			octet = tolower($i)
			if (length(octet) == 1) {
				octet = "0" octet
			}
			out = out (i > 1 ? ":" : "") octet
		}
		print out
	}'
}

# 物理インターフェース側のゲートウェイ MAC を返す。
#
# `route -n get default` を使わないのは、VPN 接続中はデフォルトルートが utun* に向き、
# トンネルの終端を掴んでしまって物理ネットワークを識別できなくなるため。DHCP が配った
# router オプションから引けば VPN の有無に影響されない。
physical_gateway_mac() {
	for device in $(networksetup -listallhardwareports | awk '/^Device: en/ { print $2 }'); do
		router=$(ipconfig getoption "$device" router 2>/dev/null) || continue
		# DHCP 未取得のインターフェースは空文字か 0.0.0.0 を返す
		case "$router" in
		'' | 0.0.0.0) continue ;;
		esac

		# ARP キャッシュが未充填のことがあるので 1 発だけ叩いて埋める
		ping -c 1 -t 1 "$router" >/dev/null 2>&1 || true

		# arp(8) の出力例: ? (192.168.1.1) at 0:0:5e:0:53:a on en0 ifscope [ethernet]
		# 未解決時は "-- no entry" や "at (incomplete)" になるため MAC の形をしたものだけ拾う
		mac=$(arp -n "$router" 2>/dev/null | awk '$3 == "at" && $4 ~ /^[0-9a-fA-F:]+$/ { print $4 }')
		if [ -n "$mac" ]; then
			printf '%s' "$mac" | normalize_mac
			return 0
		fi
	done

	return 1
}

on_ac_power() {
	pmset -g ps | grep -q "Now drawing from 'AC Power'"
}

# 現在 disablesleep が有効かどうかを 1 / 0 で返す。
# `pmset -g` の表示は他プロセスの assertion と混ざって読みにくいため plist を直接見る。
current_sleep_disabled() {
	if /usr/libexec/PlistBuddy -c 'Print :SystemPowerSettings:SleepDisabled' "$POWER_PLIST" 2>/dev/null | grep -q true; then
		echo 1
	else
		echo 0
	fi
}

desired=0
gateway=''

# 既知ネットワークが 1 つも設定されていなければ、ゲートウェイを引くまでもなく抑止しない
if [ -n "$KNOWN_GATEWAYS" ] && on_ac_power; then
	gateway=$(physical_gateway_mac || true)
	for known in $KNOWN_GATEWAYS; do
		# 設定側も正規化する。arp(8) の出力をそのまま貼れるようにするため
		known=$(printf '%s' "$known" | normalize_mac)
		if [ "$gateway" = "$known" ]; then
			desired=1
			break
		fi
	done
fi

current=$(current_sleep_disabled)

# 変化がないときは何もしない。pmset の呼び出しもログ出力も抑える
if [ "$desired" = "$current" ]; then
	exit 0
fi

if [ "${CLAMSHELL_GUARD_DRY_RUN:-0}" = "1" ]; then
	log "dry-run: would set disablesleep=${desired} (gateway=${gateway:-none})"
	exit 0
fi

pmset -a disablesleep "$desired"

if [ "$desired" = 1 ]; then
	log "sleep disabled: on AC power at known network (gateway=${gateway})"
else
	log "sleep restored: off AC power or unknown network (gateway=${gateway:-none})"
fi
