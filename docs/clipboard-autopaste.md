# クリップボード履歴の自動貼り付け

Noctalia Shell のクリップボード履歴（Win+Shift+V）で項目を選択した際に、自動で貼り付けまで行う設定。

## 問題

niri では `wtype`（Wayland 向け xdotool）が正常に動作しない。
Noctalia Shell の autoPaste 機能は内部で `wtype` を呼び出すため、代わりに `ydotool` を使う。

## 構成

| ファイル / 設定 | 役割 |
|----------------|------|
| `~/.config/noctalia/settings.json` | `autoPasteClipboard: true` |
| `~/.local/bin/wtype` | wtype → ydotool 変換ラッパー |
| `/etc/udev/rules.d/80-uinput.rules` | uinput デバイスの権限設定 |
| `ydotool.service` (systemd user) | ydotoold デーモン |

## 前提パッケージ

```bash
sudo pacman -S wtype ydotool
```

## セットアップ

```bash
# 1. input グループに追加（再ログイン必要）
sudo usermod -aG input $USER

# 2. uinput デバイスの権限設定
sudo tee /etc/udev/rules.d/80-uinput.rules <<< 'KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput", GROUP="input", MODE="0660"'
sudo udevadm control --reload-rules && sudo udevadm trigger

# 3. ydotoold デーモン有効化
systemctl --user enable --now ydotool.service

# 4. Noctalia Shell で autoPaste を有効化（GUI設定からも可）
# settings.json の appLauncher.autoPasteClipboard を true に設定
```

## 仕組み

1. Win+Shift+V でクリップボード履歴を開く
2. 項目を選択すると Noctalia が `cliphist decode <id> | wl-copy && wtype -M ctrl -M shift v` を実行
3. `~/.local/bin/wtype` ラッパーが引数を変換して `ydotool key ctrl+shift+v` を実行
4. 対象ウィンドウに貼り付けられる
