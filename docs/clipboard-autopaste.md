# クリップボード履歴の自動貼り付け

Noctalia Shell のクリップボード履歴（Win+Shift+V）で項目を選択した際に、自動で貼り付けまで行う設定。

## 問題

niri では `wtype`（Wayland 向け xdotool）が正常に動作しない。
Noctalia Shell の autoPaste 機能は内部で `wtype` を呼び出すため、代わりに `ydotool` を使う。

`ydotool` はキーコード（数値）のみ受け付けるため、wtype の引数形式を変換するラッパースクリプトで対応する。

## 構成

| ファイル / 設定 | 役割 |
|----------------|------|
| `~/.config/noctalia/settings.json` | `autoPasteClipboard: true` |
| `~/.local/bin/wtype` | wtype → ydotool 変換ラッパー（chezmoi管理） |
| `/usr/local/bin/wtype` | `~/.local/bin/wtype` へのシンボリックリンク |
| `/etc/udev/rules.d/80-uinput.rules` | uinput デバイスの権限設定 |
| `ydotool.service` (systemd user) | ydotoold デーモン |

## 前提パッケージ

```bash
sudo pacman -S wtype ydotool
```

## セットアップ

```bash
# 1. chezmoi apply でラッパースクリプトを配置
chezmoi apply

# 2. noctalia-shell の PATH に ~/.local/bin が含まれないため、シンボリックリンクを作成
sudo ln -s /home/emacs/.local/bin/wtype /usr/local/bin/wtype

# 3. input グループに追加（再起動必要）
sudo usermod -aG input $USER

# 4. uinput デバイスの権限設定
sudo tee /etc/udev/rules.d/80-uinput.rules <<< 'KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput", GROUP="input", MODE="0660"'
sudo udevadm control --reload-rules && sudo udevadm trigger

# 5. ydotoold デーモン有効化
systemctl --user enable --now ydotool.service

# 6. Noctalia Shell で autoPaste を有効化（GUI設定からも可）
# settings.json の appLauncher.autoPasteClipboard を true に設定

# 7. 再起動（input グループ反映のため）
systemctl reboot
```

## 仕組み

1. Win+Shift+V でクリップボード履歴を開く
2. 項目を選択すると Noctalia が `cliphist decode <id> | wl-copy && wtype -M ctrl -M shift v` を実行
3. `/usr/local/bin/wtype`（シンボリックリンク）→ `~/.local/bin/wtype`（ラッパー）が呼ばれる
4. ラッパーが wtype の引数をキーコードに変換し `ydotool key 29:1 42:1 47:1 47:0 42:0 29:0` を実行
5. 対象ウィンドウに Ctrl+Shift+V が送信され貼り付けられる
