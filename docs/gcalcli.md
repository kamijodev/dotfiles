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

## gcal-reminder プラグイン（Noctalia Shell）

Google Calendar 通知を Noctalia Shell 上で永続表示するカスタムプラグイン。

### 機能

- `appName: "Google Calendar"` の通知のみキャプチャし、手動で閉じるまで保持
- バーウィジェット: カレンダーアイコン + 通知数 + 最新の通知概要を表示
- パネル: 通知一覧の閲覧・個別/一括削除
- フルスクリーンアラート: 開始3分前（@3m〜@0m, now）に全画面でイベント名と開始時刻を表示
  - 「閉じる」: アラートを閉じるが、次の通知（@2m→@1m→now）で再表示
  - 「以降非表示」: 同イベントのアラートをすべて抑制し通知も削除

### 管理ファイル（chezmoi）

| ファイル | 役割 |
|---------|------|
| `~/.config/noctalia/plugins/gcal-reminder/manifest.json` | プラグイン定義 |
| `~/.config/noctalia/plugins/gcal-reminder/Main.qml` | 通知キャプチャ + フルスクリーンアラート |
| `~/.config/noctalia/plugins/gcal-reminder/BarWidget.qml` | バーウィジェット |
| `~/.config/noctalia/plugins/gcal-reminder/Panel.qml` | 通知一覧パネル |
| `~/.config/noctalia/plugins/gcal-reminder/Settings.qml` | フィルター設定UI |
| `~/.config/noctalia/plugins.json` | プラグイン有効/無効管理 |

### 設定

`settings.json` はプラグインが自動管理。手動変更は再起動時に上書きされる。

| 設定項目 | デフォルト | 説明 |
|---------|-----------|------|
| `filterMode` | `"filter"` | `"all"`: 全通知、`"filter"`: 指定アプリのみ |
| `filteredApps` | `["Google Calendar"]` | キャプチャ対象のアプリ名 |
| `maxNotifications` | `200` | 保持する通知の最大数 |
