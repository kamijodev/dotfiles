# Google Calendar 通知

gcalcli + systemd timer で Google Calendar の予定をデスクトップ通知する。

## 前提パッケージ

```bash
# asdf で Python をインストール
asdf plugin add python
asdf install python latest
asdf set -u python latest

# gcalcli をインストール
pip install gcalcli
```

## GCP 設定

1. [Google Cloud Console](https://console.cloud.google.com/) でプロジェクト作成
2. Google Calendar API を有効化
3. OAuth 同意画面を作成（外部）→ テストユーザーに自分の Gmail を追加
4. 認証情報 → OAuth クライアント ID を作成（デスクトップアプリ）

## gcalcli 初期化

```bash
gcalcli --client-id=<クライアントID>.apps.googleusercontent.com --client-secret=<シークレット> init
```

ブラウザで Google 認証を完了する。トークンは `~/.local/share/gcalcli/oauth` に保存される。

## 管理ファイル（chezmoi）

| ファイル | 役割 |
|---------|------|
| `~/.config/systemd/user/gcalcli-remind.service` | 通知実行サービス |
| `~/.config/systemd/user/gcalcli-remind.timer` | 1分ごとの定期実行タイマー |
| `~/.local/bin/gcalcli-remind` | agenda --nodeclined で辞退済みイベントを除外するリマインドスクリプト |
| `~/.local/bin/gcalcli-notify` | デスクトップ通知＋サウンド再生スクリプト |

## 新規環境でのセットアップ

```bash
# 1. chezmoi apply でファイルを配置
chezmoi apply

# 2. GCP 設定 & gcalcli init（上記参照）

# 3. タイマー有効化
systemctl --user daemon-reload
systemctl --user enable --now gcalcli-remind.timer
```

## 通知対象カレンダー

`gcalcli-remind.service` の `ExecStart` で `--calendar` オプションにより指定。
変更する場合は `gcalcli list` で一覧を確認し、サービスファイルを編集する。
