#!/usr/bin/env bash
# headroom の常駐 proxy (port 8787) を宣言どおりに作り直す。
# ~/.headroom/deploy/default/manifest.json は apply のたびに再生成されるため、正本はこの引数列に置く。
# apply は ~/.zshrc / ~/.bashrc / ~/.profile の headroom ブロックも書き換える。
set -euo pipefail

command -v headroom >/dev/null || { echo "headroom not found (uv tool install headroom-ai)" >&2; exit 2; }

# 既定値 (persistent-service / python / cache / anthropic / telemetry off) との差分だけを渡す。
# Bash を圧縮対象から外す理由: Kompress は空白区切りで語を切るため、分かち書きの無い日本語が
# 行ごと間引かれて読めなくなる (~/.agents/adr/217-headroom-protect-bash-output.md)
headroom install apply --protect-tool-results Bash
