# Claude Code

Claude Code CLI の設定。hooks による通知と、カスタムスキルによる開発ワークフロー自動化。

## 設定ファイル

| ファイル | 用途 |
|---------|------|
| `~/.claude/CLAUDE.md` | グローバル指示（Git操作、コメント規約、dotfiles管理） |
| `~/.claude/settings.json` | 権限・フック・デフォルト設定（chezmoi テンプレート） |
| `~/.claude/hooks/notify.sh` | 許可リクエスト時の通知 |
| `~/.claude/hooks/notify-stop.sh` | セッション終了時の通知 |
| `~/.claude/skills/*/SKILL.md` | カスタムスキル定義 |

## Hooks

### notify.sh（PermissionRequest イベント）

権限確認が必要な時にデスクトップ通知を送信。

- notify-send → kdialog → stderr の順でフォールバック

### notify-stop.sh（Stop イベント）

セッション終了時に最後のアシスタントレスポンス（最大100文字）を通知 + サウンド再生。

- transcript_path から最後のメッセージを抽出
- サウンド: `/usr/share/sounds/freedesktop/stereo/message-new-instant.oga`

## スキル

### git-commit

Conventional Commits v1.0.0 準拠のコミットメッセージを日本語で生成。

- type: feat / fix / docs / style / refactor / perf / test / build / ci / chore / revert
- scope は任意、description は日本語命令形
- BREAKING CHANGE 対応

### pr-create

ブランチ差分を分析し Pull Request を作成。

1. 事前確認（未コミット変更、リモート状態）
2. セルフレビュー（review スキルの観点で自動レビュー）
3. ユーザー確認（レビュー結果報告、承認を得る）
4. PR 作成（`gh pr create`）

マージコミットを除外し、ブランチ固有の変更のみを対象とする。

### review

コードレビューを実施し、問題点・改善提案・良い点を報告。

**必須チェック:**
- バグ（ロジックエラー、境界条件）
- セキュリティ（インジェクション、認証・認可）
- パフォーマンス（N+1クエリ、不要なループ）
- フロントエンド: FSD 準拠、Container/Presentational Pattern
- バックエンド: 不要な public メソッド、トランザクション内の非DB操作

**重要度:** CRITICAL > MAJOR > MINOR > SUGGESTION

### feature-sliced-design

Feature-Sliced Design (FSD) の実装ガイド。7層の階層構造（app → views → widgets → features → entities → shared）。Next.js App Router との統合パターンを定義。標準 FSD の `pages` の代わりに `views` を使用。

## settings.json

- デフォルトモード: PlanAndExecute
- 許可ツール: Bash, Edit, Write, WebFetch, WebSearch, Skill, Plugin:* 等
