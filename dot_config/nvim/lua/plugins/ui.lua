return {
  -- カラーテーマ集
  {
    "cpea2506/one_monokai.nvim",
    lazy = true,
    priority = 1000,
    opts = { transparent = true },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    priority = 1000,
    opts = { transparent_background = true },
  },
  {
    "folke/tokyonight.nvim",
    lazy = true,
    priority = 1000,
    opts = { transparent = true },
  },
  {
    "rebelot/kanagawa.nvim",
    lazy = true,
    priority = 1000,
    opts = { transparent = true },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = true,
    priority = 1000,
    opts = { styles = { transparency = true } },
  },
  {
    "sainnhe/gruvbox-material",
    lazy = true,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_transparent_background = 2
    end,
  },
  -- デフォルトテーマ設定
  {
    "cpea2506/one_monokai.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("one_monokai").setup({ transparent = true })
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
  -- インデントレインボー（スペース背景色）
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = {
        char = " ",
        highlight = {
          "RainbowRed",
          "RainbowYellow",
          "RainbowBlue",
          "RainbowOrange",
          "RainbowGreen",
          "RainbowViolet",
          "RainbowCyan",
        },
      },
      whitespace = {
        highlight = {
          "RainbowRed",
          "RainbowYellow",
          "RainbowBlue",
          "RainbowOrange",
          "RainbowGreen",
          "RainbowViolet",
          "RainbowCyan",
        },
        remove_blankline_trail = false,
      },
      scope = { enabled = false },
    },
    config = function(_, opts)
      local hooks = require("ibl.hooks")
      -- one_monokaiテーマに合わせた背景色
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { bg = "#3d2028" })    -- ピンク系 (#F92672)
        vim.api.nvim_set_hl(0, "RainbowYellow", { bg = "#3d3520" }) -- 黄色系 (#E6DB74)
        vim.api.nvim_set_hl(0, "RainbowBlue", { bg = "#203540" })   -- シアン系 (#66D9EF)
        vim.api.nvim_set_hl(0, "RainbowOrange", { bg = "#3d2d18" }) -- オレンジ系 (#FD971F)
        vim.api.nvim_set_hl(0, "RainbowGreen", { bg = "#283d20" })  -- 緑系 (#A6E22E)
        vim.api.nvim_set_hl(0, "RainbowViolet", { bg = "#302540" }) -- 紫系 (#AE81FF)
        vim.api.nvim_set_hl(0, "RainbowCyan", { bg = "#203538" })   -- シアン薄め
      end)
      require("ibl").setup(opts)
    end,
  },
  -- Git signs + 現在行のblame表示
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 300,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
    },
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
