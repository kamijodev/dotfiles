# zram 無効化

## 背景

CachyOS はデフォルトで zram（圧縮swap）を有効にしている（`/usr/lib/systemd/zram-generator.conf`）。
RAM 30GB の環境ではメモリに余裕があるにもかかわらず zram に大量にページが退避され、
圧縮・展開の CPU コストでシステムが重くなる問題が発生した。

## 対処

空の設定ファイルを `/etc/` に置いて、システムデフォルトを上書き無効化する:

```bash
sudo tee /etc/systemd/zram-generator.conf <<< ''
```

`[zram0]` セクションが存在しないため、zram-generator はデバイスを作成しない。

## 即時解放

再起動前に現セッションのswapを解放する場合:

```bash
sudo swapoff /dev/zram0
```
