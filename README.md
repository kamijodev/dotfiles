# dotfiles

Managed by [chezmoi](https://www.chezmoi.io/).

## Setup

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
chezmoi init --apply kamijodev
```

## Usage

```bash
chezmoi add ~/.config/foo    # 設定ファイルを追加
chezmoi edit ~/.config/foo   # 編集
chezmoi apply                # 適用
chezmoi update               # リモートから更新
chezmoi diff                 # 差分確認
chezmoi cd                   # ソースディレクトリに移動
```

## Naming

- `dot_` → `.`
- `private_` → パーミッション 0600
- `executable_` → 実行権限付き

## Docs

詳細なドキュメントは [`~/docs/`](docs/) を参照。
