local M = {}

local grep_globs = ""
local file_globs = ""

-- live_grep_args 用フィルタ
function M.prompt_grep_filter(prompt_bufnr)
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")

  local picker = action_state.get_current_picker(prompt_bufnr)
  local prompt = picker:_get_prompt()

  -- 既存の -g 引数を除去してクエリ部分だけ取得
  local query = prompt:gsub('%s*%-g%s+%S+', '')
  query = query:gsub('^%s+', ''):gsub('%s+$', '')
  query = query:gsub('^"(.*)"$', '%1')

  actions.close(prompt_bufnr)

  vim.ui.input({
    prompt = "Grep filter (e.g. !dist/, *.tsx): ",
    default = grep_globs,
  }, function(input)
    if input == nil then
      grep_globs = ""
    else
      grep_globs = input
    end

    local search_query = query
    if search_query ~= "" and grep_globs ~= "" then
      search_query = '"' .. search_query .. '"'
    end

    if grep_globs ~= "" then
      for pattern in grep_globs:gmatch("[^,]+") do
        pattern = pattern:gsub("^%s+", ""):gsub("%s+$", "")
        if pattern ~= "" then
          search_query = search_query .. " -g " .. pattern
        end
      end
    end

    vim.schedule(function()
      require("telescope").extensions.live_grep_args.live_grep_args({
        default_text = search_query,
      })
    end)
  end)
end

-- find_files 用フィルタ
function M.prompt_file_filter(prompt_bufnr)
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")

  local picker = action_state.get_current_picker(prompt_bufnr)
  local prompt = picker:_get_prompt()

  actions.close(prompt_bufnr)

  vim.ui.input({
    prompt = "File filter (e.g. !*.md, !dist/, *.tsx): ",
    default = file_globs,
  }, function(input)
    if input == nil then
      file_globs = ""
    else
      file_globs = input
    end

    local find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" }

    if file_globs ~= "" then
      for pattern in file_globs:gmatch("[^,]+") do
        pattern = pattern:gsub("^%s+", ""):gsub("%s+$", "")
        if pattern ~= "" then
          if pattern:sub(1, 1) == "!" then
            -- 除外: !*.md → --exclude *.md
            table.insert(find_command, "--exclude")
            table.insert(find_command, pattern:sub(2))
          else
            -- 包含: *.tsx → --extension tsx (拡張子) or --glob pattern
            table.insert(find_command, "--glob")
            table.insert(find_command, pattern)
          end
        end
      end
    end

    vim.schedule(function()
      require("telescope.builtin").find_files({
        default_text = prompt,
        find_command = find_command,
      })
    end)
  end)
end

function M.setup() end

return M
