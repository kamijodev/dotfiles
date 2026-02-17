# Neovim

LazyVim ベースの Neovim 設定。Gruvbox Material テーマ、AI アシスト（Claude Code + Copilot）、LSP フルサポート。

codediff.nvim の詳細は [neovim-codediff.md](neovim-codediff.md) を参照。

## 設定ファイル

| ファイル | 用途 |
|---------|------|
| `~/.config/nvim/init.lua` | エントリーポイント（netrw 無効化） |
| `~/.config/nvim/lua/config/options.lua` | エディタオプション |
| `~/.config/nvim/lua/config/keymaps.lua` | カスタムキーマップ |
| `~/.config/nvim/lua/config/lazy.lua` | Lazy.nvim ブートストラップ |
| `~/.config/nvim/lua/plugins/editor.lua` | Treesitter, Claude Code, Copilot |
| `~/.config/nvim/lua/plugins/lsp.lua` | LSP 設定 |
| `~/.config/nvim/lua/plugins/search.lua` | Telescope, grug-far |
| `~/.config/nvim/lua/plugins/ui.lua` | UI・ビジュアル系プラグイン |

## オプション設定

- 行番号表示、相対行番号
- True Color、カーソルライン表示、折り返し無効
- タブ = 2スペース、スマートインデント
- クリップボード連携、スワップファイル無効
- smartcase 検索、インクリメンタル検索
- スクロール余白 8行
- タブ・末尾スペース・NBSP を可視化

## キーマップ（Leader = Space）

### Normal モード

| キー | 動作 |
|------|------|
| H / L | 行頭(^) / 行末($) |
| Ctrl+K / Ctrl+J | 行を上/下に移動 |
| > / < | インデント |
| Leader+i | Inspect（シンボル情報） |

### Visual モード

| キー | 動作 |
|------|------|
| x / s | 削除（レジスタ非上書き） |
| > / < | インデント（選択維持） |
| Ctrl+K / Ctrl+J | 行を上/下に移動 |

## プラグイン構成

### エディタ (editor.lua)

**Treesitter** — シンタックスハイライト強化
- 対応言語: TypeScript, JavaScript, Lua, Vue, HTML, CSS, JSON, YAML, Markdown, GraphQL, Prisma, Bash

**claudecode.nvim** — Claude Code 統合
| キー | 動作 |
|------|------|
| Leader+ac | Claude 切り替え |
| Leader+af | Claude にフォーカス |
| Leader+ab | バッファを追加 |
| Leader+as | 選択テキスト送信 / ファイルツリーから追加 |
| Leader+aa / ad | 差分を承認 / 拒否 |

**Copilot** — AI コード補完
- オートトリガー有効、Tab で Accept、Ctrl+] で Dismiss

### LSP (lsp.lua)

**mason + mason-lspconfig** — LSP サーバー管理
- インストール対象: ts_ls, lua_ls, graphql, prismals, tailwindcss, biome, vue_ls

**lspsaga.nvim** — LSP UI 改善
| キー | 動作 |
|------|------|
| Leader+h | ホバー情報 |
| Leader+k | 定義へジャンプ |

### 検索 (search.lua)

**Telescope** — ファジー検索
| キー | 動作 |
|------|------|
| Ctrl+P / Leader+ff | ファイル検索 |
| Ctrl+F / Leader+fg | テキスト検索（live grep） |
| Ctrl+T | テキスト検索 |
| Leader+fr | 最近のファイル |
| Leader+fb | バッファ一覧 |
| Leader+fw | カーソル下の単語で検索 |
| Leader+fs / fS | LSP シンボル（ファイル / ワークスペース） |
| Leader+gf | Git ファイル |
| Leader+gc | Git コミット履歴 |

**grug-far.nvim** — パネル型検索・置換
| キー | 動作 |
|------|------|
| Leader+sr | 検索・置換パネル |
| Leader+sw | カーソル下の単語で置換 |

### UI (ui.lua)

| プラグイン | 用途 |
|-----------|------|
| gruvbox-material | カラーテーマ（透明背景、カスタマイズ済み） |
| nvim-tree.lua | ファイルツリー（Ctrl+N で切り替え） |
| barbar.nvim | タブバー（Ctrl+, / Ctrl+. / Ctrl+/ で操作） |
| lualine.nvim | ステータスバー |
| gitsigns.nvim | Git サイン + blame 表示 |
| indent-blankline.nvim | インデントガイド（虹色） |
| render-markdown.nvim | Markdown レンダリング |
| minimap.vim | ミニマップ（Leader+mm で切り替え） |
| vim-subversive | 置換操作（Leader+r / R / rr） |
| vim-highlightedyank | ヤンクハイライト |
| tiny-devicons-auto-colors | アイコン色自動設定 |
| codediff.nvim | VS Code 風 Git diff |

### プリセットカラーテーマ

gruvbox-material がアクティブ。以下もインストール済み（透明背景対応）:
one_monokai, catppuccin, tokyonight, kanagawa, rose-pine, cyberdream
