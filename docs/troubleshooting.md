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

## AUR -git パッケージの注意点

### -git パッケージとは

AUR の `-git` パッケージ（例: `niri-git`, `wezterm-git`）は、リポジトリの最新コミットからビルドされる開発版。安定版より新しい機能やバグ修正が入っている。

### メリット

- 安定版にまだ入っていないバグ修正・新機能が使える
- 安定版がビルドできない／動かない場合の代替手段

### デメリット

- `pacman -Syu` で安定版に自動で戻らない（AURはpacman管理外）
- 安定版と衝突するため共存できない
- 開発中のコードなので新たなバグを踏む可能性がある

### 管理方法

```bash
# 現在インストール済みの -git パッケージを確認
pacman -Qm | grep git

# 安定版に戻す（リポジトリに安定版がある場合）
sudo pacman -S <パッケージ名>  # 衝突を聞かれるので y

# -git パッケージを更新する
paru -S <パッケージ名>-git
```

### 注意

- `-git` 版を入れたら、不要になった時に手動で安定版に戻す必要がある
- `paru -Syu` は `-git` パッケージの更新チェックをするが、「最新コミットが同じ」と判断されるとスキップされる
- トラブル対応で一時的に入れた場合は、解決後に安定版に戻すこと
