---
name: pr-create
description: Pull Requestを作成する。ブランチの差分とコミット履歴を分析し、適切なタイトルと説明文を自動生成する。「PR作って」「PRを作成して」「プルリクエスト作成」「このブランチPR出して」等の指示があった場合に使用。
---

# PR Create

ブランチの変更内容を分析し、レビュー後にPull Requestを作成する。

## ワークフロー

### Phase 1: 事前確認

1. `git status` で未コミットの変更を確認
2. リモートブランチの状態を確認（push済みか）
3. `git log main..HEAD --no-merges --first-parent` でこのブランチ固有のコミット履歴を取得
4. ブランチ固有のコミットで変更されたファイルの差分を確認

### Phase 2: セルフレビュー（必須）

**PR作成前に必ず `pr-review` スキルの観点でレビューを実施する。**

レビュー観点（pr-reviewスキル参照）:
- バグ: ロジックエラー、境界条件
- セキュリティ: インジェクション、認証・認可、機密情報の露出
- パフォーマンス: N+1クエリ、不要なループ
- フロントエンド: FSD準拠、Container/Presentational Pattern
- バックエンド: 不要なpublicメソッド

レビュー結果を以下の形式で報告:
```markdown
## セルフレビュー結果

### 問題点
- [ ] **[重要度]** ファイル名:行番号 - 問題の説明

### 改善提案
- ファイル名:行番号 - 提案内容

### 良い点
- 良かった点
```

### Phase 3: ユーザー確認（必須）

レビュー結果を報告した後、**必ず** AskUserQuestion でユーザーに確認する:

- 問題点がある場合: 「以下の問題が見つかりました。このままPRを作成しますか？修正しますか？」
- 問題点がない場合: 「レビューで問題は見つかりませんでした。PRを作成してよろしいですか？」

**ユーザーの承認を得るまでPR作成に進まないこと。**

### Phase 4: PR作成

ユーザーの承認後:
1. PRタイトルと説明文を生成
2. `gh pr create` でPRを作成

### 重要: マージコミットの除外

mainブランチをマージした場合、マージで混入した他PRの変更がdiffに含まれてしまう。
PRの説明にはこのブランチ固有の変更のみを記載すること。

**ブランチ固有の変更を取得する方法:**
```bash
# このブランチで直接行われたコミットのみ取得（マージコミット除外）
git log main..HEAD --no-merges --first-parent --oneline

# ブランチ固有のコミットで変更されたファイル一覧
git log main..HEAD --no-merges --first-parent --name-only --pretty=format: | sort -u | grep -v '^$'

# 特定ファイルの差分を確認（上記で取得したファイルに対して）
git diff main...HEAD -- <file_path>
```

**注意:** `git diff main...HEAD` だけではマージで混入した変更も含まれるため、
必ずブランチ固有のコミットで変更されたファイルを特定してから差分を確認する。

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

# ブランチ固有のコミット確認（マージコミット除外）
git log main..HEAD --no-merges --first-parent --oneline

# ブランチ固有の変更ファイル一覧
git log main..HEAD --no-merges --first-parent --name-only --pretty=format: | sort -u | grep -v '^$'
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
