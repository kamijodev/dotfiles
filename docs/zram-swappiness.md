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

# swappiness の値を編集（例: 1 に変更）
sudo sed -i 's/vm.swappiness}="10"/vm.swappiness}="1"/' /etc/udev/rules.d/30-zram.rules

# 即時反映
sudo sysctl -w vm.swappiness=1
```

## 現在の設定

- swappiness: 1（`/etc/udev/rules.d/30-zram.rules`）
- zram サイズ: 8GB（`/etc/systemd/zram-generator.conf`）

## 変更履歴

- 150 → 10: 初回調整
- 10 → 1: メモリに余裕があるのに kswapd0/kcompactd が暴走し、毎秒200MB近く swap out する問題が発生。zram はカーネルから「コストが低い」と判断されるため swappiness=10 でも積極的に swap される。1 に下げることで解消。
- zram-size: ram → 8192: 30GBのzramだとswappiness=1でも15GB以上溜まり、圧縮データのRAM消費（5-6GB）+ kswapd/kcompactd のCPU負荷で体感が悪化。8GBに制限して圧縮後のRAM消費を最大3-4GBに抑制。OOMクラッシュ防止のためswap自体は残す。

## 注意

- `/etc/sysctl.d/99-swappiness.conf` を作っても udev ルールに上書きされるので意味がない
- パッケージ更新で `/usr/lib/udev/rules.d/30-zram.rules` が変わっても `/etc/` 側が優先される
