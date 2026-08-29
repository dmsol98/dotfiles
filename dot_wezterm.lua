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
}
-- =============================== TOGGLE OPACITY ==============================

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

-- Bind keymap to toggle opacity
table.insert(config.keys, {
  key = "o",
  mods = "CTRL|SHIFT",
  action = act.EmitEvent("toggle-opacity"),
})

-- =============================== THEME PICKER ================================

-- Build a fuzzy-searchable list of built-in scheme names once at config load
local scheme_names = {}
for name, _ in pairs(wezterm.color.get_builtin_schemes()) do
  table.insert(scheme_names, name)
end
table.sort(scheme_names) -- alphabetical order for the unfiltered list

local scheme_choices = {}
for _, name in ipairs(scheme_names) do
  table.insert(scheme_choices, { label = name, id = name })
end

-- Bind keymap
table.insert(config.keys, {
  key = "t",
  mods = "CTRL|SHIFT",
  action = act.InputSelector({
    title = "Select color scheme",
    choices = scheme_choices,
    fuzzy = true,
    action = wezterm.action_callback(function(window, _pane, id, _label)
      if not id then
        return -- user cancelled (Esc)
      end
      local overrides = window:get_config_overrides() or {}
      overrides.color_scheme = id
      window:set_config_overrides(overrides)
    end),
  }),
})

-- ==================================== END ====================================

return config
