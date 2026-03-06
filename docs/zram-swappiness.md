# zram / swappiness 設定

## 概要

CachyOS はデフォルトで zram (圧縮swap) を使用しており、swappiness が高めに設定されている。
メモリに余裕がある場合でも積極的にswapへ移すため、体感が重くなることがある。

## デフォルトの挙動

1. `/usr/lib/sysctl.d/70-cachyos-settings.conf` で `vm.swappiness=100` を設定
2. `/usr/lib/udev/rules.d/30-zram.rules` が zram 初期化時に `vm.swappiness=150` で上書き

udev ルールが後から実行されるため、sysctl.d の設定は実質無意味。

## カスタマイズ方法

`/etc/udev/rules.d/` に同名ファイルを置くと `/usr/lib/udev/rules.d/` のルールを上書きできる。

```bash
# vendor ルールをコピー
sudo cp /usr/lib/udev/rules.d/30-zram.rules /etc/udev/rules.d/30-zram.rules

# swappiness の値を編集（例: 10 に変更）
sudo sed -i 's/vm.swappiness}="150"/vm.swappiness}="10"/' /etc/udev/rules.d/30-zram.rules

# 即時反映
sudo sysctl vm.swappiness=10
```

## 現在の設定

- ファイル: `/etc/udev/rules.d/30-zram.rules`
- swappiness: 10（変更後）

## 注意

- `/etc/sysctl.d/99-swappiness.conf` を作っても udev ルールに上書きされるので意味がない
- パッケージ更新で `/usr/lib/udev/rules.d/30-zram.rules` が変わっても `/etc/` 側が優先される
