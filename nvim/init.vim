let mapleader = " "
set termguicolors
runtime manage-plug.vim
runtime lua/init.lua
runtime! setting-plug/*lua
runtime! setting-plug/*vim
runtime map.vim
runtime set.vim

colorschem monokai

function! SourceInitVim()
  source ~/.config/nvim/init.vim
  echo "load init vim!"
endfunction

autocmd! BufWritePost ~/.config/nvim/* :call SourceInitVim()

