#!/usr/bin/env bash
set -euo pipefail

title="${1:-Claude Code}"
body="${2:-完了}"

# 1) GNOME/KDE/多くの環境: notify-send
if command -v notify-send >/dev/null 2>&1; then
  notify-send "$title" "$body"
  paplay /usr/share/sounds/freedesktop/stereo/message-new-instant.oga 2>/dev/null &
  exit 0
fi

# 2) KDE fallback: kdialog
if command -v kdialog >/dev/null 2>&1; then
  kdialog --title "$title" --passivepopup "$body" 5
  paplay /usr/share/sounds/freedesktop/stereo/message-new-instant.oga 2>/dev/null &
  exit 0
fi

# 3) 最終手段: 端末ベル
printf '\a%s: %s\n' "$title" "$body" >&2
