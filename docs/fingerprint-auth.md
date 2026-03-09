# 指紋認証 (fprintd)

## 概要

ThinkPad X1 Carbon Gen 13 の Goodix 指紋リーダー (`27c6:658c`) を fprintd で有効化。

## セットアップ

```bash
sudo pacman -S fprintd
fprintd-enroll  # 指を繰り返しタッチして登録
fprintd-verify  # 動作確認
```

## PAM設定

以下のファイルの `#%PAM-1.0` 直後に追加：

```
auth sufficient pam_fprintd.so
```

- `/etc/pam.d/system-local-login` — TTYログイン
- `/etc/pam.d/sudo` — sudo認証

`sufficient` = 指紋 OR パスワードのどちらかで認証通過。

## 指紋の再登録

```bash
fprintd-delete "$USER"  # 既存の指紋を削除
fprintd-enroll           # 再登録
```

## 参考

- [ArchWiki - Fprint](https://wiki.archlinux.org/title/Fprint)
- [ArchWiki - ThinkPad X1 Carbon Gen 12](https://wiki.archlinux.org/title/Lenovo_ThinkPad_X1_Carbon_(Gen_12))
