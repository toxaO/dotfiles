local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

local u= require("utils")
local ddu = require("plugins.ddu.ddu_util")

local M = {}
local RG_BASE_ARGS = { "--column", "--no-heading", "--color", "never" }
local rg_excluded_extensions = {}

------------------------------
-- action functions
------------------------------
local function window_choose(args)
  u.io.begin_debug("window_choose")
  u.io.debug_echo("args", args.items)

  u.try_catch({
    try = function()
      local my_winpick = require("customs.winpick")

      for _, item in pairs(args.items) do
        local path = item.action.path

          if u.window.win_count() <= 1 then
            vim.cmd("edit " .. path)
            -- return
          else
            my_winpick.choose_for_open(path)
          end

      end
    end,

    catch = function()
      M.do_action("itemAction", args)
    end,
  })
  u.io.end_debug("window_choose")
  return 0
end

local function resolve_target_directory(item)
  local path = item and item.action and item.action.path or ""
  if path == "" then
    return ""
  end
  local normalized = fn.fnamemodify(path, ":p")
  if fn.isdirectory(normalized) == 1 then
    return normalized
  end
  return fn.fnamemodify(normalized, ":h")
end

local function toggle_hidden(ui_name, source_name)
  local matchers = ddu.get_current(ui_name)["sourceOptions"][source_name]["matchers"]
  or {}
  return ddu.toggle(matchers, 'matcher_hidden')
end

local function get_rg_excluded_extensions()
  return rg_excluded_extensions
end

local function normalize_extension(ext)
  if type(ext) ~= "string" then
    return ""
  end
  local normalized = ext:gsub("^%.*", ""):lower()
  return normalized
end

local function excluded_extensions_text()
  local excludes = get_rg_excluded_extensions()
  if #excludes == 0 then
    return "(none)"
  end
  local sorted = vim.deepcopy(excludes)
  table.sort(sorted)
  return table.concat(sorted, ",")
end

local function toggle_excluded_extension(ext)
  local excludes = get_rg_excluded_extensions()
  for i, existing in ipairs(excludes) do
    if existing == ext then
      table.remove(excludes, i)
      return true
    end
  end
  table.insert(excludes, ext)
  return false
end

local function parse_extension_selection(input, max_index)
  if not input or input == "" then
    return {}
  end

  local selected = {}
  for token in input:gmatch("[^,%s]+") do
    local start_idx, end_idx = token:match("^(%d+)%-(%d+)$")
    if start_idx and end_idx then
      local a = tonumber(start_idx)
      local b = tonumber(end_idx)
      if not a or not b then
        return nil, string.format("invalid range: %s", token)
      end
      if a > b then
        a, b = b, a
      end
      if a < 1 or b > max_index then
        return nil, string.format("out of range: %s", token)
      end
      for i = a, b do
        selected[i] = true
      end
    elseif token:match("^%d+$") then
      local i = tonumber(token)
      if not i or i < 1 or i > max_index then
        return nil, string.format("out of range: %s", token)
      end
      selected[i] = true
    else
      return nil, string.format("invalid token: %s", token)
    end
  end

  local indexes = {}
  for i, _ in pairs(selected) do
    table.insert(indexes, i)
  end
  table.sort(indexes)
  return indexes
end

local function build_filer_cd_cmd(show_files)
  local cmd = {
    "fd",
    ".",
    "--max-depth",
    "1",
    "--hidden",
    "--follow",
    "--exclude",
    ".git",
    "--type",
    "d",
  }
  if show_files then
    table.insert(cmd, "--type")
    table.insert(cmd, "f")
  end
  return cmd
end

local function refresh_rg_items()
  local params = {
    rg = {
      args = M.build_rg_args(),
      globs = M.build_rg_globs(),
    },
  }

  -- Keep local profile in sync so restart/resume and next start share the same excludes.
  ddu.patch_local("grep", {
    sourceParams = params,
  })

  ddu.do_action("updateOptions", {
    sourceParams = params,
  })
  ddu.do_action("redraw", { method = "refreshItems" })
end

function M.build_rg_args()
  return vim.deepcopy(RG_BASE_ARGS)
end

function M.build_rg_globs()
  local globs = {}
  local excludes = get_rg_excluded_extensions()
  table.sort(excludes)
  for _, ext in ipairs(excludes) do
    table.insert(globs, string.format("!*.%s", ext))
  end
  return globs
end

-- 工事中
local function item_data(args)
  u.io.show_contents("item", args)
  -- u.io.show_attribute("attr", args)
  -- print(vim.inspect(args))
  return 0
end


------------------------------
-- register actions
------------------------------

function M.reg_actions()

  ddu.action("ui", "_", "toggleHidden", function(_)
    ddu.do_action("updateOptions", {
      sourceOptions = {
        file = {
          matchers = toggle_hidden(vim.b.ddu_ui_name, "file")
        }
      }
    })
    ddu.do_action("redraw", { method = "refreshItems" })
  end)

  ddu.action("ui", "_", "toggleRgExcludeExtension", function(_)
    local item = fn["ddu#ui#get_item"]()
    local path = item
      and item.action
      and item.action.path
      or ""
    local ext = normalize_extension(fn.fnamemodify(path, ":e"))

    if ext == "" then
      print("ddu rg ignore: extension not found")
      return 0
    end

    local removed = toggle_excluded_extension(ext)
    if removed then
      print(string.format("ddu rg ignore: include *.%s", ext))
    else
      print(string.format("ddu rg ignore: exclude *.%s", ext))
    end
    print("ddu rg ignore extensions: " .. excluded_extensions_text())
    refresh_rg_items()
    return 0
  end)

  ddu.action("ui", "_", "selectRgExcludeExtensionFromVisibleItems", function(_)
    local items = fn["ddu#ui#get_items"]() or {}
    local ext_map = {}

    for _, item in ipairs(items) do
      local path = item and item.action and item.action.path or ""
      local ext = normalize_extension(fn.fnamemodify(path, ":e"))
      if ext ~= "" then
        ext_map[ext] = true
      end
    end

    local exts = {}
    for ext, _ in pairs(ext_map) do
      table.insert(exts, ext)
    end
    table.sort(exts)

    if #exts == 0 then
      print("ddu rg ignore: no extension found in visible items")
      return 0
    end

    local exclude_set = {}
    for _, ext in ipairs(get_rg_excluded_extensions()) do
      exclude_set[ext] = true
    end

    local lines = { "Toggle rg ignore extension (comma/range):" }
    for i, ext in ipairs(exts) do
      local mark = exclude_set[ext] and "[x]" or "[ ]"
      table.insert(lines, string.format("%2d. %s *.%s", i, mark, ext))
    end
    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "ddu rg extensions" })

    vim.ui.input({
      prompt = "indexes (e.g. 1,3,5 or 2-6): ",
    }, function(input)
      if not input or input == "" then
        return
      end

      local indexes, err = parse_extension_selection(input, #exts)
      if not indexes then
        print("ddu rg ignore: " .. err)
        return
      end
      if #indexes == 0 then
        return
      end

      for _, i in ipairs(indexes) do
        toggle_excluded_extension(exts[i])
      end

      print("ddu rg ignore: toggled " .. #indexes .. " extension(s)")
      print("ddu rg ignore extensions: " .. excluded_extensions_text())
      refresh_rg_items()
    end)
    return 0
  end)

  ddu.action("ui", "_", "clearRgExcludeExtensions", function(_)
    rg_excluded_extensions = {}
    print("ddu rg ignore: cleared temporary extension filters")
    print("ddu rg ignore extensions: " .. excluded_extensions_text())
    refresh_rg_items()
    return 0
  end)

  ddu.action("ui", "_", "toggleFilerCdShowFiles", function(_)
    if vim.b.ddu_ui_name ~= "filer_cd" then
      return 0
    end
    vim.b.ddu_filer_cd_show_files = not (vim.b.ddu_filer_cd_show_files == true)
    local show_files = vim.b.ddu_filer_cd_show_files == true
    ddu.do_action("updateOptions", {
      sourceParams = {
        file_external = {
          cmd = build_filer_cd_cmd(show_files),
        },
      },
    })
    ddu.do_action("redraw", { method = "refreshItems" })
    print("filer_cd: " .. (show_files and "directories + files" or "directories only"))
    return 0
  end)

  ddu.action("ui", "_", "current", function(_)
    print(vim.inspect(ddu.get_current()))
  end)

  ddu.action("kind", "_", "current", function(_)
    print(vim.inspect(ddu.get_current()))
  end)

  ddu.action("kind", "file", "argadd", function(args)
    local arglist = {}
    for _, item in ipairs(args.items) do
      local path = item.action.path
      if item.action.isDirectory then
        path = path .. "/**"
      end
      table.insert(arglist, path)
    end
    vim.cmd.args(arglist)
    return 4
  end)

  ddu.action("kind", "file", "window_choose", function(args)
    return window_choose(args)
  end)

  ddu.action("kind", "file", "tab_cd", function(args)
    local item = args.items and args.items[1] or nil
    local dir = resolve_target_directory(item)
    if dir == "" then
      print("ddu tab_cd: directory not found")
      return 0
    end
    vim.cmd("tcd " .. fn.fnameescape(dir))
    if vim.b.ddu_ui_name == "filer_cd" then
      vim.t.ddu_ui_filer_cd_path = dir
    else
      vim.t.ddu_ui_filer_main_path = dir
    end
    print('tab cwd -> "' .. dir .. '"')
    return 0
  end)

  ddu.action("ui", "_", "confirm_item", function(args)
    return item_data(args)
  end)

  ddu.action("kind", "file", "confirm_item", function(args)
    return item_data(args)
  end)

  ddu.action("kind", "action", "confirm_item", function(args)
    return item_data(args)
  end)

end

return M
