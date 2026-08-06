# Claude Code テレメトリ (Grafana LGTM Stack)

Claude Code の OpenTelemetry テレメトリを Grafana で可視化するためのローカル収集スタック。

## 構成

```
Claude Code
    │ OTLP (gRPC :4317 / HTTP :4318)
    ▼
OTel Collector
    ├─→ Mimir  :9009  (メトリクス)
    ├─→ Loki   :3100  (ログ)
    └─→ Tempo  :3200  (トレース)
                │
                ▼
           Grafana :3000  (ダッシュボード)
```

ポートは全て `127.0.0.1` にのみ bind している。収集データには `user_email` / `organization_id` /
`session_id` といった個人を識別できる属性が含まれ、かつ Grafana は認証なし (匿名 Admin) で開くため、
外部ネットワークへ晒さない。

## 起動手順

```bash
cd ~/dotfiles/hack/claude-telemetry
docker compose up -d
```

Grafana: http://localhost:3000 (認証なし)

ダッシュボード「Claude Code テレメトリ」は `dashboards/` から自動プロビジョニングされるので、
インポート操作は不要。

## 停止

```bash
docker compose down
```

データを消してリセットする場合:

```bash
docker compose down -v
```

## Claude Code テレメトリ設定

`~/.claude/settings.json` の `env` セクションに以下が追加されている:

```json
{
  "CLAUDE_CODE_ENABLE_TELEMETRY": "1",
  "OTEL_METRICS_EXPORTER": "otlp",
  "OTEL_LOGS_EXPORTER": "otlp",
  "OTEL_EXPORTER_OTLP_PROTOCOL": "grpc",
  "OTEL_EXPORTER_OTLP_ENDPOINT": "http://localhost:4317",
  "OTEL_EXPORTER_OTLP_METRICS_TEMPORALITY_PREFERENCE": "cumulative",
  "CLAUDE_CODE_ENHANCED_TELEMETRY_BETA": "1",
  "OTEL_TRACES_EXPORTER": "otlp"
}
```

トレースはベータ機能のため `CLAUDE_CODE_ENHANCED_TELEMETRY_BETA` が併せて必要。
`settings.json` の `env` は hot reload されるので、編集すれば起動中のセッションからすぐ反映される。

スタックが停止していてもエラーにはならず、単に送信が失敗するだけ。

## 収集されるデータ

- **メトリクス**: トークン使用量 (input / output / cacheRead / cacheCreation)、API コスト、
  セッション数、作業時間、コード追加削除行数、編集の承認却下。
  `model` / `skill_name` / `query_source` (main / subagent / auxiliary) 別に分解できる
- **ログ**: ツール実行、API リクエスト、hook 実行などのイベント。`event_name` や `tool_name` は
  インデックスラベルではなく structured metadata に入るため、集計には
  `{service_name="claude-code"} | event_name != ""` のようにパイプラインを挟む
- **トレース**: プロンプト 1 回が `claude_code.interaction` をルートとするスパン木になる。
  子スパンに `claude_code.llm_request` / `claude_code.tool` / `claude_code.tool.execution` /
  `claude_code.tool.blocked_on_user` (権限承認の待ち時間) が並ぶ
- **トレース由来のメトリクス**: Tempo の metrics-generator がスパンから `traces_spanmetrics_*` を
  生成し、Mimir へ remote write する。`span_name` 別のレイテンシ分布が取れるので、ツール実行時間の
  p95 や承認待ち時間をパネル化できる

プロンプト本文とツールの入出力は既定で `<REDACTED>` になり、長さだけが記録される。
本文まで送るなら `OTEL_LOG_USER_PROMPTS` / `OTEL_LOG_TOOL_CONTENT` を明示的に有効化する必要がある。

## 設定上の注意

- Mimir は `blocks_storage.tsdb.dir` を明示しないと ingester の TSDB と WAL が volume の外に
  置かれ、コンテナ再作成のたびに未フラッシュのメトリクスを失う
- Loki datasource は `uid` を固定しないと Tempo の `tracesToLogsV2` から参照できない
- ログの `trace_id` は structured metadata なので、derivedFields は本文の正規表現ではなく
  `matcherType: label` で引く
- span-metrics のヒストグラムは既定の上限が 16.384s しかなく、`llm_request` や `interaction` が
  まるごと `+Inf` に落ちて p95 が上限値に張り付く。既定の 2 倍刻みを 262.144s まで延長している
- service-graphs processor は有効だが現状 0 series。辺は CLIENT スパンと SERVER スパンのペアから
  作られるところ、Claude Code のスパンは全て `SPAN_KIND_INTERNAL` のため
