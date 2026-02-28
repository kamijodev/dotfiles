# Kanata - キーボードリマッパー

内蔵キーボード (ThinkPad) のキーリマップに kanata を使用。

## インストール

```bash
paru -S kanata-bin
```

## 権限設定

```bash
sudo groupadd uinput
sudo usermod -aG input emacs
sudo usermod -aG uinput emacs
echo 'uinput' | sudo tee /etc/modules-load.d/uinput.conf
echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-uinput.rules
```

反映にはログアウト→ログインが必要。

## 自動起動

```bash
systemctl --user enable --now kanata.service
```

## 設定ファイル

- `~/.config/kanata/kanata.kbd`
- 対象デバイス: `/dev/input/by-path/platform-i8042-serio-0-event-kbd` (内蔵キーボードのみ)

## キーマップ概要

### ベースレイヤー

- `;` → `:` (デフォルトでコロン)
- `[` / `]` → Backspace
- `'` / `\` → `-` (ハイフン)
- `ro` → `=` (イコール)
- CapsLock → IME off + Esc
- 左Shift → Win (Super)
- 左Alt → Ctrl
- 無変換 → Space
- Space → 単押し: IME off / 長押し: Shift
- 変換 → 単押し: IME on / 長押し: Alt
- カタカナひらがな → Layer 1 (ホールド)
- 右Alt → 単押し: Enter / 長押し: Layer 2

### Layer 1 (記号)

```
!  @  {  }  |  \  "  '  `  ~
#  $  (  )  &  ←  ↓  ↑  →  ;
%  ^  [  ]  *
```

### Layer 2 (ファンクション + 数字)

```
F1 F2 F3 F4 F5 F6 F7 F8 F9 F10
1  2  3  4  5  6  7  8  9  0
```

## 手動テスト

```bash
sudo kanata -c ~/.config/kanata/kanata.kbd
```

## キーコードの確認

```bash
sudo evtest /dev/input/event3
```
