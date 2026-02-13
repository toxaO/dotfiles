local wezterm = require("wezterm")
local act = wezterm.action
local copy_mode = wezterm.gui.default_key_tables().copy_mode

table.insert(copy_mode, {
  key = "Enter",
  mods = "NONE",
  action = act.Multiple({
    act.CopyTo("ClipboardAndPrimarySelection"),
    act.Multiple({
      act.ScrollToBottom,
      act.CopyMode("Close"),
    }),
  }),
})

local is_nightly =
  wezterm.version and
  (wezterm.version:find("nightly", 1, true) or wezterm.version:find("dev", 1, true))
local TAB_LEFT = wezterm.nerdfonts.ple_lower_right_triangle
local TAB_RIGHT = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("gui-startup", function()
  local _, _, window = wezterm.mux.spawn_window({})
  window:gui_window():maximize()
end)

wezterm.on("update-right-status", function(window, _)
  window:set_left_status("")
  local names = wezterm.mux.get_workspace_names()
  table.sort(names)
  local current = wezterm.mux.get_active_workspace()

  local cells = {}
  table.insert(cells, { Foreground = { Color = "#6b7089" } })
  table.insert(cells, { Text = " ws " })
  for _, name in ipairs(names) do
    local is_active = name == current
    table.insert(cells, { Text = " " })
    table.insert(cells, {
      Background = { Color = is_active and "#84a0c6" or "#2e3244" },
    })
    table.insert(cells, {
      Foreground = { Color = is_active and "#161821" or "#c6c8d1" },
    })
    table.insert(cells, { Text = " " .. name .. " " })
  end
  table.insert(cells, { Text = " " })
  window:set_right_status(wezterm.format(cells))
end)

wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
  local background = "#3e445e"
  local foreground = "#c6c8d1"
  local edge_background = "#161821"

  if tab.is_active then
    background = "#84a0c6"
    foreground = "#161821"
  end

  local edge_foreground = background
  local raw_title = tab.tab_title and #tab.tab_title > 0 and tab.tab_title or tab.active_pane.title
  local title = "   " .. wezterm.truncate_right(raw_title, max_width - 1) .. "   "

  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = TAB_LEFT },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = TAB_RIGHT },
  }
end)

return {
  leader = {
    key = "j",
    mods = "CTRL",
    timeout_milliseconds = 1000,
  },
  window_decorations = is_nightly and "RESIZE | MACOS_FORCE_SQUARE_CORNERS" or "RESIZE",
  window_frame = {
    inactive_titlebar_bg = "none",
    active_titlebar_bg = "none",
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
  show_tabs_in_tab_bar = true,
  show_new_tab_button_in_tab_bar = false,
  show_close_tab_button_in_tabs = false,
  tab_bar_at_bottom = false,
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
    tab_bar = {
      background = "#161821",
      inactive_tab_edge = "#161821",
    },
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
      action = wezterm.action_callback(function(window, pane)
        local workspaces = {}
        table.insert(workspaces, {
          id = "__create_new_workspace__",
          label = "+ Create new workspace (named)",
        })
        local current = wezterm.mux.get_active_workspace()
        for i, name in ipairs(wezterm.mux.get_workspace_names()) do
          local marker = name == current and "* " or "  "
          table.insert(workspaces, {
            id = name,
            label = string.format("%s%d. %s", marker, i, name),
          })
        end
        window:perform_action(
          act.InputSelector({
            title = "Select workspace",
            choices = workspaces,
            fuzzy = true,
            action = wezterm.action_callback(function(win, p, id, _)
              if id == "__create_new_workspace__" then
                win:perform_action(
                  act.PromptInputLine({
                    description = "New workspace name:",
                    action = wezterm.action_callback(function(w, pp, line)
                      if line and line ~= "" then
                        w:perform_action(
                          act.SwitchToWorkspace({
                            name = line,
                          }),
                          pp
                        )
                      end
                    end),
                  }),
                  p
                )
              elseif id then
                win:perform_action(
                  act.SwitchToWorkspace({
                    name = id,
                  }),
                  p
                )
              end
            end),
          }),
          pane
        )
      end),
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
      action = wezterm.action_callback(function(window, pane)
        local current = window:active_tab():get_title()
        window:perform_action(
          act.PromptInputLine({
            description = string.format("Rename tab (%s) to:", current),
            action = wezterm.action_callback(function(win, _, line)
              if line and line ~= "" then
                win:active_tab():set_title(line)
              end
            end),
          }),
          pane
        )
      end),
    },
    {
      key = ".",
      mods = "LEADER",
      action = wezterm.action_callback(function(window, pane)
        local current = wezterm.mux.get_active_workspace()
        window:perform_action(
          act.PromptInputLine({
            description = string.format("Rename workspace (%s) to:", current),
            action = wezterm.action_callback(function(_, _, line)
              if line and line ~= "" then
                wezterm.mux.rename_workspace(current, line)
              end
            end),
          }),
          pane
        )
      end),
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
      key = "{",
      mods = "LEADER",
      action = act.MoveTabRelative(-1),
    },
    {
      key = "}",
      mods = "LEADER",
      action = act.MoveTabRelative(1),
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
      mods = "LEADER",
      action = act.SwitchWorkspaceRelative(-1),
    },
    {
      key = "RightArrow",
      mods = "LEADER",
      action = act.SwitchWorkspaceRelative(1),
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
    copy_mode = copy_mode,
    w = {
      {
        key = "h",
        action = act.SplitPane({
          direction = "Left",
          size = {
            Percent = 50,
          },
        }),
      },
      {
        key = "j",
        action = act.SplitPane({
          direction = "Down",
          size = {
            Percent = 50,
          },
        }),
      },
      {
        key = "k",
        action = act.SplitPane({
          direction = "Up",
          size = {
            Percent = 50,
          },
        }),
      },
      {
        key = "l",
        action = act.SplitPane({
          direction = "Right",
          size = {
            Percent = 50,
          },
        }),
      },
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
