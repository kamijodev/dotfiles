local status, mason = pcall(require, 'mason')
if (not status) then return end
local status, mason_lspconfig = pcall(require, 'mason-lspconfig')
if (not status) then return end
local status, lspconfig = pcall(require, 'lspconfig')
if (not status) then return end
local status, cmp = pcall(require, 'cmp')
if (not status) then return end

cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  sources = {
    { name = "nvim_lsp" },
    -- { name = "buffer" },
    -- { name = "path" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ['<C-l>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm { select = true },
  }),
  experimental = {
    ghost_text = true,
  },
})


mason.setup()

local configs = require('lspconfig/configs')
local util = require('lspconfig/util')

local path = util.path

mason_lspconfig.setup_handlers({ function(server)
  local opt = {
    -- Function executed when the LSP server startup
    on_attach = function(client, bufnr)
      local opts = { noremap = true, silent = true }
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>h', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>k', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
      vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>j', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
      -- vim.api.nvim_buf_set_keymap(bufnr, 'n', '<leader>g', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
      -- vim.cmd 'autocmd BufWritePre * lua vim.lsp.buf.formatting_sync(nil, 1000)'
    end,
    capabilities = require('cmp_nvim_lsp').default_capabilities(
      vim.lsp.protocol.make_client_capabilities()
    ),
  }

  if server == "pyright" then

    local function get_python_path(workspace)
      -- Use activated virtualenv.
      if vim.env.VIRTUAL_ENV then
        return path.join(vim.env.VIRTUAL_ENV, 'bin', 'python')
      end

      -- Find and use virtualenv in workspace directory.
      local match = vim.fn.glob(path.join(workspace, 'poetry.lock'))
      if match ~= '' then
        local venv = vim.fn.trim(vim.fn.system('poetry --directory ' .. workspace .. ' env info -p'))
        return path.join(venv, 'bin', 'python')
      end

      -- Fallback to system Python.
      return exepath('python3') or exepath('python') or 'python'
    end

    opt["on_init"] = function(client)
        client.config.settings.python.pythonPath = get_python_path(client.config.root_dir)
    end

  end
  lspconfig[server].setup(opt)
end })

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover,
  {
    border = "single"
  }
)

vim.opt.signcolumn = "yes"


