vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- tbl_extend は("force", a, b)ならaをbが上書き
-- local map = vim.keymap.set

local default_opts = { noremap = true, silent = true }

local groups = {
  {
    mode = "v",
    maps = {
      { key = "x", action = "\"_x" },
      { key = "s", action = "\"_s" },
      { key = ">", action = ">gvll" },
      { key = "<", action = "<gvhh" },
      { key = "<C-k>", action = "\"zx<Up>\"zP`[V`]" },
      { key = "<C-j>", action = "\"zx\"zp`[V`]`]]`" },
      { key = "y", action = "ygv<Esc>" },
    }
  },
  {
    mode = "n",
    maps = {
      { key = "L", action = "$" },
      { key = "H", action = "^" },
      { key = "<C-k>", action = "\"zddk\"zP" },
      { key = "<C-j>", action = "\"zdd\"zp" },
      { key = "<C-w><C-/>", action = "<C-w>q" },
      { key = ">", action = ">>" },
      { key = "<", action = "<<" },
    }
  },
  {
    mode = "t",
    maps = {
      { key = "<C-w><C-w>", action = "<C-\\><C-n><C-w><C-w>" },
      { key = "<C-w><C-h>", action = "<C-\\><C-n><C-w>h" },
      { key = "<C-w><C-j>", action = "<C-\\><C-n><C-w>j" },
      { key = "<C-w><C-k>", action = "<C-\\><C-n><C-w>k" },
      { key = "<C-w><C-l>", action = "<C-\\><C-n><C-w>l" },
    }
  },
}

for _, g in ipairs(groups) do
  local mode, maps = g.mode, g.maps
  for _, map in ipairs(maps) do
    vim.keymap.set(mode, map.key, map.action, vim.tbl_extend("force", default_opts, map.opts or {}))
  end
end

-- Inspect: カーソル位置のハイライト情報表示
vim.keymap.set("n", "<leader>i", "<cmd>Inspect<cr>", { desc = "シンボル情報表示" })
