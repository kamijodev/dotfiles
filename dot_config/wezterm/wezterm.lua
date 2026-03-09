local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- Gruvbox Material Dark (medium contrast)
local gb = {
  bg_dim = "#1b1b1b",
  bg0    = "#282828",
  bg1    = "#32302f",
  bg3    = "#45403d",
  bg5    = "#5a524c",
  fg0    = "#d4be98",
  fg1    = "#ddc7a1",
  red    = "#ea6962",
  orange = "#e78a4e",
  yellow = "#d8a657",
  green  = "#a9b665",
  aqua   = "#89b482",
  blue   = "#7daea3",
  purple = "#d3869b",
  grey0  = "#7c6f64",
  grey1  = "#928374",
  grey2  = "#a89984",
  sl3    = "#504945",
}

config.automatically_reload_config = true
config.enable_wayland = true
config.tiling_desktop_environments = { "Wayland" }
config.font_size = 13.0
config.font = wezterm.font('Maple Mono NF CN')
config.use_ime = true
config.macos_window_background_blur = 20
config.color_scheme = 'Gruvbox Material (Gogh)'
config.pane_focus_follows_mouse = false
config.inactive_pane_hsb = { brightness = 1.0 }  -- 非アクティブペインも同じ明るさ
config.window_padding = { left = 32, right = 32, top = 32, bottom = 32 }

----------------------------------------------------
-- Tab
----------------------------------------------------
config.window_decorations = "NONE"
config.show_tabs_in_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
-- falseにするとタブバーの透過が効かなくなる
-- config.use_fancy_tab_bar = false

config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

config.window_background_gradient = {
  colors = { gb.bg_dim },
}

config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- config.show_close_tab_button_in_tabs = false

config.colors = {
  background = gb.bg_dim,
  tab_bar = {
    inactive_tab_edge = "none",
  },
  split = gb.bg1,
}

-- タブの形をカスタマイズ
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = gb.bg1
  local foreground = gb.grey1
  local edge_background = "none"
  if tab.is_active then
    background = gb.green
    foreground = gb.bg0
  end
  local edge_foreground = background
  local tab_title = tab.tab_title
  if not tab_title or #tab_title == 0 then
    tab_title = tab.active_pane.title
  end
  local title = "   " .. wezterm.truncate_right(tab_title, max_width - 1) .. "   "
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
-- CWD export for Noctalia Shell plugin
----------------------------------------------------

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

