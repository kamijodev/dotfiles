local status, plug = pcall(require, 'bufferline')
if (not status) then return end

plug.setup({
  options = {
    diagnostics = "nvim_lsp",
    show_close_icon = false,
    -- indicator = {
    --   style = 'underline'
    -- },
    offsets = {
      {
        filetype = "NvimTree",
        text = "- NvimTree -",
        text_align = "center",
        separator = true
      }
    }
  }
})

