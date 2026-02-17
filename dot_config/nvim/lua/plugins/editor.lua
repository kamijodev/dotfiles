return {
  -- Treesitter: シンタックスハイライト強化
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup()

      -- よく使う言語のパーサーをインストール
      local langs = {
        "typescript", "tsx", "javascript",
        "lua", "vue", "html", "css",
        "json", "yaml", "markdown",
        "graphql", "prisma", "bash",
      }
      ts.install(langs)

      -- ハイライトとインデントを有効化
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function()
          pcall(vim.treesitter.start)
          pcall(function()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end)
        end,
      })
    end,
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    keys = {
      { "<leader>a", nil, desc = "AI/Claude" },
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Claude 切り替え" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude にフォーカス" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Claude 再開" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude 続行" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "モデル選択" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "現在のバッファを追加" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude に送信" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "ファイルを追加",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
      -- 差分管理
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "差分を承認" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "差分を拒否" },
    },
  },
  {
    url = "git@github.com:kamijodev/daily-memo.nvim.git",
    cmd = "DailyMemo",
    keys = {
      { "<leader>m", "<cmd>DailyMemo<cr>", desc = "Daily Memo" },
    },
    opts = { git = { enabled = false } },
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<tab>",
            next = "<down>",
            prev = "<up>",
            dismiss = "<C-]>",
          },
        },
        panel = { enabled = false },
      })
    end,
  }
}
