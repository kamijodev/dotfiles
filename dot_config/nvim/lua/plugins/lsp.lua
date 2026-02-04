return {
  -- lspsaga: きれいなLSP UI
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      ui = {
        border = "rounded",
      },
      hover = {
        open_cmd = '!firefox',
      },
      lightbulb = {
        enable = false,
      },
      symbol_in_winbar = {
        enable = false,
      },
    },
  },

  -- Mason: LSPサーバーのインストール管理
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  -- mason-lspconfig: MasonとLSPの橋渡し
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      ensure_installed = {
        "ts_ls",           -- TypeScript/JavaScript
        "lua_ls",          -- Lua (Neovim設定用)
        "graphql",         -- GraphQL
        "prismals",        -- Prisma
        "tailwindcss",     -- TailwindCSS
        "biome",           -- Biome (リンター/フォーマッター)
        "vue_ls",          -- Vue
      },
      automatic_enable = true,
    },
  },

  -- nvim-lspconfig: 各サーバーの設定テンプレート + キーマップ
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- ホバーウィンドウにボーダーを追加
      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
      })
      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          -- セマンティックトークンを無効化（Treesitterの色を維持）
          if client then
            client.server_capabilities.semanticTokensProvider = nil
          end

          local opts = { buffer = args.buf }
          -- Leader+h: ホバー（詳細情報）- lspsaga
          vim.keymap.set("n", "<leader>h", "<cmd>Lspsaga hover_doc<cr>", opts)
          -- Leader+k: 定義へジャンプ - lspsaga
          vim.keymap.set("n", "<leader>k", "<cmd>Lspsaga goto_definition<cr>", opts)
        end,
      })
    end,
  },
}
