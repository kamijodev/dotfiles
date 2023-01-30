local status, plug = pcall(require, 'indent_blankline')
if (not status) then return end
vim.opt.list = true
-- vim.opt.listchars:append "eol:↴"
plug.setup({
  show_end_of_line = true,
})

