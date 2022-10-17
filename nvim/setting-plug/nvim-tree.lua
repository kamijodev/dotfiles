local status, plug = pcall(require, 'nvim-tree')
if (not status) then return end

plug.setup({
  update_focused_file = {
    enable = true,
    update_root = true,
  },
  diagnostics = {
    enable = true,
    icons = {
      hint = '?',
      info = 'i',
      warning = '!',
      error = 'e',
    }
  },
  renderer = {
    icons = {
      glyphs = {
        git = {
          unstaged = '*',
          staged = '*',
          ignored = ':',
        }
      }
    }
  },
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
  git = {
    ignore = false,
  },
  view = {
    width = 35,
    mappings = {
      list = {
        { key = "l", action = "cd" },
        { key = "h", action = "dir_up" },
        { key = ".", action = "toggle_dotfiles" },
        { key = "y", action = "copy" },
        { key = "p", action = "paste" },
        { key = "n", action = "create" },
        { key = "<Tab>", action = "preview" },
        { key = "d", action = "remove" },
        { key = "r", action = "rename" },
        { key = "<CR>", action = "edit_no_picker" },
      },
    },
  },
})
