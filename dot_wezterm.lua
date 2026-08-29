-- =================================== START ===================================

-- Using wezterm API
local wezterm = require("wezterm")
local act = wezterm.action

-- Initialize config list
local config = {}

-- ================================ APPEARANCE =================================

-- Font options
config.font_size = 10
config.font = wezterm.font_with_fallback({
  "JetBrains Mono",
})

-- Color scheme
config.color_scheme = "catppuccin-mocha"

-- Window opacity
config.window_background_opacity = 1

-- Tab bar
config.hide_tab_bar_if_only_one_tab = true

-- Font increase/decrease does not impact window size
config.adjust_window_size_when_changing_font_size = false

-- ================================= BEHAVIOR ==================================

-- Launch PowerShell by default
config.default_prog = {
  "powershell.exe",
  "-NoLogo",
}

-- Event: toggle opacity
wezterm.on("toggle-opacity", function(window, pane)
  local overrides = window:get_config_overrides() or {}
  if not overrides.window_background_opacity then
    overrides.window_background_opacity = 0.85
  else
    overrides.window_background_opacity = nil
  end
  print(overrides.window_background_opacity)
  window:set_config_overrides(overrides)
end)

-- Custom keymaps
config.keys = {

  -- Spawn tab for Git Bash
  {
    key = "b",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab({
      args = {
        "C:\\Program Files\\Git\\bin\\bash.exe",
        "-l",
      },
    }),
  },

  -- Spawn tab for WSL
  {
    key = "w",
    mods = "CTRL|SHIFT",
    action = act.SpawnCommandInNewTab({
      args = {
        "wsl",
        "~",
      },
    }),
  },

  -- Toggle opacity
  {
    key = "O",
    mods = "CTRL|SHIFT",
    action = wezterm.action.EmitEvent("toggle-opacity"),
  },
}

-- ==================================== END ====================================

return config
