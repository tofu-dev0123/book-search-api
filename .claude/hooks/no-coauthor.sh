#!/bin/bash
# git commit に AI の生成証跡が混入するのをブロックする。
# CLAUDE.md に書くだけでは遵守率 ~80% なので、フックで 100% にする。
set -uo pipefail

input=$(cat)
# jq が失敗しても Bash ツール全体を巻き込まない（フックのエラーで作業を止めない）
command=$(jq -r '.tool_input.command // ""' <<<"$input" 2>/dev/null) || exit 0

case "$command" in
  *"git commit"*|*"gh pr create"*) ;;
  *) exit 0 ;;
esac

if grep -qiE 'Co-Authored-By:[[:space:]]*Claude' <<<"$command"; then
  echo "ブロック: コミットメッセージに Co-Authored-By: Claude 行を付けない規約があります。該当行を削除して再実行してください。" >&2
  exit 2
fi

if grep -qiE 'Generated with \[Claude Code\]|🤖 Generated with' <<<"$command"; then
  echo "ブロック: PR 本文に 'Generated with [Claude Code]' フッターを付けない規約があります。該当行を削除して再実行してください。" >&2
  exit 2
fi

exit 0
