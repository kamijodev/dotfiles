local keymap = vim.keymap

local normalSettingList = {
  {'x', '"_x', {}},
  {'s', '"_s'},
  {'Y', 'y$'},
  {'>', '>>'},
  {'<', '<<'},
  {'<c-j>', '"zdd"zp'},
  {'<c-k>', '"zdd<up>"zP'},
  {'<c-k>', '"zdd<up>"zP'},
  {'<leader>/', ':noh<cr>', {silent=true}},
}

for i = 1 , #normalSettingList do
  keymap.set('n', normalSettingList[i][1], normalSettingList[i][2], normalSettingList[i][3])
end
