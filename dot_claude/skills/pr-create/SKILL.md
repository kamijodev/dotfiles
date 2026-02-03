---
name: pr-create
description: Pull Requestを作成する。ブランチの差分とコミット履歴を分析し、適切なタイトルと説明文を自動生成する。「PR作って」「PRを作成して」「プルリクエスト作成」等の指示があった場合に使用。
---

# PR Create

ブランチの変更内容を分析し、DraftでPull Requestを作成する。

## ワークフロー

1. `git status` で未コミットの変更を確認
2. リモートブランチの状態を確認（push済みか）
3. `git log main..HEAD` でコミット履歴を取得
4. `git diff main...HEAD` で差分を確認
5. PRタイトルと説明文を生成
6. `gh pr create` でPRを作成

## 事前チェック

### 必須条件

- すべての変更がコミット済みであること
- 現在のブランチがリモートにpush済みであること
- mainブランチとの差分が存在すること

### 確認事項

```bash
# 未コミットの変更確認
git status

# リモートとの同期状態確認
git log origin/<branch>..HEAD

# ベースブランチとの差分確認
git log main..HEAD --oneline
```

## PRタイトル生成ルール

### 形式

```
<type>: <簡潔な説明>
```

または複数の変更がある場合:

```
<メインの変更の説明>
```

### Type（単一コミットまたは明確な変更の場合）

| type | 用途 |
|------|------|
| `feat` | 新機能 |
| `fix` | バグ修正 |
| `docs` | ドキュメント |
| `refactor` | リファクタリング |
| `perf` | パフォーマンス改善 |
| `test` | テスト追加・修正 |
| `chore` | その他 |

### ガイドライン

- 70文字以内
- 日本語で記述
- 変更内容を端的に表現

## PR説明文テンプレート

基本的に`PULL_REQUEST_TEMPLATE.md`を参照
なければ下記を参照


```markdown
## 概要

<変更の目的と概要を1-3文で説明>

## 変更内容

- <主要な変更点1>
- <主要な変更点2>
- <主要な変更点3>

```

## 実行コマンド

```bash
# 基本的なPR作成
gh pr create --title "<タイトル>" --body "<説明文>"

# ドラフトPRとして作成
gh pr create --draft --title "<タイトル>" --body "<説明文>"

# ベースブランチを指定
gh pr create --base <branch> --title "<タイトル>" --body "<説明文>"

# レビュアーを指定
gh pr create --reviewer <user> --title "<タイトル>" --body "<説明文>"
```

## 出力

PR作成後、以下を報告:

- PR URL
- PRタイトル
- ベースブランチ → ヘッドブランチ

## エラー対処

| エラー | 対処 |
|--------|------|
| `branch not pushed` | `git push -u origin <branch>` を実行 |
| `no commits between` | 差分がないため、変更をコミットするよう促す |
| `pull request already exists` | 既存のPR URLを表示 |
