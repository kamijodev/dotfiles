#!/usr/bin/env bash

# 標準入力からJSON入力を読む
input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path // empty')

# デフォルトメッセージ
title="Claude Code"
body="完了"

# transcript_pathから最後のレスポンスを取得
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  last_msg=$(tac "$transcript_path" | grep -m1 '"role":"assistant"' | jq -r '.message.content[0].text // empty' 2>/dev/null | tr -cd '[:print:][:space:]' | cut -c1-100)
  if [ -n "$last_msg" ]; then
    body="$last_msg"
  fi
fi

# 通知送信
if command -v notify-send >/dev/null 2>&1; then
  notify-send "$title" "$body"
elif command -v kdialog >/dev/null 2>&1; then
  kdialog --title "$title" --passivepopup "$body" 5
else
  printf '\a%s: %s\n' "$title" "$body" >&2
fi
