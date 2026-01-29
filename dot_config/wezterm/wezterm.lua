local wezterm = require("wezterm")
local mux = wezterm.mux
local config = wezterm.config_builder()

----------------------------------------------------
-- IDE Mode (初回起動時のレイアウト)
----------------------------------------------------
-- レイアウト:
-- +------------------+--------+
-- |                  |   AI   |
-- |      Main        |  Chat  |
-- |                  |        |
-- +--------+---------+--------+
-- | Term 1 | Term 2  |
-- +--------+---------+

wezterm.on("gui-startup", function(cmd)
  local tab, main_pane, window = mux.spawn_window(cmd or {})

  -- 下部にTerminal領域 (高さ20%)
  local term1_pane = main_pane:split({
    direction = "Bottom",
    size = 0.2,
  })

  -- 上部の右側にAI Chat用pane (幅25%)
  local ai_pane = main_pane:split({
    direction = "Right",
    size = 0.25,
  })

  -- 下部paneを左右に分割 (50%/50%)
  local term2_pane = term1_pane:split({
    direction = "Right",
    size = 0.5,
  })

  -- メインpaneにフォーカス
  main_pane:activate()

  -- ウィンドウを最大化
  window:gui_window():maximize()
end)

config.automatically_reload_config = true
config.font_size = 12.0
config.font = wezterm.font('Hack Nerd Font')
config.use_ime = true
config.window_background_opacity = 0.85
config.macos_window_background_blur = 20

----------------------------------------------------
-- Tab
----------------------------------------------------
-- タイトルバーを非表示
config.window_decorations = "TITLE | RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab = true
-- falseにするとタブバーの透過が効かなくなる
-- config.use_fancy_tab_bar = false

-- タブバーの透過
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

-- タブバーを背景色に合わせる
config.window_background_gradient = {
  colors = { "#0a0a12" },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- タブの閉じるボタンを非表示
-- config.show_close_tab_button_in_tabs = false

-- タブ同士の境界線を非表示
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },
}

-- タブの形をカスタマイズ
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#282c34"
  local foreground = "#999999"
  local edge_background = "none"
  if tab.is_active then
    background = "#862aa1"
    foreground = "#ffffff"
  end
  local edge_foreground = background
  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

----------------------------------------------------
-- Mouse
----------------------------------------------------
local act = wezterm.action
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = "NONE",
    action = act.ScrollByLine(-2),
  },
  {
    event = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods = "NONE",
    action = act.ScrollByLine(2),
  },
}

----------------------------------------------------
-- keybinds
----------------------------------------------------
config.disable_default_key_bindings = true
config.keys = require("keybinds").keys
config.key_tables = require("keybinds").key_tables
config.leader = { key = "s", mods = "CTRL", timeout_milliseconds = 2000 }

return config

