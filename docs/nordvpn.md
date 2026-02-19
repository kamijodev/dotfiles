# NordVPN

GUI 付き NordVPN クライアント。

## インストール

```bash
paru -S nordvpn-gui-bin
```

`nordvpn-bin`（CLI のみ）が依存として一緒に入る。

## セットアップ

```bash
# デーモンを有効化・起動
sudo systemctl enable --now nordvpnd

# ユーザーを nordvpn グループに追加（再起動が必要）
sudo usermod -aG nordvpn $USER

# 再起動後、グループ反映を確認
id  # nordvpn が含まれていること

# ログイン（トークン方式）
nordvpn login --token <トークン>
```

### トークンの取得

Web の `nordvpn login` は 500 エラーになることがあるため、トークン方式を使う。

1. https://my.nordaccount.com にブラウザでログイン
2. **Services** → **NordVPN** → **Access Token** → **Generate New Token**
3. 生成されたトークンを `nordvpn login --token <トークン>` に渡す

## よく使うコマンド

| コマンド | 説明 |
|---------|------|
| `nordvpn connect` | 最速サーバーに接続 |
| `nordvpn connect Japan` | 日本サーバーに接続 |
| `nordvpn disconnect` | 切断 |
| `nordvpn status` | 接続状態確認 |
| `nordvpn set killswitch on` | キルスイッチ有効化 |
| `nordvpn settings` | 現在の設定を表示 |

## トラブルシューティング

### GUI で "failed to load nordvpn service"

`nordvpn` グループへの追加が反映されていない。`id` コマンドで確認し、含まれていなければ再起動する。`newgrp` では GUI アプリに反映されないため、完全な再ログインまたは再起動が必要。

### サービスが動いていない

```bash
systemctl status nordvpnd
sudo systemctl restart nordvpnd
```
