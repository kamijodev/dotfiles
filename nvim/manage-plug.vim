call plug#begin('~/.vim/plugged')
  " ui
  Plug 'akinsho/bufferline.nvim'
  Plug 'nvim-lualine/lualine.nvim'
  Plug 'navarasu/onedark.nvim'
  Plug 'tanvirtin/monokai.nvim'
  Plug 'catppuccin/nvim'
  Plug 'kyazdani42/nvim-web-devicons'
  Plug 'lukas-reineke/indent-blankline.nvim'
  " etc
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'kyazdani42/nvim-tree.lua'
  Plug 'machakann/vim-highlightedyank'
  Plug 'tomtom/tcomment_vim'
  Plug 'APZelos/blamer.nvim'
  Plug 'svermeulen/vim-subversive'
  Plug 'easymotion/vim-easymotion'
  Plug 'tpope/vim-surround'
  Plug 'tpope/vim-repeat'
  Plug 'tpope/vim-speeddating'
  Plug 'voldikss/vim-translator'

  " telescope
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'nvim-lua/plenary.nvim'

  " noice
  " Plug 'folke/noice.nvim'
  " Plug 'MunifTanjim/nui.nvim'
  Plug 'rcarriga/nvim-notify'

  " lsp + cmp
  Plug 'williamboman/mason.nvim'
  Plug 'williamboman/mason-lspconfig.nvim'
  Plug 'neovim/nvim-lspconfig'
  Plug 'hrsh7th/nvim-cmp'
  Plug 'hrsh7th/cmp-nvim-lsp'

  " git
  Plug 'vim-denops/denops.vim'
  Plug 'lambdalisue/gin.vim'
  Plug 'tpope/vim-fugitive'
  Plug 'lewis6991/gitsigns.nvim'

call plug#end()
