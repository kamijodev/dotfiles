# swap-reclaim: 定期swap解放

## 概要

zram swap にたまったデータを定期的にメモリに戻すことで、もっさり感を防ぐ。

## 構成

| ファイル | 役割 |
|---------|------|
| `~/.local/bin/swap-reclaim` | swap解放スクリプト (chezmoi管理) |
| `/etc/systemd/system/swap-reclaim.service` | oneshot実行 |
| `/etc/systemd/system/swap-reclaim.timer` | 起動10分後 + 1時間ごと |

## 動作ロジック

1. swap未使用 → スキップ
2. 空きメモリ < swap使用量 × 1.2 → メモリ不足でスキップ
3. 空きメモリ ≥ swap使用量 × 1.2 → swap解放実行

## swap解放の手順

zram は fstab ではなく systemd + zram-generator で管理されているため、単純な `swapoff/swapon -a` では復旧しない。

```
swapoff -a                              # swapを無効化 (データをRAMに戻す)
echo 1 > /sys/block/zram0/reset         # zramデバイスをリセット
systemctl start systemd-zram-setup@zram0.service dev-zram0.swap  # 再作成
```

## systemd ユニットの配置

systemd ユニットファイルは `/etc/systemd/system/` に直接配置（chezmoi管理外）。
再インストール時は以下で再配置:

```bash
# /tmp にファイルを作成してからコピー
sudo cp swap-reclaim.service swap-reclaim.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now swap-reclaim.timer
```

## 確認コマンド

```bash
systemctl list-timers swap-reclaim.timer   # 次回実行時刻
journalctl -u swap-reclaim.service -n 10   # 実行ログ
free -h                                    # メモリ/swap状況
```
