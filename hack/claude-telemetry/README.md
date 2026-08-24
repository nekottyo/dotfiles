# AI エージェント テレメトリ (Grafana LGTM Stack)

Claude Code、Codex、Copilot CLI の OpenTelemetry テレメトリ、および Headroom プロキシのメトリクスを
Grafana で可視化するためのローカル収集スタック。

## 構成

```
Claude Code ──── OTLP gRPC :4317 ────┐
Codex ────────── OTLP gRPC :4317 ────┤
Copilot CLI ──── OTLP HTTP :4318 ────┤
                                     ▼
Headroom :8787 ←── scrape ────── OTel Collector
                                     ├─→ Mimir  :9009  (メトリクス)
                                     ├─→ Loki   :3100  (ログ)
                                     └─→ Tempo  :3200  (トレース)
                                                │
                                                ▼
                                           Grafana :3000  (ダッシュボード)
```

Claude Code、Codex、Copilot CLI は collector へ push するが、Headroom だけは向きが逆で collector が
pull する。理由は後述の「Headroom メトリクス」を参照。

ポートは全て `127.0.0.1` にのみ bind している。収集データには `user_email` / `organization_id` /
`session_id` といった個人を識別できる属性が含まれ、かつ Grafana は認証なし (匿名 Admin) で開くため、
外部ネットワークへ晒さない。

## 起動手順

```bash
cd ~/dotfiles/hack/claude-telemetry
docker compose up -d
```

Grafana: http://localhost:3000 (認証なし)

ダッシュボードは `dashboards/` から自動プロビジョニングされるので、インポート操作は不要。
フォルダ `AI Agents` に 2 枚入る。

- **AI エージェント テレメトリ** — Claude Code、Codex、Copilot CLI。上部の `Agent` は既定で `All`
  (3 種すべて) で、個別に見たいときに絞る
- **Headroom プロキシ** — Headroom の圧縮とキャッシュの挙動。agent 側とは指標体系が全く別なので
  ダッシュボードを分けてある

variable の値は `service.name` そのもので、Prometheus では `job`、span metrics では `service`、
Loki では `service_name` ラベルに対応する。3 者でラベル名が違うだけで値は共通なので、
1 つの variable で全パネルを切り替えられる。Claude Code だけは statusline hook が
`job=claude-statusline` で rate limit と turn 数を別に出しているため、variable の値に
`claude-code|claude-statusline` の 2 つを含めている。

Codex は対話 CLI が `service.name=codex_cli_rs`、`codex exec` が `service.name=codex_exec` を使う。
Agent variable の Codex は両方を含めているため、実行方法をまたいで同じパネルに集約される。

複数 agent を同時に表示するパネル (トークン、コード編集行数、スパンレイテンシ) は、凡例の頭に
agent 名が出る。一部にしか無い指標はパネルのタイトルに対象を付けるか、固有の row にまとめてある。

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

## Codex テレメトリ設定

Codex は user-level の `~/.codex/config.toml` に OTel 設定を置く。project-level の
`.codex/config.toml` に書いた `[otel]` は適用されない。

```toml
[otel]
environment = "dev"
log_user_prompt = true
exporter = { otlp-grpc = { endpoint = "http://localhost:4317" } }
metrics_exporter = { otlp-grpc = { endpoint = "http://localhost:4317" } }
trace_exporter = { otlp-grpc = { endpoint = "http://localhost:4317" } }
```

設定は新しく起動した Codex process から有効になる。対話 CLI は `service.name=codex_cli_rs`、
`codex exec` は `service.name=codex_exec` を使うため、dashboard では両方を Codex として扱う。

Codex の metrics は Delta temporality 固定なので、collector の `deltatocumulative` processor で
cumulative に変換してから Mimir へ送る。Claude Code の cumulative metrics と Headroom の
Prometheus scrape metrics は変換されず、そのまま同じ pipeline を通る。collector-contrib は
`deltatocumulative` を distribution に初めて含めた `0.108.0` へ固定している。従来の `0.107.0` では
processor module 自体が image に含まれず、同じ config を読み込めない。

Codex metrics は turn 完了時だけ送られる sparse cumulative 系列で、広い窓の `increase()` は外挿により
summary を過大評価し得る。トークン、thread、cache 率の summary は `max_over_time()`、推移パネルは
interval ごとの差分を見るため `increase()` を使う。

`log_user_prompt = true` は Claude Code の現在の設定と同じく raw prompt を送る設定である。
この stack が localhost に閉じていても、prompt は Loki の永続 volume に保存される。source code、token、
個人情報を含み得るため、本文が不要なら `false` にする。dashboard の集計に raw prompt は不要。

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

## Headroom メトリクス

Headroom 側の設定は無い。collector が `configs/otel-collector.yaml` の `prometheus/headroom`
receiver で `http://host.docker.internal:8787/metrics` を 15 秒ごとに scrape する。

[公式ドキュメント](https://headroomlabs-ai.github.io/headroom/metrics/) は `HEADROOM_OTEL_METRICS_*`
による OTLP push を案内しているが、それには `pip install "headroom-ai[proxy,otel]"` が要る。
`ghcr.io/headroomlabs-ai/headroom:latest` には opentelemetry SDK が同梱されておらず
(コンテナ内で `import opentelemetry.sdk` が `ModuleNotFoundError`)、push させるには派生 image を
焼いて `headroom install apply --image` で deployment を入れ直すことになる。upstream 更新のたびに
再ビルドが要るうえ `:latest` の自動追従も壊れる。一方 `/metrics` はドキュメント上 OTel facade と
同じイベント源なので、取れる指標は push でも pull でも変わらない。それで pull を選んでいる。

`HEADROOM_TELEMETRY=off` は Headroom が開発元へ送る匿名テレメトリの設定で、ここの話とは無関係。
off のままでよい。

### メトリクス名の正規化

prometheus receiver は counter に `_total` を付け足すため、`/metrics` に出ている名前と Mimir 上の
名前が一致しない系列がある。`/metrics` の名前をそのままクエリに書くと結果が空になる。

| `/metrics` の名前 | Mimir 上の名前 |
| --- | --- |
| `headroom_latency_ms_sum` | `headroom_latency_ms_sum_total` |
| `headroom_latency_ms_count` | `headroom_latency_ms_count_total` |
| `headroom_requests_by_provider` | `headroom_requests_by_provider_total` |
| `headroom_requests_by_model` | `headroom_requests_by_model_total` |

`_max` / `_min` / `_active` 系の gauge と、元から `_total` で終わる counter は素通しされる。

### 圧縮率は近似値

サマリの「圧縮率」は近似で、Headroom 自身が出す値とは一致しない。圧縮前の総トークン数
(`/stats` の `total_tokens_before`) が Prometheus に公開されていないため、上流へ送った
`headroom_tokens_input_total` に削った `headroom_tokens_saved_total` を足し戻して分母を復元している。
この分母には圧縮対象にならなかったリクエストの入力も混ざるので、実際より低く出る。実測では
`/stats` の `avg_compression_pct` が 2.2% のとき、このパネルは 1.93% を示した。

分子の `headroom_tokens_saved_total` が数えているのは圧縮レイヤ単体の節約分だけである点にも注意。
tool schema 由来の節約 (`/stats` の `tool_schema_tokens_saved`) は Prometheus 側に系列が無く、
全レイヤ込みの節約量はダッシュボードからは見えない。正確な内訳が要るときは `/stats` を直接叩く。

### ラベルと集計上の注意

- 全系列に `job="headroom"` と `instance="host.docker.internal:8787"` が付く。個別の分解軸は
  `provider` / `model` / `transform` / `stage` と `path` の組 / `ttl` の 5 系統
- counter はプロセス起動以降の累積で、Headroom を再起動するとリセットされる。ダッシュボードは
  `increase()` と `rate()` で組んであるのでリセットは吸収される。`claude_code_*` のパネルが
  `max_over_time` を使っているのとは逆の選択で、あちらは OTLP push で標本が疎なため
  `increase()` の外挿が効きすぎる。Headroom は 15 秒間隔で scrape していて標本が密なので
  `increase()` が素直に効く
- 上記の外挿の性質上、scrape を始めた直後は表示期間の頭にデータが無く、サマリの数値が実際より
  大きく出る。1 時間ほど溜まれば落ち着く
- `headroom_latency_ms_max` などは累積の最大値であって時間窓の最大ではない。時系列で見ると単調増加に
  なるため、ダッシュボードでは平均 (`rate(_sum_total) / rate(_count_total)`) を主に置き、
  最大値は補助のパネルに分けてある
- scrape 先のポートは `headroom install apply --port` で変えられる。変えたら
  `otel-collector.yaml` の `targets` も直す

## 収集されるデータ

- **メトリクス**: トークン使用量 (input / output / cacheRead / cacheCreation)、API コスト、
  セッション数、作業時間、コード追加削除行数、編集の承認却下。
  `model` / `skill_name` / `query_source` (main / subagent / auxiliary) 別に分解できる
- **ログ**: ツール実行、API リクエスト、hook 実行などのイベント。`event_name` や `tool_name` は
  インデックスラベルではなく structured metadata に入るため、集計には
  `{service_name="claude-code"} | event_name != ""` のようにパイプラインを挟む。
  ツールの利用状況はメトリクスでなくこちら側にしかない (`claude_code_*` でツール別に割れるのは
  `code_edit_tool_decision` の Edit / Write だけ)。`tool_name` を素で絞ると `tool_decision` と
  `tool_result` の両方が数えられて実回数の約 2 倍になるので、`event_name` で必ず絞る
- **ログ側の匿名化の境界**は一貫していない。MCP は `tool_decision` の `tool_name` が `mcp_tool` に、
  `mcp_server_name` / `mcp_tool_name` が `custom` に潰れるため、サーバー別・ツール別には割れない
  (割れるのは `tool_source` の builtin / mcp と `mcp_server_scope` の user / project まで)。
  skill も `skill_activated` の `skill_name` は自作分がすべて `custom_skill` になる一方、
  `api_request` の `skill_name` には実名が入る。「ツール / skill 利用状況」row が後者を軸にしているのは
  このため。ただし `api_request` の件数は skill が有効な間の API リクエスト数であって起動回数ではない
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

### Codex

Codex は logs / metrics / traces の 3 signal を出す。Claude Code と signal の種類は同じだが、
event 名、metric 名、span 構造は Codex 固有であり、Claude の `claude_code_*` と直接は集約できない。

- **ログ**: `codex.api_request`、`codex.user_prompt`、`codex.tool_decision`、`codex.tool_result` などの
  structured event。`log_user_prompt = false` でも送られる prompt 長と、tool result に output snippet が
  含まれる可能性
- **メトリクス**: token usage、API / tool / MCP の回数と duration、turn の TTFT / TTFM / E2E、
  approval、thread、subagent spawn、compaction。Delta temporality から collector での cumulative への変換
- **トレース**: 対話 CLI は `codex_cli_rs`、`codex exec` は `codex_exec` の service 名で Tempo に入る。
  Tempo の span metrics は Claude Code / Copilot CLI と同じ `traces_spanmetrics_*` として重ねる構成

通常の Codex exec は WebSocket transport を使い、request 数と応答時間は `codex.websocket.request` /
`codex.websocket.request.duration_ms` に記録される。HTTP transport を使う経路では `codex.api_request` /
`codex.api_request.duration_ms` に入るため、dashboard は両方を transport 名付きで重ねる。

Codex の OTel instrument 名は Prometheus Remote Write で `_total`、`_sum`、`_count`、unit suffix を
付けた名前に正規化される。例えば `codex.turn.token_usage` は `codex_turn_token_usage_sum`、
`codex.websocket.request.duration_ms` は `codex_websocket_request_duration_ms_milliseconds_bucket`、
`codex.api_request.duration_ms` は `codex_api_request_duration_ms_milliseconds_bucket` になる。

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
