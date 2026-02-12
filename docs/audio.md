# オーディオ設定

PipeWire + WirePlumber 環境でのオーディオデバイス制御。

## デバイス構成

| 種別 | デバイス | 用途 |
|------|---------|------|
| Output | Vega T1 Dongle | メインスピーカー/ヘッドセット |
| Output | Radeon HDMI | モニター出力（未使用） |
| Input | Fifine Microphone | メインマイク（許可） |
| Input | その他すべて | ブロック |

## Input ホワイトリスト

Fifine Microphone 以外のすべての音声入力をブロックしている。
新しいUSBマイク等を接続しても自動的にブロックされる。

### 管理ファイル（chezmoi）

| ファイル | 役割 |
|---------|------|
| `~/.config/wireplumber/wireplumber.conf.d/51-disable-inputs.conf` | input ホワイトリスト設定 |

### 許可デバイスの変更

`51-disable-inputs.conf` の `node.name` マッチを変更する：

```
# Fifine の部分を別のデバイス名に変更
node.name = "!~alsa_input.*Fifine*"
```

デバイス名は `wpctl status` と `wpctl inspect <id>` で確認できる。

### 反映

```bash
systemctl --user restart wireplumber
```

## 確認コマンド

```bash
wpctl status              # デバイス一覧
wpctl inspect <id>        # デバイス詳細
```
