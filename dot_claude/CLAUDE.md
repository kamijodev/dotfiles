# Claude Code Instructions

## Dotfiles管理

以下のファイルを変更した場合は、chezmoiへの追加とgit pushを行う:

- `~/.zshrc`, `~/.zshenv`
- `~/.config/nvim/`
- `~/.config/starship.toml`
- `~/.config/sheldon/`
- `~/.config/wezterm/`
- `~/.gitconfig`
- `~/.ssh/config`
- `~/.claude/settings.json`
- `~/.claude/hooks/`
- `~/.claude/skills/`

```bash
chezmoi add <変更したファイル>
cd ~/.local/share/chezmoi && git add -A && git commit -m "<適切なメッセージ>" && git push
```
