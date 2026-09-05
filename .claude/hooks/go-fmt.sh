#!/bin/bash
# Go ファイルの編集後に gofmt をかける。
# Go 未インストールの環境でも作業を止めないよう、常に exit 0 で終える。
set -uo pipefail

input=$(cat)
# jq が失敗してもツール全体を巻き込まない
file_path=$(jq -r '.tool_input.file_path // ""' <<<"$input" 2>/dev/null) || exit 0

case "$file_path" in
  *.go) ;;
  *) exit 0 ;;
esac

# Go 未導入なら何もしない。導入した時点で自動的に有効になる。
command -v gofmt >/dev/null 2>&1 || exit 0

[ -f "$file_path" ] || exit 0

gofmt -w "$file_path" 2>/dev/null || true
exit 0
