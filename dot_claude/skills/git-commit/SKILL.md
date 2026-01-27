---
name: git-commit
description: Conventional Commits v1.0.0仕様に準拠したコミットメッセージを生成しコミットを実行する。コード変更のコミット時、コミットメッセージの作成依頼時、または「コミットして」等の指示があった場合に使用。git diffを解析し、日本語で意味のあるコミットメッセージを作成する。
---

# Git Commit

Conventional Commits v1.0.0仕様 (https://www.conventionalcommits.org/en/v1.0.0/) に準拠したコミットメッセージを日本語で生成する。

## ワークフロー

1. `git diff --staged` でステージされた変更を確認
2. 変更内容からtype、scope、descriptionを決定
3. 日本語でコミットメッセージを生成
4. `git commit -m "<message>"` を実行

ステージされた変更がない場合は、ユーザーにファイルをステージするよう促す。

## メッセージ構造

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Type（必須）

| type | 用途 | SemVer |
|------|------|--------|
| `feat` | 新機能の追加 | MINOR |
| `fix` | バグ修正 | PATCH |
| `docs` | ドキュメントのみの変更 | - |
| `style` | コードの意味に影響しない変更（空白、フォーマット、セミコロン等） | - |
| `refactor` | バグ修正でも新機能でもないコード変更 | - |
| `perf` | パフォーマンス改善 | - |
| `test` | テストの追加・修正 | - |
| `build` | ビルドシステムや外部依存関係の変更 | - |
| `ci` | CI設定ファイルやスクリプトの変更 | - |
| `chore` | その他の変更（srcやtestを変更しない） | - |
| `revert` | コミットの取り消し | - |

## Scope（任意）

typeの後に括弧で囲んで記述。コードベースのセクションを示す名詞を使用。

例: `feat(auth):`, `fix(api):`, `docs(readme):`

ディレクトリ名、モジュール名、機能領域、コンポーネント名から導出する。曖昧な場合は省略。

## Description（必須）

- コロンとスペースの直後に記述
- 変更内容の簡潔な要約を日本語で
- 命令形で記述:「追加する」→「〜を追加」
- 文末に句点は付けない

## Body（任意）

descriptionの後、1行空けて記述。変更の動機や以前の動作との対比を説明。

## Footer（任意）

bodyの後、1行空けて記述。git trailer形式に従う。

### BREAKING CHANGE

破壊的変更がある場合、以下のいずれかで示す:

1. type/scopeの直後に ! を付ける（例: feat!: または feat(api)!:）
2. footerに `BREAKING CHANGE: <説明>` を記述
3. 両方を併用可

BREAKING CHANGEはtypeに関係なくMAJORバージョンアップに対応。

## 例

**新機能:**
```
feat(auth): メール形式のバリデーションを追加
```

**バグ修正:**
```
fix(api): ユーザープロファイル取得時のnullポインタを修正
```

**ドキュメント:**
```
docs: READMEのインストール手順を更新
```

**スコープなし:**
```
feat: 設定オブジェクトによる他設定の継承を許可
```

**破壊的変更（!使用）:**
```
feat(api)!: レスポンス形式をJSON:APIに変更
```

**破壊的変更（footer使用）:**
```
feat: 設定ファイルのextends機能を追加

BREAKING CHANGE: 設定ファイルの`extends`キーは他の設定ファイルを継承するために使用されるようになった
```

**body付き:**
```
fix: リクエストの競合状態を防止

リクエストIDと最新リクエストへの参照を導入。
最新リクエスト以外からのレスポンスを破棄する。

Refs: #123
```

**revert:**
```
revert: feat(auth): ログイン機能を追加

Refs: 676104e
```

## 判断基準

| 変更内容 | type |
|----------|------|
| 新しいエンドポイント/コンポーネント/機能 | `feat` |
| クラッシュ/エラー/不正な動作の修正 | `fix` |
| README、コメント、docstring | `docs` |
| 空白、フォーマット、セミコロン | `style` |
| 名前変更、構造変更、メソッド抽出 | `refactor` |
| 高速化、キャッシュ導入 | `perf` |
| テストファイルのみ | `test` |
| package.json、Dockerfile、Makefile | `build` |
| .github/workflows、CI設定 | `ci` |
| .gitignore、エディタ設定 | `chore` |

## 注意事項

- 複数の変更が混在する場合は、より重要なtypeを選ぶか、別々のコミットを提案
- `feat`と`fix`以外のtypeはSemVerに影響しない（BREAKING CHANGEを含む場合を除く）
- BREAKING CHANGEは必ず大文字で記述
- footerのトークンは空白の代わりに`-`を使用（例: `Acked-by`, `Reviewed-by`）
