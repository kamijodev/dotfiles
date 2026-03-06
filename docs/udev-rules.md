# カスタム udev ルール

`/etc/udev/rules.d/` はchezmoi管理外（システムディレクトリ）のため、ここに内容を記録する。

## 仕組み

- `/usr/lib/udev/rules.d/` — パッケージが配置するベンダーデフォルト（pacman更新で上書きされる）
- `/etc/udev/rules.d/` — ユーザーカスタマイズ用（同名ファイルで `/usr/lib/` 側を上書き）

## 一覧

| ファイル | 用途 | 詳細 |
|----------|------|------|
| `30-zram.rules` | zram swappiness 変更 | [zram-swappiness.md](zram-swappiness.md) |
| `99-disable-internal-kbd.rules` | 内蔵キーボード等の無効化 | [kanata.md](kanata.md) |
| `99-uinput.rules` | kanata 用 uinput 権限 | [kanata.md](kanata.md) |
