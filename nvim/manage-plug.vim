call plug#begin('~/.vim/plugged')
  " ui
  Plug 'akinsho/bufferline.nvim'
  Plug 'nvim-lualine/lualine.nvim'
  Plug 'navarasu/onedark.nvim'
  Plug 'tanvirtin/monokai.nvim'
  Plug 'kyazdani42/nvim-web-devicons'
  " etc
  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
  Plug 'kyazdani42/nvim-tree.lua'
  Plug 'machakann/vim-highlightedyank'
  Plug 'tomtom/tcomment_vim'
  Plug 'neoclide/coc.nvim', {'branch': 'release'} 
  Plug 'APZelos/blamer.nvim'
  Plug 'svermeulen/vim-subversive'
  Plug 'easymotion/vim-easymotion'
  Plug 'tpope/vim-surround'
  Plug 'voldikss/vim-translator'
  Plug 'nvim-telescope/telescope.nvim'
  Plug 'MunifTanjim/nui.nvim'
call plug#end()
