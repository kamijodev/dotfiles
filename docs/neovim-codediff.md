# codediff.nvim

VS Code風のサイドバイサイドdiffビューアー。VS Codeのdiffアルゴリズム（Myers diff）をC実装し、2層ハイライト（行レベル + 文字レベル）を提供する。

## プラグイン情報

- リポジトリ: https://github.com/esmuellert/codediff.nvim
- 依存: `MunifTanjim/nui.nvim`
- Cライブラリは初回使用時に自動ダウンロード（コンパイラ不要）

## キーバインド

| キー | 動作 |
|---|---|
| `<leader>gd` | Git diff（エクスプローラ表示） |
| `<leader>gf` | 現在のファイル vs HEAD |
| `<leader>gh` | コミット履歴 |

### diff内のキーマップ（デフォルト）

| キー | 動作 |
|---|---|
| `q` | diffタブを閉じる |
| `<leader>b` | エクスプローラ表示切替 |
| `]c` / `[c` | 次/前のhunkへジャンプ |
| `]f` / `[f` | 次/前のファイル |
| `do` / `dp` | 変更の取得/反映（vimdiff互換） |
| `-` | ファイルのstage/unstage |
| `gf` | 前のタブでバッファを開く |

### エクスプローラ内

| キー | 動作 |
|---|---|
| `<CR>` | 選択ファイルのdiffを開く |
| `K` | diffプレビュー |
| `R` | リフレッシュ |
| `i` | list/tree表示切替 |
| `S` / `U` | 全ファイルstage/unstage |
| `X` | 変更を破棄 |

## コマンド例

```vim
:CodeDiff                        " git status表示
:CodeDiff HEAD~5                 " 特定リビジョンとの差分
:CodeDiff main                   " ブランチとの比較
:CodeDiff main...                " PR風diff（merge-base）
:CodeDiff file HEAD              " 現在ファイル vs HEAD
:CodeDiff file main HEAD         " 2つのリビジョン間
:CodeDiff history                " 直近50コミット
:CodeDiff history origin/main..HEAD  " PR用コミット範囲
```

## 設定ファイル

`~/.config/nvim/lua/plugins/ui.lua` に記述。
