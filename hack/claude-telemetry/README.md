# AI エージェント テレメトリ (Grafana LGTM Stack)

Claude Code と Copilot CLI の OpenTelemetry テレメトリを Grafana で可視化するためのローカル収集スタック。

## 構成

```
Claude Code ──── OTLP gRPC :4317 ────┐
Copilot CLI ──── OTLP HTTP :4318 ────┤
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

ダッシュボード「AI エージェント テレメトリ」は `dashboards/` から自動プロビジョニングされるので、
インポート操作は不要。上部の `Agent` は既定で `All` (Claude Code と Copilot CLI の両方) で、
片方だけ見たいときに絞る。

variable の値は `service.name` そのもので、Prometheus では `job`、span metrics では `service`、
Loki では `service_name` ラベルに対応する。3 者でラベル名が違うだけで値は共通なので、
1 つの variable で全パネルを切り替えられる。Claude Code だけは statusline hook が
`job=claude-statusline` で rate limit と turn 数を別に出しているため、variable の値に
`claude-code|claude-statusline` の 2 つを含めている。

両方を同時に表示するパネル (トークン、コード編集行数、スパンレイテンシ) は、凡例の頭に
どちらの agent かが出る。片方にしか無い指標はパネルのタイトルに `(Claude Code のみ)` と付けるか、
`Copilot CLI 固有` の row にまとめてある。

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

## Copilot CLI テレメトリ設定

Copilot CLI は user settings に telemetry セクションを持たず、環境変数だけで設定する
(`copilot help monitoring` に全仕様がある)。`~/dotfiles/.zshrc` に copilot 起動時だけ効く
wrapper を置いてある:

```zsh
copilot() {
  OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318 \
  OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf \
  command copilot "$@"
}
```

Claude Code と違い gRPC は使えない。`OTEL_EXPORTER_OTLP_PROTOCOL` に `grpc` を渡すと警告を出して
フォールバックする。取れる値は `http/json` (既定) と `http/protobuf` の 2 つで、ここでは
protobuf を選んでいる。

global に export せず wrapper にしているのは、`OTEL_EXPORTER_OTLP_ENDPOINT` が OTel を読む
他ツールへ無差別に波及するのを避けるため。

OTel は既定で無効で、次のいずれかが揃うと有効になる:

- `COPILOT_OTEL_ENABLED=true`
- `OTEL_EXPORTER_OTLP_ENDPOINT` が設定されている
- `COPILOT_OTEL_FILE_EXPORTER_PATH` が設定されている

`service.name` は既定で `github-copilot` (Claude Code は `claude-code`)。ダッシュボードの
variable がこの値をそのまま使うので、`OTEL_SERVICE_NAME` で上書きしない。

プロンプト本文・ツール引数・レスポンスは既定で送られない。送るなら
`OTEL_INSTRUMENTATION_GENAI_CAPTURE_MESSAGE_CONTENT=true` を明示的に足す (既定の無効のままにしてある)。

送信内容を手元で確認したいときは、collector を経由せずファイルへ出せる:

```bash
COPILOT_OTEL_FILE_EXPORTER_PATH=/tmp/copilot-otel.jsonl copilot
```

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

### Copilot CLI

Copilot CLI が出すのは **traces と metrics だけ**で、logs シグアルは無い。よってダッシュボードの
「イベントログ」パネルは Copilot 選択時に空になる。

- **トレース**: `invoke_agent` をルートに `plan` / `chat <model>` / `execute_tool <tool>` が並ぶ。
  subagent の実行は context propagation で同じトレースに繋がる
- **メトリクス**: 名前と属性は OTel GenAI Semantic Conventions に従う。Claude Code の
  `claude_code_*` とは体系が全く別で、共通の指標はトークン数とコード編集行数くらいしかない

  | OTel 名 | Prometheus 名 | 種別 |
  | --- | --- | --- |
  | `gen_ai.client.operation.duration` | `gen_ai_client_operation_duration_seconds` | histogram |
  | `gen_ai.client.token.usage` | `gen_ai_client_token_usage` | histogram |
  | `gen_ai.client.operation.time_to_first_chunk` | `gen_ai_client_operation_time_to_first_chunk_seconds` | histogram |
  | `gen_ai.client.operation.time_per_output_chunk` | `gen_ai_client_operation_time_per_output_chunk_seconds` | histogram |
  | `gen_ai.invoke_agent.duration` | `gen_ai_invoke_agent_duration_seconds` | histogram |
  | `gen_ai.invoke_agent.inference_calls` | `gen_ai_invoke_agent_inference_calls` | histogram |
  | `gen_ai.invoke_agent.tool_calls` | `gen_ai_invoke_agent_tool_calls` | histogram |
  | `gen_ai.execute_tool.duration` | `gen_ai_execute_tool_duration_seconds` | histogram |
  | `github.copilot.tool.call.count` | `github_copilot_tool_call_count_total` | counter |
  | `github.copilot.tool.call.duration` | `github_copilot_tool_call_duration_seconds` | histogram |
  | `github.copilot.agent.turn.count` | `github_copilot_agent_turn_count` | histogram |
  | `github.copilot.mcp.server.connection.count` | `github_copilot_mcp_server_connection_count_total` | counter |
  | `github.copilot.code.lines_added` | `github_copilot_code_lines_added_total` | counter |
  | `github.copilot.code.lines_removed` | `github_copilot_code_lines_removed_total` | counter |

  Prometheus 名は remote write exporter が unit を suffix に付けた後の形。unit が `s` のものだけ
  `_seconds` が付き、`{token}` や `{call}` のような無次元 unit には付かない。
  Copilot 側が unit を変えるとパネルが空になるので、その場合はここの対応表から直す

Claude Code のプロンプト本文とツールの入出力は既定で `<REDACTED>` になり、長さだけが記録される。
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

## ディレクトリ名について

ディレクトリは `claude-telemetry` のままにしてある。docker compose の volume が host path で
束縛されているため、改名するとスタックの作り直しが必要になる。中身は Claude Code 専用ではない。
