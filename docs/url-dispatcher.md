# URL Dispatcher

URLのドメインに応じて適切なデスクトップアプリで開く仕組み。

## 背景

Lotion（Linux向け非公式Notionアプリ）にはシングルインスタンス制御がなく、リンクをクリックするたびに新しいウィンドウが開いてしまう。
Electron の Chrome DevTools Protocol (CDP) を利用して既存ウィンドウにURLを送信することで回避する。

## 前提パッケージ

```bash
sudo pacman -S websocat   # WebSocket CLIクライアント（CDP通信に使用）
```

## 管理ファイル（chezmoi）

| ファイル | 役割 |
|---------|------|
| `~/.local/bin/url-dispatcher` | URL振り分けスクリプト本体 |
| `~/.local/share/applications/url-dispatcher.desktop` | デフォルトブラウザとして登録 |
| `~/.local/share/applications/lotion.desktop` | Lotionを `--remote-debugging-port` 付きで起動するオーバーライド |

## 動作の流れ

1. リンクをクリック → `xdg-open` → `url-dispatcher` が呼ばれる
2. `notion.so` のURL → Lotionへ振り分け
   - Lotion起動中: CDP (port 19222) 経由で既存タブにナビゲーション + niriでウィンドウフォーカス
   - Lotion未起動: `--remote-debugging-port=19222` 付きで新規起動
3. それ以外のURL → Google Chrome Canary で開く

## 新規環境でのセットアップ

```bash
# 1. chezmoi apply でファイルを配置
chezmoi apply

# 2. デフォルトブラウザをディスパッチャに設定
xdg-settings set default-web-browser url-dispatcher.desktop
```

## 振り分けルールの追加

`~/.local/bin/url-dispatcher` の `case` 文にパターンを追加する：

```bash
case "$URL" in
  https://www.notion.so/* | https://notion.so/*)
    open_in_lotion "$URL"
    ;;
  # 例: Slack のリンクを Slack アプリで開く
  # https://app.slack.com/*)
  #   open_in_slack "$URL"
  #   ;;
  *)
    exec /usr/bin/google-chrome-canary "$URL"
    ;;
esac
```
