# トラブルシューティング

## pacman -Syu 後のクラッシュ対応

### snapperでロールバック

pacmanのトランザクションごとにsnapper が pre/post スナップショットを自動作成する。

```bash
# スナップショット一覧
sudo snapper list

# ロールバック（pre=138, post=139 の例）
sudo snapper undochange 138..139
```

downgrade を一つずつ試すより早い。まずこれを試す。

### downgrade で個別に戻す

ロールバックが難しい場合、原因パッケージを特定して個別にダウングレードする。

```bash
sudo pacman -S downgrade  # 未インストールなら
sudo downgrade <パッケージ名>
```

`IgnorePkg` に追加するか聞かれるので、必要に応じて `y`。
解消したら `/etc/pacman.conf` の `IgnorePkg` から外すのを忘れないこと。

### パッケージインストール時の注意

| コマンド | 安全性 |
|---------|--------|
| `pacman -S package` | 直近にSyuしていればOK |
| `pacman -Sy package` | NG（部分更新で壊れる） |
| `pacman -Syu package` | 安全だがアプデで壊れるリスク |

## glib2 2.87 + quickshell クラッシュ (2026-02)

### 症状

`paru -Syu` で `glib2` が `2.86.4` → `2.87.1` に更新された後、quickshell (Noctalia Shell) が `free(): invalid size` でクラッシュ。

### 原因

glib2 2.87 のメモリアロケータの変更により、quickshell が `g_slice_free_chain_with_offset` でクラッシュ。

### 対処

```bash
sudo downgrade glib2  # 2.86.4 を選択
```

`/etc/pacman.conf` の `IgnorePkg` に `glib2` を追加して固定。
quickshell 側で glib2 2.87 対応されたら解除する。

### 診断方法

```bash
# coredump でクラッシュ箇所を特定
coredumpctl info -1
```

スタックトレースに `g_slice_free_chain_with_offset (libglib-2.0.so.0)` が含まれていれば glib2 が原因。
