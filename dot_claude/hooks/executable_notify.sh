#!/usr/bin/env bash
set -euo pipefail

title="${1:-Claude Code}"
body="${2:-完了}"

# 1) GNOME/KDE/多くの環境: notify-send
if command -v notify-send >/dev/null 2>&1; then
  notify-send "$title" "$body"
  exit 0
fi

# 2) KDE fallback: kdialog
if command -v kdialog >/dev/null 2>&1; then
  kdialog --title "$title" --passivepopup "$body" 5
  exit 0
fi

# 3) 最終手段: 端末ベル
printf '\a%s: %s\n' "$title" "$body" >&2
