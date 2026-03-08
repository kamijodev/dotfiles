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
systemctl --user enable --now evsieve-copilot.service
systemctl --user enable --now kanata.service
```

kanata は evsieve-copilot に依存（`Requires=`/`After=`）しているため、evsieve が先に起動する。

## Copilotキーのリマップ (evsieve)

ThinkPad の Copilot キーは `LeftShift+LeftMeta+F23` の3キーを同時送出するため、kanata 単体ではリマップできない。
evsieve で物理キーボードを grab し、このコンボを `rightalt` に変換してから kanata に渡す。

- **サービス**: `~/.config/systemd/user/evsieve-copilot.service`
- **仕組み**: `--hook` で3キー同時押しを検知 → `--withhold` で元キーを保留 → `send-key=key:rightalt` で置換
- **仮想デバイス名**: `"Internal Keyboard (evsieve)"` — kanata がこの名前で接続

## 設定ファイル

- `~/.config/kanata/kanata.kbd`
- 対象デバイス: evsieve の仮想デバイス `"Internal Keyboard (evsieve)"`（`linux-dev-names-include` で指定）

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
- Copilotキー → 右Altと同じ（evsieve経由）

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

## 内蔵デバイスの制御

内蔵キーボード・トラックポイント・タッチパッドの有効/無効を top-clock プラグインから切り替え可能。

### 仕組み

- **トグルスクリプト**: `~/.local/bin/toggle-internal-kbd` — sysfs の `inhibited` を 0/1 で切り替え（pkexec で実行）
- **状態ファイル**: `/tmp/internal-kbd-state`, `/tmp/internal-tp-state`, `/tmp/internal-pad-state` — プラグインが監視
- **UI**: top-clock プラグインにアイコン表示、クリックでトグル
- **kanata 連動**: キーボード無効化時に kanata.service を自動停止、有効化時に自動起動

### 起動時の有効化

再起動時にデバイスを有効（on）にするため以下を設定：

- **systemd サービス**: `/etc/systemd/system/init-internal-devices.service` — 起動時に `~/.local/bin/init-internal-devices` を実行
- **pacman フック**: `/etc/pacman.d/hooks/99-enable-internal-input.hook` — パッケージ操作後に同スクリプトを実行（カーネルモジュール再読み込みでリセットされる対策）
- **ポーリング**: top-clock プラグインが5秒ごとに sysfs の実際の状態を読み取りUIに反映

### 対象デバイス

| デバイス | sysfs パス |
|----------|-----------|
| キーボード | `/sys/devices/platform/i8042/serio0/input/input*/inhibited` |
| トラックポイント | `/sys/devices/platform/i8042/serio1/input/input*/inhibited` |
| タッチパッド | `/sys/devices/pci0000:00/0000:00:15.3/i2c_designware.1/i2c-1/i2c-ELAN06D4:00/0018:04F3:32B5.*/input/input*/inhibited` |

## 手動テスト

```bash
sudo kanata -c ~/.config/kanata/kanata.kbd
```

## キーコードの確認

```bash
sudo evtest /dev/input/event3
```
