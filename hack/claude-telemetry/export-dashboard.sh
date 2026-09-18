#!/usr/bin/env bash
# ローカル Grafana (claude-grafana) から agent-telemetry dashboard を export し、
# file provisioning の正本である dashboards/agent-telemetry.json を更新する。
#
# id / version は端末・保存回数ごとに変わる値なので落とす (file provisioning は
# 中身のハッシュで差分を見るため、この 2 つが残ると無意味な diff が出続ける)。
#
# 書き込み前に、counter を max_over_time(...[$__range]) で読んでいる panel が
# 無いか検査する (issue #69/#72 で見つかった取り違えパターン)。混入していれば
# ファイルを書き換えずに exit 1 する。
set -euo pipefail

GRAFANA_URL="${GRAFANA_URL:-http://localhost:3000}"
DASHBOARD_UID="agent-telemetry"
SCRIPT_DIR="$(cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
OUT_FILE="${SCRIPT_DIR}/dashboards/agent-telemetry.json"

for cmd in curl jq; do
  command -v "$cmd" >/dev/null 2>&1 || {
    echo "依存コマンドが見つからない: ${cmd}" >&2
    exit 2
  }
done

dashboard_json="$(curl -sf "${GRAFANA_URL}/api/dashboards/uid/${DASHBOARD_UID}" | jq '.dashboard | del(.id, .version)')"

if [[ -z "${dashboard_json}" || "${dashboard_json}" == "null" ]]; then
  echo "dashboard の取得に失敗した: uid=${DASHBOARD_UID}" >&2
  exit 1
fi

bad_exprs="$(jq -r '[.. | .expr? // empty] | .[]' <<<"${dashboard_json}" | grep -iE 'max_over_time\([a-zA-Z_]+_total' || true)"

if [[ -n "${bad_exprs}" ]]; then
  echo "counter を max_over_time(...[range]) で読む panel が残っているため書き込みを中止した:" >&2
  echo "${bad_exprs}" >&2
  exit 1
fi

jq '.' <<<"${dashboard_json}" >"${OUT_FILE}"
echo "export 完了: ${OUT_FILE}"
