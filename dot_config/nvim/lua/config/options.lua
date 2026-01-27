local opt = vim.opt

-- 基本
opt.number = true
opt.mouse = "a" -- a = 全部のモードで有効
opt.clipboard = "unnamedplus"
opt.swapfile = false
opt.backup = false
opt.undofile = true
opt.undolevels = 10000

-- 見た目
opt.termguicolors = true
opt.signcolumn = "yes" -- ファイルにgitとかの印
opt.cursorline = true
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8

-- 検索
opt.ignorecase = true -- 大文字小文字関係なく検索
opt.smartcase = true -- 大文字が含まれれば厳密に
opt.incsearch = true
opt.hlsearch = true

-- インデント
opt.expandtab = true -- tab -> space
opt.tabstop = 2
opt.shiftwidth = 2
opt.smartindent = true

-- 分割
opt.splitright = true
opt.splitbelow = true

-- 速さ/操作感
opt.updatetime = 200
opt.timeoutlen = 800

-- 余計な文字
opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- 文字コード
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"

