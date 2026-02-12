# スクリーンショット & 画面録画

niri 環境でのスクリーンショット・画面録画の仕組み。

## 前提パッケージ

```bash
sudo pacman -S grim slurp satty wl-copy
paru -S wl-screenrec
```

## 管理ファイル（chezmoi）

| ファイル | 役割 |
|---------|------|
| `~/.config/niri/cfg/keybinds.kdl` | キーバインド定義 |
| `~/.config/niri/cfg/rules.kdl` | sattyをフローティング起動するルール |
| `~/.config/satty/config.toml` | sattyの保存先・動作設定 |

## キーバインド

| キー | 動作 |
|------|------|
| `Mod+N` | 範囲選択スクショ → `~/Pictures/Screenshots/` に保存 → sattyで注釈 |
| `Mod+M` | 範囲選択で画面録画トグル（開始/停止） |

## スクリーンショットの流れ

1. `Mod+N` → `slurp` で範囲選択
2. `grim` で即座に `~/Pictures/Screenshots/` へ保存
3. satty が開いて注釈可能
4. コピーボタンで注釈付き版をクリップボード + 別途保存 → satty自動終了

## 画面録画の流れ

1. `Mod+M` → `slurp` で範囲選択 → 録画開始（通知あり）
2. `Mod+M` 再押下 → 録画停止 → `~/Videos/Recordings/` に保存（通知あり）
3. 20分で自動停止（ストレージ保護）
