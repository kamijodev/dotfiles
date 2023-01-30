local status, plug = pcall(require, 'gitsigns')
if (not status) then return end
plug.setup({})
