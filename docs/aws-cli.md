# AWS CLI

## 概要

AWS (Amazon Web Services) のリソースをコマンドラインから操作するためのCLIツール。

## インストール

```bash
sudo pacman -S aws-cli-v2
```

- パッケージ: `aws-cli-v2` (extra リポジトリ)
- v1 (`aws-cli`) もあるが、v2が現行の推奨バージョン

## 初期設定

```bash
aws configure
```

以下を入力:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (例: `ap-northeast-1`)
- Default output format (例: `json`)

設定ファイルは `~/.aws/config` と `~/.aws/credentials` に保存される。

## 補完

zshの補完を有効にするには:

```bash
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/usr/bin/aws_completer' aws
```

## 関連ファイル

- `~/.aws/config` - リージョン・出力形式などの設定
- `~/.aws/credentials` - 認証情報（**dotfilesで管理しない**）
