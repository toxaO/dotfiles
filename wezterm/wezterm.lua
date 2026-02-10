local wezterm = require("wezterm")
local act = wezterm.action

local is_nightly =
  wezterm.version and
  (wezterm.version:find("nightly", 1, true) or wezterm.version:find("dev", 1, true))

wezterm.on("gui-startup", function()
  local _, _, window = wezterm.mux.spawn_window({})
  window:gui_window():maximize()
end)

return {
  leader = {
    key = "j",
    mods = "CTRL",
    timeout_milliseconds = 1000,
  },
  window_decorations = is_nightly and "RESIZE | MACOS_FORCE_SQUARE_CORNERS" or "RESIZE",
  window_frame = {
    border_left_width = "1",
    border_right_width = "1",
    border_bottom_height = "1",
    border_top_height = "1",
    border_left_color = "#283457",
    border_right_color = "#283457",
    border_bottom_color = "#283457",
    border_top_color = "#283457",
  },
  use_fancy_tab_bar = false,
  tab_max_width = 32,
  tab_and_split_indices_are_zero_based = true,
  hide_tab_bar_if_only_one_tab = true,
  window_content_alignment = {
    horizontal = "Center",
    vertical = "Bottom",
  },
  color_scheme = "iceberg-dark",
  colors = {
    split = "#3b4261",
    pane_border = "#2a3150",
    pane_border_hover = "#3f4b74",
    pane_border_active = "#7aa2f7",
  },
  inactive_pane_hsb = {
    saturation = 0.7,
    brightness = 0.4,
  },
  window_background_opacity = 0.8,
  skip_close_confirmation_for_processes_named = {},
  font = wezterm.font_with_fallback({
    "Hack Nerd Font Mono",
    "Hack Nerd Font",
    "Hiragino Sans",
  }),
  keys = {
    {
      key = "Enter",
      mods = "OPT",
      action = act.DisableDefaultAssignment,
    },
    {
      key = "j",
      mods = "CTRL|LEADER",
      action = act.SendKey({
        key = "j",
        mods = "CTRL",
      }),
    },
    {
      key = "c",
      mods = "LEADER",
      action = act.ShowLauncherArgs({
        flags = "FUZZY|KEY_ASSIGNMENTS",
      }),
    },
    {
      key = "s",
      mods = "LEADER",
      action = act.ShowLauncherArgs({
        flags = "FUZZY|WORKSPACES",
      }),
    },
    {
      key = "S",
      mods = "LEADER|SHIFT",
      action = act.PromptInputLine({
        description = "New workspace name:",
        action = wezterm.action_callback(function(window, pane, line)
          if line and line ~= "" then
            window:perform_action(
              act.SwitchToWorkspace({
                name = line,
              }),
              pane
            )
          end
        end),
      }),
    },
    {
      key = ",",
      mods = "LEADER",
      action = act.PromptInputLine({
        description = "Rename tab:",
        action = wezterm.action_callback(function(window, _, line)
          if line and line ~= "" then
            window:active_tab():set_title(line)
          end
        end),
      }),
    },
    {
      key = "/",
      mods = "LEADER",
      action = act.SplitPane({
        direction = "Down",
        size = {
          Percent = 35,
        },
        command = {
          args = {
            "zsh",
            "-lic",
            "$HOME/dotfiles/wezterm/scripts/keybinds_menu.sh",
          },
        },
      }),
    },
    {
      key = "w",
      mods = "LEADER",
      action = act.ActivateKeyTable({
        name = "w",
        one_shot = true,
      }),
    },
    {
      key = "x",
      mods = "LEADER",
      action = act.CloseCurrentPane({
        confirm = true,
      }),
    },
    {
      key = "y",
      mods = "LEADER",
      action = act.ActivateCopyMode,
    },
    {
      key = "v",
      mods = "LEADER",
      action = act.PasteFrom("Clipboard"),
    },
    {
      key = "h",
      mods = "LEADER",
      action = act.ActivatePaneDirection("Left"),
    },
    {
      key = "j",
      mods = "LEADER",
      action = act.ActivatePaneDirection("Down"),
    },
    {
      key = "k",
      mods = "LEADER",
      action = act.ActivatePaneDirection("Up"),
    },
    {
      key = "l",
      mods = "LEADER",
      action = act.ActivatePaneDirection("Right"),
    },
    {
        key = 'g',
        mods = 'LEADER',
        action = act.PaneSelect
    },
    {
      key = "LeftArrow",
      mods = "SHIFT",
      action = act.ActivatePaneDirection("Left"),
    },
    {
      key = "DownArrow",
      mods = "SHIFT",
      action = act.ActivatePaneDirection("Down"),
    },
    {
      key = "UpArrow",
      mods = "SHIFT",
      action = act.ActivatePaneDirection("Up"),
    },
    {
      key = "RightArrow",
      mods = "SHIFT",
      action = act.ActivatePaneDirection("Right"),
    },
  },
  key_tables = {
    w = {
      {
        key = "s",
        action = act.SplitVertical({
          domain = "CurrentPaneDomain",
        }),
      },
      {
        key = "v",
        action = act.SplitHorizontal({
          domain = "CurrentPaneDomain",
        }),
      },
      {
        key = "w",
        action = act.ShowTabNavigator,
      },
    },
  },
}
