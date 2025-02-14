local g = vim.g
local fn = vim.fn
local api = vim.api
local opt = vim.opt
local keymap = vim.keymap

local km_opts = require("const.keymap")

local u= require("utils")
local ddu = require("plugins.ddu.ddu_util")

local M = {}

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

local function toggle_hidden(ui_name, source_name)
  local matchers = ddu.get_current(ui_name)["sourceOptions"][source_name]["matchers"]
  or {}
  return ddu.toggle(matchers, 'matcher_hidden')
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
