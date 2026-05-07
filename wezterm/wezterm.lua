local wezterm = require("wezterm")
local act = wezterm.action
local copy_mode = wezterm.gui.default_key_tables().copy_mode

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

local function replace_key_binding(bindings, new_binding)
  for i, binding in ipairs(bindings) do
    if binding.key == new_binding.key and binding.mods == new_binding.mods then
      bindings[i] = new_binding
      return
    end
  end
  table.insert(bindings, new_binding)
end

-- WSL Ubuntuをデフォルトドメインとして設定し、WSLセッションのCWDをLinuxのホームへ
if wezterm.target_triple and wezterm.target_triple:find("windows", 1, true) then
  config.default_domain = "WSL:Ubuntu"
  config.wsl_domains = {
    {
      name = "WSL:Ubuntu",
      distribution = "Ubuntu",
      default_cwd = "~",
    },
  }
end

replace_key_binding(copy_mode, {
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

local tmux_neighbor_cache = {
  current = "",
  prev = "",
  next = "",
  updated_at = 0,
}

local function tmux_neighbor_sessions(current)
  if current == "" then
    return "", ""
  end

  local now = os.time()
  if tmux_neighbor_cache.current == current and now - tmux_neighbor_cache.updated_at < 5 then
    return tmux_neighbor_cache.prev, tmux_neighbor_cache.next
  end

  local ok, success, stdout = pcall(wezterm.run_child_process, {
    "zsh",
    "-lc",
    "tmux list-sessions -F '#{session_name}' 2>/dev/null",
  })
  if not ok or not success or not stdout or stdout == "" then
    tmux_neighbor_cache.current = current
    tmux_neighbor_cache.prev = ""
    tmux_neighbor_cache.next = ""
    tmux_neighbor_cache.updated_at = now
    return "", ""
  end

  local sessions = {}
  for session in stdout:gmatch("[^\r\n]+") do
    table.insert(sessions, session)
  end
  if #sessions < 2 then
    tmux_neighbor_cache.current = current
    tmux_neighbor_cache.prev = ""
    tmux_neighbor_cache.next = ""
    tmux_neighbor_cache.updated_at = now
    return "", ""
  end

  for i, session in ipairs(sessions) do
    if session == current then
      local prev = sessions[((i - 2) % #sessions) + 1]
      local next = sessions[(i % #sessions) + 1]
      tmux_neighbor_cache.current = current
      tmux_neighbor_cache.prev = prev
      tmux_neighbor_cache.next = next
      tmux_neighbor_cache.updated_at = now
      return prev, next
    end
  end

  tmux_neighbor_cache.current = current
  tmux_neighbor_cache.prev = ""
  tmux_neighbor_cache.next = ""
  tmux_neighbor_cache.updated_at = now
  return "", ""
end

local function truncate_label(text, max_len)
  if #text <= max_len then
    return text
  end
  return text:sub(1, max_len - 1) .. "…"
end

local function active_pane_cwd(pane)
  if not pane then
    return "", ""
  end

  local ok, uri = pcall(function()
    return pane:get_current_working_dir()
  end)
  if not ok or not uri then
    return "", ""
  end

  local value = tostring(uri)
  local host, path = value:match("^file://([^/]*)(/.*)$")
  if not path then
    return "", ""
  end

  path = path:gsub("%%20", " ")
  return host or "", path
end

wezterm.on("gui-startup", function()
  local _, _, window = wezterm.mux.spawn_window({
    cwd = wezterm.home_dir,
  })
  window:gui_window():maximize()
end)

wezterm.on("update-right-status", function(window, _)
  local pane = window:active_pane()
  local vars = pane and pane:get_user_vars() or {}
  local tmux_session = vars.WEZTERM_TMUX_SESSION or ""
  local tmux_session_prev = vars.WEZTERM_TMUX_SESSION_PREV or ""
  local tmux_session_next = vars.WEZTERM_TMUX_SESSION_NEXT or ""
  local cwd = vars.WEZTERM_CWD_SHORT or ""
  local host = vars.WEZTERM_HOST or ""
  local in_tmux = vars.WEZTERM_IN_TMUX == "1"
  local separator = utf8.char(0xe0b0)
  local separator_left = utf8.char(0xe0b2)

  if not in_tmux and cwd == "" then
    local fallback_host, fallback_cwd = active_pane_cwd(pane)
    cwd = fallback_cwd
    if host == "" then
      host = fallback_host
    end
  end

  if in_tmux and cwd == "" and pane then
    local ok, title = pcall(function()
      return pane:get_title()
    end)
    if ok and title then
      tmux_session = tmux_session ~= "" and tmux_session or (title:match("^(%S+)%s+") or "")
      cwd = title:match("^%S+%s+(.+)$") or ""
    end
  end

  if not in_tmux then
    tmux_session = ""
    tmux_session_prev = ""
    tmux_session_next = ""
  end

  if cwd:find(wezterm.home_dir, 1, true) == 1 then
    cwd = "~" .. cwd:sub(#wezterm.home_dir + 1)
  end

  if #cwd > 48 then
    cwd = "..." .. cwd:sub(#cwd - 44)
  end

  if in_tmux then
    local tmux_prev_from_cli, tmux_next_from_cli = tmux_neighbor_sessions(tmux_session)
    if tmux_prev_from_cli ~= "" then
      tmux_session_prev = tmux_prev_from_cli
    end
    if tmux_next_from_cli ~= "" then
      tmux_session_next = tmux_next_from_cli
    end
  end

  local leader_active = window:leader_is_active()
  local left_cells = {}
  local right_cells = {}
  local previous_bg = nil

  local function push_segment(cells, text, bg, fg)
    if previous_bg then
      table.insert(cells, { Background = { Color = bg } })
      table.insert(cells, { Foreground = { Color = previous_bg } })
      table.insert(cells, { Text = separator })
    end
    table.insert(cells, { Background = { Color = bg } })
    table.insert(cells, { Foreground = { Color = fg } })
    table.insert(cells, { Text = " " .. text .. " " })
    previous_bg = bg
  end

  local function push_right_segment(cells, text, bg, fg)
    if not previous_bg then
      table.insert(cells, { Background = { Color = "#161821" } })
      table.insert(cells, { Foreground = { Color = bg } })
      table.insert(cells, { Text = separator_left })
    elseif previous_bg == "#161821" then
      table.insert(cells, { Background = { Color = "#161821" } })
      table.insert(cells, { Foreground = { Color = bg } })
      table.insert(cells, { Text = separator_left })
    else
      table.insert(cells, { Background = { Color = bg } })
      table.insert(cells, { Foreground = { Color = previous_bg } })
      table.insert(cells, { Text = separator })
    end
    table.insert(cells, { Background = { Color = bg } })
    table.insert(cells, { Foreground = { Color = fg } })
    table.insert(cells, { Text = " " .. text .. " " })
    previous_bg = bg
  end

  local function close_segments(cells)
    if previous_bg then
      table.insert(cells, { Background = { Color = "#161821" } })
      table.insert(cells, { Foreground = { Color = previous_bg } })
      table.insert(cells, { Text = separator })
    end
    previous_bg = nil
  end

  local function push_right_current_session(cells, text)
    local current_bg = "#84a0c6"
    if previous_bg then
      table.insert(cells, { Background = { Color = previous_bg } })
      table.insert(cells, { Foreground = { Color = current_bg } })
      table.insert(cells, { Text = separator_left })
    else
      table.insert(cells, { Background = { Color = "#161821" } })
      table.insert(cells, { Foreground = { Color = current_bg } })
      table.insert(cells, { Text = separator_left })
    end
    table.insert(cells, { Background = { Color = current_bg } })
    table.insert(cells, { Foreground = { Color = "#161821" } })
    table.insert(cells, { Text = " " .. text .. " " })
    previous_bg = current_bg
  end

  local function split_path(path)
    path = path:gsub("/+$", "")
    if path == "" then
      return nil, nil, nil
    end

    local root = ""
    local rest = path
    if path == "~" then
      return nil, nil, "~/"
    elseif path:sub(1, 2) == "~/" then
      root = "~"
      rest = path:sub(3)
    elseif path:sub(1, 1) == "/" then
      root = "/"
      rest = path:sub(2)
    end

    local parts = {}
    for part in rest:gmatch("[^/]+") do
      table.insert(parts, part)
    end

    if #parts == 0 then
      return nil, nil, root == "/" and "/" or root .. "/"
    elseif #parts == 1 then
      return nil, root ~= "" and root or nil, parts[1] .. "/"
    end

    local current_dir = parts[#parts] .. "/"
    local parent = parts[#parts - 1]
    local ancestors = root
    for i = 1, #parts - 2 do
      if ancestors == "" or ancestors == "/" then
        ancestors = ancestors .. parts[i]
      else
        ancestors = ancestors .. "/" .. parts[i]
      end
    end

    if ancestors == "" then
      ancestors = nil
    end

    return ancestors, parent, current_dir
  end

  if not in_tmux and host ~= "" then
    push_segment(left_cells, host, "#454b68", "#c6c8d1")
  end

  local ancestors, parent, current_dir = split_path(cwd)
  if ancestors then
    push_segment(left_cells, ancestors, "#2e3244", "#c6c8d1")
  end
  if parent then
    push_segment(left_cells, parent, "#3e445e", "#c6c8d1")
  end
  if current_dir then
    push_segment(left_cells, current_dir, "#84a0c6", "#161821")
  end
  close_segments(left_cells)

  previous_bg = nil
  if leader_active then
    push_right_segment(right_cells, "LEADER", "#e2a478", "#161821")
  end

  if tmux_session_prev ~= "" then
    push_right_segment(right_cells, truncate_label(tmux_session_prev, 20), "#3e445e", "#c6c8d1")
  end

  if tmux_session ~= "" then
    push_right_current_session(right_cells, truncate_label(tmux_session, 20))
  end

  if tmux_session_next ~= "" then
    push_segment(right_cells, truncate_label(tmux_session_next, 20), "#2e3244", "#c6c8d1")
  end
  close_segments(right_cells)

  window:set_left_status(wezterm.format(left_cells))
  window:set_right_status(wezterm.format(right_cells))
end)

local function switch_workspace_sorted(window, pane, delta)
  local names = wezterm.mux.get_workspace_names()
  if #names == 0 then
    return
  end
  table.sort(names)
  local current = wezterm.mux.get_active_workspace()
  local idx = 1
  for i, name in ipairs(names) do
    if name == current then
      idx = i
      break
    end
  end
  local next_idx = ((idx - 1 + delta) % #names) + 1
  window:perform_action(
    act.SwitchToWorkspace({
      name = names[next_idx],
    }),
    pane
  )
end

local function load_keybind_choices()
  local choices = {}
  local notes_file = wezterm.home_dir .. "/dotfiles/wezterm/keybinds.tsv"
  local file = io.open(notes_file, "r")

  if not file then
    return choices
  end

  for line in file:lines() do
    if line ~= "" and not line:match("^#") then
      local shortcut, category, description = line:match("^([^\t]+)\t([^\t]+)\t([^\t]+)\t")
      if shortcut and category and description then
        table.insert(choices, {
          id = shortcut .. ":" .. description,
          label = string.format("%-22s %-10s %s", shortcut, category, description),
        })
      end
    end
  end

  file:close()
  return choices
end

local function show_keybinds_selector(window, pane)
  window:perform_action(
    act.InputSelector({
      title = "WezTerm keybinds",
      choices = load_keybind_choices(),
      fuzzy = true,
      action = wezterm.action_callback(function() end),
    }),
    pane
  )
end

wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
  return {
    { Background = { Color = "#161821" } },
    { Text = " " },
  }
end)

local base_config = {
  default_cwd = wezterm.home_dir,
  leader = {
    key = "b",
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
  tab_bar_at_bottom = false,
  tab_max_width = 32,
  status_update_interval = 1000,
  tab_and_split_indices_are_zero_based = true,
  hide_tab_bar_if_only_one_tab = false,
  color_scheme = "iceberg-dark",
  colors = {
    split = "#3b4261",
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
      action = act.SpawnTab("CurrentPaneDomain"),
    },
    {
      key = "C",
      mods = "LEADER|SHIFT",
      action = act.ActivateCommandPalette,
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
                            spawn = {
                              cwd = wezterm.home_dir,
                            },
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
                spawn = {
                  cwd = wezterm.home_dir,
                },
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
      action = wezterm.action_callback(function(window, pane)
        show_keybinds_selector(window, pane)
      end),
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
      key = "n",
      mods = "LEADER",
      action = act.Multiple({
        act.ActivateTabRelative(1),
        act.ActivateKeyTable({
          name = "tab_nav",
          one_shot = false,
          timeout_milliseconds = 1200,
        }),
      }),
    },
    {
      key = "p",
      mods = "LEADER",
      action = act.Multiple({
        act.ActivateTabRelative(-1),
        act.ActivateKeyTable({
          name = "tab_nav",
          one_shot = false,
          timeout_milliseconds = 1200,
        }),
      }),
    },
    {
      key = "N",
      mods = "LEADER|SHIFT",
      action = act.Multiple({
        wezterm.action_callback(function(window, pane)
          switch_workspace_sorted(window, pane, 1)
        end),
        act.ActivateKeyTable({
          name = "ws_nav",
          one_shot = false,
          timeout_milliseconds = 1200,
        }),
      }),
    },
    {
      key = "P",
      mods = "LEADER|SHIFT",
      action = act.Multiple({
        wezterm.action_callback(function(window, pane)
          switch_workspace_sorted(window, pane, -1)
        end),
        act.ActivateKeyTable({
          name = "ws_nav",
          one_shot = false,
          timeout_milliseconds = 1200,
        }),
      }),
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
    tab_nav = {
      {
        key = "n",
        action = act.ActivateTabRelative(1),
      },
      {
        key = "p",
        action = act.ActivateTabRelative(-1),
      },
      {
        key = "Escape",
        action = act.PopKeyTable,
      },
    },
    ws_nav = {
      {
        key = "n",
        action = wezterm.action_callback(function(window, pane)
          switch_workspace_sorted(window, pane, 1)
        end),
      },
      {
        key = "p",
        action = wezterm.action_callback(function(window, pane)
          switch_workspace_sorted(window, pane, -1)
        end),
      },
      {
        key = "Escape",
        action = act.PopKeyTable,
      },
    },
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

for key, value in pairs(base_config) do
  config[key] = value
end

return config
