" -- map --
nnoremap x "_x
vnoremap x "_x
nnoremap s "_s
vnoremap s "_s
nnoremap Y y$
nnoremap > >>
nnoremap < <<
nnoremap <C-j> "zdd"zp
nnoremap <C-k> "zdd<Up>"zP
vnoremap <C-k> "zx<Up>"zP`[V`]
vnoremap <C-j> "zx"zp`[V`]`]]`
vnoremap > >gvll
vnoremap < <gvhh
nnoremap <silent> <Leader>/ :noh<CR>
nnoremap L $
nnoremap H ^
nnoremap <silent><leader>p :e ~/.config/nvim/init.vim<CR>
nnoremap <silent> <leader>, :bprevious<CR>
nnoremap <silent> <leader>. :bn<CR>
nnoremap <silent> <Leader>w :bp\|bd #<CR>
vmap y ygv<Esc>

" -- plug-map --
" voldikss/vim-translator
nmap <silent> <Leader>t <Plug>TranslateW
vmap <silent> <Leader>t <Plug>TranslateWV

" kyazdani42/nvim-tree.lua
nnoremap <c-n> <cmd>NvimTreeToggle<cr>

" neoclide/coc.nvim
function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction
nmap <silent> <leader>k <Plug>(coc-definition)
nnoremap <silent> <leader>h :call ShowDocumentation()<cr>

" svermeulen/vim-subversive
nmap <Leader>r <plug>(SubversiveSubstitute)
nmap <Leader>R <plug>(SubversiveSubstituteLine)
nmap <Leader>rr <plug>(SubversiveSubstituteToEndOfLine)

" easymotion/vim-easymotion
nmap <Leader>s <Plug>(easymotion-overwin-f)
