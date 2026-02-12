# fcitx5 (日本語入力)

niri 環境での日本語入力設定。

## 前提パッケージ

```bash
sudo pacman -S fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-mozc
paru -S fcitx5-skin-ori-git
```

## 環境変数

`~/.config/niri/cfg/misc.kdl` で設定済み：

```kdl
environment {
    GTK_IM_MODULE "fcitx"
    QT_IM_MODULE "fcitx"
    XMODIFIERS "@im=fcitx"
}
```

## テーマ

Ori dark を使用（丸角・ダークテーマ）。

`fcitx5-configtool` → アドオン → Classic UI → テーマ で「Ori dark」を選択。

## 候補ウィンドウの方向

`fcitx5-configtool` → グローバルオプション → 候補ウィンドウの方向 で横並び/縦並びを切り替え可能。
