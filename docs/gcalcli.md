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
| `~/.config/systemd/user/gcalcli-remind.timer` | 1分ごとの定期実行タイマー（AccuracySec=1s） |
| `~/.local/bin/gcalcli-remind` | リマインド通知 + gcalcli-today を毎分呼び出し |
| `~/.local/bin/gcalcli-notify` | デスクトップ通知＋サウンド再生スクリプト |
| `~/.local/bin/gcalcli-today` | 今日の予定をJSON出力 → `/tmp/gcal-today-events.json` |

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

`gcalcli-remind` と `gcalcli-today` で `--calendar` オプションにより指定。
現在の対象: `(上條) HapInS`, `f.kamijodev@gmail.com`
変更する場合は `gcalcli list` で一覧を確認し、両スクリプトを編集する。

## データフロー

```
gcalcli-remind.timer (1分毎)
  └→ gcalcli-remind
       ├→ gcalcli-notify (5分以内の予定を通知)
       └→ gcalcli-today (今日の全予定を /tmp/gcal-today-events.json に出力)
            └→ Noctalia FileView が検知 → バー/パネル更新
```

除外対象: `Busy`（データから除外）、`稼働`（バー表示のみ除外、パネルには表示）

## gcal-reminder プラグイン（Noctalia Shell）

Google Calendar 通知を Noctalia Shell 上で永続表示するカスタムプラグイン。

### 機能

- **バーウィジェット**: 進行中または次の予定を表示（`稼働`は除外）
  - 進行中: `タイトル (〜HH:MM)`
  - 次の予定: `HH:MM タイトル`
- **パネル**: 今日の全予定を時系列表示（進行中ハイライト、終了済み半透明）
- **通知キャプチャ**: `appName: "Google Calendar"` の通知のみキャプチャし手動で閉じるまで保持
- **フルスクリーンアラート**: 開始3分前（@3m〜@0m, now）に全画面でイベント名と開始時刻を表示
  - 「閉じる」: アラートを閉じるが、次の通知（@2m→@1m→now）で再表示
  - 「以降非表示」: 同イベントのアラートをすべて抑制し通知も削除

### 管理ファイル（chezmoi）

| ファイル | 役割 |
|---------|------|
| `~/.config/noctalia/plugins/gcal-reminder/manifest.json` | プラグイン定義 |
| `~/.config/noctalia/plugins/gcal-reminder/Main.qml` | 通知キャプチャ + FileView監視 + フルスクリーンアラート |
| `~/.config/noctalia/plugins/gcal-reminder/BarWidget.qml` | 進行中/次の予定を表示 |
| `~/.config/noctalia/plugins/gcal-reminder/Panel.qml` | 今日の予定一覧 |
| `~/.config/noctalia/plugins/gcal-reminder/Settings.qml` | フィルター設定UI |
| `~/.config/noctalia/plugins.json` | プラグイン有効/無効管理 |

### 設定

`settings.json` はプラグインが自動管理。手動変更は再起動時に上書きされる。

| 設定項目 | デフォルト | 説明 |
|---------|-----------|------|
| `filterMode` | `"filter"` | `"all"`: 全通知、`"filter"`: 指定アプリのみ |
| `filteredApps` | `["Google Calendar"]` | キャプチャ対象のアプリ名 |
| `maxNotifications` | `200` | 保持する通知の最大数 |
