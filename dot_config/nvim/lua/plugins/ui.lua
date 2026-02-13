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
    "scottmckendry/cyberdream.nvim",
    lazy = false,
    priority = 1000,
    opts = { transparent = true },
  },
  {
    "sainnhe/gruvbox-material",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.gruvbox_material_transparent_background = 2
      -- ピンクをもう少し紫っぽく
      vim.g.gruvbox_material_colors_override = {
        purple = { '#b48ead', '139' },
      }
      vim.cmd([[colorscheme gruvbox-material]])
      -- ホバーウィンドウの背景を暗く
      vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#141414" })
      vim.api.nvim_set_hl(0, "FloatBorder", { bg = "#141414", fg = "#7daea3" })
    end,
  },
  -- one_monokai（テーマ選択用に残す）
  {
    "cpea2506/one_monokai.nvim",
    lazy = true,
    priority = 1000,
    opts = { transparent = true },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    opts = {},
  },
  {
    "rachartier/tiny-devicons-auto-colors.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    config = function()
      require("tiny-devicons-auto-colors").setup()
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
      -- gruvbox-materialに合わせた背景色
      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { bg = "#3c2020" })    -- 赤系 (#ea6962)
        vim.api.nvim_set_hl(0, "RainbowYellow", { bg = "#3c3020" }) -- 黄系 (#d8a657)
        vim.api.nvim_set_hl(0, "RainbowBlue", { bg = "#203038" })   -- 青系 (#7daea3)
        vim.api.nvim_set_hl(0, "RainbowOrange", { bg = "#3c2818" }) -- オレンジ系 (#e78a4e)
        vim.api.nvim_set_hl(0, "RainbowGreen", { bg = "#283020" })  -- 緑系 (#a9b665)
        vim.api.nvim_set_hl(0, "RainbowViolet", { bg = "#302830" }) -- 紫系 (#b48ead)
        vim.api.nvim_set_hl(0, "RainbowCyan", { bg = "#203030" })   -- アクア系 (#89b482)
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
  -- Git diff (VS Code風サイドバイサイド)
  {
    "esmuellert/codediff.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    cmd = "CodeDiff",
    keys = {
      { "<leader>g", "<cmd>CodeDiff<cr>", desc = "Git diff" },
    },
    opts = {},
    config = function(_, opts)
      require("codediff").setup(opts)
      -- diffハイライトを薄い色で上書き
      local diff_hl = {
        CodeDiffLineInsert = { bg = "#1a241a" },
        CodeDiffLineDelete = { bg = "#241a1a" },
        CodeDiffCharInsert = { bg = "#1e301e" },
        CodeDiffCharDelete = { bg = "#301e1e" },
      }
      for name, val in pairs(diff_hl) do
        vim.api.nvim_set_hl(0, name, val)
      end
      vim.api.nvim_create_autocmd("ColorScheme", {
        callback = function()
          for name, val in pairs(diff_hl) do
            vim.api.nvim_set_hl(0, name, val)
          end
        end,
      })
      -- タブクローズ時に残留バッファを掃除
      vim.api.nvim_create_autocmd("TabClosed", {
        callback = function()
          vim.schedule(function()
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
                local name = vim.api.nvim_buf_get_name(buf)
                local ft = vim.bo[buf].filetype
                if ft == "codediff-explorer" or name:match("^codediff://") then
                  vim.api.nvim_buf_delete(buf, { force = true })
                elseif name == "" and not vim.bo[buf].modified and vim.api.nvim_buf_line_count(buf) <= 1 then
                  local lines = vim.api.nvim_buf_get_lines(buf, 0, 1, false)
                  if #lines == 0 or lines[1] == "" then
                    vim.api.nvim_buf_delete(buf, { force = true })
                  end
                end
              end
            end
          end)
        end,
      })
    end,
  },
  -- ミニマップ
  {
    "wfxr/minimap.vim",
    cmd = { "Minimap", "MinimapClose", "MinimapToggle" },
    keys = {
      { "<leader>mm", "<cmd>MinimapToggle<cr>", desc = "ミニマップ切り替え" },
    },
    init = function()
      vim.g.minimap_width = 10
      vim.g.minimap_auto_start = 0
      vim.g.minimap_auto_start_win_enter = 0
      vim.g.minimap_highlight_range = 1
      vim.g.minimap_highlight_search = 1
      vim.g.minimap_git_colors = 1
    end,
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
      },
      exclude_ft = { "codediff-explorer" },
      exclude_name = { "codediff://*" },
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
