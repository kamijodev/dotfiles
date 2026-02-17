# Git

Git のグローバル設定。

## 設定ファイル

`~/.gitconfig`

## ユーザー設定

- 名前: `kamijodev`
- メール: `f.kamijodev@gmail.com`

## デフォルト動作

- `push.default = current` — プッシュ時は現在のブランチ
- `init.defaultBranch = main` — 新規リポジトリのデフォルトブランチ
- `core.editor = nvim` — コミットメッセージエディタ

## エイリアス

| エイリアス | コマンド |
|-----------|---------|
| `st` | `status` |
| `com` | `commit` |
| `ame` | `commit --amend` |
| `co` | `checkout` |
| `sw` | `switch` |
| `br` | `branch` |
| `l1` | `log --oneline` |
| `back` | `reset --hard HEAD^` |
| `cp` | `cherry-pick` |
