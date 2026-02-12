# クリップボード履歴

noctalia-shell + cliphist によるクリップボード履歴管理。

## 前提パッケージ

```bash
sudo pacman -S cliphist wl-clipboard
```

## 仕組み

noctalia-shell が内蔵で `wl-paste --watch cliphist store` を実行し、クリップボードを監視・蓄積する。別途 autostart に追加する必要はない。

## キーバインド

| キー | 動作 |
|------|------|
| `Mod+Shift+V` | クリップボード履歴を開く |

## noctalia 設定

`~/.config/noctalia/settings.json` で以下が有効になっている必要がある：

```json
"enableClipboardHistory": true
```

## トラブルシューティング

「クリップボード履歴は無効です」と表示される場合：

1. `cliphist` がインストールされているか確認: `which cliphist`
2. noctalia の設定で `enableClipboardHistory` が `true` か確認
3. ログアウト→ログインで noctalia-shell を再起動
