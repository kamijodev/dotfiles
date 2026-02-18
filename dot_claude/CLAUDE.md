# Claude Code Instructions

## Git操作

`git push` は引数なしだと権限エラーになるため、必ずリモートとブランチを明示する：

```bash
# NG
git push

# OK
git push origin <branch>
```

## コードコメント

コメントにはコードの「目的」や「理由」のみを書く。以下のようなPR説明・変更履歴に該当する情報はコメントに含めない：

- 最適化手法の記述（例: `相関サブクエリ除去`, `GROUP BY除去`, `N+1解消`）
- 変更前との差分の説明（例: `5 JOIN除去`, `3テーブル削減`）
- 番号付きステップ（例: `// 1. ...`, `// 2. ...`）で変更の流れを示すもの
- 件数やテーブル数など実装詳細の補足（例: `20件: A→B→C→D`）

これらはPRの説明文やコミットメッセージに記載する。

## Dotfiles管理

`chezmoi managed` で管理対象ファイルを確認できる。
管理対象のファイルを変更した場合は、以下を実行:

```bash
chezmoi add <変更したファイル>
cd ~/.local/share/chezmoi && git add -A && git commit -m "<適切なメッセージ>" && git push origin main
```

### 環境変更時のドキュメント

環境に変更を加えた場合（ツール導入、設定追加・変更、ワークフロー構築、デバイス設定など）、以下を必ず行う：

1. **dotfiles**: 設定ファイルは `chezmoi add` で管理に追加
2. **docs**: 変更内容を `~/.local/share/chezmoi/docs/` にMarkdownで残す。dotfilesだけで再現できるものでも、何をなぜやったか・構成の全体像・変更方法がわかるように書く
3. **check-tools.zsh**: 新しいツールを追加した場合は `~/.config/zsh/check-tools.zsh` にチェックを追加
4. **パッケージリスト**: dotfilesリポジトリに `git push` する際は、必ず事前にパッケージリストを更新してコミットに含める
   ```bash
   pacman -Qqen > ~/.local/share/chezmoi/pkglist-pacman.txt
   pacman -Qqem > ~/.local/share/chezmoi/pkglist-aur.txt
   ```
