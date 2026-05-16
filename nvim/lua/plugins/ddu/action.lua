local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

local u= require("utils")
local ddu = require("plugins.ddu.ddu_util")

local M = {}
local FILE_EXTERNAL_CMD = {
  "fd",
  ".",
  "--type",
  "f",
  "--hidden",
  "--follow",
  "--exclude",
  ".git",
  "--exclude",
  "node_modules",
  "--exclude",
  "vendor",
  "--exclude",
  ".next",
  "--exclude",
  ".venv",
  "--exclude",
  "__pycache__",
  "--exclude",
  ".mypy_cache",
  "--exclude",
  "out",
}
local DIRECTORY_EXTERNAL_CMD = {
  "fd",
  ".",
  "--type",
  "d",
  "--hidden",
  "--follow",
  "--exclude",
  ".git",
  "--exclude",
  "node_modules",
  "--exclude",
  "vendor",
  "--exclude",
  ".next",
  "--exclude",
  ".venv",
  "--exclude",
  "__pycache__",
  "--exclude",
  ".mypy_cache",
  "--exclude",
  "out",
}
local RG_BASE_ARGS = { "--json" }
local RECENT_DIRECTORY_LIMIT = 50
local rg_globs = {}
local rg_excluded_extensions = {}
local recent_directories = {}

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

local function add_recent_directory(path)
  local dir = fn.fnamemodify(path, ":p")
  if fn.isdirectory(dir) ~= 1 then
    dir = fn.fnamemodify(dir, ":h")
  end
  if dir == "" then
    return
  end

  for i = #recent_directories, 1, -1 do
    if recent_directories[i] == dir then
      table.remove(recent_directories, i)
    end
  end
  table.insert(recent_directories, 1, dir)

  while #recent_directories > RECENT_DIRECTORY_LIMIT do
    table.remove(recent_directories)
  end
end

local function start_filer(path)
  local dir = fn.fnamemodify(path, ":p")
  if fn.isdirectory(dir) ~= 1 then
    dir = fn.fnamemodify(dir, ":h")
  end
  if dir == "" then
    return false
  end
  add_recent_directory(dir)
  vim.t.ddu_ui_filer_main_path = dir
  fn["ddu#start"]({
    name = "filer",
    sourceOptions = {
      file = {
        path = dir,
      },
    },
  })
  pcall(fn["ddu#ui#do_action"], "cursorNext")
  return true
end

local function set_reference_dir(slot, dir)
  vim.g.ddu_reference_dirs = vim.g.ddu_reference_dirs or {}
  vim.g.ddu_reference_dirs[slot] = dir
  print(string.format("reference %d -> %s", slot, dir))
end

local function item_to_qf(item)
  local action = item and item.action or {}
  local path = action.path or action.filename
  if path == nil or path == "" then
    return nil
  end
  return {
    filename = path,
    lnum = action.lineNr or action.lnum or 1,
    col = action.columnNr or action.col or 1,
    text = item.display or item.word or path,
  }
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

local function extension_from_path(path)
  if type(path) ~= "string" or path == "" then
    return ""
  end
  local basename = path:match("([^/\\]+)$") or path
  local ext = basename:match("%.([^.]+)$")
  return normalize_extension(ext or "")
end

local function collect_extensions_from_visible_items()
  local items = vim.b.ddu_ui_items
  if type(items) ~= "table" then
    items = fn["ddu#ui#get_items"]() or {}
  end
  local ext_map = {}

  for _, item in ipairs(items) do
    local path = item and item.action and item.action.path or ""
    if path ~= "" then
      local ext = extension_from_path(path)
      if ext ~= "" then
        ext_map[ext] = true
      end
    end
  end

  local exts = {}
  for ext, _ in pairs(ext_map) do
    table.insert(exts, ext)
  end
  table.sort(exts)
  return exts
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

local function show_extension_list_message(exts)
  local excludes = {}
  for _, ext in ipairs(get_rg_excluded_extensions()) do
    excludes[ext] = true
  end

  local lines = { "Toggle rg ignore extension (comma/range):" }
  for i, ext in ipairs(exts) do
    local mark = excludes[ext] and "[x]" or "[ ]"
    table.insert(lines, string.format("%2d. %s *.%s", i, mark, ext))
  end
  vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "ddu rg extensions" })
end

local function current_uses_rg(current)
  local sources = current and current.sources or {}
  for _, source in ipairs(sources) do
    if source.name == "rg" then
      return true
    end
  end
  return false
end

local function refresh_rg_items()
  local current = ddu.get_current(vim.b.ddu_ui_name)
  if not current_uses_rg(current) then
    return
  end
  local current_rg_params = current and current.sourceParams and current.sourceParams.rg or {}
  local params = {
    rg = M.build_rg_params(current_rg_params.paths),
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

local function parse_globs(input)
  local globs = {}
  if type(input) ~= "string" or input == "" then
    return globs
  end
  for glob in input:gmatch("%S+") do
    table.insert(globs, glob)
  end
  return globs
end

local function unique_directories(items)
  local seen = {}
  local dirs = {}

  for _, item in ipairs(items or {}) do
    if item and item.kind == "file" then
      local dir = resolve_target_directory(item)
      if dir ~= "" and not seen[dir] then
        seen[dir] = true
        add_recent_directory(dir)
        table.insert(dirs, dir)
      end
    end
  end

  table.sort(dirs)
  return dirs
end

local function unique_file_paths(items)
  local seen = {}
  local paths = {}

  for _, item in ipairs(items or {}) do
    if item and item.kind == "file" then
      local path = item.action and item.action.path or ""
      if path ~= "" then
        path = fn.fnamemodify(path, ":p")
        if not seen[path] then
          seen[path] = true
          table.insert(paths, path)
        end
      end
    end
  end

  return paths
end

local function get_selected_file_items()
  local items = fn["ddu#ui#get_selected_items"]() or {}
  local file_items = {}
  for _, item in ipairs(items) do
    if item.kind == "file" then
      table.insert(file_items, item)
    end
  end
  return file_items
end

local function start_grep(paths)
  if #paths == 0 then
    print("ddu grep: directory not found")
    return false
  end

  local options = {
    name = "grep",
    sources = { { name = "rg" } },
    sourceOptions = {
      rg = {
        converters = {},
        matchers = {},
        sorters = {},
        volatile = true,
      },
    },
    sourceParams = {
      rg = M.build_rg_params(paths),
    },
  }

  vim.g.ddu_ff_last_start_options = vim.deepcopy(options)
  fn["ddu#start"](options)
  return true
end

local function start_ff_from_paths(paths)
  if #paths == 0 then
    print("ddu ff: file items not found")
    return false
  end
  for _, path in ipairs(paths) do
    add_recent_directory(path)
  end

  local options = {
    sources = { { name = "file_external" } },
    sourceParams = {
      file_external = M.build_file_external_selected_params(paths),
    },
  }

  vim.g.ddu_ff_last_start_options = vim.deepcopy(options)
  fn["ddu#start"](options)
  return true
end

function M.build_rg_args()
  return vim.deepcopy(RG_BASE_ARGS)
end

function M.build_rg_globs()
  local globs = vim.deepcopy(rg_globs)
  local excludes = get_rg_excluded_extensions()
  table.sort(excludes)
  for _, ext in ipairs(excludes) do
    table.insert(globs, string.format("!*.%s", ext))
  end
  return globs
end

function M.build_rg_params(paths)
  local params = {
    args = M.build_rg_args(),
    globs = M.build_rg_globs(),
  }
  if paths ~= nil then
    params.paths = paths
  end
  return params
end

function M.build_file_external_params()
  return {
    cmd = vim.deepcopy(FILE_EXTERNAL_CMD),
  }
end

function M.build_directory_external_params()
  return {
    cmd = vim.deepcopy(DIRECTORY_EXTERNAL_CMD),
  }
end

function M.build_recent_directory_params()
  local cmd = { "sh", "-c", "for path do printf '%s\\n' \"$path\"; done", "ddu-recent-dirs" }
  for _, dir in ipairs(recent_directories) do
    table.insert(cmd, dir)
  end
  return { cmd = cmd }
end

function M.build_file_external_selected_params(paths)
  local script = [[
{
  for path do
    if [ -d "$path" ]; then
      fd . "$path" --type f --hidden --follow \
        --exclude .git \
        --exclude node_modules \
        --exclude vendor \
        --exclude .next \
        --exclude .venv \
        --exclude __pycache__ \
        --exclude .mypy_cache \
        --exclude out
    elif [ -e "$path" ]; then
      printf '%s\n' "$path"
    fi
  done
} | sort -u
]]
  local cmd = { "sh", "-c", script, "ddu-open-ff" }
  for _, path in ipairs(paths) do
    table.insert(cmd, path)
  end
  return { cmd = cmd }
end

function M.project_root()
  local root = vim.b.project_root
  if root == nil or root == "" then
    root = u.fs.get_project_root_current_buf()
  end
  if root == nil or root == "" then
    root = fn["getcwd"](-1, 0)
  end
  return root
end

function M.start_filer(path)
  return start_filer(path)
end

function M.start_reference_filer(slot)
  local dirs = vim.g.ddu_reference_dirs or {}
  local dir = dirs[slot]
  if dir == nil or dir == "" then
    print(string.format("reference %d is empty", slot))
    return false
  end
  return start_filer(dir)
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
    local ext = extension_from_path(path)

    if ext == "" then
      return 0
    end

    toggle_excluded_extension(ext)
    refresh_rg_items()
    return 0
  end)

  ddu.action("ui", "_", "selectRgExcludeExtensionFromVisibleItems", function(_)
    local exts = collect_extensions_from_visible_items()

    if #exts == 0 then
      return 0
    end

    show_extension_list_message(exts)

    vim.ui.input({
      prompt = "indexes (e.g. 1,3,5 or 2-6): ",
    }, function(input)
      if not input or input == "" then
        return
      end

      local indexes, err = parse_extension_selection(input, #exts)
      if not indexes then
        vim.notify(err, vim.log.levels.WARN, { title = "ddu rg extensions" })
        return
      end
      if #indexes == 0 then
        return
      end

      for _, i in ipairs(indexes) do
        toggle_excluded_extension(exts[i])
      end

      refresh_rg_items()
    end)
    return 0
  end)

  ddu.action("ui", "_", "clearRgExcludeExtensions", function(_)
    rg_excluded_extensions = {}
    refresh_rg_items()
    return 0
  end)

  ddu.action("ui", "_", "editRgGlobs", function(_)
    local current = ddu.get_current(vim.b.ddu_ui_name)
    local source_params = current and current.sourceParams or {}
    local current_globs = source_params.rg and source_params.rg.globs or M.build_rg_globs()

    vim.ui.input({
      prompt = "rg globs: ",
      default = table.concat(current_globs, " "),
    }, function(input)
      if input == nil then
        return
      end
      rg_globs = parse_globs(input)
      if current_uses_rg(current) then
        refresh_rg_items()
      else
        vim.notify(
          "rg globs -> " .. table.concat(M.build_rg_globs(), " "),
          vim.log.levels.INFO,
          { title = "ddu rg" }
        )
      end
    end)
    return 0
  end)

  ddu.action("ui", "_", "openFfFromSelectedFileItems", function(_)
    local paths = unique_file_paths(get_selected_file_items())
    start_ff_from_paths(paths)
    return 0
  end)

  ddu.action("ui", "_", "current", function(_)
    print(vim.inspect(ddu.get_current()))
  end)

  ddu.action("kind", "_", "current", function(_)
    print(vim.inspect(ddu.get_current()))
  end)

  ddu.action("kind", "file", "quickfix", function(args)
    local qflist = {}
    for _, item in ipairs(args.items) do
      local qf = item_to_qf(item)
      if qf ~= nil then
        table.insert(qflist, qf)
      end
    end
    if #qflist == 0 then
      print("ddu quickfix: no file items")
      return 0
    end
    fn.setqflist(qflist, "r")
    vim.cmd("copen")
    return 0
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
    vim.t.ddu_ui_filer_main_path = dir
    print('tab cwd -> "' .. dir .. '"')
    return 0
  end)

  ddu.action("kind", "file", "open_filer", function(args)
    local item = args.items and args.items[1] or nil
    local dir = resolve_target_directory(item)
    if dir == "" then
      print("ddu open_filer: directory not found")
      return 0
    end
    start_filer(dir)
    return 0
  end)

  ddu.action("kind", "file", "grep", function(args)
    local dirs = unique_directories(args.items)
    if #dirs == 0 then
      print("ddu grep: directory not found")
      return 0
    end
    start_grep(dirs)
    return 0
  end)

  for slot = 1, 4 do
    local current_slot = slot
    ddu.action("kind", "file", "set_reference_dir_" .. slot, function(args)
      local item = args.items and args.items[1] or nil
      local dir = resolve_target_directory(item)
      if dir == "" then
        print("ddu reference: directory not found")
        return 0
      end
      set_reference_dir(current_slot, dir)
      return 4
    end)
  end

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
