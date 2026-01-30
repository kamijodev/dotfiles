return {
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
      },
      automatic_enable = true,
    },
  },

  -- nvim-lspconfig: 各サーバーの設定テンプレート + キーマップ
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          -- セマンティックトークンを無効化（Treesitterの色を維持）
          if client then
            client.server_capabilities.semanticTokensProvider = nil
          end

          local opts = { buffer = args.buf }
          -- Leader+h: ホバー（詳細情報）
          vim.keymap.set("n", "<leader>h", vim.lsp.buf.hover, opts)
          -- Leader+k: 定義へジャンプ
          vim.keymap.set("n", "<leader>k", vim.lsp.buf.definition, opts)
        end,
      })
    end,
  },
}
