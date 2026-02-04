return {
  -- パネル型検索・置換
  {
    "MagicDuck/grug-far.nvim",
    keys = {
      { "<leader>sr", function() require("grug-far").toggle_instance({ instanceName = "main" }) end, desc = "検索・置換パネル" },
      { "<leader>sw", function() require("grug-far").open({ prefill = { search = vim.fn.expand("<cword>") } }) end, desc = "カーソル下の単語で置換" },
    },
    config = function()
      require("grug-far").setup({
        windowCreationCommand = "topleft vsplit",
        startInInsertMode = false,
        keymaps = {
          replace = { n = "<localleader>r" },
          qflist = { n = "<localleader>q" },
          syncLocations = { n = "<localleader>s" },
          close = { n = "q" },
          openLocation = { n = "<Enter>" },
          gotoLocation = { n = "o" },
        },
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    cmd = "Telescope",
    keys = {
      -- ファイル検索 (VSCode: Ctrl+P)
      { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "ファイル検索" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "ファイル検索" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "最近のファイル" },

      -- テキスト検索
      { "<C-f>", "<cmd>Telescope live_grep<cr>", desc = "テキスト検索" },
      { "<C-t>", "<cmd>Telescope live_grep<cr>", desc = "正規表現検索" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "テキスト検索 (grep)" },
      { "<leader>fw", "<cmd>Telescope grep_string<cr>", desc = "カーソル下の単語を検索" },

      -- バッファ・その他
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "バッファ一覧" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "ヘルプ検索" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "コマンド検索" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "キーマップ検索" },

      -- LSP関連
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<cr>", desc = "シンボル検索 (ファイル)" },
      { "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "シンボル検索 (ワークスペース)" },

      -- Git
      { "<leader>gf", "<cmd>Telescope git_files<cr>", desc = "Gitファイル検索" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Gitコミット履歴" },

      -- テーマ切り替え
      { "<leader>ft", "<cmd>Telescope colorscheme enable_preview=true<cr>", desc = "テーマ切り替え" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = "  ",
          entry_prefix = "  ",
          path_display = { "truncate" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
            width = 0.87,
            height = 0.80,
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<Esc>"] = actions.close,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<C-Down>"] = actions.cycle_history_next,
            },
          },
        },
        pickers = {
          find_files = {
            hidden = true,
            file_ignore_patterns = { "^.git/", "node_modules" },
          },
          live_grep = {
            additional_args = function()
              return { "--hidden", "--glob", "!.git/*" }
            end,
          },
        },
      })

      -- fzf拡張を読み込み（高速化）
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
