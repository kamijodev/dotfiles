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
  -- Markdownをリッチ表示（見出しに色付き背景）
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
    config = function()
      require("render-markdown").setup({})
      local function set_heading_bgs()
        vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { bg = "#3c2020" }) -- 赤系
        vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { bg = "#3c2818" }) -- オレンジ系
        vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { bg = "#3c3020" }) -- 黄系
        vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { bg = "#283020" }) -- 緑系
        vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { bg = "#203030" }) -- アクア系
        vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { bg = "#302830" }) -- 紫系
      end
      set_heading_bgs()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_heading_bgs })
    end,
  },
  -- deviconsの色をカラーテーマに合わせて自動調整
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
  -- ファイルツリー（Ctrl+nで切り替え）
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
  -- ステータスライン
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" }, -- アイコン欲しい人向け
    config = function()
      require("lualine").setup()
    end,
  },
  -- ヤンク範囲をハイライト表示
  {
    "machakann/vim-highlightedyank"
  },
  -- チャンクハイライト（ブロックの開始〜終了をL字線で接続）
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      chunk = {
        enable = true,
        style = { { fg = "#7daea3" } },
        delay = 50,
      },
      indent = {
        enable = true,
        chars = { "│" },
        style = { { fg = "#3a3a3a" } },
      },
      line_num = { enable = false },
      blank = { enable = false },
    },
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
    opts = {
      explorer = { view_mode = "tree" },
    },
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
      -- エクスプローラから直接ファイルを開いてcodediffを閉じる
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "codediff-explorer",
        callback = function(ev)
          vim.keymap.set("n", "o", function()
            local lifecycle = require("codediff.ui.lifecycle")
            local tabpage = vim.api.nvim_get_current_tabpage()
            local explorer = lifecycle.get_explorer(tabpage)
            if not explorer or not explorer.tree then return end
            local node = explorer.tree:get_node()
            if not node or not node.data or not node.data.path then return end
            local abs_path = explorer.git_root .. "/" .. node.data.path
            vim.cmd("tabclose")
            vim.schedule(function()
              vim.cmd("edit " .. vim.fn.fnameescape(abs_path))
            end)
          end, { buffer = ev.buf, noremap = true, silent = true, desc = "ファイルを開いてcodediffを閉じる" })
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
  -- モーションで置換（<leader>r でヤンク内容に置き換え）
  {
    "svermeulen/vim-subversive",
    keys = {
      { "<leader>r", "<plug>(SubversiveSubstitute)" },
      { "<leader>R", "<plug>(SubiersiveSubstituteLine)" },
      { "<leader>rr", "<plug>(SubversiveSubstituteToEndOfLine)" },
    }
  },
  -- タブライン（セパレータなし、アクティブ=背景同化、非アクティブ=グレー背景+薄文字）
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
      highlight_inactive_file_icons = true,
      icons = {
        separator = { left = "", right = "" },
        inactive = { separator = { left = "", right = "" } },
        separator_at_end = false,
      },
    },
    lazy = false,
    keys = {
      { "<C-,>", "<Cmd>BufferPrevious<CR>" },
      { "<C-.>", "<Cmd>BufferNext<CR>" },
      { "<C-/>", "<Cmd>BufferClose<CR>", desc = "バッファを閉じる" },
    },
    config = function(_, opts)
      require("barbar").setup(opts)

      local function set_barbar_highlights()
        local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
        local fg = normal.fg and string.format("#%06x", normal.fg) or "#d4be98"
        local dim = "#5a5b5e"

        -- 組み込みTabLine系も透明に
        vim.cmd("hi! TabLine guibg=NONE ctermbg=NONE")
        vim.cmd("hi! TabLineFill guibg=NONE ctermbg=NONE")
        vim.cmd("hi! TabLineSel guibg=NONE ctermbg=NONE")

        local inactive_bg = "#282828"
        local suffixes = { "", "Mod", "Sign", "Index", "SignRight", "Number", "Btn", "ADDED", "CHANGED", "DELETED", "ERROR", "HINT", "INFO", "WARN", "Pin", "PinBtn" }

        -- アクティブタブ: 背景透明（エディタと同化）
        for _, suffix in ipairs(suffixes) do
          local bold = (suffix == "" or suffix == "Mod") and " gui=bold" or ""
          vim.cmd("hi! BufferCurrent" .. suffix .. " guifg=" .. fg .. " guibg=NONE ctermbg=NONE" .. bold)
        end
        -- アイコンは背景だけ設定し、fg は devicons の色を維持
        vim.cmd("hi! BufferCurrentIcon guibg=NONE ctermbg=NONE")
        vim.cmd("hi! BufferCurrentTarget guifg=#ea6962 guibg=NONE ctermbg=NONE gui=bold")

        -- 非アクティブタブ: 薄いグレー背景
        for _, prefix in ipairs({ "BufferInactive", "BufferVisible", "BufferAlternate" }) do
          for _, suffix in ipairs(suffixes) do
            vim.cmd("hi! " .. prefix .. suffix .. " guifg=" .. dim .. " guibg=" .. inactive_bg .. " ctermbg=NONE")
          end
          -- アイコンは背景だけ設定し、fg は devicons の色を維持
          vim.cmd("hi! " .. prefix .. "Icon guibg=" .. inactive_bg .. " ctermbg=NONE")
          vim.cmd("hi! " .. prefix .. "Target guifg=#ea6962 guibg=" .. inactive_bg .. " ctermbg=NONE gui=bold")
        end

        vim.cmd("hi! BufferTabpageFill guibg=NONE ctermbg=NONE")
        vim.cmd("hi! BufferTabpages guifg=" .. fg .. " guibg=NONE ctermbg=NONE")
        vim.cmd("hi! BufferOffset guibg=NONE ctermbg=NONE")
      end

      vim.defer_fn(set_barbar_highlights, 50)

      vim.api.nvim_create_autocmd({ "ColorScheme", "BufEnter", "BufAdd" }, {
        callback = function()
          vim.schedule(set_barbar_highlights)
        end,
      })
    end
  },
  -- パンくずリスト（winbar: パス + LSP/treesitterでコード構造を表示、グレー文字）
  {
    "Bekaboo/dropbar.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      bar = {
        sources = function(buf, _)
          local sources = require("dropbar.sources")
          local utils = require("dropbar.utils")
          if vim.bo[buf].ft == "markdown" then
            return { sources.path, sources.markdown }
          end
          if vim.bo[buf].buftype == "terminal" then
            return { sources.terminal }
          end
          return { sources.path, utils.source.fallback({ sources.lsp, sources.treesitter }) }
        end,
      },
    },
    config = function(_, opts)
      require("dropbar").setup(opts)
      local dim = "#6e6e6e"
      local function set_dropbar_hl()
        vim.cmd("hi! WinBar guifg=" .. dim .. " guibg=NONE")
        vim.cmd("hi! WinBarNC guifg=" .. dim .. " guibg=NONE")
        vim.cmd("hi! DropBarIconKindFile guifg=" .. dim)
        vim.cmd("hi! DropBarIconKindFolder guifg=" .. dim)
        vim.cmd("hi! DropBarKindFile guifg=" .. dim)
        vim.cmd("hi! DropBarKindFolder guifg=" .. dim)
        vim.cmd("hi! DropBarIconUISeparator guifg=#505050")
      end
      set_dropbar_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_dropbar_hl })
    end,
  },
}
