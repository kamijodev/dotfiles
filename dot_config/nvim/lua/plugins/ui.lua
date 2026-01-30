return {
  -- カラーテーマ集
  { "cpea2506/one_monokai.nvim", lazy = true, priority = 1000 },
  { "catppuccin/nvim", name = "catppuccin", lazy = true, priority = 1000 },
  { "folke/tokyonight.nvim", lazy = true, priority = 1000 },
  { "rebelot/kanagawa.nvim", lazy = true, priority = 1000 },
  { "rose-pine/neovim", name = "rose-pine", lazy = true, priority = 1000 },
  { "sainnhe/gruvbox-material", lazy = true, priority = 1000 },
  -- デフォルトテーマ設定
  {
    "cpea2506/one_monokai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme one_monokai]])
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    keys = {
      { "<C-n>", "<cmd>NvimTreeToggle<CR>", desc = "ファイルツリー切り替え" },
      -- { "<leader>o", "<cmd>NvimTreeFocus<CR>", desc = "NvimTree Focus" },
      -- { "<leader>f", "<cmd>NvimTreeFindFile<CR>", desc = "NvimTree Find File" },
      -- { "<leader>c", "<cmd>NvimTreeCollapse<CR>", desc = "NvimTree Collapse" },
    },
    opts = {
      sync_root_with_cwd = true,  -- カレントディレクトリに追従
      respect_buf_cwd = true,     -- バッファのcwdを尊重
      update_focused_file = {
        enable = true,            -- 開いたファイルを自動ハイライト
        update_root = true,       -- ファイルに応じてルートも更新
      },
      actions = {
        open_file = {
          quit_on_open = true,    -- ファイルを開いたらツリーを閉じる
        },
      },
      on_attach = function(bufnr)
        local api = require("nvim-tree.api")
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "n", api.fs.create, { buffer = bufnr, desc = "ファイル作成" })
      end,
    },
    config = function(_, opts)
      require("nvim-tree").setup(opts)
    end
  },
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- アイコン欲しい人向け
    config = function()
      require("lualine").setup()
    end,
  },
  {
    "machakann/vim-highlightedyank"
  },
  {
    "svermeulen/vim-subversive",
    keys = {
      { "<leader>r", "<plug>(SubversiveSubstitute)" },
      { "<leader>R", "<plug>(SubiersiveSubstituteLine)" },
      { "<leader>rr", "<plug>(SubversiveSubstituteToEndOfLine)" },
    }
  },
  {
    "romgrk/barbar.nvim",
    dependencies = {
      "lewis6991/gitsigns.nvim",        -- 任意: git差分表示
      "nvim-tree/nvim-web-devicons",    -- 任意: ファイルアイコン
    },
    init = function() vim.g.barbar_auto_setup = false end,
    opts = {
      animation = true,
      tabpages = true,
      sidebar_filetypes = {
        NvimTree = true,
      }
    },
    lazy = false,
    keys = {
      { "<C-,>", "<Cmd>BufferPrevious<CR>" },
      { "<C-.>", "<Cmd>BufferNext<CR>" },
      { "<C-/>", "<Cmd>BufferClose<CR>", desc = "バッファを閉じる" },
    },
    config = function(_, opts)
      local function brighten_barbar_current_text()
        local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
        vim.api.nvim_set_hl(0, "BufferCurrent",    { fg = normal.fg, bold = true })
        vim.api.nvim_set_hl(0, "BufferCurrentMod", { fg = normal.fg, bold = true })
        -- 非アクティブを暗く（TabLineに寄せる）
        vim.api.nvim_set_hl(0, "BufferInactive",    { fg = "#5a5b5e" })
        vim.api.nvim_set_hl(0, "BufferInactiveMod", { fg = "#5a5b5e" })
      end

      brighten_barbar_current_text()

      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = brighten_barbar_current_text,
      })

      require("barbar").setup(opts)
    end
  }
}
