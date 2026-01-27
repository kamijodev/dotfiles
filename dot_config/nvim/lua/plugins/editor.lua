return {
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
