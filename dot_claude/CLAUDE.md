# Claude Code Instructions

## Dotfiles管理

`chezmoi managed` で管理対象ファイルを確認できる。
管理対象のファイルを変更した場合は、以下を実行:

```bash
chezmoi add <変更したファイル>
cd ~/.local/share/chezmoi && git add -A && git commit -m "<適切なメッセージ>" && git push
```
